library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.seven_segment_pkg.all;

entity seven_segment_agent is
	generic (
		lamp_mode: 		lamp_configuration := common_anode;
		decimal_support:	boolean := true;
		implementer: 		natural	:= 200;
		revision: 		natural	:= 0;
		signed_support: 	boolean	:= true;
		blank_zeros_support:	boolean	:= true
	);
	port (
		-- Input ports
		clk:		in	std_logic;
		reset_n:	in	std_logic;
		address:	in	std_logic_vector(1 downto 0);
		read:		in	std_logic;
		write:		in	std_logic;
		writedata:	in	std_logic_vector(31 downto 0);
		-- Output ports
		readdata:	out	std_logic_vector(31 downto 0);
		digits:		out 	std_logic_vector(41 downto 0)
	);
end entity seven_segment_agent;

architecture logic of seven_segment_agent is
	-- signals
	signal control: 	std_logic_vector(31 downto 0) := (others => '0');
	signal data: 		std_logic_vector(31 downto 0) := (others => '0');
	--signal features:	std_logic_vector(31 downto 0);
		
	-- get features function 
	function get_features
		return std_logic_vector
	is
		variable ret: std_logic_vector(31 downto 0);
	begin
		ret := (others => '0');
		ret(31 downto 24) := std_logic_vector(to_unsigned(implementer, 8));
		ret(23 downto 16) := std_logic_vector(to_unsigned(revision, 8));

		if lamp_mode = common_anode then
			ret(3) := '1';
		end if;
		
		if decimal_support then
			ret(0) := '1';
		end if;
		
		if blank_zeros_support then
			ret(2) := '1';
		end if;
		
		if signed_support then
			ret(1) := '1';
		end if;
		return ret;
	end function get_features;
	
	--double dabble function
	function to_bcd (
		data_value: in std_logic_vector(15 downto 0)
	) return std_logic_vector
	is
	variable ret: std_logic_vector(19 downto 0);
	variable temp: std_logic_vector(data_value'range);
	begin
		temp := data_value;
		ret := (others => '0');
		for i in data_value'range loop
			for j in 0 to ret'length/4 - 1 loop
				if unsigned(ret(4*j + 3 downto 4*j)) >= 5 then
					ret(4*j + 3 downto 4*j) :=
							std_logic_vector(
								unsigned(ret(4*j + 3 downto 4 * j)) + 3);
				end if;
			end loop;
			ret := ret(ret'high -1 downto 0) & temp(temp'high);
			temp := temp(temp'high - 1 downto 0) & '0';
		end loop;
		return ret;
	end function to_bcd;
	
	-- concatenation function
	function concat_function(
		config:		in		seven_segment_digit_array
	) return std_logic_vector
	is
		variable ret:	std_logic_vector(41 downto 0);
	begin
		for i in seven_segment_digit_array'range loop
			ret(7*i + 6 downto 7*i) := config(i).g & config(i).f & config(i).e &	config(i).d & config(i).c & config(i).b & config(i).a;
		end loop;

		return ret;
	end function concat_function;
	
	signal hex_digits: seven_segment_digit_array;
	constant outputs_off: seven_segment_digit_array
				:= ( others => lamps_off(lamp_mode) );
				
	signal data_to_driver:	std_logic_vector(31 downto 0);
	--
	type leading_zeros is array (seven_segment_digit_array'range) of boolean;
	signal have_seen_only_zeros: leading_zeros;

begin

	data_driver: process(data, control) is
		variable intermediate: std_logic_vector(15 downto 0);
		variable twos: signed(15 downto 0);
	begin
		if decimal_support and control(1) = '1' then
			if signed_support and control(3) = '1' and data(15) = '1' then
				twos := -signed(data(15 downto 0));
				intermediate := std_logic_vector(twos);
			else
				intermediate := data(15 downto 0);
			end if;
			data_to_driver(31 downto 20) <= (others => '0');
			data_to_driver(19 downto  0) <= to_bcd(intermediate(15 downto 0));
		else
			data_to_driver <= data;
		end if;
	end process data_driver;

	digits <= concat_function(hex_digits) when control(0) = '1'
				else concat_function(outputs_off);

	-- populate digits array
	assign_digit: for digit in seven_segment_digit_array'reverse_range generate
		constant high_bit: natural := 4 * digit + 3;
		constant low_bit:  natural := 4 * digit;
	begin
		process(control, data_to_driver, data, have_seen_only_zeros) is
		begin
			if decimal_support and signed_support and control(3) = '1'
						and digit = seven_segment_digit_array'high
						and data(15) = '1' and control(1) = '1' then
				-- only if we have decimal support, signed support
				-- we are showing negative decimal numbers, we are
				-- a negative number and we are on the leftmost lamp
				hex_digits(digit) <= lamps_negative(lamp_mode);
				have_seen_only_zeros(digit) <= true;
				
			elsif decimal_support and control(1) = '1'
						and digit = seven_segment_digit_array'high then
				-- only if we have decimal support, we are showing decimal numbers
				-- and we are the leftmost lamp
				hex_digits(digit) <= lamps_off(lamp_mode);
				have_seen_only_zeros(digit) <= true;

			elsif decimal_support and blank_zeros_support
						and control(2) = '1' and control(1) = '1'
						and digit > 0
						and digit < seven_segment_digit_array'high
						and have_seen_only_zeros(digit + 1)
						and data_to_driver(high_bit downto low_bit) = "0000" then
				-- blank leading zeros if needed
				hex_digits(digit) <= lamps_off(lamp_mode);
				have_seen_only_zeros(digit) <= true;

			else
				-- everything else
				have_seen_only_zeros(digit) <= false;
				hex_digits(digit) <= get_hex_digit(
												to_integer(
													unsigned(
														data_to_driver(high_bit downto low_bit)
													)
												), lamp_mode
											);
			end if;
		end process;
	end generate;

	-- Clock trigger
	change_trigger: process(clk) is
	begin
		if rising_edge(clk) then
			if reset_n = '0' then
				control <= (others => '0');
				data <= (others => '0');
			elsif read = '1' then
				case address is
					when "00" => readdata <= data;
					when "01" => readdata <= control;
					when "10" => readdata <= get_features;
					when "11" => readdata <= std_logic_vector(to_unsigned(16#41445335#, 32));
					when others => null;
				end case;
			elsif write = '1' then
				case address is
					when "00" => data <= writedata;
					when "01" => --control <= writedata;
							if decimal_support then
								control(1) <= writedata(1);
							end if;
							if decimal_support and signed_support then
								control(3) <= writedata(3);
							end if;
							if decimal_support and blank_zeros_support then
								control(2) <= writedata(2);
							end if;
							control(0) <= writedata(0);
					when others => null;
				end case;
			end if;
		
		end if;
	end process change_trigger;
end architecture logic;
