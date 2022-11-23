set sseg_lamps {
		{ C14 E15 C15 C16 E16 D17 C17 } 
		{ C18 D18 E18 B16 A17 A18 B17 } 
		{ B20 A20 B19 A21 B21 C22 B22 }
		{ F21 E22 E21 C19 C20 D19 E17 }
		{ F18 E20 E19 J18 H19 F19 F20 }
		{ J20 K20 L18 N18 M20 N19 N20 }
	}

proc set_pins { digits { name "hex_digit" } } {
    global sseg_lamps
    for { set i 0 } { ${i} < ${digits} } { incr i } {
	  set j 0
	  foreach lamp { a b c d e f g } {
		set location [ lindex [ lindex ${sseg_lamps} ${i} ] ${j} ]
		set_location_assignment PIN_${location} -to ${name}\[${i}\].${lamp}
		incr j
	  }
    }
}	