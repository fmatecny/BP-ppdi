-----------------------------------------------------------------------------
-- Multiplexor pre deliaci PPI - paralelne paralelni integrator
-----------------------------------------------------------------------------
-- Autor: Jan Opalka (modifikacia Frantisek Matecny)   
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ============================= MPX4 =================================
-- DATA_IN_W - vstup W multiplexoru
-- DATA_IN_X - vstup X multiplexoru
-- DATA_IN_Y - vstup Y multiplexoru
-- DATA_IN_Z - vstup Z multiplexoru
-- SEL       - riadenie (	00 = vstup W,
--							01 = vstup X,
--							10 = vstup Y,
--							11 = vstup Z)
-- DATA_OUT  - vystupne data

entity mpx4 is
   generic ( width: integer );
   port (
      DATA_IN_W: in std_logic_vector(width-1 downto 0);
      DATA_IN_X: in std_logic_vector(width-1 downto 0);
      DATA_IN_Y: in std_logic_vector(width-1 downto 0);
      DATA_IN_Z: in std_logic_vector(width-1 downto 0);
      SEL: in std_logic_vector(1 downto 0);
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end mpx4;

architecture behavioral of mpx4 is
begin
   mpx4_p: process (DATA_IN_W,DATA_IN_X,DATA_IN_Y,DATA_IN_Z,SEL)
   begin
		case SEL is
			when "00" => DATA_OUT <= DATA_IN_W;	-- DVx
            when "01" => DATA_OUT <= DATA_IN_X;	-- DUx
            when "10" => DATA_OUT <= DATA_IN_Y;	-- const   
            when "11" => DATA_OUT <= DATA_IN_Z;	-- regs_div    
            when others => null;
		end case;
   end process;

end behavioral;
