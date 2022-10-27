library ieee;
use ieee.std_logic_1164.all;

package project_pkg is
	---- component declarations
	component vga_fsm is
		generic (
			vga_res:	vga_timing := vga_res_default
		);
		port (
			-- Input ports
			FPGA_clock:		in	std_logic;
			reset:			in	std_logic;
			-- Output ports
			point:			out	coordinate;
			point_valid:		out	boolean;
			h_sync:			out	std_logic;
			v_sync:			out 	std_logic
		);
	end component vga_fsm;
	
	component control_unit is
		generic(
			threshold:	ads_sfixed := to_ads_sfixed(4);
			lines:		natural 	range 0 to 479;
			pixels: 	natural 	range 0 to 639
		);
		port (
			-- Input ports
			done: 			in 	std_logic;
			iteration_count: 	in	std_logic;
			-- Output ports
			FPGA_clock:		out	std_logic;
			reset:			out	std_logic;
			wren:			out 	std_logic
		);
	end component control_unit;
	
	component computational_unit is
		generic(
			iterations: positive range 1 to 64:= 32;
			threshold:	ads_sfixed := to_ads_sfixed(4)
		);
		port (
			-- Input ports
			fpga_clock: 			in 	std_logic;
			reset:				in	std_logic;
			seed:				in	ads_complex; --complex #C
			-- Output ports
			done:				out	std_logic;
			iteration_count:		out	natural range 0 to iterations - 1
		);
	end component computational_unit;

end package project_pkg;
