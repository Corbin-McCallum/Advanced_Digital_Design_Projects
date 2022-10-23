library ieee;
use ieee.std_logic_1164.all;

entity computational_unit is
	-- Input ports
	fpga_clock: 			in 	std_logic;
	-- Output ports
	done:		out	std_logic;
	reset:			out	std_logic;
	wren:				out	std_logic
end entity computational_unit;

architecture computation of computational_unit is

begin

end architecture computation;