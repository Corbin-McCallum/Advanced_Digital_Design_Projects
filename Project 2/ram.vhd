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
		clock:	in std_logic;
		
		-- port A (write)
		addr_a:	in std_logic_vector(addr_Width - 1 downto 0);
		wren:		in std_logic;
		data_in_a:	in std_logic_vector(data_width - 1 downto 0);
		
		-- port B (Read)
		addr_b: in std_logic_vector(addr_Width - 1 downto 0);
		data_out_b:	out std_logic_Vector(data_Width - 1 downto 0)
	);
end entity ram;

architecture rtl of ram is
	type storage_type is array(0 to 2**addr_width - 1)
			of std_logic_vector(data_width - 1 downto 0);
	shared variable storage: storage_type;
begin
	port_a: process(clock) is
	begin
		if rising_edge(clock) then
			if wren = '1' then
				storage(to_integer(unsigned(addr_a))) := data_in_a;
			end if;
		end if;
	end process port_a;
	
	-- port b
	port_b: process(clock, addr_b) is
	begin
		if rising_edge(clock) then
			data_out_b <= storage(to_integer(unsigned(addr_b)));
		end if;
	end process port_b;
end architecture rtl;


