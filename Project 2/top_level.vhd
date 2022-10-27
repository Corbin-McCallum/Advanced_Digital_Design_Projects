library ieee;
use ieee.std_logic_1164.all;

library work;
use work.project_pkg.all;

entity top_level is
	generic(
		lines:	natural range 0 to 479;
		pixels: 	natural range 0 to 639
	);
	port (
		reset:		in	std_logic;
		clock:		in	std_logic
	);
end entity top_level;

architecture arch1 of top_level is

begin
	
	signal_driver:vga_fsm
		port map (
			-- Input ports
			FPGA_clock 		=> clock;
			reset 			=> reset
			-- Output ports
			point			=> point;
			point_valid		=> point_valid;
			h_sync			=> h_sync;
			v_sync			=> v_sync
		);

	control:control_unit
		generic map(
			threshold 		=> threshold;
			lines			=> lines;
			pixels 			=> pixels
		);
		port map(
			-- Input ports
			done			=> done;
			iteration_count		=> iteration_count;
			-- Output ports
			FPGA_clock		=> clock;
			reset			=> reset;
			wren			=> wren
		);
	mandalbrot_engine:computational_unit
		generic map(
			iterations		=> iterations;
			threshold		=> threshold
		);
		port map(
			-- Input ports
			fpga_clock		=> clock;
			reset			=> reset;
			seed			=> seed; --complex #C
			-- Output ports
			done			=> done;
			iteration_count		=> iteration_count
		);
end architecture arch1;
