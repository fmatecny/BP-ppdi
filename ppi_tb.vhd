--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:17:15 04/28/2016
-- Design Name:   
-- Module Name:   C:/Documents and Settings/ppi/ppi_tb.vhd
-- Project Name:  ppi
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ppi
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ppi_tb IS
END ppi_tb;
 
ARCHITECTURE behavior OF ppi_tb IS 
constant n: natural := 32;

-- pociatocna podmienka - 1 
constant data0: std_logic_vector(n-1 downto 0) := "00100000000000000000000000000000";
--constant data0: std_logic_vector(n-1 downto 0) := "0010000000000000000000000000000000000000000000000000000000000000"; 

-- integracny krok - 0,1
constant step: std_logic_vector(n-1 downto 0) := "00000011001100110011001100110011";
--constant step: std_logic_vector(n-1 downto 0) := "0000001100110011001100110011001100110011001100110011001100110011";
   
	-- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ppi
	 generic (width: integer);
    PORT(
         V0 : IN  std_logic_vector(width-1 downto 0);
         U0 : IN  std_logic_vector(width-1 downto 0);
         DATA0 : IN  std_logic_vector(width-1 downto 0);
         STEP : IN  std_logic_vector(width-1 downto 0);
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         OEN : OUT  std_logic;
         ERR : OUT  std_logic;
         RESULT : OUT  std_logic_vector(width-1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal V0 : std_logic_vector(n-1 downto 0);
   signal U0 : std_logic_vector(n-1 downto 0);
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';

 	--Outputs
   signal OEN : std_logic;
   signal ERR : std_logic;
   signal RESULT : std_logic_vector(n-1 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
uut: ppi
	generic map( width => n )
	PORT MAP (
          V0 => V0,
          U0 => U0,
          DATA0 => DATA0,
          STEP => STEP,
          CLK => CLK,
          RESET => RESET,
          OEN => OEN,
          ERR => ERR,
          RESULT => RESULT
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
      VARIABLE int_v,int_u: integer;
   begin      
      reset <= '1';
		wait for CLK_period;
		reset <= '0';
      
      --DV3,DU3
		if (n = 32) then
			int_v := -89478;			--  -0,0001666667
			int_u := -89478;			--  -0,0001666667
			v0 <= CONV_STD_LOGIC_VECTOR(int_v,n);
			u0 <= CONV_STD_LOGIC_VECTOR(int_u,n);
		elsif (n = 64) then
			v0 <= "1111111111111110101000100111100110000011110000010011000111010110";
			u0 <= "1111111111111110101000100111100110000011110000010011000111010110";
		end if;			
			
		wait for CLK_period*2;
      
      --DV2, DU2
		if (n = 32) then
			int_v := 2684354;		--  0.005
			v0 <= CONV_STD_LOGIC_VECTOR(int_v,n);
		elsif (n = 64) then
			v0 <= "0000000000101000111101011100001010001111010111000010100011110101";
		end if;
		int_u := 0;				--  0
      u0 <= CONV_STD_LOGIC_VECTOR(int_u,n);
		
      wait for CLK_period*2;
      --DV1, DU1
		if (n = 32) then
			int_v := -53687091;   --  -0.1
			int_u := 53687091;		--   0.1
			v0 <= CONV_STD_LOGIC_VECTOR(int_v,n);
			u0 <= CONV_STD_LOGIC_VECTOR(int_u,n);
		elsif (n = 64) then		
			v0 <= "1111110011001100110011001100110011001100110011001100110011001101";		 
			u0 <= "0000001100110011001100110011001100110011001100110011001100110011";
		end if;
		
     wait for CLK_period*2;
     
     --v0, u0 
		if (n = 32) then
			int_v := 2**29;			--  1
			v0 <= CONV_STD_LOGIC_VECTOR(int_v,n);
		elsif (n = 64) then
			v0 <= "0010000000000000000000000000000000000000000000000000000000000000";
		end if;
		int_u := 0;					-- 0
      u0 <= CONV_STD_LOGIC_VECTOR(int_u,n);
		
      wait for CLK_period*2;
		report("ulozene");
		
		wait for CLK_period*4;
		if (err = '1') then
			report ("delenie nulou");
		else
				wait until oen = '1';		
				report ("koniec");
		end if;

      wait;
   end process;

END;
