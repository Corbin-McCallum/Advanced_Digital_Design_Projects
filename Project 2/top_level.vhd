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
	
	signal_driver: vga_fsm
	port map (
		-- Input ports
		FPGA_clock 		=> clock;
		reset 			=> reset
		-- Output ports
		point			=> ;
		point_valid		=> ;
		h_sync			=> ;
		v_sync			=>
	);

	control:control_unit
	generic map(
		threshold 		=> threshold;
		lines			=> ;
		pixels 			=>
	);
	port map(
		-- Input ports
		done			=> ;
		iteration_count		=> ;
		-- Output ports
		FPGA_clock		=> ;
		reset			=> ;
		wren			=>
	);

end architecture arch1;
