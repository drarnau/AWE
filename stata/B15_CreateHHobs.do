// Copy husband's and wife's characteristics
drop cpsidp relate
sort cpsid mish
ds cpsid mish Time year sex statecensus, not

* Loop over all variables
foreach v of varlist `r(varlist)' {
  di "`v'"
  * Create variables
  local vname = upper(substr(`"`v'"', 1, 1)) + substr(`"`v'"', 2, .)

  forval s = 1/2 {
    gen Aux`s'`v' = `v' if sex == `s'
  }

  by cpsid mish: egen h`vname' = max(Aux1`v')
  by cpsid mish: egen w`vname' = max(Aux2`v')
  drop Aux*

  * Label new variables
  local auxlbl : var label `v'
  local hlbl = "Husband's `auxlbl'"
  local wlbl = "Wife's `auxlbl'"
  la var h`vname' "`hlbl'"
  la var w`vname' "`wlbl'"

  * Add value labels
  local auxlbl : value label `v'
  la values h`vname' `auxlbl'
  la values w`vname' `auxlbl'

  drop `v'
}

// Drop sex
drop sex

// Keep one observation per household
by cpsid mish: keep if _n == 1

// Household variables
* Weight
gen HHwtfinl = (hWtfinl + wWtfinl)
la var HHwtfinl "Sum of husband and wife wtfinl"
