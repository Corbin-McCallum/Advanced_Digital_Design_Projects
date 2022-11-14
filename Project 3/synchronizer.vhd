library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is
	generic (
		stages: natural := 3
	);
	port (
		clock:	 in	std_logic;
		reset:	 in	std_logic;
		data_in:  in 	std_logic;
		data_out: out std_logic
	);
end entity synchronizer;

architecture shift of synchronizer is
	signal storage: std_logic_vector(stages - 1 downto 0);
begin
	data_out <= storage(stages - 1);

	sreg: process(clock) is
	begin
		if rising_edge(clock) then
			if reset = '0' then
				storage <= (others => '0');
			else
				storage <= storage(stages - 2 downto 0) & data_in;
			end if;
		end if;
	end process sreg;

end architecture shift;