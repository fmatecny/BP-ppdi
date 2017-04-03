-----------------------------------------------------------------------------
-- Registry pre deliaci PPI - paralelne paralelni integrator
-----------------------------------------------------------------------------
-- Autor: Frantisek Matecny
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ============================= PAMAT REGISTROV =================================
-- DATA_IN	 - vstup
-- SEL      - riadenie(00 = reg_0,
--						01 = reg_1, 
--						10 = reg_2, 
--						11 = reg_3)
-- CLK		 - citanie - 0, zapis - 1
-- DATA_OUT  - vystupne data

entity registry is
   generic ( width: integer );
   port (
      DATA_IN: in std_logic_vector(width-1 downto 0);
      SEL: in std_logic_vector(1 downto 0);
      CLK: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end registry ;

architecture behavioral of registry is
signal reg_0: std_logic_vector(width-1 downto 0) := (others => '0'); 
signal reg_1: std_logic_vector(width-1 downto 0) := (others => '0');  
signal reg_2: std_logic_vector(width-1 downto 0) := (others => '0');  
signal reg_3: std_logic_vector(width-1 downto 0) := (others => '0');  

begin
   reg_p: process (DATA_IN, SEL, CLK)
   begin
      if clk'event AND clk = '1' then
          case SEL is
            when "00" => reg_0 <= DATA_IN;	-- x0
            when "01" => reg_1 <= DATA_IN;	-- DX1
            when "10" => reg_2 <= DATA_IN;	-- DX2
            when "11" => reg_3 <= DATA_IN;	-- DX3      
            when others => null;
          end case;              	  
       end if;
  end process;

   output_p: process (SEL)
   begin
          case SEL is
            when "00" => DATA_OUT <= reg_0;	-- x0
            when "01" => DATA_OUT <= reg_1;	-- DX1
            when "10" => DATA_OUT <= reg_2;	-- DX2
            when "11" => DATA_OUT <= reg_3;	-- DX3      
            when others => null;
          end case;
	end process;
end behavioral;
