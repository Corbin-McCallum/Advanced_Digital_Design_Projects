library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library wysiwyg;
use wysiwyg.fiftyfivenm_components.all;

entity display_control is
	generic(
		max_address:	natural:= 16
	);
	port (
		-- Input
		clock_50:	in 	std_logic;
		head_ptr:	in 	natural range 0 to max_address - 1;
		reset:		in	std_logic;
		-- Output
		tail_ptr:	out	natural range 0 to max_address - 1
	);
end entity display_control;

architecture logic of display_control is
	
	type 		state_type is (wait_state, increment_state);
		
	signal	tail:			natural range 0 to max_address - 1;
	signal 	state, next_state: 	state_type;
	signal 	start_transfer: 	std_logic;
	signal 	end_transfer:	 	std_logic;
	
	
	function increment_ready(
		head_pointer, tail_pointer: in natural
	) return boolean
	is 
	begin
		if (head_pointer > tail_pointer) and (head_pointer - tail_pointer > 1) then
			return true;
		elsif (tail_pointer > head_pointer) and not (head_pointer = 0 and tail_pointer = (max_address - 1)) then
			return true;
		end if;
		return false;
	end function increment_ready;
	
begin
	tail_ptr <= tail;
	transition_function: process(state, end_transfer, tail, head_ptr) is
		begin
			case state is
				when wait_state => 
					--check tail and head distance
					if increment_ready(head_ptr, tail) then
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
	
	save_state: process(clock_50, reset) is
	begin
		if reset = '0' then
			state <= wait_state;
		elsif rising_edge(clock_50) then
			state <= next_state;
		end if;
	end process save_state;
	
	output_process: process(clock_50, reset) is
		begin 
		if reset = '0' then
			tail <= max_address - 1;					
		elsif rising_edge(clock_50) then			
			if state = increment_state then
				if tail = max_address - 1 then
					tail <= 0;
				else
					tail <= tail + 1;
				end if;
			end if;
		end if;
			
	end process output_process;
	
end architecture logic;
