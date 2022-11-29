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
		
		hex_digits:	out 	seven_segment_digit_array
	);
end entity toplevel;

architecture top of toplevel is
	signal counter: 	unsigned(29 downto 0);
	signal binary_out: 	std_logic;
	signal binary_in: 	std_logic;
begin

	assign_digit: for digit in seven_segment_digit_array'range generate
		constant high_bit: natural := counter'high - 4*(5 - digit);
		constant low_bit:  natural := high_bit - 3;
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
	
	ma0: max10_adc
		port map (
			pll_clk 		=> clock_10,
			chsel   		=> '0',
			soc	  		=> start_conversion,
			tsen	  		=> '1' ,
			dout	  		=> data_out,
			eoc	  		=> end_conversion,
			clk_dft 		=> clock_1
		);
	
	ac0: adc_control
		generic map(
			max_address 		=>
		);
		port map (
			clock_10 		=> clock_10,
			clock_1  		=> clock_1,
			tail_ptr 		=> ,
			reset			=> ,
		
			write_en 		=> ,
			data_out 		=> ,
			head_ptr 		=>
		);
		
	dc0: display_control
		generic map(
			max_address =>
		);
		port map(
			-- Input
			clock_50		=> clock_50 ,
			head_ptr		=> ,
			reset			=> ,
			-- Output
			write_en		=> ,
			tail_ptr		=> ,
			data_out		=> 
		);
	
	b0: buffer
		generic map
		(
			DATA_WIDTH 		=> ,
			ADDR_WIDTH 		=> 
		);

		port map
		(
			clk_a			=> clock_1,
			clk_b			=> clock_50,
			addr_a			=> ,
			addr_b			=> ,
			data_a			=> ,
			data_b			=> ,
			we_a			=> ,
			we_b			=> ,
			q_a			=> ,
			q_b			=> 
		);
		
	gtb0: gray_to_binary
		generic map(
			input_width		=>
		);
		port map(
			gray_in			=> ,
			bin_out			=> binary_out
		);
		
	btg0: binary_to_gray
		generic map(
			input_width		=>
		);
		port map(
			bin_in			=> binary_in,
			gray_out		=>
		);
	

end architecture top;
