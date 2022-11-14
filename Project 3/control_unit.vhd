library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

library vga;
use vga.vga_data.all;

entity control_unit is
	generic(
		vga_res:			vga_timing := vga_res_default;
		threshold:		ads_sfixed := to_ads_sfixed(4);
		total_iterations:	natural := 16 
	);
	port (
		-- Input ports
		reset:		in		std_logic;
		fpga_clock:	in		std_logic;
		c_value:		in		ads_complex;
		-- Output ports
		iterations:	out 	natural;
		start_vga:	out	boolean
	);
end entity control_unit;

architecture logic of control_unit is
	-- components
	component computational_unit is
		generic(
			iterations: positive range 1 to 64:= 32;
			threshold:	ads_sfixed := to_ads_sfixed(4)
		);
		port (
			-- Input ports
			fpga_clock: 			in 	std_logic;
			reset:					in		std_logic;
			enable:					in		std_logic;
			seed:						in		ads_complex; --complex #C
			z_in:						in		ads_complex;
			-- Output ports
			done:						out	std_logic;
			iteration_count:		out	natural range 0 to iterations - 1
		);
	end component computational_unit;
	signal computation_done: std_logic_vector(0 to total_iterations-1);
	signal computation_reset: std_logic_vector(0 to total_iterations-1);
	
	signal current_point: coordinate;
	
	type ads_complex_array is array(0 to total_iterations - 1) of ads_complex;
	
	signal z_value: ads_complex; --_array;
	
	subtype iteration_type is natural range 0 to total_iterations - 1;
	type iteration_count_type is array(0 to total_iterations - 1) of iteration_type;
	signal iteration_count: iteration_count_type;
	
	signal selector: iteration_type;
	constant delta: ads_sfixed := to_ads_sfixed(real(1)/real(120));
	
	--signal current_point: coordinate;
	
begin
	
	point_setup: process (fpga_clock) is
	begin
		if rising_edge(fpga_clock) then
			if reset = '0' then
				current_point <= make_coordinate(0,0);
			else
				current_point <= next_coordinate(current_point, vga_res);
			end if;
		end if;
	end process point_setup;
	
	-- scheduler for computational units
	scheduler: process (fpga_clock) is
	begin
		if rising_edge(fpga_clock) then
			if reset = '0' then
				selector <= 0;
				start_vga <= false;
			elsif selector = iteration_type'high then
				selector <= 0;
				start_vga <= true;
			else
				selector <= selector + 1;
			end if;
		end if;
	end process scheduler;
	
	-- reset vector
	reset_vect: process(selector) is
		variable resets: std_logic_vector(computation_reset'range);-- := (others => '1');
	begin
		resets := (others => '1');
		resets(selector) := '0';
		computation_reset <= resets;
	end process reset_vect;
	
	-- output
	iterations <= iteration_count(selector);
	
	-- make computational units
	vector_machines: for i in 0 to total_iterations - 1 generate
		cuL: computational_unit
			generic map (
				iterations => total_iterations,
				threshold => threshold
			)
			port map (
				fpga_clock => fpga_clock,
				reset => computation_reset(i),
				enable => '1',
				seed => c_value,
				z_in => z_value,
				done => computation_done(i),
				iteration_count => iteration_count(i)
			);			
	end generate vector_machines;
	
	z_value <= ads_cmplx(
				to_ads_sfixed(current_point.x) * delta - to_ads_sfixed(2),
				to_ads_sfixed(2) - to_ads_sfixed(current_point.y) * delta
			);
	
--	transition_function: process(state, current_point, computation_done) is
--		begin
--			case state is
--				when reset_state => 
--						next_state <= generate_next_z;
--				when generate_next_z => 
--						next_state <= enable;
--				when enable => 
--					--check if computational unit is all done with iterations
--					if computation_done = '1' then
--						next_state <= read_result;
--					else
--						next_state <= enable;
--					end if;
--				when read_result =>
--					--if at the seed limit, set wren to 1 for ram to start storing computational data
--					if (current_point.x = 559 and current_point.y = 559) then
--						next_state <= done_state;
--					else --the seed limit hasn't been reached, next state is reset.
--						next_state <= reset_state;
--					end if;
--				when done_state => 
--						next_state <= done_state;
--			end case;
--	end process transition_function;
--	
--	save_state: process(fpga_clock) is
--		begin
--			-- check for edge of clock, add reset logic
--			if rising_edge(fpga_clock) then
--				if reset = '0' then
--					state <= reset_state;
--				else
--					state <= next_state;
--				end if;
--			end if;
--	end process save_state;
--				
--	output_process: process(fpga_clock, reset) is
--		begin -- add reset logic
--			if reset = '0' then
--				computation_reset <= '1';
--				current_point <= ( x=> 80, y => 0 );
--				computation_enable <= '0';
--				done <= '0';				
--			elsif rising_edge(fpga_clock) then
--				if state = reset_state then
--					computation_reset <= '0';
--				else
--					computation_reset <= '1';
--				end if;
--
--				if state = generate_next_Z then
--					if current_point.x < 559 then
--						current_point.x <= current_point.x + 1;
--					else
--						current_point.x <= 80;
--						current_point.y <= current_point.y + 1;
--					end if;
--				else
--					current_point <= current_point;
--				end if;
--				
--				
--				if state = enable then
--					computation_enable <= '1';
--				else
--					computation_enable <= '0';
--				end if;
--
--				if state = store_result then
--					wren <= '1';
--				else
--					wren <= '0';
--				end if;
--				
--				if state = done_state then
--					done <= '1';
--				else
--					done <= '0';
--				end if;
--			end if;
--	end process output_process;
	
	
end architecture logic; 