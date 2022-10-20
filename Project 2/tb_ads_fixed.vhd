library ieee;
use ieee.numeric_std.all;

library ads;
use ads.ads_fixed.all;

entity tb_ads_sfixed is
end entity tb_ads_sfixed;

architecture test_fixture of tb_ads_sfixed is
	signal value: ads_sfixed;
begin

	test: process is
	begin
		-- test creation using signed
		report "test 1" severity note;
		value <= to_ads_sfixed(to_signed(0, value'length));
		wait for 1 ns;

		-- test binary +
		report "test 2" severity note;
		for i in 0 to 100 loop
			value <= value + to_ads_sfixed(to_signed(-100 * (2**18), value'length));
			wait for 1 ns;
		end loop;

		-- test creation using integer
		report "test 3" severity note;
		value <= to_ads_sfixed(-100);
		wait for 1 ns;
		value <= to_ads_sfixed(100);
		wait for 1 ns;

		-- test binary +
		report "test 4" severity note;
		for i in 0 to 100 loop
			value <= value + to_ads_sfixed(100);
			wait for 1 ns;
		end loop;

		-- test binary -
		report "test 5" severity note;
		for i in 0 to 100 loop
			value <= value - to_ads_sfixed(100);
			wait for 1 ns;
		end loop;

		value <= to_ads_sfixed(-300);
		for i in 0 to 100 loop
			value <= value - to_ads_sfixed(-100);
			wait for 1 ns;
		end loop;

		-- test unary -
		report "test 6" severity note;
		value <= -value;
		wait for 1 ns;
		value <= -value;
		wait for 1 ns;

		-- test binary *
		report "test 7" severity note;
		value <= to_ads_sfixed(2);
		wait for 1 ns;
		for i in 0 to 20 loop
			value <= value * to_ads_sfixed(3);
			wait for 1 ns;
		end loop;

		--
		report "test 8" severity note;
		value <= to_ads_sfixed(512);
		wait for 1 ns;
		value <= value * to_ads_sfixed(2);
		wait for 1 ns;

		--
		report "test 9" severity note;
		for i in 0 to 20 loop
			value <= value * to_ads_sfixed(to_signed(-2**17, value'length));
			wait for 1 ns;
		end loop;

		report "test 10" severity note;
		value <= to_ads_sfixed(-0.5);
		wait for 1 ns;
		for i in 1 to 100 loop
			value <= to_ads_sfixed(10.0 / real(i));
			wait for 1 ns;
		end loop;

		report "test 11" severity note;
		value <= to_ads_sfixed(-2);
		wait for 1 ns;
		value <= value * to_ads_sfixed(512);
		wait for 1 ns;
		value <= value * to_ads_sfixed(-0.5);
		wait for 1 ns;
		value <= value * to_ads_sfixed(-1.5);
		wait for 1 ns;
		value <= value + to_ads_sfixed(1.1);
		wait for 1 ns;

		wait;
	end process test;

end architecture test_fixture;
