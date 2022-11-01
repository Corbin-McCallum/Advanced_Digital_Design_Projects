library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;

library ads;
use ads.ads_complex_pkg.all;
use ads.ads_fixed.all;

use work.netpbm_config.all;

entity mandelbrot_netpbm_generator is
end entity mandelbrot_netpbm_generator;

architecture test_fixture of mandelbrot_netpbm_generator is

	-- your mandelbrot computational engine here
	component computational_unit is
		generic(
			iterations: positive range 1 to 64:= 32;
			threshold:	ads_sfixed := to_ads_sfixed(4)
		);
		port (
			-- Input ports
			fpga_clock: 			in 	std_logic;
			reset:					in		std_logic;
			seed:						in		ads_complex; --complex #C
			-- Output ports
			done:						out	std_logic;
			iteration_count:		out	natural range 0 to iterations - 1
		);
	end component computational_unit;


	signal iteration_test: natural range 0 to iterations + 1;

	signal seed: ads_complex;
	signal clock: std_logic		:= '0';
	signal reset: std_logic		:= '0';
	signal enable: std_logic	:= '0';

	signal iteration_count: natural range 0 to iterations;
	signal output_valid: boolean;

	signal finished: boolean	:= false;

begin

	clock <= not clock after 1 ps when not finished else '0';

	generator:computational_unit
		generic map (
			iterations 			=> iterations,
			threshold			=> threshold
		)
		port map (
			fpga_clock			=> clock,
			reset 				=> reset,
			seed 					=> seed,
			done					=> done,
			iteration_count 	=> iteration_count
		);
	
	make_pgm: process
		variable x_coord: ads_sfixed;
		variable y_coord: ads_sfixed;
		variable output_line: line;
	begin
		-- header information
		---- P2
		write(output_line, string'("P2"));
		writeline(output, output_line);
		---- resolution
		write(output_line, integer'image(x_steps) & string'(" ")
				& integer'image(y_steps));
		writeline(output, output_line);
		---- maximum value
		write(output_line, integer'image(iterations - 1));
		writeline(output, output_line);

		-- from here onwards, stimulus depends on your implementation

		-- ensure generator is disabled
		enable <= '0';

		-- reset generator
		wait until rising_edge(clock);
		reset <= '1';
		wait until rising_edge(clock);
		reset <= '0';

		-- enable the generator
		enable <= '1';

		for i in 0 to iterations - 1 loop
			wait until rising_edge(clock);
			write(output_line, integer'image(iterations - 1 - iteration_count));
			writeline(output, output_line);
			flush(output);
		end loop;

		-- all done
		finished <= true;
		wait;
	end process make_pgm;

end architecture test_fixture;
