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
		c0:				in	std_logic; --clock input from pll
		reset:			in	std_logic;
		enable:			in boolean;
		--input from control_unit to vga_fsm
		
		-- Output ports
		point:			out	coordinate;
		point_valid:	out	boolean;
		h_sync:			out	std_logic;
		v_sync:			out 	std_logic
	);
end entity vga_fsm;

architecture fsm of vga_fsm is
	signal current_point: coordinate;
begin
	-- Process of handling resets and/or getting next corrdinate 
	count_pixel: process(c0) is
	begin
		if rising_edge(c0) then
			if reset = '0' then
				current_point <= make_coordinate(0,0);
			elsif enable then
				current_point <= next_coordinate(current_point, vga_res);
			end if;
		end if;
	end process count_pixel;
	
	-- Process to sync vga horizontal and vertical signals
	sync_point: process(c0) is
	begin
	
		if rising_edge(c0) then 
			h_sync <= do_horizontal_sync(current_point, vga_res);
			v_sync <= do_vertical_sync(current_point, vga_res);
		end if;
	end process sync_point;
	
	-- Process to set point valid true or flase
	check_point: process(c0) is
	begin
		if rising_edge(c0) then
			point <= current_point;
			point_valid <= point_visible(current_point, vga_res);
		end if;
	end process check_point;
end architecture fsm;