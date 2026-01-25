library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LIB_TEC_MATRICIAL_4x4_INTESC_RevA is
GENERIC(
    FREQ_CLK : INTEGER := 100_000_000
);

PORT(
    CLK        : IN  STD_LOGIC;
    COLUMNAS   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
    FILAS      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    BOTON_PRES : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    IND        : OUT STD_LOGIC;

    --------------------------
    -- NUEVO: LEDs internos --
    --------------------------
    LEDS       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
);
end LIB_TEC_MATRICIAL_4x4_INTESC_RevA;

architecture Behavioral of LIB_TEC_MATRICIAL_4x4_INTESC_RevA is

CONSTANT DELAY_1MS  : INTEGER := (FREQ_CLK/1000)-1;
CONSTANT DELAY_10MS : INTEGER := (FREQ_CLK/100)-1;

signal CONTA_1MS  : integer range 0 to DELAY_1MS := 0;
signal BANDERA    : std_logic := '0';
signal CONTA_10MS : integer range 0 to DELAY_10MS := 0;
signal BANDERA2   : std_logic := '0';

signal REG_B1  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_B2  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_B3  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_BA  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_B4  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_B5  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_B6  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_BB  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_B7  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_B8  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_B9  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_BC  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_BAS : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_B0  : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_BGA : std_logic_vector(7 downto 0) := (others=>'0');
signal REG_BD  : std_logic_vector(7 downto 0) := (others=>'0');

signal FILA_REG_S : std_logic_vector(3 downto 0) := (others=>'0');
signal FILA : integer range 0 to 3 := 0;

signal IND_S : std_logic := '0';
signal EDO : integer range 0 to 1 := 0;

-- NUEVO: registro entero para usar como  ndice de LED
signal KEY_INT : integer range 0 to 15 := 0;

begin

FILAS <= FILA_REG_S;

---------------------------------------------------
-- RETARDO 1ms
---------------------------------------------------
process(CLK)
begin
    if rising_edge(CLK) then
        CONTA_1MS <= CONTA_1MS + 1;
        BANDERA <= '0';
        if CONTA_1MS = DELAY_1MS then
            CONTA_1MS <= 0;
            BANDERA <= '1';
        end if;
    end if;
end process;

---------------------------------------------------
-- RETARDO 10ms
---------------------------------------------------
process(CLK)
begin
    if rising_edge(CLK) then
        CONTA_10MS <= CONTA_10MS + 1;
        BANDERA2 <= '0';
        if CONTA_10MS = DELAY_10MS then
            CONTA_10MS <= 0;
            BANDERA2 <= '1';
        end if;
    end if;
end process;

---------------------------------------------------
-- BARRIDO DE FILAS
---------------------------------------------------
process(CLK, BANDERA2)
begin
    if rising_edge(CLK) and BANDERA2 = '1' then
        FILA <= FILA + 1;
        if FILA = 3 then
            FILA <= 0;
        end if;
    end if;
end process;

with FILA select
    FILA_REG_S <= "1000" when 0,
                  "0100" when 1,
                  "0010" when 2,
                  "0001" when others;

---------------------------------------------------
-- ANTIRREBOTE: registros de historial
---------------------------------------------------
process(CLK, BANDERA)
begin
    if rising_edge(CLK) and BANDERA = '1' then
        if FILA_REG_S = "1000" then
            REG_B1 <= REG_B1(6 downto 0) & COLUMNAS(3);
            REG_B2 <= REG_B2(6 downto 0) & COLUMNAS(2);
            REG_B3 <= REG_B3(6 downto 0) & COLUMNAS(1);
            REG_BA <= REG_BA(6 downto 0) & COLUMNAS(0);

        elsif FILA_REG_S = "0100" then
            REG_B4 <= REG_B4(6 downto 0) & COLUMNAS(3);
            REG_B5 <= REG_B5(6 downto 0) & COLUMNAS(2);
            REG_B6 <= REG_B6(6 downto 0) & COLUMNAS(1);
            REG_BB <= REG_BB(6 downto 0) & COLUMNAS(0);

        elsif FILA_REG_S = "0010" then
            REG_B7 <= REG_B7(6 downto 0) & COLUMNAS(3);
            REG_B8 <= REG_B8(6 downto 0) & COLUMNAS(2);
            REG_B9 <= REG_B9(6 downto 0) & COLUMNAS(1);
            REG_BC <= REG_BC(6 downto 0) & COLUMNAS(0);

        elsif FILA_REG_S = "0001" then
            REG_BAS <= REG_BAS(6 downto 0) & COLUMNAS(3);
            REG_B0  <= REG_B0(6 downto 0) & COLUMNAS(2);
            REG_BGA <= REG_BGA(6 downto 0) & COLUMNAS(1);
            REG_BD  <= REG_BD(6 downto 0) & COLUMNAS(0);
        end if;
    end if;
end process;

---------------------------------------------------
-- DETECCI N DE TECLA Y C DIGO
---------------------------------------------------
process(CLK)
begin
    if rising_edge(CLK) then
        IND_S <= '1';

        if REG_B0 = "11111111" then BOTON_PRES <= X"0"; KEY_INT <= 0;
        elsif REG_B1 = "11111111" then BOTON_PRES <= X"1"; KEY_INT <= 1;
        elsif REG_B2 = "11111111" then BOTON_PRES <= X"2"; KEY_INT <= 2;
        elsif REG_B3 = "11111111" then BOTON_PRES <= X"3"; KEY_INT <= 3;
        elsif REG_B4 = "11111111" then BOTON_PRES <= X"4"; KEY_INT <= 4;
        elsif REG_B5 = "11111111" then BOTON_PRES <= X"5"; KEY_INT <= 5;
        elsif REG_B6 = "11111111" then BOTON_PRES <= X"6"; KEY_INT <= 6;
        elsif REG_B7 = "11111111" then BOTON_PRES <= X"7"; KEY_INT <= 7;
        elsif REG_B8 = "11111111" then BOTON_PRES <= X"8"; KEY_INT <= 8;
        elsif REG_B9 = "11111111" then BOTON_PRES <= X"9"; KEY_INT <= 9;
        elsif REG_BA = "11111111" then BOTON_PRES <= X"A"; KEY_INT <= 10;
        elsif REG_BB = "11111111" then BOTON_PRES <= X"B"; KEY_INT <= 11;
        elsif REG_BC = "11111111" then BOTON_PRES <= X"C"; KEY_INT <= 12;
        elsif REG_BD = "11111111" then BOTON_PRES <= X"D"; KEY_INT <= 13;
        elsif REG_BAS = "11111111" then BOTON_PRES <= X"E"; KEY_INT <= 14;
        elsif REG_BGA = "11111111" then BOTON_PRES <= X"F"; KEY_INT <= 15;
        else
            IND_S <= '0';
        end if;

    end if;
end process;

---------------------------------------------------
-- M QUINA DE ESTADOS PARA IND
---------------------------------------------------
process(CLK)
begin
    if rising_edge(CLK) then
        if EDO = 0 then
            if IND_S = '1' then
                IND <= '1';
                EDO <= 1;
            else
                IND <= '0';
            end if;
        else
            if IND_S = '1' then
                IND <= '0';
            else
                EDO <= 0;
            end if;
        end if;
    end if;
end process;

---------------------------------------------------
-- ? CONTROL DE LOS 16 LEDS DE LA BOOLEAN BOARD
---------------------------------------------------
process(KEY_INT, IND_S)
begin
    LEDS <= (others => '0');
    if IND_S = '1' then
        LEDS(KEY_INT) <= '1';
    end if;
end process;

end Behavioral;
