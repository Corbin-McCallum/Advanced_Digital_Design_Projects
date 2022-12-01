library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library wysiwyg;
use wysiwyg.fiftyfivenm_components.all;

entity adc_control is
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
end entity adc_control;

architecture logic of adc_control is
	
	component pll
		port (
			inclk0:	in	std_logic := '0';
			c0:	out 	std_logic 
		);
	end component;
	
	component max10_adc is
			port(
				pll_clk:	in	std_logic;
				chsel:		in	natural range 0 to 2**5 - 1;
				soc:		in	std_logic;
				tsen:		in	std_logic;
				dout:		out	natural range 0 to 2**12 - 1;
				eoc:		out	std_logic;
				clk_dft:	out	std_logic
			);
	end component max10_adc;
	
	type state_type is (
			idle_state, start_state, wait_state, write_state, data_out_state);
	signal pll_clock_out: std_logic;
	signal clk_dft: std_logic;
	signal head: natural range 0 to max_address - 1;
	signal state, next_state: state_type;
	signal start_conversion: std_logic;
	signal end_conversion:	 std_logic;
	
	function increment_ready(
		head_pointer, tail_pointer: in natural
	) return boolean
	is 
	begin
		if (head_pointer > tail_pointer) and not (head_pointer = (max_address - 1) and tail_pointer = 0) then
			return true;
		elsif (tail_pointer > head_pointer) and (tail_pointer - head_pointer > 1) then
			return true;
		end if;
		return false;
	end function increment_ready;
	
begin
	clock_1 <= clk_dft;
	head_ptr <= head;

	pll0: pll
		port map (
			inclk0	=> clock_10,
			c0			=> pll_clock_out
		);
	
	ma0: max10_adc
		port map (
			pll_clk => pll_clock_out,
			chsel   => 0,
			soc	=> start_conversion,
			tsen	=> '1' ,
			dout	=> data_out,
			eoc	=> end_conversion,
			clk_dft => clk_dft
		);
		
	transition_function: process(state, end_conversion, head, tail_ptr) is
		begin
			case state is
				when idle_state => 
						next_state <= start_state;
				when start_state => 
						next_state <= wait_state;
				when wait_state => 
					--check if end of conversion is reached
					if end_conversion = '1' then
						next_state <= write_state;
					else
						next_state <= wait_state;
					end if;
				when write_state =>
					if increment_ready(head, tail_ptr) then
						next_state <= data_out_state;
					else 
						next_state <= write_state;
					end if;
				when data_out_state =>
					next_state <= idle_state;
				when others =>
					next_state <= idle_state;
				
			end case;
	end process transition_function;
	
	save_state: process(clk_dft, reset) is
	begin
		if reset = '0' then
			state <= idle_state;
		elsif rising_edge(clk_dft) then
			state <= next_state;
		end if;
	end process save_state;
	
	output_process: process(clk_dft, reset) is
		begin
			if reset = '0' then
				head <= 0;
				-- init other control signals here
			elsif rising_edge(clk_dft) then
				if state = start_state or state = wait_state then
					start_conversion <= '1';
				else
					start_conversion <= '0';
				end if;
				
				if state = data_out_state then
					if head = max_address - 1 then
						head <= 0;
					else
						head <= head + 1;
					end if;
					write_en <= '1';
				else
					write_en <= '0';
				end if;

			end if;
	end process output_process;

		
end architecture logic;
