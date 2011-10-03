--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:13:53 09/23/2011
-- Design Name:   
-- Module Name:   C:/Users/benjambj/Documents/Xilinx/Projects/Exercise1/alu_tb.vhd
-- Project Name:  Exercise1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY alu_tb IS
END alu_tb;
 
ARCHITECTURE behavior OF alu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         alu_funct : IN  std_logic_vector(31 downto 0);
         alu_in_a : IN  std_logic_vector(31 downto 0);
         alu_in_b : IN  std_logic_vector(31 downto 0);
         alu_out : OUT  std_logic_vector(31 downto 0);
         alu_status : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal alu_funct : std_logic_vector(31 downto 0) := (others => '0');
   signal alu_in_a : std_logic_vector(31 downto 0) := (others => '0');
   signal alu_in_b : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal alu_out : std_logic_vector(31 downto 0);
   signal alu_status : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   --constant <clock>_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          alu_funct => alu_funct,
          alu_in_a => alu_in_a,
          alu_in_b => alu_in_b,
          alu_out => alu_out,
          alu_status => alu_status
        );

   -- Clock process definitions
   --<clock>_process :process
   --begin
	--	<clock> <= '0';
	--	wait for <clock>_period/2;
	--	<clock> <= '1';
	--	wait for <clock>_period/2;
   --end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 90 ns;	

--    Test of func 0x0: Addition. Start time: 100 ns
		alu_funct <= X"00000000";
		wait for 10 ns;
     
		-- basic addition test
		-- expected output => 00000001
		-- expected status => 00000000
		alu_in_a <= X"00000000";
		alu_in_b <= X"00000001";
				
		wait for 50 ns;
			
		-- tests positive overflow	
		-- expected output => 80000000
		-- expected status => 00000110
		alu_in_a <= X"7FFFFFFF";
		alu_in_b <= X"00000001";
		
		wait for 50 ns;
		
		-- tests neg + pos, border values
		-- expected output => 00000000
		-- expected status => 00000001
		alu_in_a <= X"FFFFFFFF";
		alu_in_b <= X"00000001";
		
		wait for 50 ns;
		
		-- tests negative overflow
		-- expected output => 7FFFFFFF
		-- expected status => 00000100
		alu_in_a <= X"80000000";
		alu_in_b <= X"FFFFFFFF";
		
		wait for 50 ns;
		
		-- tests border value, negative result
		-- expected output => FFFFFFFF
		-- expected status => 00000010
		alu_in_a <= X"00000001";
		alu_in_b <= X"FFFFFFFE";
		
		wait for 50 ns;
		
		-- tests border value
		-- expected output => 00000000
		-- expected status => 00000001
		alu_in_a <= X"00000000";
		alu_in_b <= X"00000000";
		
		wait for 40 ns;
		
-- 	Test of func 0x1: Subtraction. Start time: 400 ns
		alu_funct <= X"00000001";
		wait for 10 ns;
		
		-- basic test
		-- expected output => 00000000
		-- expected status => 00000001
		alu_in_a <= X"00000001";
		alu_in_b <= X"00000001";

		wait for 50 ns;
		
		-- border value
		-- expected output => 80000001
		-- expected status => 00000010
		alu_in_a <= X"00000000";
		alu_in_b <= X"7FFFFFFF";

		wait for 50 ns;
		
		-- border value
		-- expected output => 80000000
		-- expected status => 00000010
		alu_in_a <= X"80000001";
		alu_in_b <= X"00000001";

		wait for 50 ns;
		
		-- tests negative overflow
		-- expected output => 7FFFFFFF
		-- expected status => 00000100
		alu_in_a <= X"80000000";
		alu_in_b <= X"00000001";
						
		wait for 50 ns;
		
		-- tests positive overflow
		-- expected output => 80000000
		-- expected status => 00000110
		alu_in_a <= X"7FFFFFFF";
		alu_in_b <= X"FFFFFFFF";
		
		wait for 40 ns;
		
-- 	Test of func 0x2: Multiplication. Start time: 650 ns
		alu_funct <= X"00000002";
		wait for 10 ns;
		
		-- basic test
		-- expected output => 00000006
		-- expected status => 00000000
		alu_in_a <= X"00000002";
		alu_in_b <= X"00000003";
		
		wait for 50 ns;
		
		-- tests multiplication with zero
		-- expected output => 00000000
		-- expected status => 00000001
		alu_in_a <= X"00000000";
		alu_in_b <= X"AAAAAAAA"; 
		
		wait for 50 ns;
		
		-- tests pos - neg multiplication
		-- expected output => FFFFFFFF
		-- expected status => 00000010
		alu_in_a <= X"00000001";
		alu_in_b <= X"FFFFFFFF"; 
		
		wait for 50 ns;
		
		-- tests neg - pos multiplication
		-- expected output => FFFFFFFF
		-- expected status => 00000010
		alu_in_a <= X"FFFFFFFF";
		alu_in_b <= X"00000001"; 
		
		wait for 50 ns;
		
		-- tests neg - neg multiplication
		-- expected output => 00000001
		-- expected status => 00000000
		alu_in_a <= X"FFFFFFFF";
		alu_in_b <= X"FFFFFFFF"; 
		
		wait for 50 ns;
		
		-- tests border values and overflow
		-- expected output => FFFFFFFC
		-- expected status => 00000010
		alu_in_a <= X"7FFFFFFF";
		alu_in_b <= X"00000004"; 
		
		wait for 40 ns;
		
-- 	Test of func 0x3: Division. Start time: 950 ns
		alu_funct <= X"00000003";
		wait for 10 ns;
		
		--div test code
		
		wait for 40 ns;
		
-- 	Test of func 0x4: Nor. Start time: 1000 ns
		alu_funct <= X"00000004";
		wait for 10 ns;
		
		-- basic tests
		-- expected output => 50505050
		-- expected status => 00000000
		alu_in_a <= X"AAAAAAAA";
		alu_in_b <= X"0F0F0F0F"; 
		
		wait for 50 ns;
		
		-- test x nor 0 == not
		-- expected output => 55555555
		-- expected status => 00000000
		alu_in_a <= X"AAAAAAAA";
		alu_in_b <= X"00000000"; 
		
		wait for 50 ns;
		
		-- test x nor 0 == not
		-- expected output => FFFFFFFF
		-- expected status => 00000010
		alu_in_a <= X"00000000";
		alu_in_b <= X"00000000"; 
				
		wait for 50 ns;
		
		-- test x nor ~x == 0
		-- expected output => 00000000
		-- expected status => 00000001
		alu_in_a <= X"AAAAAAAA";
		alu_in_b <= X"55555555"; 
		
		wait for 40 ns;
		
-- 	Test of func 0x5: Xor. Start time: 1200 ns 
		alu_funct <= X"00000005";
		wait for 10 ns;
		
		-- basic tests
		-- expected output => FFFFFFFF
		-- expected status => 00000010
		alu_in_a <= X"AAAAAAAA";
		alu_in_b <= X"55555555"; 
		
		wait for 50 ns;
		
		-- test x xor x == 0
		-- expected output => 00000000
		-- expected status => 00000001
		alu_in_a <= X"AAAAAAAA";
		alu_in_b <= X"AAAAAAAA"; 
		
		wait for 50 ns;
		
		-- test x xor 0 == x
		-- expected output => 12345678
		-- expected status => 00000000
		alu_in_a <= X"12345678";
		alu_in_b <= X"00000000"; 
		
		wait for 50 ns;
		
		-- test x xor -1 == ~x
		-- expected output => 55555555
		-- expected status => 00000000
		alu_in_a <= X"AAAAAAAA";
		alu_in_b <= X"FFFFFFFF"; 
		
		wait for 40 ns;
		
-- 	Test of func 0x6: Or. Start time: 1400 ns
		alu_funct <= X"00000006";
		wait for 10 ns;
		
		-- basic tests
		-- expected output => FFFFFFFF
		-- expected status => 00000010
		alu_in_a <= X"AAAAAAAA";
		alu_in_b <= X"55555555"; 
		
		wait for 50 ns;
		
		-- x or ~0 = ~0
		-- expected output => FFFFFFFF
		-- expected status => 00000010
		alu_in_a <= X"00000000";
		alu_in_b <= X"FFFFFFFF"; 
		
		wait for 50 ns;
		
		-- test x or 0 == x
		-- expected output => AAAAAAAA
		-- expected status => 00000010
		alu_in_a <= X"AAAAAAAA";
		alu_in_b <= X"00000000"; 
		
		wait for 40 ns;
		
-- 	Test of func 0x7: And. Start time: 1550 ns
		alu_funct <= X"00000007";
		wait for 10 ns;
		
		-- basic tests
		-- expected output => 0A0A0A0A
		-- expected status => 00000000
		alu_in_a <= X"AAAAAAAA";
		alu_in_b <= X"0F0F0F0F"; 
		
		wait for 50 ns;
		
		-- test x and 0 == 0
		-- expected output => 00000000
		-- expected status => 00000001
		alu_in_a <= X"AAAAAAAA";
		alu_in_b <= X"00000000"; 
		
		wait for 50 ns;
		
		-- test x and ~0 == x
		-- expected output => 00000002
		-- expected status => 00000000
		alu_in_a <= X"FFFFFFFF";
		alu_in_b <= X"00000002"; 
		
		wait for 40 ns;
				
-- 	Test of func 0x8: Logical left shift. Start time: 1700 ns
		alu_funct <= X"00000008";
		wait for 10 ns;
		
		-- basic tests
		-- expected output => 2AAAAAA8
		-- expected status => 00000000
		alu_in_a <= X"0AAAAAAA";
		alu_in_b <= X"00000002"; 
		
		wait for 50 ns;
		
		-- test carry
		-- expected output => AAAAAAA8
		-- expected status => 00000000
		alu_in_a <= X"AAAAAAAA";
		alu_in_b <= X"00000002"; 
		
		wait for 50 ns;
		
		-- test carry
		-- expected output => 6AAAAAA8
		-- expected status => 00001000
		alu_in_a <= X"5AAAAAAA";
		alu_in_b <= X"00000002"; 
		
		wait for 50 ns;
		
		-- test zero
		-- expected output => 00000000
		-- expected status => 00001001
		alu_in_a <= X"F0000000";
		alu_in_b <= X"00000004"; 

		wait for 50 ns;
		
		-- test neg - no flag
		-- expected output => B5555554
		-- expected status => 00000000
		alu_in_a <= X"5AAAAAAA";
		alu_in_b <= X"00000001"; 

		wait for 40 ns;
		
		--Test of func 0x9: Arithmetic left shift. Start time: 1950 ns
		alu_funct <= X"00000009";
		wait for 10 ns;
		
		-- basic tests
		-- expected output => FFFFFFFE
		-- expected status => 00000010
		alu_in_a <= X"FFFFFFFF";
		alu_in_b <= X"00000001"; 
		
		wait for 50 ns;
		
		-- test no overflow
		-- expected output => FFFFFFFF
		-- expected status => 00000010
		alu_in_a <= X"FFFFFFFF";
		alu_in_b <= X"00000000";
		
		wait for 50 ns;
		
		-- test overflow, pos >> negative
		-- expected output => FFFFFFF0
		-- expected status => 00000110
		alu_in_a <= X"0FFFFFFF";
		alu_in_b <= X"00000004";
		
		wait for 50 ns;
		
		-- test zero - should this trigger overflow? 
		-- expected output => 00000000
		-- expected status => 00000001
		alu_in_a <= X"0FFFFFFF";
		alu_in_b <= X"00000020";
		
		wait for 40 ns;
		
-- 	Test of func 0xA: Logical right shift. Start time: 2150 ns
		alu_funct <= X"0000000A";
		wait for 10 ns;
		
		-- test carry; keep last bit shifted out
		-- expected output => 02AAAAAA
		-- expected status => 00001000
		alu_in_a <= X"0AAAAAAA";
		alu_in_b <= X"00000002"; 
		
		wait for 50 ns;
				
		-- test zero
		-- expected output => 00000000
		-- expected status => 00001001
		alu_in_a <= X"00000001";
		alu_in_b <= X"00000001"; 
		
		wait for 50 ns;
		
		-- test negative, no shift amount
		-- expected output => FFFFFFFF
		-- expected status => 00000000
		alu_in_a <= X"FFFFFFFF";
		alu_in_b <= X"00000000";
		
		wait for 40 ns;
		
-- 	Test of func 0xB: Arithmetic right shift. Start time: 2300 ns
		alu_funct <= X"0000000B";
		wait for 10 ns;
		
		-- basic tests
		-- expected output => 3FFFFFFF
		-- expected status => 00000000
		alu_in_a <= X"7FFFFFFF";
		alu_in_b <= X"00000001";
		
		wait for 50 ns;
		
		-- test sign extension
		-- expected output => FFFFFFFF
		-- expected status => 00000010
		alu_in_a <= X"FFFFFFFF";
		alu_in_b <= X"0000000F"; 
		
		wait for 50 ns;
		
		-- test zero
		-- expected output => 00000000
		-- expected status => 00000001
		alu_in_a <= X"00000001";
		alu_in_b <= X"00000001"; 
		
		wait for 50 ns;
		
   end process;

END;
