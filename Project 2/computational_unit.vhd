library ieee;
use ieee.std_logic_1164.all;

entity computational_unit is
	generic(
		lines:	natural range 0 to 479;
		pixels: natural range 0 to 639
	);
	port (
		-- Input ports
		fpga_clock: 		in 	std_logic;
		reset:			in	std_logic;
		-- Output ports
		done:			out	std_logic;
		itteration_count:	out	std_logic
	);
end entity computational_unit;

architecture computation of computational_unit is

begin

end architecture computation;
