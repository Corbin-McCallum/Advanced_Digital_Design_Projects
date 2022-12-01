library ieee;
use ieee.std_logic_vector_1164.all;

package project_pkg is

component adc_control is
	generic (
		max_address:	natural := 16
	);
	port (
		clock_10:	in	std_logic;
		tail_ptr:	in	natural range 0 to max_address - 1;
		reset:		in	std_logic;
		
		clock_1:	out	std_logic;
		
		write_en:	out 	std_logic;
		data_out:	out 	natural range 0 to 2**12 - 1;
		head_ptr:	out 	natural range 0 to max_address - 1
	);
end component adc_control;


component display_control is
	generic(
		max_address:	natural:= 16
	);
	port (
		-- Input
		clock_50:	in 	std_logic;
		head_ptr:	in 	natural range 0 to max_address - 1;
		reset:		in	std_logic;
		-- Output
		tail_ptr:	out	natural range 0 to max_address - 1
	);
end component display_control;


component true_dual_port_ram_dual_clock is

	generic 
	(
		DATA_WIDTH : natural := 8;
		ADDR_WIDTH : natural := 6
	);

	port 
	(
		clk_a	: 	in std_logic;
		clk_b	: 	in std_logic;
		addr_a: 	in natural range 0 to 2**ADDR_WIDTH - 1;
		addr_b: 	in natural range 0 to 2**ADDR_WIDTH - 1;
		data_a: 	in std_logic_vector((DATA_WIDTH-1) downto 0);
		data_b: 	in std_logic_vector((DATA_WIDTH-1) downto 0);
		we_a	: 	in std_logic := '1';
		we_b	: 	in std_logic := '1';
		q_a	: 	out std_logic_vector((DATA_WIDTH -1) downto 0);
		q_b	: 	out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end component true_dual_port_ram_dual_clock;

component two_stage_synchronizer is
	generic (
		input_width: positive := 16
	);
	port (
		data_in:	in 	std_logic_vector(input_width - 1 downto 0);
		clk_1:		in	std_logic;
		clk_2:		in 	std_logic;
		data_out:	out 	std_logic_vector(input_Width - 1 downto 0)
	);
end component two_stage_synchronizer;


end package project_pkg;
