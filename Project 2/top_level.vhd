library ieee;
use ieee.std_logic_1164.all;

library work;
use work.project_pkg.all;

library vga;
use vga.vga_data.all;

library ads;
use ads.ads_fixed.all;

entity top_level is
	generic(
		lines:		natural range 0 to 479;
		pixels: 	natural range 0 to 639
	);
	port (
		reset:		in	std_logic;
		clock:		in	std_logic
	);
end entity top_level;

architecture arch1 of top_level is
	constant threshold: 			ads_sfixed := to_ads_sfixed(4);
	constant iterations: 			positive range 1 to 64:= 32;
	constant stages:			natural := 3;
	signal clock_signal: 			std_logic;
	signal reset_signal: 			std_logic;
	signal wren_signal: 			std_logic;
	signal seed_signal: 			ads_complex;
	signal iteration_count_signal_1: 	natural range 0 to iterations - 1;
	signal iteration_count_signal_2:	std_logic;
	signal done_signal: 			std_logic;
	signal point_signal:			std_logic;
	signal point_valid_signal:		boolean;
	signal v_sync_signal:			std_logic;
	signal h_sync_signal:			std_logic;
begin
	
	signal_driver:vga_fsm
		port map (
			-- Input ports
			FPGA_clock 		=> clock_signal,
			reset 			=> reset_signal,
			-- Output ports
			point			=> point_signal,
			point_valid		=> point_valid_signal,
			h_sync			=> h_sync_signal,
			v_sync			=> v_sync_signal
		);

	control:control_unit
		generic map(
			threshold 		=> threshold,
			lines			=> lines,
			pixels 			=> pixels
		)		
		port map(
			-- Input ports
			done			=> done_signal,
			iteration_count		=> iteration_count_signal_2,
			-- Output ports
			FPGA_clock		=> clock_signal,
			reset			=> reset_signal,
			wren			=> wren_signal
		);
		
	mandalbrot_engine:computational_unit
		generic map(
			iterations		=> iterations,
			threshold		=> threshold
		)
		port map(
			-- Input ports
			fpga_clock		=> clock_signal,
			reset			=> reset_signal,
			seed			=> seed_signal, --complex #C
			-- Output ports
			done			=> done_signal,
			iteration_count		=> iteration_count_signal_1
		);
		
	sync:synchronizer
		generic map(
			stages			=> stages
		)
		port map(
			clock			=> clock_signal,
			reset			=> reset_signal,
			data_in			=> point_signal,
			data_out		=> data_out
		);
end architecture arch1;
