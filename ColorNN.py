"""
ColorNN - Clasificador de Colores usando Red Neuronal
=====================================================
Detecta: Blanco, Negro, Rojo usando una red neuronal simple

Modos de uso:
1. Capturar datos de entrenamiento (tecla 'c')
2. Entrenar el modelo (tecla 't')
3. Clasificar en tiempo real (automático después de entrenar)
"""

import cv2
import numpy as np
import urllib.request
import time
import os
import pickle
from pathlib import Path
import serial
import serial.tools.list_ports

# Intentar importar TensorFlow
try:
    import tensorflow as tf
    from tensorflow import keras
    from tensorflow.keras import layers
    print(f"TensorFlow version: {tf.__version__}")
except ImportError:
    print("ERROR: TensorFlow no está instalado.")
    print("Instálalo con: pip install tensorflow")
    exit()

# ============================================================
# CONFIGURACIÓN
# ============================================================
# Índice de cámara (0 = integrada, 1 = externa USB, puede variar)
CAMERA_INDEX = 1  # Cambiar a 0 si la externa no funciona
cap = None  # Objeto VideoCapture global

# Configuración Serial
SERIAL_PORT = "COM6"  # Cambiar según el puerto del microcontrolador
BAUD_RATE = 9600
ser = None  # Conexión serial

# Códigos binarios para colores
CODIGOS_BINARIOS = {
    "Blanco": "01",
    "Negro": "10",
    "Rojo": "11"
}

# Directorio para datos y modelo
DATA_DIR = Path("color_nn_data")
DATA_DIR.mkdir(exist_ok=True)
MODEL_PATH = DATA_DIR / "color_model.keras"
DATA_PATH = DATA_DIR / "training_data.pkl"

# Clases de colores
CLASES = ["Blanco", "Negro", "Rojo"]
CLASE_ACTUAL = 0  # Índice de la clase actual para captura

# Tamaño de la región de interés (ROI) para capturar
ROI_SIZE = 200

# ============================================================
# FUNCIONES AUXILIARES
# ============================================================

def inicializar_camara():
    """Inicializa la cámara USB externa"""
    global cap
    cap = cv2.VideoCapture(CAMERA_INDEX, cv2.CAP_DSHOW)  # CAP_DSHOW para Windows
    
    if not cap.isOpened():
        print(f"❌ No se pudo abrir la cámara con índice {CAMERA_INDEX}")
        print("Intentando listar cámaras disponibles...")
        for i in range(5):
            test_cap = cv2.VideoCapture(i, cv2.CAP_DSHOW)
            if test_cap.isOpened():
                print(f"  ✓ Cámara {i} disponible")
                test_cap.release()
            else:
                print(f"  ✗ Cámara {i} no disponible")
        return False
    
    # Configurar resolución (opcional)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    
    print(f"✓ Cámara {CAMERA_INDEX} inicializada correctamente")
    return True

def get_frame():
    """Obtiene un frame desde la cámara USB"""
    global cap
    if cap is None or not cap.isOpened():
        return None
    
    ret, frame = cap.read()
    if ret:
        return frame
    return None

def extraer_caracteristicas(roi):
    """
    Extrae características del ROI para la red neuronal.
    Usa valores promedio de RGB y HSV.
    """
    # Convertir a float y normalizar
    roi_float = roi.astype(np.float32) / 255.0
    
    # Promedios RGB
    b_mean = np.mean(roi_float[:, :, 0])
    g_mean = np.mean(roi_float[:, :, 1])
    r_mean = np.mean(roi_float[:, :, 2])
    
    # Convertir a HSV
    hsv = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)
    hsv_float = hsv.astype(np.float32)
    hsv_float[:, :, 0] /= 179.0  # H normalizado
    hsv_float[:, :, 1] /= 255.0  # S normalizado
    hsv_float[:, :, 2] /= 255.0  # V normalizado
    
    h_mean = np.mean(hsv_float[:, :, 0])
    s_mean = np.mean(hsv_float[:, :, 1])
    v_mean = np.mean(hsv_float[:, :, 2])
    
    # Desviaciones estándar
    r_std = np.std(roi_float[:, :, 2])
    g_std = np.std(roi_float[:, :, 1])
    b_std = np.std(roi_float[:, :, 0])
    
    # Vector de características
    return np.array([r_mean, g_mean, b_mean, h_mean, s_mean, v_mean, r_std, g_std, b_std])

def crear_modelo():
    """Crea el modelo de red neuronal"""
    model = keras.Sequential([
        layers.Input(shape=(9,)),  # 9 características
        layers.Dense(64, activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(32, activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(len(CLASES), activation='softmax')
    ])
    
    model.compile(
        optimizer='adam',
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return model

def cargar_datos():
    """Carga los datos de entrenamiento si existen"""
    if DATA_PATH.exists():
        with open(DATA_PATH, 'rb') as f:
            return pickle.load(f)
    return {'X': [], 'y': []}

def guardar_datos(datos):
    """Guarda los datos de entrenamiento"""
    with open(DATA_PATH, 'wb') as f:
        pickle.dump(datos, f)

def entrenar_modelo(datos):
    """Entrena el modelo con los datos capturados"""
    if len(datos['X']) < 10:
        print("ADVERTENCIA: Se necesitan más datos para entrenar (mínimo 10 muestras)")
        return None
    
    X = np.array(datos['X'])
    y = np.array(datos['y'])
    
    print(f"\nEntrenando con {len(X)} muestras...")
    print(f"Distribución: {dict(zip(CLASES, [sum(y==i) for i in range(len(CLASES))]))}")
    
    model = crear_modelo()
    
    # Entrenar
    history = model.fit(
        X, y,
        epochs=50,
        batch_size=8,
        validation_split=0.2,
        verbose=1
    )
    
    # Guardar modelo
    model.save(MODEL_PATH)
    print(f"\nModelo guardado en: {MODEL_PATH}")
    
    return model

def cargar_modelo():
    """Carga el modelo si existe"""
    if MODEL_PATH.exists():
        return keras.models.load_model(MODEL_PATH)
    return None

def conectar_serial():
    """Conecta con el puerto serial"""
    global ser
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
        print(f"✓ Conexión serial exitosa en {SERIAL_PORT} @ {BAUD_RATE} bps")
        time.sleep(2)  # Esperar a que el puerto se estabilice
        return True
    except Exception as e:
        print(f"❌ ERROR al conectar serial: {e}")
        print("Puertos disponibles:")
        for port, desc, hwid in serial.tools.list_ports.comports():
            print(f"  - {port}: {desc}")
        return False

def enviar_codigo_color(nombre_color):
    """Envía el código binario del color por serial"""
    global ser
    if ser is None or not ser.is_open:
        return
    
    codigo = CODIGOS_BINARIOS.get(nombre_color)
    if codigo:
        try:
            # Enviar como byte (0x01=Blanco, 0x02=Negro, 0x03=Rojo)
            byte_codigo = {"01": b'\x01', "10": b'\x02', "11": b'\x03'}
            ser.write(byte_codigo.get(codigo, b'\x00'))
            print(f"▶ Enviado: {nombre_color} (código: {codigo})")
        except Exception as e:
            print(f"❌ Error al enviar por serial: {e}")

# Variable global para almacenar último mensaje del FPGA
ultimo_mensaje_fpga = ""
fpga_ready_para_color = False  # Flag que indica si FPGA pide el color
fpga_ready_timestamp = 0  # Timestamp cuando se recibe la señal Ready

def leer_serial_fpga():
    """Lee datos del FPGA si hay disponibles. Retorna True si recibe 'R' (Ready)"""
    global ser, ultimo_mensaje_fpga, fpga_ready_para_color, fpga_ready_timestamp
    if ser is None or not ser.is_open:
        return False
    
    try:
        if ser.in_waiting > 0:
            datos = ser.read(ser.in_waiting)
            texto = datos.decode('ascii', errors='ignore').strip()
            if texto:
                # Verificar si es señal de Ready ('R')
                if 'R' in texto:
                    print(f"📡 FPGA LISTO - Solicitando color...")
                    fpga_ready_para_color = True
                    fpga_ready_timestamp = time.time()  # Guardar timestamp
                    return True
                
                # Interpretar mensaje del FPGA
                # Formato NUEVO: "MTCMA\n" o "NX2GR\n" 
                # Carácter 1: M/N = Magnético/No magnético
                # Carácter 2: T/X = Metálico/No metálico
                # Carácter 3: 1/2/3 = Blanco/Negro/Rojo
                # Carácter 4: C/M/G = Chico/Mediano/Grande
                # Carácter 5: A/R = Aceptado/Rechazado
                
                # Debug: mostrar datos crudos recibidos
                print(f"📥 Datos crudos recibidos: {repr(texto)} (longitud: {len(texto)})")
                
                mensaje = ""
                i = 0
                for char in texto:
                    # Ignorar saltos de línea y retornos de carro al inicio
                    if char == '\n' or char == '\r':
                        continue
                        
                    # Primer carácter: Magnético
                    if i == 0:
                        if char == 'M':
                            mensaje += "MAGNÉTICO | "
                        elif char == 'N':
                            mensaje += "NO MAGNÉTICO | "
                        else:
                            print(f"⚠️ Carácter inesperado en posición 0: '{char}'")
                        i += 1
                    # Segundo carácter: Metálico
                    elif i == 1:
                        if char == 'T':
                            mensaje += "METÁLICO | "
                        elif char == 'X':
                            mensaje += "NO METÁLICO | "
                        else:
                            print(f"⚠️ Carácter inesperado en posición 1: '{char}'")
                        i += 1
                    # Tercer carácter: Color
                    elif i == 2:
                        if char == '1':
                            mensaje += "Color: BLANCO | "
                        elif char == '2':
                            mensaje += "Color: NEGRO | "
                        elif char == '3':
                            mensaje += "Color: ROJO | "
                        elif char == '0':
                            mensaje += "Color: SIN DETECTAR | "
                        else:
                            print(f"⚠️ Carácter inesperado en posición 2: '{char}'")
                        i += 1
                    # Cuarto carácter: Altura
                    elif i == 3:
                        if char == 'C':
                            mensaje += "Altura: CHICO | "
                        elif char == 'M':
                            mensaje += "Altura: MEDIANO | "
                        elif char == 'G':
                            mensaje += "Altura: GRANDE | "
                        elif char == '0':
                            mensaje += "Altura: SIN DETECTAR | "
                        else:
                            print(f"⚠️ Carácter inesperado en posición 3: '{char}'")
                        i += 1
                    # Quinto carácter: Estado
                    elif i == 4:
                        if char == 'A':
                            mensaje += "✅ ACEPTADO"
                        elif char == 'R':
                            mensaje += "❌ RECHAZADO"
                        else:
                            print(f"⚠️ Carácter inesperado en posición 4: '{char}'")
                        i += 1
                
                if mensaje:
                    ultimo_mensaje_fpga = mensaje
                    print(f"◀ FPGA: {mensaje}")
                elif i > 0:
                    print(f"⚠️ Mensaje incompleto recibido (solo {i} caracteres)")
    except Exception as e:
        print(f"Error leyendo serial: {e}")
    
    return False

# ============================================================
# MAIN
# ============================================================

print("=" * 60)
print("ColorNN - Clasificador de Colores con Red Neuronal")
print("=" * 60)
print(f"Usando cámara externa (índice: {CAMERA_INDEX})")
print("-" * 60)

# Inicializar cámara USB
print(f"\nInicializando cámara {CAMERA_INDEX}...")
if not inicializar_camara():
    print("❌ ERROR: No se pudo inicializar la cámara")
    print("Verifica que la cámara externa esté conectada")
    print("Puedes cambiar CAMERA_INDEX en el código (0, 1, 2...)")
    exit()

# Intentar conectar serial
print(f"\nIntentando conectar serial en {SERIAL_PORT}...")
if conectar_serial():
    print("Serial conectado ✓")
else:
    print(f"Advertencia: No se pudo conectar al puerto {SERIAL_PORT}")
    print("Continuando sin envío serial...\n")

print("✓ Cámara lista!")
print("\n" + "=" * 60)
print("CONTROLES:")
print("  1, 2, 3  - Seleccionar clase (1=Blanco, 2=Negro, 3=Rojo)")
print("  C        - Capturar muestra de la clase actual")
print("  S        - ENVIAR color detectado a la FPGA")
print("  T        - Entrenar modelo con datos capturados")
print("  R        - Resetear datos de entrenamiento")
print("  Q        - Salir")
print("=" * 60)

# Cargar datos y modelo existentes
datos = cargar_datos()
model = cargar_modelo()

if model:
    print(f"✓ Modelo cargado desde: {MODEL_PATH}")
else:
    print("ℹ No hay modelo entrenado. Captura datos y entrena (T)")

print(f"ℹ Datos existentes: {len(datos['X'])} muestras")
print("-" * 60)

CLASE_ACTUAL = 0

while True:
    frame = get_frame()
    if frame is None:
        time.sleep(0.1)
        continue
    
    # Nota: Si necesitas rotar el frame, descomenta la siguiente línea:
    # frame = cv2.rotate(frame, cv2.ROTATE_90_CLOCKWISE)
    
    h, w = frame.shape[:2]
    
    # Definir ROI en el centro
    cx, cy = w // 2, h // 2
    x1, y1 = cx - ROI_SIZE // 2, cy - ROI_SIZE // 2
    x2, y2 = cx + ROI_SIZE // 2, cy + ROI_SIZE // 2
    
    roi = frame[y1:y2, x1:x2]
    
    # Dibujar rectángulo del ROI
    cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
    
    # Mostrar clase actual para captura
    cv2.putText(frame, f"Clase: {CLASES[CLASE_ACTUAL]} (1-3 cambiar)", 
                (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
    cv2.putText(frame, f"Datos: {len(datos['X'])} muestras", 
                (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
    
    # Si hay modelo, hacer predicción
    if model is not None:
        features = extraer_caracteristicas(roi)
        pred = model.predict(features.reshape(1, -1), verbose=0)
        clase_pred = CLASES[np.argmax(pred)]
        confianza = np.max(pred) * 100
        
        # Mostrar predicción
        color_texto = (0, 255, 0) if confianza > 70 else (0, 255, 255)
        cv2.putText(frame, f"Prediccion: {clase_pred} ({confianza:.1f}%)", 
                    (10, h - 20), cv2.FONT_HERSHEY_SIMPLEX, 1, color_texto, 2)
        
        # Mostrar instrucción
        cv2.putText(frame, "Esperando señal de FPGA (R)...", 
                    (10, h - 80), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 0), 2)
        
    else:
        cv2.putText(frame, "Sin modelo - Presiona T para entrenar", 
                    (10, h - 20), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
    
    # Leer datos del FPGA
    leer_serial_fpga()
    
    # Si FPGA está lista para recibir color, esperar 1 segundo antes de sensar y enviar
    if fpga_ready_para_color and model is not None:
        tiempo_transcurrido = time.time() - fpga_ready_timestamp
        
        if tiempo_transcurrido >= 1.0:  # Esperar 1 segundo después de recibir 'R'
            features = extraer_caracteristicas(roi)
            pred = model.predict(features.reshape(1, -1), verbose=0)
            clase_pred = CLASES[np.argmax(pred)]
            confianza = np.max(pred) * 100
            
            # Enviar el color detectado
            enviar_codigo_color(clase_pred)
            print(f"✓ Color enviado automáticamente: {clase_pred} ({confianza:.1f}%)")
            
            # Resetear flag
            fpga_ready_para_color = False
    
    # Mostrar último mensaje del FPGA en la ventana
    if ultimo_mensaje_fpga:
        cv2.putText(frame, f"FPGA: {ultimo_mensaje_fpga}", 
                    (10, h - 50), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)
    
    # Mostrar si está esperando señal de FPGA
    if fpga_ready_para_color:
        cv2.putText(frame, ">>> ENVIANDO COLOR <<<", 
                    (w//2 - 150, h//2), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 3)
    
    # Redimensionar y mostrar
    frame_resized = cv2.resize(frame, (640, 480))
    cv2.imshow('ColorNN - Clasificador con Red Neuronal', frame_resized)
    
    key = cv2.waitKey(1) & 0xFF
    
    if key == ord('q'):
        break
    elif key == ord('1'):
        CLASE_ACTUAL = 0
        print(f"Clase seleccionada: {CLASES[CLASE_ACTUAL]}")
    elif key == ord('2'):
        CLASE_ACTUAL = 1
        print(f"Clase seleccionada: {CLASES[CLASE_ACTUAL]}")
    elif key == ord('3'):
        CLASE_ACTUAL = 2
        print(f"Clase seleccionada: {CLASES[CLASE_ACTUAL]}")
    elif key == ord('c'):
        # Capturar muestra
        features = extraer_caracteristicas(roi)
        datos['X'].append(features)
        datos['y'].append(CLASE_ACTUAL)
        guardar_datos(datos)
        print(f"✓ Muestra capturada para '{CLASES[CLASE_ACTUAL]}' - Total: {len(datos['X'])}")
    elif key == ord('s'):
        # Enviar color detectado a la FPGA
        if model is not None:
            features = extraer_caracteristicas(roi)
            pred = model.predict(features.reshape(1, -1), verbose=0)
            clase_pred = CLASES[np.argmax(pred)]
            confianza = np.max(pred) * 100
            if confianza > 50:  # Umbral más bajo para envío manual
                enviar_codigo_color(clase_pred)
                print(f"✓ Color enviado: {clase_pred} ({confianza:.1f}%)")
            else:
                print(f"⚠ Confianza muy baja ({confianza:.1f}%), intenta de nuevo")
        else:
            print("❌ No hay modelo entrenado")
    elif key == ord('t'):
        # Entrenar modelo
        print("\n" + "=" * 40)
        print("ENTRENANDO MODELO...")
        print("=" * 40)
        model = entrenar_modelo(datos)
        if model:
            print("✓ Modelo entrenado exitosamente!")
    elif key == ord('r'):
        # Resetear datos
        datos = {'X': [], 'y': []}
        guardar_datos(datos)
        print("✓ Datos de entrenamiento eliminados")

cv2.destroyAllWindows()

# Liberar cámara
if cap is not None:
    cap.release()
    print("Cámara liberada")

# Cerrar conexión serial
if ser and ser.is_open:
    ser.close()
    print("Serial cerrado")

print("\nPrograma terminado")
