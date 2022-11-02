library ieee;
use ieee.std_logic_1164.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;


entity computational_unit is
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
		-- Output ports
		done:						out	std_logic;
		iteration_count:		out	natural range 0 to iterations - 1
	);
end entity computational_unit;

architecture computation of computational_unit is
	signal z: 				ads_complex;
	signal iteration: 	natural range 0 to iterations - 1;
	signal all_done:		std_logic;
	
begin
	-- Obtaining a colored point on the Mandelbrot set
	compute_point: process(reset, fpga_clock) is
	begin
		if reset = '0' then
			z <= ( re => (others => '0'), im => (others => '0') );
			iteration <= 0;
			all_done <= '0';
		elsif rising_edge(fpga_clock) then
			if enable = '1' then
				if (abs2(z) >= threshold) or (iteration = (iterations - 1)) then
					all_done <= '1';
				else
					z <= ads_square(z) + seed;
					iteration <= iteration + 1;
				end if;
			end if;
		end if;
	end process compute_point;
	
	iteration_count <= iteration;
	done <= all_done;
	

end architecture computation;
