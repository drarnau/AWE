// Create list of sufixes for empstat
local mylist = ""
forvalues m = 1/8 {
  local mylist = "`mylist' _m`m'"
}

// Iterate over suffixes
foreach m in "" `mylist' {
  gen MyEmSt`m'     = 10 if empstat`m' >= 10 & empstat`m' <= 12 // Employed
  replace MyEmSt`m' = 20 if empstat`m' >= 20 & empstat`m' <= 22 // Unemployed
  replace MyEmSt`m' = 30 if empstat`m' >= 30 & empstat`m' <= 36 // NILF
}

// Assign label to variable
la var MyEmSt "Labor market status"

// Label values
la define lbl_EmSt 10 "Employed" ///
                   20 "Unemployed" ///
                   30 "NILF"

la values MyEmSt lbl_EmSt
