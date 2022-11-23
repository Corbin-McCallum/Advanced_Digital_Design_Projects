library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.seven_segment_pkg.all;

entity toplevel is
	generic (
		lamp_mode: lamp_configuration := default_lamp_config
	);
	port (
		clock_50:	in	std_logic;
		reset:		in	std_logic;
		
		hex_digits:	out seven_segment_digit_array
	);
end entity toplevel;

architecture top of toplevel is
	signal counter: unsigned(29 downto 0);
begin

	assign_digit: for digit in seven_segment_digit_array'range generate
		constant high_bit: natural := counter'high - 4*(5 - digit);
		constant low_bit: natural := high_bit - 3;
	begin
		hex_digits(digit) <= get_hex_digit(to_integer(counter(high_bit downto low_bit)), lamp_mode);
	end generate;
	
	count: process(clock_50, reset) is
	begin
		if reset = '0' then
			counter <= (others => '0');
		elsif rising_edge(clock_50) then
			counter <= counter + "1";
		end if;
	end process count;

end architecture top;