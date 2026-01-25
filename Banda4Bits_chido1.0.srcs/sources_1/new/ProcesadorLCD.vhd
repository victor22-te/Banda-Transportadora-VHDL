----------------------------------------
----------PROCESADOR LCD----------------
----------¡NO MODIFICAR!----------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity PROCESADOR_LCD4BITS_REVC is

GENERIC(
			FPGA_CLK : INTEGER := 100_000_000;
			NUM_INST : INTEGER := 1
);

PORT(CLK 				: IN  STD_LOGIC;
	  VECTOR_MEM 		: IN  STD_LOGIC_VECTOR(8  DOWNTO 0);
	  C1A,C2A,C3A,C4A : IN  STD_LOGIC_VECTOR(39 DOWNTO 0);
	  C5A,C6A,C7A,C8A : IN  STD_LOGIC_VECTOR(39 DOWNTO 0);       	
	  RS 					: OUT STD_LOGIC;
	  RW 					: OUT STD_LOGIC;
	  ENA 				: OUT STD_LOGIC;
	  BD_LCD 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);			         
	  DATA 				: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	  DIR_MEM 			: OUT INTEGER RANGE 0 TO NUM_INST
	);

end PROCESADOR_LCD4BITS_REVC;

architecture Behavioral of PROCESADOR_LCD4BITS_REVC is

CONSTANT MAX_DELAY 			  : INTEGER := (FPGA_CLK/8);		 -- Delay de 31.25 milisegundos
CONSTANT ESCALA_ENABLE 		  : integer := (FPGA_CLK/600);  -- 700us
CONSTANT ESCALA_CICLO_ENABLE : integer := (FPGA_CLK/6_000); -- 100us
CONSTANT OFFSET_ENABLE		  : INTEGER := (FPGA_CLK/6_000); -- 100us

signal salto 		   : std_logic := '0';
signal avanzar 	   : std_logic := '0';
signal ok_enable 	   : std_logic := '0';
signal enable_fin	   : std_logic := '0';
signal data_s 		   : std_logic_vector(8  downto 0) := (others => '0');
signal vec_ram 	   : std_logic_vector(7  downto 0) := (others => '0');
signal vec_l_ram 	   : std_logic_vector(7  downto 0) := (others => '0');
signal vec_c_char    : std_logic_vector(39 downto 0) := (others => '0');
signal edo 			   : integer range 0 to 109 := 0;
signal dir_mem_s 	   : integer range 0 to NUM_INST := 0;
signal edo_enable    : integer range 0 to 2 := 0;
signal max_enable	   : integer range 0 to escala_enable := 0;
signal conta_enable  : integer range 0 to escala_enable := 0;
signal ciclo_enable  : integer range 0 to escala_enable := 0;
signal conta_delay   : integer range 0 to MAX_DELAY  := 0;
signal dir_salto_mem : integer range 0 to NUM_INST := 0;

begin

process(CLK)
begin
if rising_edge(clk) then
	if edo = 0 then
		conta_delay <= conta_delay+1;
		if conta_delay = MAX_DELAY then
			conta_delay <= 0;
			edo <= 1;
		end if;
	
	elsif edo = 1 then
		if VECTOR_MEM = "000000000" OR VECTOR_MEM = "111111111" THEN
			edo <= 102;--FIN DE CÓDIGO
		elsif VECTOR_MEM(8) = '0' then
			edo <= 45;--CHAR_ASCII
		else
			edo <= 2;--CUALQUIER OTRA INSTRUCCIÓN
		end if;
		  
	elsif edo = 2 then
		-- IMPORTANTE: Verificar comandos específicos ANTES del rango de posición
		-- porque algunos códigos se solapan
		if 	VECTOR_MEM(7 downto 0) >= x"01" and VECTOR_MEM(7 downto 0) <= x"04" then
			edo <= 3;  -- INI_LCD
		elsif VECTOR_MEM(7 downto 0) >= x"09" and VECTOR_MEM(7 downto 0) <= x"41" then
			edo <= 35; -- CHAR
		elsif VECTOR_MEM(7 downto 0) = x"7c" then
			edo <= 49; -- BUCLE_INI (debe ir ANTES del rango de posición)
		elsif VECTOR_MEM(7 downto 0) = x"7D" then
			edo <= 50; -- BUCLE_FIN (debe ir ANTES del rango de posición)
		elsif VECTOR_MEM(7 downto 0) >= X"7E" and VECTOR_MEM(7 downto 0) <= X"85" then
			edo <= 51; -- GUARDAR CARACTER 
		elsif VECTOR_MEM(7 downto 0) >= X"86" and VECTOR_MEM(7 downto 0) <= X"8D" then
			edo <= 88; -- LEER CARACTER
		elsif VECTOR_MEM(7 downto 0) = X"FE" or VECTOR_MEM(7 downto 0) = X"FD" then
			edo <= 93; -- LIMPIAR PANTALLA
		elsif VECTOR_MEM(7 downto 0) >= X"8E" and VECTOR_MEM(7 downto 0) <= X"97" then
			edo <= 103; -- INT_NUM
		-- Ahora sí el rango de posición (líneas 1-4)
		-- L1-L2: 0x50-0x77, L3(col1-4): 0x78-0x7B, L3(col5+)+L4: 0xA0-0xC3
		elsif (VECTOR_MEM(7 downto 0) >= x"50" and VECTOR_MEM(7 downto 0) <= x"7B") or
		      (VECTOR_MEM(7 downto 0) >= x"A0" and VECTOR_MEM(7 downto 0) <= x"C3") then
			edo <= 40; -- POSICIÓN (líneas 1-4)
		else
			edo <= 102;
		end if;	
			
			
	-------------------------------------------------
	----------------Inicializar LCD------------------
	
	elsif edo = 3 then --SET
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "0011";
		edo <= 4;
		
	elsif edo = 4 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 5;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 5 then
		conta_delay <= conta_delay+1;
		if conta_delay = MAX_DELAY/8 then
			conta_delay <= 0;
			edo <= 6;
		end if;
	
	elsif edo = 6 then --SET
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "0011";
		edo <= 7;
		
	elsif edo =7  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 8;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 8 then
		conta_delay <= conta_delay+1;
		if conta_delay = MAX_DELAY/32 then
			conta_delay <= 0;
			edo <= 9;
		end if;
		
	elsif edo = 9 then --SET
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "0011";
		edo <= 10;
		
	elsif edo = 10  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 104;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 104 then --SET OFF
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "0010";
		edo <= 105;
		
	elsif edo = 105  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 11;
		else
			ok_enable <= '1';
		end if;	
		
	elsif edo = 11 then --FUNCTION SET HIGH (4 BITS, 2 LÍNEAS, 5X8)
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "0010";
		edo <= 12;
		
	elsif edo = 12  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 13;
		else
			ok_enable <= '1';
		end if;	
	
	elsif edo = 13 then --FUNCTION SET LOW (4 BITS, 2 LÍNEAS, 5X8)
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "1000";
		edo <= 14;
		
	elsif edo = 14  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 15;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 15 then --DISPLAY OFF HIGH
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "0000";
		edo <= 16;
		
	elsif edo = 16  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 17;
		else
			ok_enable <= '1';
		end if;	
		
	elsif edo = 17 then --DISPLAY OFF LOW
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "1000";
		edo <= 18;
		
	elsif edo = 18  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 19;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 19 then --DISPLAY CLEAR HIGH
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "0000";
		edo <= 20;
		
	elsif edo = 20  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 21;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 21 then --DISPLAY CLEAR LOW
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "0001";
		edo <= 22;
		
	elsif edo = 22  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 23;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 23 then --ENTRY MODE SET HIGH
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "0000";
		edo <= 24;
		
	elsif edo = 24  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 25;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 25 then --ENTRY MODE SET LOW
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "0110";
		edo <= 26;
		
	elsif edo = 26  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 27;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 27 then --ADDRES RAM HIGH
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "1000";
		edo <= 28;
		
	elsif edo = 28  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 29;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 29 then --ADDRES RAM HIGH
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "0000";
		edo <= 30;
		
	elsif edo = 30  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 31;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 31 then --CURSOR_LCD HIGH
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 32;
		if VECTOR_MEM = '1'&x"01" then
			data <= "0000";
		elsif VECTOR_MEM = '1'&x"02" then
			data <= "0000"; 
		elsif VECTOR_MEM = '1'&x"03" then
			data <= "0000";
		else
			data <= "0000";
		end if;
	
	elsif edo = 32 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 33;
		else
			ok_enable <= '1';
		end if;	
	
	elsif edo = 33 then --CURSOR_LCD LOW
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 34;
		if VECTOR_MEM = '1'&x"01" then
			data <= "1100";
		elsif VECTOR_MEM = '1'&x"02" then
			data <= "1101"; 
		elsif VECTOR_MEM = '1'&x"03" then
			data <= "1110";
		else
			data <= "1111";
		end if;
	
	elsif edo = 34 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"01";
			AVANZAR <= '1';
			edo <= 101;
		else
			ok_enable <= '1';
		end if;	
	-------------------------------------------------
	-------------------------------------------------

	
	-------------------------------------------------
	-----------------------CHAR----------------------
	elsif edo = 35 then
		RS <= '1';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 36;
		if VECTOR_MEM >= '1'&x"09" and VECTOR_MEM <= '1'&x"22" then
			data_s <= VECTOR_MEM - ('0'&x"a8");
		elsif VECTOR_MEM >= '1'&x"23" and VECTOR_MEM <= '1'&x"3c" then
			data_s <= VECTOR_MEM - ('0'&x"e2");
		else
			data_s <= VECTOR_MEM - ('1'&x"0d");
		end if;	
		
	elsif edo = 36 then
		DATA <= data_s(7 downto 4);
		edo <= 37;
	
	elsif edo = 37 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 38;
		else
			ok_enable <= '1';
		end if;

	elsif edo = 38 then
		DATA <= data_s(3 downto 0);
		edo <= 39;
	
	elsif edo = 39 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"02";
			AVANZAR <= '1';
			edo <= 101;
		else
			ok_enable <= '1';
		end if;	
		
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	---------------------POSICIÓN--------------------
	elsif edo = 40 then
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 41;
		-- Línea 1: códigos 0x50-0x63 -> direcciones DDRAM 0x80-0x93
		IF VECTOR_MEM >= '1'&X"50" AND VECTOR_MEM <= '1'&X"63" THEN
			data_s <= VECTOR_MEM - ('0'&X"D0");
		-- Línea 2: códigos 0x64-0x77 -> direcciones DDRAM 0xC0-0xD3
		ELSIF VECTOR_MEM >= '1'&X"64" AND VECTOR_MEM <= '1'&X"77" THEN
			data_s <= VECTOR_MEM - ('0'&X"A4");
		-- Línea 3: códigos 0x78-0x7B y 0xA0-0xAF -> direcciones DDRAM 0x94-0xA7
		ELSIF VECTOR_MEM >= '1'&X"78" AND VECTOR_MEM <= '1'&X"7B" THEN
			data_s <= VECTOR_MEM - ('0'&X"E4");  -- 0x178-0xE4 = 0x94
		ELSIF VECTOR_MEM >= '1'&X"A0" AND VECTOR_MEM <= '1'&X"AF" THEN
			data_s <= VECTOR_MEM - ('0'&X"0C");  -- 0x1A0-0x0C = 0x194 -> lower 8 bits = 0x94+offset
		-- Línea 4: códigos 0xB0-0xC3 -> direcciones DDRAM 0xD4-0xE7
		ELSIF VECTOR_MEM >= '1'&X"B0" AND VECTOR_MEM <= '1'&X"C3" THEN
			data_s <= VECTOR_MEM - ('0'&X"DC");  -- 0x1B0-0xDC = 0xD4
		END IF;
		
	elsif edo = 41 then
		DATA <= data_s(7 downto 4);
		edo <= 42;
	
	elsif edo = 42 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 43;
		else
			ok_enable <= '1';
		end if;

	elsif edo = 43 then
		DATA <= data_s(3 downto 0);
		edo <= 44;
	
	elsif edo = 44 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"03";
			AVANZAR <= '1';
			edo <= 101;
		else
			ok_enable <= '1';
		end if;
		
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	------------------CHAR_ASCII---------------------
	elsif edo = 45 then
		RS <= '1';
		RW <= '0';
		DATA <= VECTOR_MEM(7 downto 4);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 46;
	
	elsif edo = 46 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 47;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 47 then
		RS <= '1';
		RW <= '0';
		DATA <= VECTOR_MEM(3 downto 0);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 48;
	
	elsif edo = 48 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"05";
			AVANZAR <= '1';
			edo <= 101;
		else
			ok_enable <= '1';
		end if;	
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	--------------------BUCLE INI--------------------
	elsif edo = 49 then
		dir_salto_mem <= dir_mem_s;
		BD_LCD <= x"06";
		AVANZAR <= '1';
		edo <= 101;
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	--------------------BUCLE FIN--------------------
	elsif edo = 50 then
		BD_LCD <= x"07";
		salto <= '1';
		edo <= 101;
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	----------------GUARDAR CARACTER-----------------
	elsif edo = 51 then
		if 	vector_mem(7 downto 0) = x"7e" then vec_ram <= x"40"; vec_c_char <= c1a;
		elsif vector_mem(7 downto 0) = x"7f" then vec_ram <= x"48"; vec_c_char <= c2a;
		elsif vector_mem(7 downto 0) = x"80" then vec_ram <= x"50"; vec_c_char <= c3a;
		elsif vector_mem(7 downto 0) = x"81" then vec_ram <= x"58"; vec_c_char <= c4a;
		elsif vector_mem(7 downto 0) = x"82" then vec_ram <= x"60"; vec_c_char <= c5a;
		elsif vector_mem(7 downto 0) = x"83" then vec_ram <= x"68"; vec_c_char <= c6a;
		elsif vector_mem(7 downto 0) = x"84" then vec_ram <= x"70"; vec_c_char <= c7a;
		elsif vector_mem(7 downto 0) = x"85" then vec_ram <= x"78"; vec_c_char <= c8a;
		end if;
		edo <= 52;
		
	elsif edo = 52 then	
		RS <= '0';
		RW <= '0';
		DATA <= vec_ram(7 downto 4);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 53;
		
	elsif edo = 53 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 54;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 54 then	
		RS <= '0';
		RW <= '0';
		DATA <= vec_ram(3 downto 0);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 55;
		
	elsif edo = 55 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 56;
		else
			ok_enable <= '1';
		end if;	
		
	elsif edo = 56 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(39);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 57;
		
	elsif edo = 57 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 58;
		else
			ok_enable <= '1';
		end if;
		
		
	elsif edo = 58 then	
		RS <= '1';
		RW <= '0';
		DATA <= VEC_C_CHAR(38 DOWNTO 35);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 59;
		
	elsif edo = 59 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 60;
		else
			ok_enable <= '1';
		end if;	
		
	elsif edo = 60 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(34);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 61;
		
	elsif edo = 61 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 62;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 62 then	
		RS <= '1';
		RW <= '0';
		DATA <= VEC_C_CHAR(33 DOWNTO 30);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 63;
		
	elsif edo = 63 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 64;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 64 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(29);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 65;
		
	elsif edo = 65 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 66;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 66 then	
		RS <= '1';
		RW <= '0';
		DATA <= VEC_C_CHAR(28 DOWNTO 25);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 67;
		
	elsif edo = 67 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 68;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 68 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(24);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 69;
		
	elsif edo = 69 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 106;
		else
			ok_enable <= '1';
		end if;
	

	elsif edo = 106 then
		RS <= '1';
		RW <= '0';
		DATA <= VEC_C_CHAR(23 DOWNTO 20);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 107;
		
	elsif edo = 107 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 108;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 108 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(19);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 109;
		
	elsif edo = 109 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 70;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 70 then	
		RS <= '1';
		RW <= '0';
		DATA <= VEC_C_CHAR(18 DOWNTO 15);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 71;
		
	elsif edo = 71 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 72;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 72 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(14);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 73;
		
	elsif edo = 73 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 74;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 74 then	
		RS <= '1';
		RW <= '0';
		DATA <= VEC_C_CHAR(13 DOWNTO 10);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 75;
		
	elsif edo = 75 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 76;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 76 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(9);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 77;
		
	elsif edo = 77 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 78;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 78 then	
		RS <= '1';
		RW <= '0';
		DATA <= VEC_C_CHAR(8 DOWNTO 5);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 79;
		
	elsif edo = 79 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 80;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 80 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(4);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 81;
		
	elsif edo = 81 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 82;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 82 then	
		RS <= '1';
		RW <= '0';
		DATA <= VEC_C_CHAR(3 DOWNTO 0);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 83;
		
	elsif edo = 83 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 84;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 84 then	
		RS <= '1';
		RW <= '0';
		DATA <= "0000";
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 85;
		
	elsif edo = 85 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 86;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 86 then	
		RS <= '1';
		RW <= '0';
		DATA <= "0010";
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 87;
		
	elsif edo = 87 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"09";
			AVANZAR <= '1';
			edo <= 101;
		else
			ok_enable <= '1';
		end if;
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	------------------LEER CARACTER------------------
	elsif edo = 88 then
		if 	vector_mem(7 downto 0) = x"86" then vec_l_ram <= x"00";
		elsif vector_mem(7 downto 0) = x"87" then vec_l_ram <= x"01";
		elsif vector_mem(7 downto 0) = x"88" then vec_l_ram <= x"02";
		elsif vector_mem(7 downto 0) = x"89" then vec_l_ram <= x"03";
		elsif vector_mem(7 downto 0) = x"8a" then vec_l_ram <= x"04";
		elsif vector_mem(7 downto 0) = x"8b" then vec_l_ram <= x"05";
		elsif vector_mem(7 downto 0) = x"8c" then vec_l_ram <= x"06";
		elsif vector_mem(7 downto 0) = x"8d" then vec_l_ram <= x"07";
		end if;
		edo <= 89;
		
	elsif edo = 89 then
		RS <= '1';
		RW <= '0';
		DATA <= VEC_L_RAM(7 downto 4);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 90;
		
	elsif edo = 90 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 91;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 91 then
		RS <= '1';
		RW <= '0';
		DATA <= VEC_L_RAM(3 downto 0);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 92;
		
	elsif edo = 92 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"0A";
			AVANZAR <= '1';
			edo <= 101;
		else
			ok_enable <= '1';
		end if;
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	----------------LIMPIAR PANTALLA-----------------
	elsif edo = 93 then
		if VECTOR_MEM(7 downto 0) = X"FE" then
			RS <= '0';
			RW <= '0';
			DATA <= "0000";
			ciclo_enable <= ESCALA_CICLO_ENABLE;
			edo <= 94;
		else
			RS <= '0';
			RW <= '0';
			DATA <= "0000";
			ciclo_enable <= ESCALA_CICLO_ENABLE;
			BD_LCD <= X"02";
			edo <= 101;
		end if;
		
	elsif edo = 94 then 
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 95;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 95 then
			RS <= '0';
			RW <= '0';
			DATA <= "0001";
			ciclo_enable <= ESCALA_CICLO_ENABLE;
			edo <= 96;
		
	elsif edo = 96 then 
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"08";
			AVANZAR <= '1';
			edo <= 101;
		else
			ok_enable <= '1';
		end if;
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	---------------------INT_NUM---------------------
	elsif edo = 103 then
		data_s <= VECTOR_MEM - ('1'&X"5E");
		edo <= 97;
	
	elsif edo = 97 then
		RS <= '1';
		RW <= '0';
		DATA <= data_s(7 downto 4);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 98;
	
	elsif edo = 98 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"04";
			AVANZAR <= '1';
			edo <= 99;
		else
			ok_enable <= '1';
		end if;	
	
	elsif edo = 99 then
		RS <= '1';
		RW <= '0';
		DATA <= data_s(3 downto 0);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 100;
	
	elsif edo = 100 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"04";
			AVANZAR <= '1';
			edo <= 101;
		else
			ok_enable <= '1';
		end if;	
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	----------------LIMPIAR SEÑALES------------------
	elsif edo = 101 then
		BD_LCD <= X"00";
		AVANZAR <= '0';
		salto <= '0';
		edo <= 1;
	-------------------------------------------------
	-------------------------------------------------
		
	end if;
end if;
end process;


-------------------------------------------------
----------------GENERADOR ENABLE-----------------
process(clk)
begin
if rising_edge(clk) then
	if edo_enable = 0 then
		if ok_enable = '1' then
			edo_enable <= 1;
		end if;
		
	elsif edo_enable = 1 then
		conta_enable <= conta_enable+1;
		if conta_enable >= ESCALA_ENABLE then
			conta_enable <= 0;
			enable_fin <= '1';
			edo_enable <= 2;
		end if;
		
	elsif edo_enable = 2 then
		enable_fin <= '0';
		edo_enable <= 0;
		
	end if;
end if;
end process;

process(conta_enable, edo_enable, ciclo_enable)
begin
if conta_enable > ciclo_enable+OFFSET_ENABLE and  conta_enable < ciclo_enable+(OFFSET_ENABLE*2) and edo_enable = 1 then
	ENA <= '1';
else
	ENA <= '0';
end if;
end process;
-------------------------------------------------
-------------------------------------------------


-------------------------------------------------
-------------DIRECCIÓN DE MEMORIA----------------
process(clk)
begin
if rising_edge(clk) then
	if avanzar = '1' then
		dir_mem_s <= dir_mem_s+1;
	elsif salto = '1' then
		dir_mem_s <= dir_salto_mem;
	end if;
end if;
end process;

DIR_MEM <= dir_mem_s;
-------------------------------------------------
-------------------------------------------------

end Behavioral;