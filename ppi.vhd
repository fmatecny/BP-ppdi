-----------------------------------------------------------------------------
-- Deliaci PPI - paralelne paralelni integrator
----------------------------------------------------------------------------- 
-- Autor: Jan Opalka (modifikacia Frantisek Matecny)  
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ============================= PPI =================================
-- signaly mikroprocesoroveho radica:
-- V0		- vstupne hodnoty registrov 'v'
-- U0		- vstupne hodnoty registrov 'u'
-- DATA0    - pocatocna podmienka
-- STEP		- integracny krok
-- CLK		- hodiny
-- RESET  	- reset PPI

-- OEN  	- output enable PPI
-- ERR		- delenie nulou
-- RESULT  	- vystup PPI

-- genericke vstupne parametry
-- width 	- pocet bitov sbernic

entity ppi is
   generic ( width: integer );             
   port (
	  V0: std_logic_vector(width-1 downto 0);
	  U0: std_logic_vector(width-1 downto 0);
		
      DATA0: std_logic_vector(width-1 downto 0);
      STEP: std_logic_vector(width-1 downto 0);
      CLK:     in std_logic;
      RESET:   in std_logic;
		
      OEN:     out std_logic;
      ERR:      out std_logic;
      RESULT:  out std_logic_vector(width-1 downto 0)
   );
end ppi;

architecture struct of ppi is
-- ==================== pouzite komponenty =================
component controller is
   generic( width:  integer);
   port (
      --input
      CLK: in std_logic;
      RESET: in std_logic;
      DONE: in std_logic;
      
      --output
	  START: out std_logic;
      
      CLK_V:  out std_logic;
      SEL2:  out std_logic_vector(1 downto 0);
      
      CLK_U:  out std_logic;
      SEL3:  out std_logic_vector(1 downto 0);
      
      CLK_CONST:   out std_logic;
      
      SEL4:  out std_logic_vector(1 downto 0);
      
      CLK_Y:  out std_logic;
      SEL5:  out std_logic_vector(1 downto 0);
      
      SEL6:  out std_logic_vector(1 downto 0);
      
      SEL7:  out std_logic;
      
      BLOK:  out std_logic;
      SEL8:  out std_logic;
      
      SEL_XOR:   out std_logic;
      
      CLK_RV: out std_logic;
      
      CLK_ACC: out std_logic;
      
      OEN: 	  out std_logic
   );
end component;

component acc is
   generic ( width: integer );
   port (
      DATA_IN: in std_logic_vector(width-1 downto 0);
      CLK: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end component;

component adder is
   generic ( width: integer );
   port (
      DATA_IN_X: in std_logic_vector(width-1 downto 0);
      DATA_IN_Y: in std_logic_vector(width-1 downto 0);
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end component;

component const is
generic ( width: integer );
   port (
      CLK: in std_logic;
      RESET: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end component;

component mpx2 is
   generic ( width: integer );
   port (
      DATA_IN_X: in std_logic_vector(width-1 downto 0);
      DATA_IN_Y: in std_logic_vector(width-1 downto 0);
      SEL: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end component;

component mpx4 is
   generic ( width: integer );
   port (
      DATA_IN_W: in std_logic_vector(width-1 downto 0);
      DATA_IN_X: in std_logic_vector(width-1 downto 0);
      DATA_IN_Y: in std_logic_vector(width-1 downto 0);
      DATA_IN_Z: in std_logic_vector(width-1 downto 0);
      SEL: in std_logic_vector(1 downto 0);
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end component;

component mpx_blok is
   generic ( width: integer );
   port (
      DATA_IN_X: in std_logic_vector(width-1 downto 0);
      DATA_IN_Y: in std_logic_vector(width-1 downto 0);
      SEL: in std_logic;
      BLOK: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end component;

component mul is
   generic ( width: integer );
   port (
      DATA_IN_X: in std_logic_vector(width-1 downto 0);
      DATA_IN_Y: in std_logic_vector(width-1 downto 0);
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end component;

component register_rv is
   generic ( width: integer );
   port (
      CLK: in std_logic;
      data0: in std_logic_vector(width-1 downto 0);
		RESET: in std_logic;
      DATA_IN: in std_logic_vector(width-1 downto 0);
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end component;

component regs_div is
   generic ( width: integer );
   port (
      SEL: in std_logic_vector(1 downto 0);
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end component;

component registry is
   generic ( width: integer );
   port (
      DATA_IN: in std_logic_vector(width-1 downto 0);
      SEL: in std_logic_vector(1 downto 0);
      CLK: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end component;

component regs_y is
   generic ( width: integer );
   port (
      DATA_IN: in std_logic_vector(width-1 downto 0);
      SIG: in std_logic_vector(width-1 downto 0);
      SEL: in std_logic_vector(1 downto 0);
      CLK: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end component;

component srt_divider is
   generic ( width: integer );
   port (
  y: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
  RESET: in std_logic;
  CLK: in std_logic;
  START: in std_logic;
  quotient: OUT STD_LOGIC_VECTOR(0 TO width-1);
  done: OUT STD_LOGIC;
  err: OUT STD_LOGIC
   );
end component;

component xor_comp is
   generic ( width: integer );
   port (
      DATA_IN_X: in std_logic_vector(width-1 downto 0);
      SEL_XOR: in std_logic;
      DATA_OUT: out std_logic_vector(width-1 downto 0)
   );
end component;


-- ================== vlastny popis prepojenia ppi =====================
-- definicie signalov:
-- zbernice
signal sig_regsv, sig_regsu, sig_regsy, sig_divider, sig_const, sig_mul, sig_regsdiv, sig_xor, sig_mpx6, sig_mpx7, sig_mpx8, sig_acc, sig_rv, sig_sum, sig_result:  std_logic_vector(width-1 downto 0);

-- riadiace signaly
signal sig_sel7, sig_sel8, sig_selxor, sig_blok, sig_start, sig_done: std_logic;
signal sig_sel2, sig_sel3, sig_sel4, sig_sel5, sig_sel6: std_logic_vector(1 downto 0);

-- clk - enable komponent z controlleru
signal sig_clkrv, sig_clkacc, sig_clkregsv, sig_clkregsu, sig_clkregsy, sig_clkconst :std_logic;

-- prepojenie komponent
begin

ppi_controller: controller
   generic map ( width => width )
   port map (
      CLK   => CLK,
      RESET   => RESET,
	  START  => sig_start,
	  DONE => sig_done,
      
      OEN   => OEN,
      
      CLK_RV    => sig_clkrv,
      CLK_ACC    => sig_clkacc,      
      
      CLK_V => sig_clkregsv,
      CLK_U => sig_clkregsu,
      CLK_Y => sig_clkregsy,
      
      CLK_CONST => sig_clkconst,
      
      SEL2  => sig_sel2,
      SEL3  => sig_sel3,
      SEL4  => sig_sel4,
      SEL5  => sig_sel5,
      SEL6  => sig_sel6,
      SEL7  => sig_sel7,
      SEL8  => sig_sel8,
      
      SEL_XOR => sig_selxor,
      BLOK => sig_blok

   );

ppi_acc: acc
   generic map ( width => width )
   port map (
      DATA_IN   => sig_sum,
      CLK       => sig_clkacc,
      DATA_OUT  => sig_acc
   );

ppi_adder: adder         
   generic map ( width => width )
   port map (
      DATA_IN_X  => sig_mul,
      DATA_IN_Y  => sig_mpx8,
      DATA_OUT   => sig_sum
   );

ppi_const: const
   generic map ( width => width )
   port map (
      CLK   	=> sig_clkconst,
      RESET     => RESET,
      DATA_OUT  => sig_const
   );

ppi_mpx6: mpx4
   generic map ( width => width)
   port map (
      DATA_IN_W => sig_regsv,
      DATA_IN_X	=> sig_regsu,
      DATA_IN_Y	=> sig_const,
      DATA_IN_Z	=> sig_regsdiv,
      SEL      => sig_sel6,
      DATA_OUT  => sig_mpx6
   );
   
ppi_mpx7: mpx2
   generic map ( width => width)
   port map (
      DATA_IN_X => sig_regsy,
      DATA_IN_Y	=> sig_acc,
      SEL      => sig_sel7,
      DATA_OUT  => sig_mpx7
   );

ppi_mpx8: mpx_blok
   generic map ( width => width)
   port map (
      DATA_IN_X => sig_rv,
      DATA_IN_Y	=> sig_xor,
      SEL      => sig_sel8,
      BLOK		=> sig_blok,
      DATA_OUT  => sig_mpx8
   );

ppi_mul: mul
   generic map ( width => width)
   port map (
      DATA_IN_X => sig_mpx6,
      DATA_IN_Y	=> sig_mpx7,
      DATA_OUT  => sig_mul
   );
  
ppi_register_rv: register_rv
   generic map ( width => width )
   port map (
      CLK       => sig_clkrv,
      DATA0		=> DATA0,
		RESET		=> RESET,
      DATA_IN   => sig_acc,
      DATA_OUT  => sig_rv
   );
 
ppi_regs_div: regs_div
   generic map ( width => width )
   port map (
      SEL	    => sig_sel4,
      DATA_OUT  => sig_regsdiv
   );

ppi_regs_u: registry
	generic map ( width => width )
   port map (
      DATA_IN  => U0,
	  SEL		=> sig_sel3,
	  CLK		=> sig_clkregsu,
      DATA_OUT => sig_regsu
   );

ppi_regs_v: regs_y
	generic map ( width => width )
   port map (
      DATA_IN  => V0,
		SIG		=> sig_divider,
	  SEL		=> sig_sel2,
	  CLK		=> sig_clkregsv,
      DATA_OUT => sig_regsv
   );
   
ppi_regs_y: regs_y
	generic map ( width => width )
   port map (
      DATA_IN  => sig_mul,
      SIG		=> STEP,
	  SEL		=> sig_sel5,
	  CLK		=> sig_clkregsy,
      DATA_OUT => sig_regsy
   );


ppi_xor: xor_comp
	generic map ( width => width )
   port map (
      DATA_IN_X => sig_acc,
      SEL_XOR => sig_selxor,
      DATA_OUT => sig_xor
   );
	
ppi_srt_divider: srt_divider
   generic map ( width => width )
   port map (
      y   => V0,
      CLK	=> CLK,
      reset => RESET,
      start	=> sig_start,
      quotient  => sig_divider,
      done	=>  sig_done,
      err	=> ERR
   );
   
RESULT <= sig_rv;
end struct;
