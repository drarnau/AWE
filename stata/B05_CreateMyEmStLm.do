// Iterate over EmSt variables (normal and DeNUNified)
foreach v of varlist MyEmSt MyEmStC {
  * Create variable
  gen `v'Lm = .
  local auxlbl : var label `v'
  la var `v'Lm "Last month's `auxlbl'"

  * Iterate over relevant months
  foreach mt of numlist 2/4 6/8 {
    local my = `mt' - 1
    replace `v'Lm = `v'_m`my' if mish == `mt' & MyFlag_m`mt' == 1
  }
}

// Label value L variables
la values MyEmSt*Lm lbl_EmSt
