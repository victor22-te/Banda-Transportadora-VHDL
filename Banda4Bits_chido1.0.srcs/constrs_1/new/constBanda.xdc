# clk input is from the 100 MHz oscillator on Boolean board
#create_clock -period 10.000 -name gclk [get_ports CLK]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {CLK}]

# Set Bank 0 voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# On-board Slide Switches
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports {SW_RESET}]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports {SW_START}]
#set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports {SW2}]
#set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports {sw[3]}]
#set_property -dict {PACKAGE_PIN T1 IOSTANDARD LVCMOS33} [get_ports {sw[4]}]
#set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {sw[5]}]
#set_property -dict {PACKAGE_PIN R1 IOSTANDARD LVCMOS33} [get_ports {sw[6]}]
#set_property -dict {PACKAGE_PIN P2 IOSTANDARD LVCMOS33} [get_ports {sw[7]}]
#set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {sw[8]}]
#set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports {sw[9]}]
#set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports {sw[10]}]
#set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {sw[11]}]
#set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports {sw[12]}]
#set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports {sw[13]}]
#set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {sw[14]}]
#set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {sw[15]}]

#Puertos expansores boolean
set_property -dict {PACKAGE_PIN N5 IOSTANDARD LVCMOS33} [get_ports {RS}]
set_property -dict {PACKAGE_PIN K4 IOSTANDARD LVCMOS33} [get_ports {ENA}]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {RW}]
#set_property -dict {PACKAGE_PIN N4 IOSTANDARD LVCMOS33} [get_ports {DATA_LCD[0]}]
#set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33} [get_ports {DATA_LCD[1]}]
#set_property -dict {PACKAGE_PIN N5 IOSTANDARD LVCMOS33} [get_ports {DATA_LCD[2]}]
#set_property -dict {PACKAGE_PIN K4 IOSTANDARD LVCMOS33} [get_ports {DATA_LCD[3]}]
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports {DATA_LCD[0]}]
set_property -dict {PACKAGE_PIN M4 IOSTANDARD LVCMOS33} [get_ports {DATA_LCD[1]}]
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports {DATA_LCD[2]}]
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports {DATA_LCD[3]}]

#Teclado matricial
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports {COLUMNAS[0]}]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports {COLUMNAS[1]}]
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports {COLUMNAS[2]}]
set_property -dict {PACKAGE_PIN E12 IOSTANDARD LVCMOS33} [get_ports {COLUMNAS[3]}]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {FILAS[0]}]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {FILAS[1]}]
set_property -dict {PACKAGE_PIN B14 IOSTANDARD LVCMOS33} [get_ports {FILAS[2]}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports {FILAS[3]}]


#Puertos Ultrasonico
#set_property -dict {PACKAGE_PIN N4 IOSTANDARD LVCMOS33} [get_ports {TRIGGER}]
#set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33} [get_ports {ECO}]

#Sensor IR banderas
set_property -dict {PACKAGE_PIN R7 IOSTANDARD LVCMOS33} [get_ports {IR_IN}]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports {IR_IN2}]
set_property -dict {PACKAGE_PIN P6 IOSTANDARD LVCMOS33} [get_ports {IR_IN3}]
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports {IR_IN4}]
set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33} [get_ports {IR_IN5}]
set_property -dict {PACKAGE_PIN K6 IOSTANDARD LVCMOS33} [get_ports {IR_IN6}]
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports {IR_IN7}]


#Servo clasificador
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {SERVO_OUT}]

#Sensor Magnetico
set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33} [get_ports {MAGNETIC_IN}]
#Sensor Capacitivo
set_property -dict {PACKAGE_PIN N4 IOSTANDARD LVCMOS33} [get_ports {METALIC_IN}]
#Sensores de altura
#Chico
set_property -dict {PACKAGE_PIN M5 IOSTANDARD LVCMOS33} [get_ports {IR_HEIGHT1}]
#Mediano
set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports {IR_HEIGHT2}]
#Grande
set_property -dict {PACKAGE_PIN L6 IOSTANDARD LVCMOS33} [get_ports {IR_HEIGHT3}]

# UART para comunicacion con camara (9600 baud)
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {UART_RX}]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {UART_TX}]

# Salidas del Motor
set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS33} [get_ports {MOTOR_ENA}]
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {MOTOR_IN1}]
set_property -dict {PACKAGE_PIN R5 IOSTANDARD LVCMOS33} [get_ports {MOTOR_IN2}]

# On-board LEDs
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {LEDS[0]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {LEDS[1]}]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports {LEDS[2]}]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {LEDS[3]}]
#set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
#set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
#set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
#set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVCMOS33} [get_ports {led[7]}]
#set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {led[8]}]
#set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS33} [get_ports {led[9]}]
#set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {led[10]}]
#set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVCMOS33} [get_ports {led[11]}]
#set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS33} [get_ports {led[12]}]
#set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {led[13]}]
#set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {led[14]}]
#set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {led[15]}]


# Button J5
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {BTN_RESET}]

# Display 0 (Display 4)
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports {D0_AN[0]}]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports {D0_AN[1]}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {D0_AN[2]}]
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports {D0_AN[3]}]

set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS33} [get_ports {D0_SEG[0]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS33} [get_ports {D0_SEG[1]}]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33} [get_ports {D0_SEG[2]}]
set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33} [get_ports {D0_SEG[3]}]
set_property -dict {PACKAGE_PIN A7 IOSTANDARD LVCMOS33} [get_ports {D0_SEG[4]}]
set_property -dict {PACKAGE_PIN D6 IOSTANDARD LVCMOS33} [get_ports {D0_SEG[5]}]
set_property -dict {PACKAGE_PIN B5 IOSTANDARD LVCMOS33} [get_ports {D0_SEG[6]}]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS33} [get_ports {D0_SEG[7]}]

# Display 1 (Display 8)
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports {D1_AN[0]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {D1_AN[1]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {D1_AN[2]}]
set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVCMOS33} [get_ports {D1_AN[3]}]

set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {D1_SEG[0]}]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {D1_SEG[1]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {D1_SEG[2]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {D1_SEG[3]}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {D1_SEG[4]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {D1_SEG[5]}]
set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS33} [get_ports {D1_SEG[6]}]
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS33} [get_ports {D1_SEG[7]}]


# On-board Buttons
#set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
#set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
#set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {btn[2]}]
#set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {btn[3]}]

# On-board color LEDs
#set_property -dict {PACKAGE_PIN V6 IOSTANDARD LVCMOS33} [get_ports {RGB0[0]}];   # RBG0_R
#set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports {RGB0[1]}];   # RBG0_G
#set_property -dict {PACKAGE_PIN U6 IOSTANDARD LVCMOS33} [get_ports {RGB0[2]}];   # RBG0_B
#set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports {RGB1[0]}];   # RBG1_R
#set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {RGB1[1]}];   # RBG1_G
#set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {RGB1[2]}];   # RBG1_B


# UART
#set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {UART_rxd}]
#set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {UART_txd}]

#HDMI Signals
#set_property -dict { PACKAGE_PIN T14   IOSTANDARD TMDS_33 } [get_ports {hdmi_clk_n}]
#set_property -dict { PACKAGE_PIN R14   IOSTANDARD TMDS_33 } [get_ports {hdmi_clk_p}]

#set_property -dict { PACKAGE_PIN T15   IOSTANDARD TMDS_33  } [get_ports {hdmi_tx_n[0]}]
#set_property -dict { PACKAGE_PIN R17   IOSTANDARD TMDS_33  } [get_ports {hdmi_tx_n[1]}]
#set_property -dict { PACKAGE_PIN P16   IOSTANDARD TMDS_33  } [get_ports {hdmi_tx_n[2]}]
                                    
#set_property -dict { PACKAGE_PIN R15   IOSTANDARD TMDS_33  } [get_ports {hdmi_tx_p[0]}]
#set_property -dict { PACKAGE_PIN R16   IOSTANDARD TMDS_33  } [get_ports {hdmi_tx_p[1]}]
#set_property -dict { PACKAGE_PIN N15   IOSTANDARD TMDS_33  } [get_ports {hdmi_tx_p[2]}]

# PWM audio signals
#set_property -dict {PACKAGE_PIN N13 IOSTANDARD LVCMOS33} [get_ports {left_audio_out}]
#set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {right_audio_out}]

# BLE UART signals
#set_property -dict {PACKAGE_PIN G5 IOSTANDARD LVCMOS33} [get_ports {ble_uart_tx}]
#set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS33} [get_ports {ble_uart_rx}]
#set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33} [get_ports {ble_uart_rts}]
#set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports {ble_uart_cts}]

# Servomotor signals
#set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {servo0}]
#set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS33} [get_ports {servo1}]
#set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports {servo2}]
#set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {servo3}]