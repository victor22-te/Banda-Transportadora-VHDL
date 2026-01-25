library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity servo_control is
    Port (
        clk              : in  STD_LOGIC;         -- 100 MHz
        objeto_rechazado : in  STD_LOGIC;         -- '1' = rechazado, '0' = aceptado
        servo            : out STD_LOGIC          -- PWM hacia servo
    );
end servo_control;

architecture Behavioral of servo_control is

    constant CLOCK_FREQ : integer := 100_000_000;   -- 100 MHz
    constant PWM_FREQ   : integer := 50;            -- 50 Hz (20 ms)
    constant PERIOD     : integer := CLOCK_FREQ / PWM_FREQ;

    -- Pulsos para calibración (barrido completo)
    constant PULSE_0deg   : integer := 100_000;     -- 1.0 ms = 0°
    constant PULSE_45deg  : integer := 125_000;     -- 1.25 ms = 45°
    constant PULSE_90deg  : integer := 150_000;     -- 1.5 ms = 90°
    constant PULSE_135deg : integer := 175_000;     -- 1.75 ms = 135°
    constant PULSE_180deg : integer := 200_000;     -- 2.0 ms = 180°

    signal counter      : integer range 0 to PERIOD - 1 := 0;
    signal pulse_width  : integer := PULSE_0deg;

begin

    process(clk)
    begin
        if rising_edge(clk) then

            -- Contador del periodo PWM
            if counter = PERIOD - 1 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;

            -- Operación directa según objeto_rechazado
            -- 90° = Aceptado (cumple todas las características)
            -- 0° = Rechazado (no cumple alguna característica)
            if objeto_rechazado = '1' then
                pulse_width <= PULSE_0deg;      -- Rechazado: 0°
            else
                pulse_width <= PULSE_90deg;     -- Aceptado: 90°
            end if;

            -- Generación del PWM
            if counter < pulse_width then
                servo <= '1';
            else
                servo <= '0';
            end if;

        end if;
    end process;

end Behavioral;
