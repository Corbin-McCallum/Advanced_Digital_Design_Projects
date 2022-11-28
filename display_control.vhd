library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library wysiwyg;
use wysiwyg.fiftyfivenm_components.all;

entity display_control is
	port (
		-- Input
		clock:			in	std_logic;
		binary_code:		in	std_logic;
		-- Output
		write_en:		out 	std_logic;
		data_out:		out 	natural range 0 to 2**12 - 1
	);
end entity display_control;

architecture logic of adc_control is
	
	type state_type is (wait_state, increment_state);

	signal state, next_state: 	state_type;
	signal start_transfer: 		std_logic;
	signal end_transfer:	 	std_logic;
	
begin

	transition_function: process(state, end_transfer) is
		begin
			case state is
				when wait_state => 
					--check if end of transfer is reached
					if end_transfer = '0' then
						next_state <= wait_state;
					else
						next_state <= increment_state;
					end if;
				when increment_state =>
					-- increment tail
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
		end if;
			
		if rising_edge(clock) then
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
