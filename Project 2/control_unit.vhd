library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	generic(
		threshold:		ads_sfixed := to_ads_sfixed(4);
		total_iterations:	natural := 32 
	);
	port (
		-- Input ports
		reset:			in	std_logic;
		fpga_clock:		in	std_logic;
		-- Output ports
		address:		out 	natural;
		iterations:		out 	natural;
		done:		 	out 	std_logic;
		wren:			out 	std_logic
	);
end entity control_unit;

architecture logic of control_unit is
	-- Type and signal decleration used for the control_unit
	type state_type is (reset_state, generate_next_seed, enable, store_result, done_state);
	signal computation_done: std_logic;
	signal state, next_state: state_type := reset;
	signal current_point: coordinate;
	signal enable_computation: std_logic;
	signal seed: ads_complex;
begin

	transition_function: process(state, current_point, computation_done) is
		begin
			case state is
				when reset_state => 
						next_state <= generate_next_seed;
				when generate_next_seed => 
						next_state <= enable;
				when enable => 
					--check if computational unit is all done with iterations
					if computation_done = '1' then
						next_state <= store_result;
					else
						next_state <= enable;
					end if;
				when store_result =>
					--if at the seed limit, set wren to 1 for ram to start storing computational data
					if (current_point.x = 479 and current_point.y = 479) then
						next_state <= done_state;
					else --the seed limit hasn't been reached, next state is reset.
						next_state <= reset_state;
					end if;
				when done_state => 
						next_state <= done_state;
			end case;
	end process transition_function;
	
	save_state: process(fpga_clock) is
		begin
			-- check for edge of clock, add reset logic
			if rising_edge(fpga_clock) then
				if reset = '0' then
					state <= reset_state;
				else
					state <= next_state;
				end if;
			end if;
	end process save_state;
				
	output_process: process(fpga_clock) is
		begin -- add reset logic
			if rising_edge(fpga_clock) then
				if state = reset_state then
					reset <= '0';
				else
					reset <= '1';
				end if;

				if state = generate_next_seed then
					current_point <= ---
				else
					current_poimt <= current_point;
				end if;

				if state = enable then
					enable_computation <= '1';
				else
					enable_computation <= '0';
				end if;

				if state = store_result then
					wren <= '1';
				else
					wren <= '0';
				end if;
			end if;
	end process output_process;
end architecture logic; 

