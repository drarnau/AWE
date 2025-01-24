// Define labour market states
local mystates = "E U N"

// Tempfiles
* to store data with groups
tempfile grouped
* to store appended data
tempfile appended

// Iterate over all `tinfile'_*.dta files in folder ITransitions
local files : dir "${ITransitions}" files "`tinfile'_*.dta"
foreach f of local files {
  // Load data
  use "${ITransitions}`f'", clear

  // Create groups of categories
  egen grp = group(`catvars')
  levelsof grp, local(levels)

  // Save tempfile
  save `grouped', replace

  // Iterate over each subgroup
  local k = 0 // Initialise 1st iteration counter
  foreach g of local levels {
    clear mata
    use * if grp == `g' using `grouped', clear
    drop grp
    sort Time

    // Order variables to guarantee correct read to Mata
    order Time EtoE EtoU EtoN UtoE UtoU UtoN NtoE NtoU NtoN `catvars'

    // Create Return matrix in Mata
    mata: RetM = J(`=_N', 9, .)

    // Iterate over all periods
    forval t = 1/`=_N' {
      // Load matrix data into mata
      mata: T = st_data(`t', ("*to*"))
      mata: T = rowshape(T,cols(T)^(1/2))

      // Apply time-aggregation bias correction
      include "H02a_MataTA.do"

      // Store result (R) in return matrix (RetM)
      mata: RetM[`t', .] = R
    }

    // Import all values from Mata
    unab tvars : ?to?
    getmata (`tvars') = RetM, replace

    // Set negative and >1 values to missing
    foreach y of local mystates {
      foreach t of local mystates {
        // Define variable name
        local v = "`y'to`t'"

        // Drop diogonal elements
        if ("`y'" == "`t'") {
          drop `v'
        }
        else {
          replace `v' = . if `v' < 0
          replace `v' = . if `v' > 1
        }
      }
      // Set to missing rows that sum to > 1
      egen double auxsum = rowtotal(`y'to?)
      foreach v of varlist `y'to? {
        replace `v' = . if auxsum > 1
      }
      drop auxsum
    }

    // Compute diagonal elements
    foreach yt of local mystates{
      egen auxNmiss = rowmiss(`yt'to?)
      egen double auxsum = rowtotal(`yt'to?)
      generate double `yt'to`yt' = 1 - auxsum if auxNmiss == 0
      drop aux*
    }

    // Transform to percentages
    foreach v of varlist ?to? {
      replace `v' = `v'*100
    }

    // Append and save
    if (`k' == 0) {
      local k = `k' + 1
      save `appended', replace
    }
    else {
      append using `appended'
      save `appended', replace
    }
  }

  // Save outfile
  local of = subinstr("`f'","`tinfile'","`toutfile'",.)
  save "${ITransitions}`of'", replace
}
