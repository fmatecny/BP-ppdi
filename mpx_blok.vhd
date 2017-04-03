-----------------------------------------------------------------------------
-- Multiplexor s nulovanim pre deliaci PPI - paralelne paralelni integrator
-----------------------------------------------------------------------------
-- Autor: Jan Opalka (modifikacia Frantisek Matecny)   
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ============================= MPX_BLOK =================================
-- DATA_IN_X - vstup X multiplexoru
-- DATA_IN_Y - vstup Y multiplexoru
-- SEL       - riadenie (0 = vstup X, 1 = vstup Y)
-- BOK       - nulovanie
-- DATA_OUT  - vystupne data



entity mpx_blok is
   generic ( width: integer );
   port (
      DATA_IN_X: in std_logic_vector(width-1 downto 0);
      DATA_IN_Y: in std_logic_vector(width-1 downto 0);
      SEL: in std_logic;
      BLOK: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end mpx_blok;

architecture behavioral of mpx_blok is
begin
   mpx_p: process (DATA_IN_X,DATA_IN_Y,SEL, BLOK)
   begin
      if BLOK = '0' then
        if SEL = '0' then
           DATA_OUT <= DATA_IN_X;	-- RV
        else
           DATA_OUT <= DATA_IN_Y;	-- ACC
        end if;
      else
         DATA_OUT <= (others => '0'); -- nuluje vystup
      end if;
   end process;
end behavioral;
