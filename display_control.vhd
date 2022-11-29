library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library wysiwyg;
use wysiwyg.fiftyfivenm_components.all;

entity display_control is
	port (
		-- Input
		clock:			in std_logic;
		binary_code:		in std_logic;
		-- Output
		write_en:		out std_logic;
		data_out:		out natural range 0 to 2**12 - 1
	);
end entity display_control;

architecture logic of display_control is
	
	type 		state_type is (wait_state, increment_state);
	
	signal	tail:			natural;
	signal 	state, next_state: 	state_type;
	signal 	start_transfer: 	std_logic;
	signal 	end_transfer:	 	std_logic;
	
	
	function increment_ready(
		head_pointer, tail_pointer: in natural;
	) return boolean;
	is 
	begin
		if (head_pointer > tail_pointer) and (head_pointer - tail_pointer > 1) then
			if (head_pointer > 0) and (tail_pointer < 7) then
				return true;
			else
				return false;
			end if;
		else
			return false
		end if;
	end function increment_ready;
	
begin

	transition_function: process(state, end_transfer) is
		begin
			case state is
				when wait_state => 
					--check tail and head distance
					if increment_ready(binary_code, tail) then
						next_state <= increment_state;
					else
						next_state <= wait_state;
					end if;
				when increment_state =>
					-- wait
					next_state <= wait_state;
				when others =>
					next_state <= wait_state;
			end case;
	end process transition_function;
	
	output_process: process(clock) is
		begin 
							
		if rising_edge(clock) then
			if state = wait_state then
				if start_transfer = '1' then
					write_en 	<= '1';
				else
					start_transfer 	<= '1';
				end if;
			end if;
			
			if state = increment_state then
				if end_transfer = '1' then
					write_en 	<= '0';
				else
					end_transfer 	<= '1';
				end if;
			end if;
		end if;
			
	end process output_process;
	
end architecture logic;
