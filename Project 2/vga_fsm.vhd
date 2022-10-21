library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;

entity vga_fsm is
	generic (
		vga_res:	vga_timing := vga_res_default
	);
	port (
		vga_clock:		in	std_logic;
		reset:			in	std_logic;

		point:			out	coordinate;
		point_valid:	out	boolean;

		h_sync:			out	std_logic;
		v_sync:			out 	std_logic
	);
end entity vga_fsm;

architecture fsm of vga_fsm is
	signal reset:				std_logic;
	signal vga_clock: 		std_logic;
	
	signal hsync:				std_logic;
	signal vsync: 				std_logic;
	signal point_valid: 		std_logic_vector(1 downto 0);
begin
	sync_point: process(vga_clock,coordinate) is
	begin
		if vga_clock = '1' then 
			h_sync <= do_horizontal_sync(coordinate);
			v_sync <= do_vertical_sync(coordinate);
		else
			point <= next_coordinate(coordinate)
		end if;
	end process sync_point;
	
	check_point: process(coordinate) is
	begin
		if point_visible(coordinatecoordinate) = '1' then 
			point_valid <= 1;
		else
			point_valid <= 0;
		end if;
	end process check_point;

end architecture fsm;
