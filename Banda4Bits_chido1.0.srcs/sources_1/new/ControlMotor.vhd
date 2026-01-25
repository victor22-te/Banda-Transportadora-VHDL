----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.12.2025 11:16:49
-- Design Name: 
-- Module Name: ControlMotor - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Módulo de control para un motor DC usando puente H L298N
--              Funciones: Avanzar y Parar
-- 
-- Dependencies: Ninguna
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--   L298N Pinout (Motor A):
--   - ENA: Enable Motor A (PWM o '1' para velocidad máxima)
--   - IN1, IN2: Control dirección Motor A
--   
--   Tabla de estados (IN1, IN2):
--     Avanzar: IN1='1', IN2='0'
--     Retroceder: IN1='0', IN2='1'
--     Parar: IN1='0', IN2='0'
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlMotor is
    Port ( 
        CLK      : in  STD_LOGIC;                    -- Reloj del sistema
        RESET    : in  STD_LOGIC;                    -- Reset activo alto
        AVANZAR  : in  STD_LOGIC;                    -- '1' = Avanzar, '0' = Parar
        
        -- Salidas hacia el L298N (Motor A)
        ENA      : out STD_LOGIC;                    -- Enable Motor
        IN1      : out STD_LOGIC;                    -- Control dirección
        IN2      : out STD_LOGIC                     -- Control dirección
    );
end ControlMotor;

architecture Behavioral of ControlMotor is

begin

    -- Proceso de control de motor
    process(CLK, RESET)
    begin
        if RESET = '1' then
            -- Estado de reset: Motor detenido
            ENA <= '0';
            IN1 <= '0';
            IN2 <= '0';
            
        elsif rising_edge(CLK) then
            if AVANZAR = '1' then
                -- Avanzar: Motor hacia adelante
                ENA <= '1';         -- Habilitar Motor
                IN1 <= '1';         -- Adelante
                IN2 <= '0';
            else
                -- Retroceder: Motor hacia atrás
                ENA <= '0';         -- Habilitar Motor
                IN1 <= '0';         -- Atrás
                IN2 <= '0';
            end if;
        end if;
    end process;
    

end Behavioral;
