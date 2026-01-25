library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Contador_Display is
    GENERIC(
        FPGA_CLK : INTEGER := 100_000_000
    );
    PORT(
        CLK              : IN  STD_LOGIC;
        RESET            : IN  STD_LOGIC;  -- Reset de contadores (activo alto)
        INC_ACEPTADOS    : IN  STD_LOGIC;  -- Pulso para incrementar aceptados
        INC_RECHAZADOS   : IN  STD_LOGIC;  -- Pulso para incrementar rechazados
        CONTADOR_LLENO   : OUT STD_LOGIC;  -- '1' cuando algún contador = 15
        -- Display 0 (Aceptados)
        D0_AN            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);  -- Ánodos (activo bajo)
        D0_SEG           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Segmentos (activo bajo)
        -- Display 1 (Rechazados)
        D1_AN            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);  -- Ánodos (activo bajo)
        D1_SEG           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)   -- Segmentos (activo bajo)
    );
end Contador_Display;

architecture Behavioral of Contador_Display is
    
    -- Contadores de objetos (0-15)
    signal contador_aceptados  : UNSIGNED(3 downto 0) := (others => '0');
    signal contador_rechazados : UNSIGNED(3 downto 0) := (others => '0');
    
    -- Sincronización de pulsos de incremento
    signal inc_acep_prev  : STD_LOGIC := '0';
    signal inc_rech_prev  : STD_LOGIC := '0';
    
    -- Multiplexación de displays (1kHz refresh)
    constant REFRESH_COUNT : INTEGER := FPGA_CLK / 4000;  -- 4 dígitos * 1kHz = 4kHz
    signal refresh_counter : INTEGER range 0 to REFRESH_COUNT := 0;
    signal digit_select    : INTEGER range 0 to 3 := 0;
    
    -- Dígitos a mostrar (BCD)
    signal d0_digit0, d0_digit1 : STD_LOGIC_VECTOR(3 downto 0);  -- Display 0
    signal d1_digit0, d1_digit1 : STD_LOGIC_VECTOR(3 downto 0);  -- Display 1
    
    -- Función para convertir BCD a 7 segmentos (activo bajo, ánodo común)
    function bcd_to_7seg(bcd : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
        variable seg : STD_LOGIC_VECTOR(7 downto 0);
    begin
        -- Formato: DP G F E D C B A (activo bajo)
        case bcd is
            when "0000" => seg := "11000000";  -- 0
            when "0001" => seg := "11111001";  -- 1
            when "0010" => seg := "10100100";  -- 2
            when "0011" => seg := "10110000";  -- 3
            when "0100" => seg := "10011001";  -- 4
            when "0101" => seg := "10010010";  -- 5
            when "0110" => seg := "10000010";  -- 6
            when "0111" => seg := "11111000";  -- 7
            when "1000" => seg := "10000000";  -- 8
            when "1001" => seg := "10010000";  -- 9
            when "1010" => seg := "10001000";  -- A
            when "1011" => seg := "10000011";  -- b
            when "1100" => seg := "11000110";  -- C
            when "1101" => seg := "10100001";  -- d
            when "1110" => seg := "10000110";  -- E
            when "1111" => seg := "10001110";  -- F
            when others => seg := "11111111";  -- Apagado
        end case;
        return seg;
    end function;
    
begin

    -- Separar contadores en dígitos decimales
    d0_digit1 <= std_logic_vector(contador_aceptados / 10);   -- Decenas
    d0_digit0 <= std_logic_vector(contador_aceptados mod 10); -- Unidades
    
    d1_digit1 <= std_logic_vector(contador_rechazados / 10);  -- Decenas
    d1_digit0 <= std_logic_vector(contador_rechazados mod 10);-- Unidades
    
    -- Indicador de contador lleno
    CONTADOR_LLENO <= '1' when (contador_aceptados = 15 or contador_rechazados = 15) else '0';
    
    -- Proceso de incremento de contadores con detección de flanco
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                contador_aceptados <= (others => '0');
                contador_rechazados <= (others => '0');
                inc_acep_prev <= '0';
                inc_rech_prev <= '0';
            else
                -- Detección de flanco ascendente para incrementar aceptados
                if INC_ACEPTADOS = '1' and inc_acep_prev = '0' then
                    if contador_aceptados < 15 then
                        contador_aceptados <= contador_aceptados + 1;
                    end if;
                end if;
                inc_acep_prev <= INC_ACEPTADOS;
                
                -- Detección de flanco ascendente para incrementar rechazados
                if INC_RECHAZADOS = '1' and inc_rech_prev = '0' then
                    if contador_rechazados < 15 then
                        contador_rechazados <= contador_rechazados + 1;
                    end if;
                end if;
                inc_rech_prev <= INC_RECHAZADOS;
            end if;
        end if;
    end process;
    
    -- Proceso de multiplexación de displays
    process(CLK)
    begin
        if rising_edge(CLK) then
            if refresh_counter >= REFRESH_COUNT then
                refresh_counter <= 0;
                if digit_select = 3 then
                    digit_select <= 0;
                else
                    digit_select <= digit_select + 1;
                end if;
            else
                refresh_counter <= refresh_counter + 1;
            end if;
        end if;
    end process;
    
    -- Asignación de displays según dígito seleccionado
    process(digit_select, d0_digit0, d0_digit1, d1_digit0, d1_digit1)
    begin
        case digit_select is
            when 0 =>
                -- Display 0, Unidades
                D0_AN <= "1110";  -- Activa dígito 0 (activo bajo)
                D0_SEG <= bcd_to_7seg(d0_digit0);
                D1_AN <= "1111";  -- Todos apagados
                D1_SEG <= "11111111";
                
            when 1 =>
                -- Display 0, Decenas
                D0_AN <= "1101";  -- Activa dígito 1 (activo bajo)
                if d0_digit1 = "0000" then
                    D0_SEG <= "11111111";  -- Apagar si es 0 (leading zero suppression)
                else
                    D0_SEG <= bcd_to_7seg(d0_digit1);
                end if;
                D1_AN <= "1111";
                D1_SEG <= "11111111";
                
            when 2 =>
                -- Display 1, Unidades
                D0_AN <= "1111";
                D0_SEG <= "11111111";
                D1_AN <= "1110";  -- Activa dígito 0 (activo bajo)
                D1_SEG <= bcd_to_7seg(d1_digit0);
                
            when 3 =>
                -- Display 1, Decenas
                D0_AN <= "1111";
                D0_SEG <= "11111111";
                D1_AN <= "1101";  -- Activa dígito 1 (activo bajo)
                if d1_digit1 = "0000" then
                    D1_SEG <= "11111111";  -- Apagar si es 0 (leading zero suppression)
                else
                    D1_SEG <= bcd_to_7seg(d1_digit1);
                end if;
                
            when others =>
                D0_AN <= "1111";
                D0_SEG <= "11111111";
                D1_AN <= "1111";
                D1_SEG <= "11111111";
        end case;
    end process;

end Behavioral;
