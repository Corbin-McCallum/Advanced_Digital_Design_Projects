library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.seven_segment_pkg.all;

entity toplevel is
	generic (
		lamp_mode: lamp_configuration := default_lamp_config;
		address_width: natural := 6
	);
	port (
		clock_50:	in	std_logic;
		clock_10:	in 	std_logic;
		reset:		in	std_logic;
		
		hex_digits:	out 	seven_segment_digit_array
	);
end entity toplevel;

architecture top of toplevel is
	constant max_address: natural := 2**address_width;
	
	signal head_ptr_1, tail_ptr_1: natural range 0 to max_address - 1;
	signal head_ptr_50, tail_ptr_50: natural range 0 to max_address - 1;
	-- signal binary_out: 			std_logic;
	-- signal binary_in: 			std_logic;
	-- signal input_width_signal: positive := 16;
	-- signal gray_in_signal: 		std_logic_vector(input_width - 1 downto 0);
	
	
begin

	assign_digit: for digit in seven_segment_digit_array'range generate
		constant high_bit: natural := counter'high - 4*(5 - digit);
		constant low_bit:  natural := high_bit - 3;
	begin
		hex_digits(digit) <= get_hex_digit(to_integer(counter(high_bit downto low_bit)), lamp_mode);
	end generate;
	
	
	ac0: adc_control
		generic map(
			max_address 	=> max_address
		);
		port map(
			clock_10 	=> clock_10,
			clock_1  	=> clock_1,
			tail_ptr 	=> tail_ptr_1,
			reset	 	=> reset,
		
			write_en 	=> write_en,
			data_out 	=> data_out,
			head_ptr 	=> head_ptr_1
		);
		
	dc0: display_control
		generic map(
			max_address => max_address
		);
		port map(
			-- Input
			clock_50	=> clock_50 ,
			head_ptr	=> head_ptr_50,
			reset		=> reset,
			-- Output
			tail_ptr	=> tail_ptr_50
		);
	
	b0: true_dual_port_ram_dual_clock
		generic map
		(
			DATA_WIDTH 	=> address_width,
			ADDR_WIDTH 	=> addr_width_signal
		);

		port map
		(
			clk_a		=> clock_1,
			clk_b		=> clock_50,
			addr_a		=> head_ptr_1,
			addr_b		=> tail_ptr_50,
			data_a		=> data_out,
			data_b		=> (others => '0'),
			we_a		=> write_en,
			we_b		=> '0',
			q_a		=> open,
			q_b		=> data_out
		);
		
	tss0: two_stage_synchronizer
		generic (
			input_width	=> input_width
		);
		port (
			data_in:	=> head_ptr_1,
			clk_1:		=> clock_1,
			clk_2:		=> clock_50,
			data_out:	=> head_ptr_50
		);
		
	tss1: two_stage_synchronizer
		generic (
			input_width	=> input_width
		);
		port (
			data_in:	=> tail_ptr_50,
			clk_1:		=> clock_50,
			clk_2:		=> clock_1,
			data_out:	=> tail_ptr_1
		);


end architecture top;
