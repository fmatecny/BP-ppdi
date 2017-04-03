-----------------------------------------------------------------------------
-- Akumulator pre deliaci PPI - paralelne paralelni integrator
-----------------------------------------------------------------------------
-- Autor: Frantisek Matecny
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- =========================== akumulator ===============================
-- DATA_IN - vstupne data
-- CLK     - povolenie zapisu
-- DATA_OUT- vystupne data

entity acc is
   generic ( width: integer );
   port (
      DATA_IN: in std_logic_vector(width-1 downto 0);
      CLK: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end acc;

architecture behavioral of acc is
signal reg: std_logic_vector(width-1 downto 0) := (others => '0');  -- vlastny obsah akumulatora
begin
   acc_p: process (CLK)
   begin
      if clk'event AND Clk = '1' then
			reg <= DATA_IN;
      end if;
   end process;
DATA_OUT <= reg;

end behavioral;


