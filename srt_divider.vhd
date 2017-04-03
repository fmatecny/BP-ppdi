-----------------------------------------------------------------------------
-- SRT delicka pre deliaci PPI - paralelne paralelni integrator
-----------------------------------------------------------------------------
-- Autor: Jean Pierre Deschamps, Gustavo D. Sutter and Enrique Cantó (modifikacia Frantisek Matecny)
-- Z knihy: Guide to FPGA Implementation of Arithmetic Functions
-- Dostupny z: http://www.arithmetic-circuits.org/guide2fpga/vhdl_codes.htm
-- Datum: 1.5.2016
-----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- srt_divider.vhd
--
-- section 9.2.3 SRT division
--
-- x = xn xn-1 ... x0: integer in 2's complement form
-- y = 1 yn-2 ... y0: normalized natural
-- condition: -y <= x < y
-- quotient q =  q0. q1 ... qp: fractional in 2's complement form
-- remainder r = rn rn-1 ... r0: integer in 2's complement form
-- x = (q0.q1 q2 ... qp)·y + (r/y)·2-p with -y <= r < y
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.math_real.all;
ENTITY srt_divider IS
  GENERIC(width: integer := 32);
PORT(
  y: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  quotient: OUT STD_LOGIC_VECTOR(0 TO width-1);
--  remainder: OUT STD_LOGIC_VECTOR(n DOWNTO 0);
  done: OUT STD_LOGIC;
  err: OUT STD_LOGIC
);
constant p: integer := width-3;
constant n: integer := width-1;
END srt_divider;

ARCHITECTURE circuit OF srt_divider IS
  SIGNAL x, r, next_r, two_r, norm_y: STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL plus1, minus1, load, update, shift: STD_LOGIC;
  SIGNAL operation: STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL q, qm: STD_LOGIC_VECTOR(0 TO p);
  SIGNAL shift_count: STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL reg: STD_LOGIC_VECTOR(n DOWNTO 0); 
  
  SUBTYPE index IS NATURAL RANGE 0 TO p-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 6;
  SIGNAL current_state: state;
  
BEGIN
  reg(n DOWNTO 0) <= (OTHERS => y(n));
  x(n DOWNTO n-2) <= "001"; x(n-3 DOWNTO 0) <= (OTHERS => '0');		-- 1.0
  two_r <= r(n-1 DOWNTO 0)&'0';
  plus1 <= NOT(r(n)) AND (r(n-1) OR r(n-2));
  minus1 <= r(n) AND (NOT(r(n-1)) OR NOT(r(n-2)));
  operation <= plus1 & minus1;
  WITH operation SELECT next_r <= two_r - norm_y WHEN "10",
								  two_r + norm_y WHEN "01",
								  two_r WHEN OTHERS;
  
  -- normalizovanie y - 1.yn-2 ... y0
  normalized_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
		IF load = '1' THEN
			norm_y <= y;
			shift_count(5 DOWNTO 0) <= (OTHERS => '0');
		ELSIF norm_y(n) = '1' THEN
				norm_y(n DOWNTO 0) <= (norm_y(n DOWNTO 0) xor reg(n DOWNTO 0)) + 1;
		ELSIF norm_y(n-1) = '0' THEN
				norm_y(n-1 DOWNTO 1) <= norm_y(n-2 DOWNTO 0); norm_y(0) <= '0';
				shift_count <= shift_count + 1;
		ELSIF shift = '1' AND shift_count > 0 THEN
			shift_count <= shift_count -1;
		END IF;
    END IF;
  END PROCESS;

  -- register zvysku
  remainder_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN r <= (x(n DOWNTO 0) xor reg(n DOWNTO 0)) + y(n);
      ELSIF update = '1' THEN r <= next_r;
      END IF;  
    END IF;
  END PROCESS;
--  remainder <= r;

  -- register na prevod on-the-fly
  q_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN q <= (OTHERS => '0');
      ELSIF update = '1' THEN 
      
        IF plus1 = '1' THEN q(0 TO p-1) <= q(1 TO p); q(p) <= '1';
        ELSIF minus1 = '1' THEN q(0 TO p-1) <= qm(1 TO p); q(p) <= '1';
        ELSE q(0 TO p-1) <= q(1 TO p); q(p) <= '0'; 
        END IF;
      ELSIF shift = '1' AND shift_count > 0 THEN
				q(0 TO p-1) <= q(1 TO p); q(p) <= '0';
      END IF;  
    END IF;
  END PROCESS;
  
  -- register na prevod on-the-fly
  qm_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN qm(0 TO p-1) <= (OTHERS => '0'); qm(p) <= '1';
      ELSIF update = '1' THEN 
      
        IF plus1 = '1' THEN qm(0 TO p-1) <= q(1 TO p); qm(p) <= '0';
        ELSIF minus1 = '1' THEN qm(0 TO p-1) <= qm(1 TO p); qm(p) <= '0';
        ELSE qm(0 TO p-1) <= qm(1 TO p); qm(p) <= '1'; 
        END IF;
            
      END IF;  
    END IF;
  END PROCESS;

  quotient <= y(n)&y(n)&q;

  -- citac
  counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN count <= 0; 
      ELSIF update = '1' THEN count <= (count+1) MOD p;
      END IF;
    END IF;
  END PROCESS;

  -- prepinanie stavov delicky
  next_state: PROCESS(clk)
  BEGIN
    IF reset = '1' THEN current_state <= 0;
    ELSIF clk'EVENT AND clk = '1' THEN
      CASE current_state IS
        WHEN 0 => IF start = '0' THEN current_state <= 1; END IF;					  -- zaciatok vypoctu
        WHEN 1 => IF start = '1' THEN current_state <= 2; END IF;
		WHEN 2 => IF y > 0 THEN current_state <= 3; ELSE current_state <= 6; END IF;  -- delenie 0
        WHEN 3 => IF norm_y(n-1) = '1' THEN current_state <= 4; END IF;				  -- koniec normalizacie
        WHEN 4 => IF count = p-1 THEN current_state <= 5; END IF;					  -- koniec delenia
		WHEN 5 => IF shift_count = 0 THEN current_state <= 0; END IF;				  -- spatna normalizacia vysledku
	    WHEN 6 => null;
      END CASE;
    END IF;
  END PROCESS;

  -- nastavenie riadiacich signalov
  output_function: PROCESS(clk, current_state)
  BEGIN
    CASE current_state IS
      WHEN 0 TO 1 => load <= '0'; update <= '0'; done <= '1'; err <= '0'; shift <= '0';
      WHEN 2 => load <= '1'; update <= '0'; done <= '0'; shift <= '0';
		WHEN 3 => load <= '0'; update <= '0'; done <= '0'; shift <= '0';
      WHEN 4 => load <= '0'; update <= '1'; done <= '0'; shift <= '0';
		WHEN 5 => load <= '0'; update <= '0'; done <= '0'; shift <= '1';
		WHEN 6 => err <= '1';
    END CASE;
  END PROCESS;
    
END circuit;
