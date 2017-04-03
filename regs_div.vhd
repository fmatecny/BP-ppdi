-----------------------------------------------------------------------------
-- Registry podielov pre deliaci PPI - paralelne paralelni integrator
-----------------------------------------------------------------------------
-- Autor: Frantisek Matecny 
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ============================= REGISTRY PODIELOV =================================
-- SEL       - riadenie(00 = reg_0,
--						01 = reg_1, 
--						10 = reg_2)
-- DATA_OUT  - vystupne data

entity regs_div is
   generic ( width: integer );
   port (
      SEL: in std_logic_vector(1 downto 0);
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end regs_div;

architecture behavioral of regs_div is
begin
   reg_p: process (SEL)
   begin
	 if (width = 64) then
		case SEL is
			   when "00" => DATA_OUT <= "0001000000000000000000000000000000000000000000000000000000000000";	-- 1/2  64bit
            when "01" => DATA_OUT <= "0000101010101010101010101010101010101010101010101010101010101010";	-- 1/3
            when "10" => DATA_OUT <= "0000100000000000000000000000000000000000000000000000000000000000";	-- 1/4    
            when others => null;
		end case;
	 elsif (width = 32) then
	 	case SEL is
			   when "00" => DATA_OUT <= "00010000000000000000000000000000";	-- 1/2  32bit
            when "01" => DATA_OUT <= "00001010101010101010101010101010";	-- 1/3
            when "10" => DATA_OUT <= "00001000000000000000000000000000";	-- 1/4    
            when others => null;
		end case;
	 end if;
  end process;
end behavioral;

