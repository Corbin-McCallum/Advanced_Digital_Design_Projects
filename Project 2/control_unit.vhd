library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	generic(
		threshold:	ads_sfixed := to_ads_sfixed(4);
		lines:	natural range 0 to 479;
		pixels: 	natural range 0 to 639
	);
	port (
		-- Input ports
		done: 			in 	std_logic;
		iteration_count: 	in		std_logic;
		-- Output ports
		FPGA_clock:		out	std_logic;
		reset:			out	std_logic;
		wren:			out std_logic
	);
end entity control_unit;

architecture logic of control_unit is

	type state_type is (reset_state, generate_next_seed, enable, store_result, done_state);
	signal state, next_state: state_type := reset;
	
	signal current_point: corrdiante;
	signal seed: ads_complex;
begin

	transition_function: process(state, seed) is
		begin
			case state is
				when reset_state => 
					if reset = '0' then
						next_state <= generate_next_seed;
					else
						next_state <= done_state;
					end if;
				when generate_next_seed => next_state <= enable;
				when enable => 
					if done = '1'then
						next_state <= done;
					else
						next_state <= store_result;
					end if;
				when store_result => next_state <=
				when done_state => next_state <= reset_state;
				
			end case;
	end process transition_function;
end architecture logic;
