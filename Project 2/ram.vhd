library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
	generic (
		data_width: positive := 5;
		addr_Width: positive := 18
	);
	port (
		-- global
		clock:	std_logic;
		
		-- port A (write)
		addr_a:	std_logic_vector(addr_Width - 1 downto 0);
		wren:		std_logic;
		data_in_a:	std_logic_vector(data_width - 1 downto 0);
		
		-- port B (Read)
		addr_b: std_logic_vector(addr_Width - 1 downto 0);
		data_out_b:	std_logic_Vector(data_Width - 1 downto 0)
	);
end entity ram;

architecture rtl of ram is
	type storage_type is array(0 to 2**addr_width - 1)
			of std_logic_vector(data_width - 1 downto 0);
	shared variable storage: storage_type;
begin
	port_a: process(clock) is
	begin
		if wren = '1' then
			storage(to_integer(unsigned(addr_a))) <= data_in_a;
		end if;
	end process port_a;
	
	-- port b
	data_out_b <= storage(to_integer(unsigned(addr_b)));
end architecture rtl;
		