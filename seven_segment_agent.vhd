library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.seven_segment_config.all;

entity seven_segment_agent is
	generic (
		lamp_mode: 			lamp_configuration;
		decimal_support:		boolean;
		implementer: 			natural	:= 200;
		revision: 			natural	:= 0;
		signed_support: 		boolean;
		blank_zeros_support	boolean
	);
	port (
		-- Input ports
		clk:			in	std_logic;
		reset_n:		in	std_logic;
		address:		in	std_logic_vector(1 downto 0);
		read:			in	std_logic;
		write:			in	std_logic;
		writedata:		in	std_logic_vector(31 downto 0);
		-- Output ports
		readdata:		out	std_logic_vector(31 downto 0);
		lamps:			out 	std_logic_vector(41 downto 0)
	);
end entity seven_segment_agent;

architecture logic of seven_segment_agent is
	-- signals
	signal control: 	std_logic_vector(31 downto 0);
	signal data: 		std_logic_vector(31 downto 0);
	signal features:	std_logic_vector(31 downto 0);
	-- procedures
	procedure get_features
		return std_logic_vector
	is
		variable ret: std_logic_vector(31 downto 0);
	begin
		ret := (others => '0');
		ret(31 downto 24) := std_logic_vector(to_unsigned(implementer, 8));
		ret(23 downto 16) := std_logic_vector(to_unsigned(revision, 8));

		if lamp_mode = common_anode then
			ret(3) = '1';
		end if;
		
		if decimal_support then
			ret(0) = '1';
		end if;
		
		if blank_zeros_support then
			ret(2) = '1';
		end if;
		return ret;
	end procedure get_features;
	-- functions
	function concat_function(
		config:		in	seven_segment_output
	) return std_logic_vector
	is
		variable ret:	std_logic_vector(41 downto 0);
	begin
		for i in seven_segment_output'range loop
			ret(7*i + 6 downto 7*i) := config(i).g & config(i).f & config(i).e &	config(i).d & config(i).c & config(i).b & config(i).a;
		end loop;

		return ret;
	end function concat_function;
begin

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
				end case;
			elsif write = '1' then
				case address is
					when "00" => writedata <= data;
					when "01" => writedata <= control;
					when others => null;
				end case;
			end if;
		
		end if;
	end process change_trigger;
end architecture logic;
