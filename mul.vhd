-----------------------------------------------------------------------------
-- Nasobicka pre deliaci PPI - paralelne paralelni integrator
-----------------------------------------------------------------------------
-- Autor: Frantisek Matecny   
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ============================= nasobicka =================================
-- DATA_IN_X - vstup X nasobicky
-- DATA_IN_Y - vstup Y nasobicky
-- DATA_OUT  - vystupne data

entity mul is
   generic ( width: integer );
   port (
      DATA_IN_X: in std_logic_vector(width-1 downto 0);
      DATA_IN_Y: in std_logic_vector(width-1 downto 0);
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end mul;

architecture behavioral of mul is
signal reg: std_logic_vector(2*width-1 downto 0);	-- vysledok nasobenia
signal reg_x: std_logic_vector(width-1 downto 0);	-- vlastny obsah vstupu X
signal reg_y: std_logic_vector(width-1 downto 0);	-- vlastny obsah vstupu Y
signal reg_xor: std_logic_vector(width-1 downto 0) := (others => '1');
begin
   mul_p: process (DATA_IN_X, DATA_IN_Y, reg_x, reg_y, reg)
   begin
		if (DATA_IN_X(width-1) = '1') then		-- prevod na kladne cislo
			reg_x <= (DATA_IN_X xor reg_xor) + 1;
		else
			reg_x <= DATA_IN_X;
		end if;
		
		if (DATA_IN_Y(width-1) = '1') then		-- prevod na kladne cislo
			reg_y <= (DATA_IN_Y xor reg_xor) + 1;
		else
			reg_y <= DATA_IN_Y;
		end if;
		
		reg <= reg_x * reg_y;
		
		if ((DATA_IN_X(width-1) xor DATA_IN_Y(width-1)) = '1') then		-- spatny prevod na zaporne cislo
			DATA_OUT <= ((reg (2*width-4 downto width-3)) xor reg_xor) + 1;
		else
			DATA_OUT <= reg (2*width-4 downto width-3);
		end if;
		
	end process;
end behavioral;
