-----------------------------------------------------------------------------
-- Komponenta xor pre deliaci PPI - paralelne paralelni integrator
-----------------------------------------------------------------------------
-- Autor: Jan Opalka (modifikacia Frantisek Matecny)   
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ============================= XOR_COMP =================================
-- DATA_IN_X 	- vstup X multiplexoru
-- SEL_XOR      - riadenie (1 = zmena znamienka)
-- DATA_OUT  	- vystupni data

entity xor_comp is
   generic ( width: integer );
   port (
      DATA_IN_X: in std_logic_vector(width-1 downto 0);
      SEL_XOR: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end xor_comp;

architecture behavioral of xor_comp is
signal reg: std_logic_vector(width-1 downto 0) := (others => '1');
begin
   xor_p: process (DATA_IN_X,SEL_XOR)
   begin
      if SEL_XOR = '1' then -- zmena znamienka
         DATA_OUT <= (DATA_IN_X xor reg) + 1;
      else						
         DATA_OUT <= DATA_IN_X;
      end if;
   end process;

end behavioral;
