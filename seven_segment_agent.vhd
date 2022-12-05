library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.seven_segment_config.all;

entity seven_segment_agent is
	generic (
		lamp_mode: 		lamp_configuration;
		decimal_support:	boolean;
		implementer: 		natural;
		revision: 		natural
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
	-- functions
	function: concat_function(
		config:		in	seven_segment_output;
	) return std_logic_vector
	is
		variable ret:	std_logic_vector(41 downto 0);
	begin
		for i in seven_segment_output'range loop
			ret(7*i + 6 downto 7*i) := config(i).g & config(i).f & config(i).e &	config(i).d & config(i).c & config(i).b & config(i).a;
		end loop;
		return ret;
	end concat_function;
begin

	-- Clock trigger
	change_trigger: process(clk) is
	begin
		if rising_edge(clk) then
			if reset_n = '1' then
				control 	<= '0';
				data 		<= '0';
			end if;
		else
		
		end if;
	end process change_trigger;
end architecture;
