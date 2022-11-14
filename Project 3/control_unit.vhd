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
		iterations:	out 	natural
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

	for i in iterations downto 0 generate
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
	end generate;
end architecture logic; 
