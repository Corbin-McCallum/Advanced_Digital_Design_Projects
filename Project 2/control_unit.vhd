library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	generic(
		lines:	natural 	range 	0 to 479;
		pixels: natural 	range 	0 to 639;
	);
	port (
		-- Input ports
		done: 			in 	std_logic;
		-- Output ports
		FPGA_clock:		out	std_logic;
		reset:			out	std_logic;
		wren:			out	std_logic
	);
end entity control_unit;

architecture logic of control_unit is
	signal current_point: corrdiante;
begin

end architecture logic;
