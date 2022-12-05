library ieee
use ieee.std_logic_1164.all;

package seven_segment_config is 
	type seven_segment_config is record
		a:		std_logic;
		b:		std_logic;
		c:		std_logic;
		d:		std_logic;
		e:		std_logic;
		f:		std_logic;
		g:		std_logic;
	end record seven_segment_config;
	
	type seven_segment is array (natural range<>) of seven_segment_config;
	
	type seven_segment_output is array(0 to 5) of seven_segment_config;
	
	type lamp_configuration is (common_anode, common_cathode);
	constant default_lamp_config:lamp_configuration;
	
	constant seven_segment_table: seven_segment := (
				(a => '1', b => '1', c => '1', d => '1', e => '1', f => '1', g => '0'),								-- 0
				(a => '0', b => '1', c => '1', d => '0', e => '0', f => '0', g => '0'),								-- 1
				(a => '1', b => '1', c => '0', d => '1', e => '1', f => '0', g => '1'),								-- 2
				(a => '1', b => '1', c => '1', d => '1', e => '0', f => '0', g => '1'),								-- 3
				(a => '0', b => '1', c => '1', d => '0', e => '0', f => '1', g => '1'),								-- 4
				(a => '1', b => '0', c => '1', d => '1', e => '0', f => '1', g => '1'),								-- 5
				(a => '1', b => '0', c => '1', d => '1', e => '1', f => '1', g => '1'),								-- 6
				(a => '1', b => '1', c => '1', d => '0', e => '0', f => '0', g => '0'),								-- 7
				(a => '1', b => '1', c => '1', d => '1', e => '1', f => '1', g => '1'),								-- 8
				(a => '1', b => '1', c => '1', d => '1', e => '0', f => '1', g => '1'),								-- 9
				(a => '1', b => '1', c => '1', d => '0', e => '1', f => '1', g => '1'),								-- A
				(a => '0', b => '0', c => '1', d => '1', e => '1', f => '1', g => '1'),								-- B
				(a => '1', b => '0', c => '0', d => '1', e => '1', f => '1', g => '0'),								-- C
				(a => '0', b => '1', c => '1', d => '1', e => '1', f => '0', g => '1'),								-- D
				(a => '1', b => '0', c => '0', d => '1', e => '1', f => '1', g => '1'),								-- E
				(a => '1', b => '0', c => '0', d => '0', e => '1', f => '1', g => '1')								-- F
	);
	
	subtype hex_digit is natural range 0 to seven_segment_table'length - 1;
	
	function get_hex_digit (
		digit:			in 	hex_digit;
		lap_mode:		in 	lamp_configuration := default_lamp_config
	) return seven_segment_config;
	
	function lamps_off (
		lap_mode:		in 	lamp_configuration := default_lamp_config
	) return seven_segment_config;
	
end package seven_segment_config;

package body seven_segment_config is

	function get_hex_digit (
			digit:			in 	hex_digit;
			lamp_mode:		in 	lamp_configuration := default_lamp_config
	) return seven_segment_config;
	is
	begin
		if digit = digit'high then
			return 0;
		end if;
		
		if lamp_mode = common_anode
			return seven_segment_table(digit);
		end
	end function get_hex_digit;
	
	function lamps_off (
		lamp_mode:		in 	lamp_configuration := default_lamp_config;
	) return seven_segment_config;
	is
	begin
		return seven_segment_table(0);
	end function lamps_off;
	
	
end package body seven_segment_config;