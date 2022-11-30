library ieee;
use ieee.std_logic_1164.all;

entity two_stage_synchronizer is
	generic (
		input_width: positive := 16
	);
	port (
		data_in:	in 	std_logic_vector(input_width - 1 downto 0);
		clk_1:		in	std_logic;
		clk_2:		in 	std_logic;
		data_out:	out 	std_logic_vector(input_Width - 1 downto 0)
	);
end entity two_stage_synchronizer;
	
architecture logic of two_stage_synchronizer is
	component binary_to_gray is
		generic (
			input_width: positive := 16
		);
		port (
			bin_in: in std_logic_vector(input_width - 1 downto 0);
			gray_out: out std_logic_vector(input_width - 1 downto 0)
		);
	end component binary_to_gray;
	
	component gray_to_binary is
		generic (
			input_width: positive := 16
		);
		port (
			gray_in: in std_logic_vector(input_width - 1 downto 0);
			bin_out: out std_logic_vector(input_width - 1 downto 0)
		);
	end component gray_to_binary;
	
	signal btg_signal: 		std_logic_vector(input_width -1 downto 0);
	signal btg_clk_1_signal:	std_logic_vector(input_width -1 downto 0);
	signal btg_clk_2_signal: 	std_logic_vector(input_width -1 downto 0);
	signal gtb_signal:		std_logic_vector(input_width -1 downto 0);
begin
	
	b2g: bin_to_gray
			generic map (
				input_width 	=> input_width
			)
			port map (
				bin_in		=> data_in,
				gray_out	=> btg_signal 
			);
			
	g2b: gray_to_bin
			generic map(
				input_width 	=> input_width
			)
			port map(
				gray_in 	=> gtb_signal,
				bin_out 	=> data_out
			);
			
	s1: process(clk_1) is
	begin
		if rising_edge(clk_1) then
			btg_clk_1_signal <= btg_signal;
		end if;
	end process s1;
	
	s2: process(clk_2) is
	begin
		if rising_edge(clk_2) then
			btg_clk_2_signal <= btg_clk_1_signal;
		end if;
	end process s2;
		
	s3: process(clk_2) is
	begin
		if rising_edge(clk_2) then
			gtb_signal <= btg_clk_2_signal;
		end if;
	end process s3;
	
	
end architecture logic;
	
