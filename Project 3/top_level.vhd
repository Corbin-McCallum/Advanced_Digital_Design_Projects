library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vga;
use vga.vga_data.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

use work.seed_table.all;

entity top_level is
	generic(
		vga_res: vga_timing := vga_res_default;
		iterations: natural := 16;
		threshold: ads_sfixed := to_ads_sfixed(4)
	);
	port (
		reset:	in		std_logic;
		clock:	in		std_logic;
		
		h_sync:	out 	std_logic;
		v_sync:	out 	std_logic;
		red:		out 	natural range 0 to 15;
		blue:		out 	natural range 0 to 15;
		green:  	out 	natural range 0 to 15
		);
end entity top_level;

architecture arch1 of top_level is
	signal clock_signal: 	std_logic;
	
	signal point_signal:			coordinate;
	signal point_valid_signal:	boolean;
	
	signal write_address, read_address: natural;
	
	signal iteration_count:	natural range 0 to iterations - 1;
	signal iteration_read: std_logic_vector(4 downto 0);
	
	signal enable_vga: boolean;
	
	signal seed_index: seed_index_type;

	
	component pll
		PORT
		(
			inclk0: 		IN STD_LOGIC  := '0';
			c0		: 		OUT STD_LOGIC 
		);
	end component;
	
	component control_unit
		generic (
			threshold:		ads_sfixed := to_ads_sfixed(4);
			total_iterations:	natural := 16 
		);
		PORT
		(
			-- Input ports
			reset:		in		std_logic;
			fpga_clock:	in		std_logic;
			c_value:		in		ads_complex;
			-- Output ports
			iterations:	out 	natural;
			start_vga:	out	boolean
		);
	end component;
	
	component vga_fsm
		generic (
			vga_res:	vga_timing := vga_res_default

		);
		PORT
		(
			-- Input ports
			c0:				in	std_logic; --clock input from pll
			reset:			in	std_logic;
			enable:			in boolean;
			--input from control_unit to vga_fsm
		
			-- Output ports
			point:			out	coordinate;
			point_valid:	out	boolean;
			h_sync:			out	std_logic;
			v_sync:			out 	std_logic
		);
	end component;
	
		
begin
--	red <= to_integer(unsigned(iteration_read(4 downto 1))) when point_valid_signal
--				else 0;
--	green <= to_integer(unsigned(iteration_read(4 downto 1))) when point_valid_signal
--				else 0;
--	blue <= to_integer(unsigned(iteration_read(4 downto 1))) when point_valid_signal
--				else 0;

	gen_seed_index: process(clock_signal) is
	begin
		if rising_edge(clock_signal) then
			if reset = '0' then
				seed_index <= 0;
			elsif (point_signal.x = vga_res.horizontal.active)
						and (point_signal.y = vga_res.vertical.active) then
				seed_index <= get_next_seed_index(seed_index);
			end if;
		end if;
	end process gen_seed_index;

	red <= iteration_count when point_valid_signal else 0;
	blue <= 0;
	green <= 0;

	--read_address <= point_signal.y * 480 + point_signal.x;
	
	pll0: pll
		port map(
			--input port
			inclk0	=> clock,
			--output port
			c0 		=> clock_signal
		);
		
		
	signal_driver:vga_fsm
		generic map (
			vga_res		=> vga_res_default
		)
		port map (
			-- Input ports
			c0 				=> clock_signal,
			reset 			=> reset,
			enable			=> enable_vga,
			-- Output ports
			point				=> point_signal,
			point_valid		=> point_valid_signal,
			h_sync			=> h_sync,
			v_sync			=> v_sync
		);

	control:control_unit
		generic map(
			threshold			=> threshold,
			total_iterations	=> iterations
		)		
		port map(
			reset					=> reset,
			fpga_clock			=> clock_signal,
			c_value				=> seed_rom(seed_index), -- ( re => to_ads_sfixed(-0.3), im => to_ads_sfixed(0.6) ),
			-- Output ports
			iterations			=> iteration_count,
			start_vga			=> enable_Vga
		);
		
		

end architecture arch1;