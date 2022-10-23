library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;

entity vga_fsm is
	generic (
		vga_res:	vga_timing := vga_res_default
	);
	port (
		-- Input ports
		vga_clock:		in	std_logic;
		reset:			in	std_logic;
		-- Output ports
		point:			out	coordinate;
		point_valid:	out	boolean;
		h_sync:			out	std_logic;
		v_sync:			out 	std_logic
	);
end entity vga_fsm;

architecture fsm of vga_fsm is
	signal current_point: corrdiante;
begin
	-- Process of handling resets and/or getting next corrdinate 
	count_pixel: process(vga_clock) is
	begin
		if rising_edge(vga_clock) then
			if reset = '0' then
				current_point <= make_coordinate(0,0);
			else
				current_point <= next_coordinate(current_point);
			end if;
		end if;
	end process count_pixel;
	
	-- Process to sync vga horizontal and vertical signals
	sync_point: process(vga_clock,current_point) is
	begin
		if rising_edge(vga_clock) then 
			h_sync <= do_horizontal_sync(current_point);
			v_sync <= do_vertical_sync(current_point);
		end if;
	end process sync_point;
	
	-- Process to set point valid true or flase
	check_point: process(current_point) is
	begin
		if point_visible(current_point) = '1' then 
			point_valid <= 1;
		else
			point_valid <= 0;
		end if;
	end process check_point;
end architecture fsm;
