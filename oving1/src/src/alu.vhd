-------------------------------------------------------------------------------
-- Title      : ALU
-- Project    : dmkons, vhdl-ving p Nalle
-------------------------------------------------------------------------------
-- File       : alu.vhd
-- Author     : Asbjrn Djupdal  <asbjoern@djupdal.org>
-- Company    : 
-- Last update: 2008-06-19
-- Platform   : BenERA, Virtex 1000E
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003/08/07  1.0      djupdal	Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
--use IEEE.numeric_std.to_integer;
--use IEEE.numeric_bit.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;

entity alu is

  port (
    alu_funct : in std_logic_vector(31 downto 0);
    alu_in_a  : in std_logic_vector(31 downto 0);
    alu_in_b  : in std_logic_vector(31 downto 0);

    alu_out    : out std_logic_vector(31 downto 0);
    alu_status : out std_logic_vector(31 downto 0));

end alu;    

-------------------------------------------------------------------------------

architecture alu_arch of alu is
	 
    COMPONENT barrel_shift_left
    PORT(
         data_in: IN  std_logic_vector(31 downto 0);
         shift_amount : IN  std_logic_vector(31 downto 0);
         data_out_signed: OUT  std_logic_vector(31 downto 0);
			data_out_unsigned: OUT unsigned(31 downto 0)
        );
    END COMPONENT;
	 COMPONENT barrel_shift_right
    PORT(
         data_in: IN  std_logic_vector(31 downto 0);
         shift_amount : IN  std_logic_vector(31 downto 0);
         data_out_signed: OUT  std_logic_vector(31 downto 0);
			data_out_unsigned: OUT unsigned(31 downto 0)
        );
    END COMPONENT;

	

	signal shift_left_signed_result: std_logic_vector(31 downto 0);
	signal shift_left_unsigned_result: UNSIGNED (31 downto 0);
	signal shift_right_signed_result: std_logic_vector(31 downto 0);
	signal shift_right_unsigned_result: UNSIGNED (31 downto 0);

begin

  shift_left: barrel_shift_left port map (
		data_in => alu_in_a,
		shift_amount => alu_in_b,
		data_out_signed => shift_left_signed_result,
		data_out_unsigned => shift_left_unsigned_result
	);
	
	shift_right: barrel_shift_right port map (
		data_in => alu_in_a,
		shift_amount => alu_in_b,
		data_out_signed => shift_right_signed_result,
		data_out_unsigned => shift_right_unsigned_result
	);


  process (alu_funct, alu_in_a, alu_in_b, shift_left_signed_result, shift_left_unsigned_result, shift_right_signed_result, shift_right_unsigned_result)
	constant neutral_flag: std_logic_vector(31 downto 0) := X"00000000";
	
	-- Positions of status flags in status register
	constant zero_pos: integer := 0;
	constant negative_pos: integer := 1;
	constant overflow_pos: integer := 2;
	constant carry_pos: integer := 3;
		
	-- Used for temporary storage to operate on function result
	variable output_holder: std_logic_vector(31 downto 0) := X"00000000";
	variable output64_holder: std_logic_vector(63 downto 0) := X"0000000000000000";
	variable flag_holder: std_logic_vector(31 downto 0) := X"00000000";
	
	variable i: integer := 0;
	
	-- Function selection codes
	constant add_code: std_logic_vector(31 downto 0) := X"00000000";
	constant sub_code: std_logic_vector(31 downto 0) := X"00000001";
	constant mul_code: std_logic_vector(31 downto 0) := X"00000002";
	constant div_code: std_logic_vector(31 downto 0) := X"00000003";
	constant nor_code: std_logic_vector(31 downto 0) := X"00000004";
	constant xor_code: std_logic_vector(31 downto 0) := X"00000005";
	constant or_code: std_logic_vector(31 downto 0) := X"00000006";
	constant and_code: std_logic_vector(31 downto 0) := X"00000007";
	constant sll_code: std_logic_vector(31 downto 0) := X"00000008";
	constant sla_code: std_logic_vector(31 downto 0) := X"00000009";
	constant srl_code: std_logic_vector(31 downto 0) := X"0000000A";
	constant sra_code: std_logic_vector(31 downto 0) := X"0000000B";
  begin
  	case alu_funct is
	
	-- Addition
		when add_code => 
			output_holder := (alu_in_a + alu_in_b);
			flag_holder := neutral_flag;
			
			flag_holder(zero_pos) := nor_reduce(output_holder);
			flag_holder(negative_pos) := output_holder(31);
			flag_holder(overflow_pos) := not(alu_in_a(31) xor alu_in_b(31)) and (alu_in_a(31) xor output_holder(31));
						
			alu_out <= output_holder;
			alu_status <= flag_holder;
	
	--Subtraction
		when sub_code => 
			output_holder := (alu_in_a - alu_in_b);
			flag_holder := neutral_flag;

			flag_holder(zero_pos) := nor_reduce(output_holder);
			flag_holder(negative_pos) := output_holder(31);
			flag_holder(overflow_pos) := (alu_in_a(31) xor alu_in_b(31)) and (alu_in_a(31) xor output_holder(31));
						
			alu_out <= output_holder;
			alu_status <= flag_holder;
			
	-- Multiplication
		when mul_code =>
			output64_holder := alu_in_a * alu_in_b;
			flag_holder := neutral_flag;

			flag_holder(zero_pos) := nor_reduce(alu_in_a) or nor_reduce(alu_in_b);
			flag_holder(negative_pos) := output64_holder(31);

			alu_out <= output64_holder(31 downto 0);
			alu_status <= flag_holder;
		
	-- Bitwise NOR
		when nor_code => 
			output_holder := alu_in_a nor alu_in_b;
			flag_holder := neutral_flag;
			
			flag_holder(zero_pos) := nor_reduce(output_holder);
			flag_holder(negative_pos) := output_holder(31);
			
			alu_out <= output_holder;
			alu_status <= flag_holder;
		
	-- Bitwise XOR
		when xor_code => 
			output_holder := alu_in_a xor alu_in_b;
			flag_holder := neutral_flag;
			
			flag_holder(zero_pos) := nor_reduce(output_holder);
			flag_holder(negative_pos) := output_holder(31);
					
			alu_out <= output_holder;
			alu_status <= flag_holder;
		
	-- Bitwise OR
		when or_code => 
			output_holder := alu_in_a or alu_in_b;
			flag_holder := neutral_flag;

			flag_holder(zero_pos) := nor_reduce(output_holder);
			flag_holder(negative_pos) := output_holder(31);
			
			alu_out <= output_holder;
			alu_status <= flag_holder;
			
	-- Bitwise AND
		when and_code => 
			output_holder := alu_in_a and alu_in_b;
			flag_holder := neutral_flag;

			flag_holder(zero_pos) := nor_reduce(output_holder);
			flag_holder(negative_pos) := output_holder(31);
			
			alu_out <= output_holder;
			alu_status <= flag_holder;
		
	-- Shift left logical
		when sll_code =>
			output_holder := std_logic_vector(shift_left_unsigned_result);
			flag_holder := neutral_flag;


		-- Get the last bit shifted out
			i := conv_integer(alu_in_b);
			if (i /= 0) then
				flag_holder(carry_pos) := alu_in_a(32-i);
			else
				flag_holder(carry_pos) := '0';
			end if;
			
			flag_holder(zero_pos) := nor_reduce(output_holder);
		
			alu_out <= output_holder;
			alu_status <= flag_holder;
	
	-- Shift left arithmetic
		when sla_code =>
			output_holder := shift_left_signed_result;
			flag_holder := neutral_flag;
		
			flag_holder(zero_pos) := nor_reduce(output_holder);
			flag_holder(negative_pos) := output_holder(31);
			flag_holder(overflow_pos) := output_holder(31) xor alu_in_a(31);
			
			alu_out <= output_holder;
			alu_status <= flag_holder;
			
	-- Shift right logical
		when srl_code =>
			output_holder := std_logic_vector(shift_right_unsigned_result);
			flag_holder := neutral_flag;
		
			flag_holder(zero_pos) := nor_reduce(output_holder);

		-- Get the last bit shifted out
			i := conv_integer(alu_in_b);
			if (i /= 0) then
				flag_holder(carry_pos) := alu_in_a(i-1);
			else
				flag_holder(carry_pos) := '0';
			end if;
		
			alu_out <= output_holder;
			alu_status <= flag_holder;
	
	-- Shift right arithmetic
		when sra_code =>
			output_holder := shift_right_signed_result;
			flag_holder := neutral_flag;
		
			flag_holder(zero_pos) := nor_reduce(output_holder);
			flag_holder(negative_pos) := output_holder(31);
		
			alu_out <= output_holder;
			alu_status <= flag_holder;
	
	-- Invalid function code
		when others => 
			alu_out <= X"00000000";
			alu_status <= neutral_flag;
		
	end case;
  end process;
end alu_arch;
