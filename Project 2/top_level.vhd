library ieee;
use ieee.std_logic_1164.all;

entity top_level is
	generic(
		lines:	natural range 0 to 479;
		pixels: natural range 0 to 639
	);
	port (
		reset:		in	std_logic;
		clock:		in	std_logic
	);
end entity top_level;

architecture arch1 of top_level is

begin

end architecture arch1;
