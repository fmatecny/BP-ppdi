-----------------------------------------------------------------------------
-- Konstanty pre deliaci PPI - paralelne paralelni integrator
-----------------------------------------------------------------------------
-- Autor: Frantisek Matecny  
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-- ============================= konstanty =================================
-- CLK      - povolenie zapisu
-- RESET    - nastavenie predvolenej hodnoty
-- DATA_OUT - hodnota konstanty


entity const is
generic ( width: integer );
   port (
      CLK: in std_logic;
      RESET: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end const;

architecture behavioral of const is
signal reg: std_logic_vector(width-1 downto 0) := (others => '0');
begin 
   p_1: process (RESET, CLK)
   begin
      if RESET = '1' then
         reg(width-1 downto width-3) <= "010";	reg(width-4 downto 0) <= (others => '0'); -- 2.0
      elsif CLK'event AND CLK = '1' then
            reg(width-1 downto width-3) <= "011"; reg(width-4 downto 0) <= (others => '0');	-- 3.0
      end if;
   end process;
DATA_OUT <= reg;
end behavioral;

