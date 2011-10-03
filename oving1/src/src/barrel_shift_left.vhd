----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:44:01 09/29/2011 
-- Design Name: 
-- Module Name:    barrel_shift_left - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity barrel_shift_left is
    Port ( data_in : in  STD_LOGIC_VECTOR (31 downto 0);
           shift_amount : in  STD_LOGIC_VECTOR (31 downto 0);
           data_out_signed : out  STD_LOGIC_VECTOR (31 downto 0);
			  data_out_unsigned : out UNSIGNED (31 downto 0));
end barrel_shift_left;

architecture Behavioral of barrel_shift_left is

begin

	process (data_in, shift_amount) 
	begin
		data_out_signed <= shl(data_in, shift_amount);
		data_out_unsigned <= shl(unsigned(data_in), unsigned(shift_amount));
	end process;

end Behavioral;

