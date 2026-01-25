----------------------------------------------------------------------------------
-- Módulo: InfraRojo
-- Descripción: Sensor infrarrojo con debouncing para detección de objetos
--              Configurado para reloj de 100 MHz
--              Salida OBJETO_DETECTADO = '1' cuando un objeto está presente
-- 
-- Nota: Los sensores IR típicamente dan '0' cuando detectan objeto (lógica inversa)
--       Este módulo invierte la lógica para facilitar su uso
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InfraRojo is
    GENERIC(
        FPGA_CLK : INTEGER := 100_000_000;  -- Frecuencia del reloj (100 MHz)
        DEBOUNCE_TIME_MS : INTEGER := 10     -- Tiempo de debounce en milisegundos
    );
    Port ( 
        CLK             : in  STD_LOGIC;   -- Reloj del sistema (100 MHz)
        IR_IN           : in  STD_LOGIC;   -- Entrada del sensor IR (típicamente '0' = objeto detectado)
        OBJETO_DETECTADO: out STD_LOGIC;   -- '1' cuando hay objeto, '0' cuando no hay
        IR_RAW          : out STD_LOGIC    -- Salida sin procesar (para debugging)
    );
end InfraRojo;

architecture Behavioral of InfraRojo is

    -- Constante para el contador de debounce
    -- Para 100 MHz y 10ms: 100_000_000 * 0.010 = 1_000_000 ciclos
    constant DEBOUNCE_LIMIT : integer := (FPGA_CLK / 1000) * DEBOUNCE_TIME_MS;
    
    -- Señales para debounce
    signal contador_debounce : integer range 0 to DEBOUNCE_LIMIT := 0;
    signal ir_estable        : std_logic := '0';  -- Estado estabilizado del IR
    signal ir_prev           : std_logic := '0';  -- Estado previo para detectar cambios

begin

    -- Salida raw para debugging
    IR_RAW <= IR_IN;
    
    -- Proceso de debounce
    process(CLK)
    begin
        if rising_edge(CLK) then
            -- Comparar entrada actual con estado estable
            if IR_IN /= ir_estable then
                -- La entrada cambió, incrementar contador
                if contador_debounce < DEBOUNCE_LIMIT then
                    contador_debounce <= contador_debounce + 1;
                else
                    -- El contador llegó al límite, aceptar el nuevo estado
                    ir_estable <= IR_IN;
                    contador_debounce <= 0;
                end if;
            else
                -- La entrada es igual al estado estable, reiniciar contador
                contador_debounce <= 0;
            end if;
        end if;
    end process;
    
    -- Invertir la lógica: Sensores IR típicamente dan '0' cuando detectan objeto
    -- Por lo tanto: '0' en IR_IN = objeto presente = '1' en OBJETO_DETECTADO
    OBJETO_DETECTADO <= not ir_estable;

end Behavioral;
