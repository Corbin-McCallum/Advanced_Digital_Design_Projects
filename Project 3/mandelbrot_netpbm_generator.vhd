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
	component control_unit is
		generic(
			threshold:		ads_sfixed := to_ads_sfixed(4);
			total_iterations:	natural := 32 
		);
		port (
			-- Input ports
			reset:		in		std_logic;
			fpga_clock:	in		std_logic;
			-- Output ports
			address:		out 	natural;
			iterations:	out 	natural;
			done:		 	out 	std_logic;
			wren:			out 	std_logic
		);
	end component control_unit;


	signal iteration_test: natural range 0 to iterations + 1;

	signal seed: ads_complex;
	signal clock: std_logic		:= '0';
	signal reset: std_logic		:= '0';
	signal enable: std_logic	:= '0';

	signal done: std_logic;
	signal iteration_count: natural;
	signal wren: std_logic;

	signal finished: boolean	:= false;

begin

	clock <= not clock after 1 ps when not finished else '0';

	generator:control_unit
		generic map (
			total_iterations 	=> iterations,
			threshold			=> escape
		)
		port map (
			fpga_clock			=> clock,
			reset 				=> reset,
			address				=> open,
			done					=> done,
			iterations		 	=> iteration_count,
			wren					=> wren
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
		write(output_line, string'("480 480"));
		writeline(output, output_line);
		---- maximum value
		write(output_line, integer'image(iterations - 1));
		writeline(output, output_line);

		-- from here onwards, stimulus depends on your implementation

		-- reset generator
		wait until rising_edge(clock);
		reset <= '0';
		wait until rising_edge(clock);
		reset <= '1';

		
		while done = '0' loop
			wait until rising_edge(clock);
			if wren = '1' then
				write(output_line, integer'image(iterations - iteration_count - 1));
				writeline(output, output_line);
			end if;
		end loop;
		
		-- all done
		finished <= true;
		wait;
	end process make_pgm;

end architecture test_fixture;