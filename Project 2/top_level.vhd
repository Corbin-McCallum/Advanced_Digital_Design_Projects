library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vga;
use vga.vga_data.all;

library ads;
use ads.ads_fixed.all;

entity top_level is
	generic(
		vga_res: vga_timing := vga_res_default;
		iterations: natural := 32;
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
	signal wren_signal: 		std_logic;

	signal point_signal:			coordinate;
	signal point_valid_signal:	boolean;
	
	signal write_address, read_address: natural;
	
	signal iteration_count:	natural range 0 to iterations - 1;
	signal iteration_read: std_logic_vector(4 downto 0);

	
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
			total_iterations:	natural := 32 
		);
		PORT
		(
			-- Input ports
			reset:		in		std_logic;
			fpga_clock:	in		std_logic;
			-- Output ports
			address:		out 	natural;
			iterations:	out 	natural;
			done:		 	out 	std_logic;
			wren:			out 	std_logic
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
			--input from control_unit to vga_fsm
		
			-- Output ports
			point:			out	coordinate;
			point_valid:	out	boolean;
			h_sync:			out	std_logic;
			v_sync:			out 	std_logic
		);
	end component;
	
	component ram
		generic (
			data_width: positive := 5;
			addr_Width: positive := 18
		);
		PORT
		(
			-- global
			clock:	in std_logic;
		
			-- port A (write)
			addr_a:	in std_logic_vector(addr_Width - 1 downto 0);
			wren:		in std_logic;
			data_in_a:	in std_logic_vector(data_width - 1 downto 0);
		
			-- port B (Read)
			addr_b: in std_logic_vector(addr_width - 1 downto 0);
			data_out_b:	out std_logic_Vector(data_width - 1 downto 0)
		);
	end component;
	
begin
	red <= to_integer(unsigned(iteration_read(4 downto 1))) when point_valid_signal
				else 0;
	green <= to_integer(unsigned(iteration_read(4 downto 1))) when point_valid_signal
				else 0;
	blue <= to_integer(unsigned(iteration_read(4 downto 1))) when point_valid_signal
				else 0;

	read_address <= point_signal.y * 480 + point_signal.x;
	
	pll0: pll
		port map(
			--input port
			inclk0	=> clock,
			--output port
			c0 		=> clock_signal
		);
		
	ram0: ram
		generic map (
			data_width => 5,
			addr_width => 18
		)
		port map(
			--input signals
			clock			=> clock_signal,
			wren			=> wren_signal,
			addr_a		=> std_logic_vector(to_unsigned(write_address, 18)),
			data_in_a 	=> std_logic_vector(to_unsigned(iteration_count, 5)),
			--output signals
			addr_b		=> std_logic_vector(to_unsigned(read_address, 18)),
			data_out_b	=> iteration_read
		);
		
	signal_driver:vga_fsm
		generic map (
			vga_res		=> vga_res_default
		)
		port map (
			-- Input ports
			c0 				=> clock_signal,
			reset 			=> reset,
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
			-- Output ports
			address				=> write_address,
			iterations			=> iteration_count,
			done		 			=> open,
			wren					=> wren_signal
		);
		
		

end architecture arch1;
