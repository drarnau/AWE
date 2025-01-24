// Assign tempfiles
tempfile original
tempfile unmatched

// Count number of observations for later check
count
local N_original = `r(N)'

// Store unmatchable ids for append
save `original'
keep if empstat == 0
save `unmatched'

// Drop unmatchable ids
use `original'
drop if empstat == 0
sort cpsidp MyTime

// Create variables with values for all mish observations
foreach v of varlist `myvars' age race sex {
  forvalues m = 1/8 {
    gen aux = `v' if mish == `m'
    by cpsidp: egen aux2 = total(aux)
    gen `v'_m`m' = aux2 if aux2 != 0
    drop aux*
  }
}

// Flag consistent matches
foreach mt of numlist 2/4 6/8 {
  local my = `mt' - 1

  gen MyFlag_m`mt' = 1 if age_m`mt' != . & age_m`my' != . & ///
                          sex_m`mt' != . & sex_m`my' != . & ///
                          race_m`mt' != . & race_m`mt' != .

  replace MyFlag_m`mt' = 0 if age_m`mt' - age_m`my' > 1 | age_m`mt' - age_m`my' < 0
  replace MyFlag_m`mt' = 0 if race_m`mt' != race_m`my'
  replace MyFlag_m`mt' = 0 if sex_m`mt' != sex_m`my'

  * Label flag variable
  la var MyFlag_m`mt' "Valid `my'-`mt' transition"
}

// Drop matching age, race, sex variables
drop age_* race_* sex_*

// Append unmatchable
append using `unmatched', nol

// Check number of observations
count
if (`r(N)' != `N_original') {
  di as error "B02_LinkMonths.do: Number of original observations not recovered"
}
