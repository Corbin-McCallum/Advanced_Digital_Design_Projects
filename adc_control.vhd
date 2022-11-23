
entity adc_control is
	port (
		clock_10:	in	std_logic;
		clock_1:		in	std_logic;
		
		write_en:	out std_logic;
		data_out:	out natural range 0 to 2**12 - 1
	);
end entity adc_control;

architecture logic of adc_control is
	
	component max10_adc is
			port(
				pll_clk:	in		std_logic;
				chsel:	in		natural range 0 to 2**5 - 1;
				soc:		in		std_logic;
				tsen:		in		std_logic;
				dout:		out	natural range 0 to 2**12 - 1;
				eoc:		out	std_logic;
				clk_dft:	out	std_logic
			);
	end component max10_adc;
	
	type state_type is (
			idle_state, start_state, wait_state, write_state);

	signal state, next_state: state_type;
	signal start_conversion: std_logic;
	signal end_conversion:	 std_logic;
	
begin
	ma0: max10_adc
		port map (
			pll_clk => clock_10,
			chsel:  => '0',
			soc:	  => start_conversion,
			tsen:	  => '1' ,
			dout:	  => data_out,
			eoc:	  => end_conversion,
			clk_dft:=> clock_1
		);
		
	transition_function: process(state, end_conversion) is
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
					--write data out
					next_state <= idle_state;
				when others =>
					next_state <= idle_state;
				
			end case;
	end process transition_function;
	
	output_process: process(clock_1) is
		begin -- add reset logic
							
			if rising_edge(clock_1) then
				if state = idle_state then
					start_conversion <= '1';
				else
					start_conversion <= '0';
				end if;

				if state = wait_state then
					if end_conversion = '1' then
						tsen = '0';
					else
						tsen = '1';
					end if;
				end if;
				
				
				if state = write_state then
					write_en <= '1';
				else
					write_en <= '0';
				end if;

			end if;
	end process output_process;

	
		
