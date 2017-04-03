-----------------------------------------------------------------------------
-- Kontroler pre deliaci PPI - paralelne paralelni integrator
-----------------------------------------------------------------------------
-- Autor: Frantisek Matecny
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.math_real.all;
-- =========================== controller ===============================
-- RESET   	- reset integratoru (nulovanie)
-- CLK     	- hodiny
-- DONE    	- koniec delenia

-- START	- start delenia
-- CLK_V	- registry 'v' enable
-- SEL2    	- registry 'v' select 
-- CLK_U	- registry 'u' enable
-- SEL3    	- registry 'u' select 
-- CLK_CONST- const enable
-- SEL4		- mpx4 select
-- CLK_Y	- registry 'y' enable
-- SEL5    	- registry 'y' select
-- SEL6		- mpx6 select
-- SEL7		- mpx7 select
-- BLOK		- nulovanie mpx8
-- SEL8		- mpx8 select
-- SEL_XOR	- xor select
-- CLK_RV	- rv enable
-- CLK_ACC	- acc enable
-- OEN     	- output enable

entity controller is
   generic(
     width:  integer);
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
      
      CLK_CONST: out std_logic;
      
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
end controller;

architecture struct of controller is

-- ======================= riadenie vypoctu ppi  ============================
-- definicia stavou automatu, ktory riadi vypocet PPI
type TStav is (ResetState, Setup_DX3,In_DX3,Setup_DX2,In_DX2,Setup_DX1,In_DX1,Setup_U0,In_U0,
				Init, MulUh, WaitDIV, SaveDIV, CalculationDY1, WriteACC1,
				MulDY1DV1, SetupDU1h, MulDU1h, SetupACCdiv2, MulACCdiv2, SetupCalcDY2, CalculationDY2, WriteACC2,
				MulCountDY2, SetupDY2DV1, MulDY2DV1, SetupDY1DV2, MulDY1DV2, SetupDU2h, MulDU2h, SetupACCdiv3, MulACCdiv3, SetupCalcDY3, CalculationDY3, WriteACC3,
				MulCountDY3, SetupDY3DV1, MulDY3DV1, SetupDY2DV2, MulDY2DV2, SetupDY1DV3, MulDY1DV3, SetupDU3h, MulDU3h, SetupACCdiv4, MulACCdiv4, SetupCalcDY4, CalculationDY4, WriteACC4, Result);

-- uchovanie stavu automatu
signal ActualState, NextState: TStav;

begin
--------------------------------------------------------------------------------
-- Konecny automat:
-- stavovy register - prepnutie na nasledujuci stav
Clock: process(RESET,CLK)
begin
  if CLK'event and CLK='1' then
    if reset = '1' then
      ActualState <= ResetState;
    else  
      ActualState <= NextState;
    end if;
  end if;  
end process;

-- zvolenie nasledujuceho stavu
NaslStav: process(ActualState, done)
begin
  case ActualState is
------------- ulozenie hodnot do registrov 'u' a 'v'
	when ResetState => 
		NextState <= Setup_DX3;
		
	when Setup_DX3 =>
		NextState <= In_DX3;
		
	when In_DX3 =>
		NextState <= Setup_DX2;
		
	when Setup_DX2 =>
		NextState <= In_DX2;
		
	when In_DX2 =>
		NextState <= Setup_DX1;
		
	when Setup_DX1 =>
		NextState <= In_DX1;
		
	when In_DX1 =>
		NextState <= Setup_U0;
		
	when Setup_U0 =>
		NextState <= In_U0;
		
	when In_U0 =>
		NextState <= Init;
		
-- ================ zaciatok vypoctu DY1 ===============
    when Init =>
        NextState <= MulUH;
      
    when MulUH =>
      NextState <= WaitDIV;
      
    when WaitDIV =>
		if done = '1' then
			NextState <= SaveDIV;
		else
			NextState <= WaitDIV;
		end if;
      
    when SaveDIV =>
      NextState <= CalculationDY1;
      
    when CalculationDY1 =>
      NextState <= WriteACC1;
      
    when WriteACC1 =>
        NextState <= MulDY1DV1;
        
-- ======================== DY2 =======================     
    when MulDY1DV1 =>
      NextState <= SetupDU1h;
      
    when SetupDU1h =>
      NextState <= MulDU1h;
      
    when MulDU1h =>
      NextState <= SetupACCdiv2;
      
    when SetupACCdiv2 =>
      NextState <= MulACCdiv2;
      
    when MulACCdiv2 =>
      NextState <= SetupCalcDY2;
      
    when SetupCalcDY2 =>
      NextState <= CalculationDY2;
      
    when CalculationDY2 =>
        NextState <= WriteACC2;
      
    when WriteACC2 =>
      NextState <= MulCountDY2;
      
-- ======================== DY3 =======================     
    when MulCountDY2 =>
      NextState <= SetupDY2DV1;
      
    when SetupDY2DV1 =>
      NextState <= MulDY2DV1;
      
    when MulDY2DV1 =>
      NextState <= SetupDY1DV2;
      
    when SetupDY1DV2 =>
      NextState <= MulDY1DV2;
      
    when MulDY1DV2 =>
      NextState <= SetupDU2h;
      
    when SetupDU2h =>
      NextState <= MulDU2h;
      
    when MulDU2h =>
      NextState <= SetupACCdiv3;
      
    when SetupACCdiv3 =>
      NextState <= MulACCdiv3;
      
    when MulACCdiv3 =>
      NextState <= SetupCalcDY3;
      
    when SetupCalcDY3 =>
      NextState <= CalculationDY3;
      
    when CalculationDY3 =>
      NextState <= WriteACC3;
      
    when WriteACC3 =>
      NextState <= MulCountDY3;
      
-- ======================== DY4 =======================       
    when MulCountDY3 =>
      NextState <= SetupDY3DV1;
      
    when SetupDY3DV1 =>
      NextState <= MulDY3DV1;
      
    when MulDY3DV1 =>
      NextState <= SetupDY2DV2;
      
    when SetupDY2DV2 =>
      NextState <= MulDY2DV2;
      
    when MulDY2DV2 =>
      NextState <= SetupDY1DV3;
      
     when SetupDY1DV3 =>
      NextState <= MulDY1DV3;
      
    when MulDY1DV3 =>
      NextState <= SetupDU3h;     
    
    when SetupDU3h =>
      NextState <= MulDU3h;
      
    when MulDU3h =>
      NextState <= SetupACCdiv4;
      
    when SetupACCdiv4 =>
      NextState <= MulACCdiv4;
      
    when MulACCdiv4 =>
      NextState <= SetupCalcDY4;
      
    when SetupCalcDY4 =>
      NextState <= CalculationDY4;
      
    when CalculationDY4 =>
      NextState <= WriteACC4;
      
    when WriteACC4 =>
      NextState <= Result;
      
-- ======================== RESULT =======================     
    when Result =>
      if reset = '0' then
        NextState <= Result;
      else
        NextState <= Init;
      end if;
      
    when others =>
      null;
      
  end case;
end process;


-- riadiace signaly kontroleru
Vystup: process(ActualState)
begin
	START <= '0';

	CLK_V  <= '0';
	SEL2  <= "00";

	CLK_U  <= '0';
	SEL3  <= "00";

	CLK_CONST   <= '0';

	SEL4  <= "00";

	CLK_Y  <= '0';
	SEL5  <= "00";

	SEL6  <= "00";

	SEL7  <= '0';

	BLOK  <= '0';
	SEL8  <= '0';

	SEL_XOR   <= '0';

	CLK_RV <= '0';

	CLK_ACC <= '0';

	OEN 	<= '0';
  
  case ActualState is
	when ResetState =>
		CLK_RV <= '1';
	
	when Setup_DX3 =>
		SEL2 <= "11";
		SEL3 <= "11";

	when In_DX3 =>
		SEL2 <= "11";
		SEL3 <= "11";
		CLK_V <= '1';
		CLK_U <= '1';


	when Setup_DX2 =>
		SEL2 <= "10";
		SEL3 <= "10";
		
	when In_DX2 =>
		SEL2 <= "10";
		SEL3 <= "10";
		CLK_V <= '1';
		CLK_U <= '1';


	when Setup_DX1 =>
		SEL2 <= "01";
		SEL3 <= "01";
		
	when In_DX1 =>
		SEL2 <= "01";
		SEL3 <= "01";
		CLK_V <= '1';
		CLK_U <= '1';
	
		
	when Setup_U0 =>
		null;
		
	when In_U0 =>
		CLK_U <= '1';


 ---------------- DY1 ------------------ 
    when Init =>
		CLK_Y <= '1';
--		CLK_RV <= '1';
		SEL6  <= "01";		
		BLOK  <= '1';

    when MulUh =>
		START <= '1';
		CLK_ACC <= '1';
		CLK_V  <= '1';
		SEL6  <= "01";	
		BLOK  <= '1';

    when WaitDIV =>
		null;
 
    when SaveDIV =>
		CLK_V  <= '1';
		SEL5  <= "01";
		SEL7  <= '1';
 
    when CalculationDY1 =>
		CLK_ACC <= '1';
		CLK_Y  <= '1';
		SEL5  <= "01";
		SEL7  <= '1';

    when WriteACC1 =>   
		CLK_RV <= '1';
		SEL2  <= "01";
		SEL5  <= "01";		
		BLOK  <= '1';
---------------- DY2 -------------
    when MulDY1DV1 =>
		CLK_ACC <= '1';	
		SEL2  <= "01";
		SEL5  <= "01";
		BLOK  <= '1';

    when SetupDU1h => 		
		SEL3  <= "01";
		SEL6  <= "01";
		SEL8  <= '1';
		SEL_XOR   <= '1';
		
    when MulDU1h =>
		CLK_ACC <= '1';	
		SEL3  <= "01";
		SEL6  <= "01";
		SEL8  <= '1';
		SEL_XOR   <= '1';
		
    when SetupACCdiv2 =>
		SEL6  <= "11";
		SEL7  <= '1';		
		BLOK  <= '1';
    
    when MulACCdiv2 =>
		CLK_ACC <= '1';
		SEL6  <= "11";
		SEL7  <= '1';		
		BLOK  <= '1';

    when SetupCalcDY2 =>
		SEL5  <= "10";
		SEL7  <= '1';

    when CalculationDY2 =>
		CLK_ACC <= '1';
		CLK_Y  <= '1';
		SEL5  <= "10";
		SEL6  <= "00";
		SEL7  <= '1';
    
    when WriteACC2 =>
		CLK_RV <= '1';		
		SEL5  <= "10";
		SEL6  <= "10";		
		BLOK  <= '1';

----------------- DY3 --------------------
    when MulCountDY2 =>
		CLK_Y  <= '1';		
		SEL5  <= "10";
		SEL6  <= "10";		
		BLOK  <= '1';
		
	when SetupDY2DV1 =>	
		SEL2  <= "01";
		SEL5  <= "10";
		BLOK  <= '1';
		CLK_CONST   <= '1';		
	
	when MulDY2DV1 =>
		CLK_ACC <= '1';		
		SEL2  <= "01";
		SEL5  <= "10";		
		BLOK  <= '1';

	when SetupDY1DV2 =>	
		SEL2  <= "10";
		SEL5  <= "01";
		SEL8  <= '1';
		
	when MulDY1DV2 =>
		CLK_ACC <= '1';	
		SEL2  <= "10";
		SEL5  <= "01";
		SEL8  <= '1';
		
	when SetupDU2h =>	
		SEL3  <= "10";
		SEL6  <= "01";
		SEL8  <= '1';
		SEL_XOR   <= '1';
	
	when MulDU2h =>
		CLK_ACC <= '1';	
		SEL3  <= "10";
		SEL6  <= "01";
		SEL8  <= '1';
		SEL_XOR   <= '1';
		
	when SetupACCdiv3 =>		
		SEL4  <= "01";
		SEL6  <= "11";
		SEL7  <= '1';
		BLOK  <= '1';
	
	when MulACCdiv3 =>
		CLK_ACC <= '1';	
		SEL4  <= "01";
		SEL6  <= "11";
		SEL7  <= '1';		
		BLOK  <= '1';
		
	when SetupCalcDY3 =>
		SEL5	<= "11";
		SEL7  <= '1';
	
	when CalculationDY3 =>
		CLK_ACC <= '1';
		CLK_Y  <= '1';
		SEL5	<= "11";
		SEL7  <= '1';
		
	when WriteACC3 =>
		CLK_RV <= '1';	
		SEL5  <= "11";
		SEL6  <= "10";		
		BLOK  <= '1';

------------------ DY4 ---------------		
	when MulCountDY3 =>
		CLK_Y  <= '1';		
		SEL5  <= "11";
		SEL6  <= "10";
		BLOK  <= '1';

	when SetupDY3DV1 =>
		SEL2  <= "01";
		SEL5  <= "11";	
		BLOK  <= '1';
	
	when MulDY3DV1 =>
		CLK_ACC <= '1';		
		SEL2  <= "01";
		SEL5  <= "11";
		BLOK  <= '1';
		
	when SetupDY2DV2 =>		
		SEL2  <= "10";
		SEL5  <= "10";
		SEL8  <= '1';
		
	when MulDY2DV2 =>
		CLK_ACC <= '1';	
		SEL2  <= "10";
		SEL5  <= "10";
		SEL8  <= '1';
				
	when SetupDY1DV3 =>	
		SEL2  <= "11";
		SEL5  <= "01";
		SEL8  <= '1';

	when MulDY1DV3 =>
		CLK_ACC <= '1';
		SEL2  <= "11";
		SEL5  <= "01";
		SEL8  <= '1';
	
	when SetupDU3h =>		
		SEL3  <= "11";
		SEL6  <= "01";
		SEL8  <= '1';
		SEL_XOR   <= '1';
		
	when MulDU3h =>
		CLK_ACC <= '1';		
		SEL3  <= "11";
		SEL6  <= "01";
		SEL8  <= '1';
		SEL_XOR   <= '1';
			
	when SetupACCdiv4 =>
		SEL4  <= "10";
		SEL6  <= "11";
		SEL7  <= '1';
		BLOK  <= '1';
		
	when MulACCdiv4 =>
		CLK_ACC <= '1';		
		SEL4  <= "10";
		SEL6  <= "11";
		SEL7  <= '1';		
		BLOK  <= '1';
		
	when SetupCalcDY4 =>
		SEL7  <= '1';
	
	when CalculationDY4 =>
		CLK_ACC <= '1';
		SEL7  <= '1';

	when WriteACC4 =>
		CLK_RV <= '1';	
		BLOK  <= '1';
------------ result --------------
    when Result =>
      OEN <= '1';

    when others =>
      null;
  end case;
end process;

end struct;
