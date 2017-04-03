-----------------------------------------------------------------------------
-- Scitacka pre deliaci PPI - paralelne paralelni integrator
-----------------------------------------------------------------------------
-- Autor: Jan Opalka (modifikacia Frantisek Matecny)   
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- =========================== scitacka ===============================
-- DATA_IN_X - prvy operand scitania
-- DATA_IN_Y - druhy operand scitania
-- DATA_OUT  - vysledok scitania

entity adder is
   generic ( width: integer );
   port (
      DATA_IN_X: in std_logic_vector(width-1 downto 0);
      DATA_IN_Y: in std_logic_vector(width-1 downto 0);
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end adder;

architecture behv of adder is
begin
   DATA_OUT <= DATA_IN_X + DATA_IN_Y;
end behv;
