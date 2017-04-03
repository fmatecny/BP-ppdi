-----------------------------------------------------------------------------
-- Register RV pre deliaci PPI - paralelne paralelni integrator
-----------------------------------------------------------------------------
-- Autor: Jan Opalka (modifikacia Frantisek Matecny)
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- =========================== n-bitovy register pre vysledok ============================
-- DATA0	- pociatocna podmienka
-- DATA_IN 	- vstupne data
-- CLK 		- enable
-- RESET	- ulozenie pociatocnej podmienky
-- DATA_OUT - vystupne data
entity register_rv is
   generic ( width: integer );
   port (
      CLK: in std_logic;
      data0: in std_logic_vector(width-1 downto 0);
	  RESET: in std_logic;
      DATA_IN: in std_logic_vector(width-1 downto 0);
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end register_rv;

architecture behavioral of register_rv is
signal reg: std_logic_vector(width-1 downto 0) := (others => '0');  -- vlastny obsah registru
begin
   p_reg: process (CLK, RESET)
   begin  
      if clk'event AND Clk = '1' then
         if reset = '1' then		-- pociatocna podmienka
           reg <= data0;
         else 
           reg<=DATA_IN;
         end if;
      end if;
   end process;
DATA_OUT <= reg;

end behavioral;
