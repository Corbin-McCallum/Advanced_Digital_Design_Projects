library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	generic(
		threshold:	ads_sfixed := to_ads_sfixed(4);
		lines:		natural range 0 to 479;
		pixels: 	natural range 0 to 479
	);
	port (
		-- Input ports
		done: 			in 	std_logic;
		iteration_count: 	in	std_logic;
		seed_limit:		in	std_logic;
		-- Output ports
		FPGA_clock:		out	std_logic;
		reset:			out	std_logic;
		wren:			out 	std_logic
	);
end entity control_unit;

architecture logic of control_unit is
	-- Type and signal decleration used for the control_unit
	type state_type is (reset_state, generate_next_seed, enable, store_result, done_state);
	signal state, next_state: state_type := reset;
	signal current_point: coordinate;
	signal seed: ads_complex;
begin

	transition_function: process(state, seed) is
		begin
			case state is
				when reset_state => 
					-- set reset = '0' then next state
						reset <= '0';
						next_state <= generate_next_seed;
					
				when generate_next_seed => 
					--check the seed limit first
					if (seed_limit = '0') then --haven't reached the seed limit
						next_state <= enable;
					else 
						next_state <= store_result;
					end if;
				when enable => 
					--check if computational unit is all done with iterations
					if done = '1'then
						next_state <= store_result;
					else
						--do something with fpga clock
						fpga_clock <= '1';
						next_state <= enable;
					end if;
				when store_result =>
					--if at the seed limit, set wren to 1 for ram to start storing computational data
					if (seed_limit = '1') then
						wren <= '1';
						next_state <= done_state;
					else --the seed limit hasn't been reached, next state is reset.
						next_state <= reset_state;
					end if;
				when done_state => next_state <= done_state;
				
			end case;
	end process transition_function;
end architecture logic; 
