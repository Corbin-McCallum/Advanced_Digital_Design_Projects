library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

library vga;
use vga.vga_data.all;

entity control_unit is
	generic(
		threshold:		ads_sfixed := to_ads_sfixed(4);
		total_iterations:	natural := 32 
	);
	port (
		-- Input ports
		reset:		in	std_logic;
		fpga_clock:	in	std_logic;
		-- Output ports
		address:	out 	natural;
		iterations:	out 	natural;
		done:		out 	std_logic;
		wren:		out 	std_logic
	);
end entity control_unit;

architecture logic of control_unit is
	-- components
	component computational_unit is
		generic(
			iterations: positive range 1 to 64:= 32;
			threshold:	ads_sfixed := to_ads_sfixed(4)
		);
		port (
			-- Input ports
			fpga_clock: 		in 	std_logic;
			reset:			in	std_logic;
			enable:			in	std_logic;
			seed:			in	ads_complex; --complex #C
			-- Output ports
			done:			out	std_logic;
			iteration_count:	out	natural range 0 to iterations - 1
		);
	end component computational_unit;

	-- Type and signal decleration used for the control_unit
	type state_type is (
			reset_state, generate_next_seed,
			enable, store_result, done_state);

	signal state, next_state: state_type := reset_state;

	signal computation_enable: std_logic;
	signal computation_reset: std_logic;
	signal computation_done: std_logic;
	
	signal current_point: coordinate;
	signal seed: ads_complex;
	
	constant delta: ads_sfixed := to_ads_sfixed(real(1)/real(120));
	
begin
	
	seed <= ads_cmplx(
				to_ads_sfixed(current_point.x) * delta - to_ads_sfixed(2),
				to_ads_sfixed(2) - to_ads_sfixed(current_point.y) * delta
			);
	address <= 480 * current_point.y + current_point.x;

	cu0: computational_unit
		generic map (
			iterations 	=> total_iterations,
			threshold	=> threshold
		)
		port map (
			fpga_clock 	=> fpga_clock,
			reset 		=> computation_reset,
			enable 		=> computation_enable,
			seed 		=> seed,
			done		=> computation_done,
			iteration_count => iterations
		);

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
				
	output_process: process(fpga_clock, reset) is
		begin -- add reset logic
			if reset = '0' then
				computation_reset <= '1';
				current_point <= ( x=> 0, y => 0 );
				computation_enable <= '0';
				wren <= '0';
				done <= '0';				
			elsif rising_edge(fpga_clock) then
				if state = reset_state then
					computation_reset <= '0';
				else
					computation_reset <= '1';
				end if;

				if state = generate_next_seed then
					if current_point.x < 479 then
						current_point.x <= current_point.x + 1;
					else
						current_point.x <= 0;
						current_point.y <= current_point.y + 1;
					end if;
				else
					current_point <= current_point;
				end if;
				
				
				if state = enable then
					computation_enable <= '1';
				else
					computation_enable <= '0';
				end if;

				if state = store_result then
					wren <= '1';
				else
					wren <= '0';
				end if;
				
				if state = done_state then
					done <= '1';
				else
					done <= '0';
				end if;
			end if;
	end process output_process;
	
	
end architecture logic; 
