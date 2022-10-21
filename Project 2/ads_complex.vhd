---- this file is part of the ADS library

library ads;
use ads.ads_fixed.all;

package ads_complex_pkg is
	-- complex number in rectangular form
	type ads_complex is
	record
		re: ads_sfixed;
		im: ads_sfixed;
	end record ads_complex;

	---- functions

	-- make a complex number
	function ads_cmplx (
			re, im: in ads_sfixed
		) return ads_complex;

	-- returns l + r
	function "+" (
			l, r: in ads_complex
		) return ads_complex;

	-- returns l - r
	function "-" (
			l, r: in ads_complex
		) return ads_complex;

	-- returns l * r
	function "*" (
			l, r: in ads_complex
		) return ads_complex;

	-- returns the complex conjugate of arg
	function conj (
			arg: in ads_complex
		) return ads_complex;

	-- returns || arg || ** 2
	function abs2 (
			arg: in ads_complex
		) return ads_sfixed;

	-- constants
	constant complex_zero: ads_complex :=
					ads_cmplx(to_ads_sfixed(0), to_ads_sfixed(0));

end package ads_complex_pkg;

package body ads_complex_pkg is

	-- function implementations
	function "+" (
			l, r: ads_complex
		) return ads_complex
	is
		variable ret: ads_complex;
	begin
		ret.re := l.re + r.re;
		ret.im := l.im + r.im;
		return ret;
	end function "+";

	-- implement all other functions here
	-- subtraction implementation 
	function "-"(
			l, r: ads_complex
		) return ads_complex
	is
		variable ret: ads_complex;
	begin
		ret.re := l.re - r.re;
		ret.im := l.im - r.im;
		return ret;
	end function "-";
	
	-- multiplication implementation
	function "*"(
			l, r: ads_complex
		) return ads_complex
	is
		variable ret: ads_complex;
	begin
		ret.re := (l.re*r.re) - (l.im*r.im);
		ret.im := (l.im*r.re) - (r.im*l.re);
		return ret;
	end function "*";
	
	-- complex conjugate implementation
		function conj(
			l: ads_complex
		) return ads_complex
	is
		variable ret: ads_complex;
	begin
		ret.re := l.re;
		ret.im := -l.im;
		return ret;
	end function conj;
	
	--square magnitude complex  implementation	
	function abs2(
			l: ads_complex
		) return ads_fixed
	is
		variable ret: ads_fixed;
	begin
		ret:= (l.re*l.re) + (l.im*l.im);
		return ret;
	end function abs2;
	
	
	
	--square complex implementation	
	function ads_square(
			l: ads_complex
		) return ads_complex
	is
		variable ret: ads_complex;
	begin
		ret.re := (l.re*l.re) - (l.im*l.im);
		ret.im := (l.im*l.re) + (l.im*l.re);
		return ret;
	end function ads_square;
	
	

end package body ads_complex_pkg;
