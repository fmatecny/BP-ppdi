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

-- ============================= MPX2 =================================
-- DATA_IN_X - vstup X multiplexoru
-- DATA_IN_Y - vstup Y multiplexoru
-- SEL       - riadenie (0 = vstup X, 1 = vstup Y)
-- DATA_OUT  - vystupne data

entity mpx2 is
   generic ( width: integer );
   port (
      DATA_IN_X: in std_logic_vector(width-1 downto 0);
      DATA_IN_Y: in std_logic_vector(width-1 downto 0);
      SEL: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end mpx2;

architecture behavioral of mpx2 is
begin
   mpx_p: process (DATA_IN_X,DATA_IN_Y,SEL)
   begin
      if SEL = '0' then     -- prepne se vstup X
         DATA_OUT <= DATA_IN_X;
      else		              -- prepne se vstup Y
         DATA_OUT <= DATA_IN_Y;
      end if;
   end process;

end behavioral;
