library ieee;
use ieee.std_logic_1164.all;

entity computational_unit is
	generic(
		lines:	natural range 0 to 479;
		pixels: 	natural range 0 to 639
	);
	port (
		-- Input ports
		fpga_clock: 			in 	std_logic;
		reset:				in		std_logic;
		-- Output ports
		done:				out	std_logic;
		itteration_count:		out	std_logic
	);
end entity computational_unit;

architecture computation of computational_unit is
	signal threshold:	natural;
	signal c: 		ads_complex;
	signal z: 		ads_complex;
	signal iteration: 	natural;
	signal iterations:	natural;
begin
	-- Obtaining a colored point on the Mandelbrot set
	compute_point: process(c,iterations)
		z			<= 0;
		iteration		<= 0;
		c 			<= 0;

		algo_1: while iteration < iterations loop
			z <= ads_square(z);
			Z <= z + c;
			
			if abs2(z) > threshold then
				exit algo_1;
			end if;
			iteration <= iteration + 1;
		end loop algo_1;
		
		return colormap[iteration];
	end process compute_point;
	
	-- Generating the colored Mandelbrot set
	generate_set: process(c)
		line_count: for i in lines'range generate
			pixel_count: for j in pixels'range generate
				color <= compute_point(c);
				plot i,j, color;
			end generate pixel_count;		
		end generate line_count;
	end process generate_set;
	
end architecture computation;
