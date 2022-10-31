library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	generic(
		threshold:	ads_sfixed := to_ads_sfixed(4);
		total_iterations = natural := 32 
	);
	port (
		-- Input ports
		reset:					in		std_logic;
		FPGA_clock:				in		std_logic;
		-- Output ports
		address:					out 	natural;
		iterations:				out 	natural;
		done:		 				out 	std_logic;
		wren:						out 	std_logic
	);
end entity control_unit;

architecture logic of control_unit is
	-- Type and signal decleration used for the control_unit
	type state_type is (reset_state, generate_next_seed, enable, store_result, done_state);
	signal computation_done: 
	signal state, next_state: state_type := reset;
	signal current_point: coordinate;
	signal seed: ads_complex;
begin

	transition_function: process(state, current_point, computation_done) is
		begin
			case state is
				when reset_state => 
						next_state <= generate_next_seed;
				when generate_next_seed => 
					--check the seed limit first
					if (current_point = '0') then --haven't reached the seed limit
						next_state <= enable;
					else 
						next_state <= store_result;
					end if;
				when enable => 
					--check if computational unit is all done with iterations
					if computation_done = '1'then
						next_state <= store_result;
					else
						next_state <= enable;
					end if;
				when store_result =>
					--if at the seed limit, set wren to 1 for ram to start storing computational data
					if (current_point = '1') then
						next_state <= done_state;
					else --the seed limit hasn't been reached, next state is reset.
						next_state <= reset_state;
					end if;
				when done_state => 
						next_state <= done_state;
			end case;
	end process transition_function;
	
	output_process: process(state) is
		begin
			case state is
				when reset_state => 
						reset <= '0';					
				when generate_next_seed => 
					
				when enable => 
					
				when store_result =>
				
			end case;
			
	end process output_process;
end architecture logic; 

