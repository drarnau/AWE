// Tempfiles
* to store data with groups
tempfile grouped
* to store appended data
tempfile appended

// Iterate over all `tinflie'_*.dta files in `tindir' folder
local files : dir "`tindir'" files "`tinfile'_*.dta"
foreach f of local files {
  // Load data
  use "`tindir'`f'", clear

  // Execute selection commands
  `timecom'
  `selcom'

  // Create groups of categories
  egen grp = group(`catvars')
  levelsof grp, local(levels)

  // Save tempfile
  save `grouped', replace

  // Iterate over each subgroup
  local k = 0 // Initialise 1st iteration counter
  foreach g of local levels {
    use * if grp == `g' using `grouped', clear
    drop grp

    // Compute cyclical component of logged rates
    tsset Time
    foreach v of varlist ?rate {
      // Interpolate if there are gaps
      count if `v' == .
      if (`r(N)' > 0) {
        ipolate `v' Time, generate(aux)
        drop `v'
        rename aux `v'
      }
      generate double log`v' = log(`v')
      tsfilter hp double cyclog`v' = log`v', smooth($smoothp)
      drop log`v'
    }

    // Merge GDP data
    merge 1:1 Time using $GDP, nogenerate

    // Compute moments
    foreach v of varlist ?rate {
      correlate cyclog`v' cyclogGDP
      generate double rho_`v' = `r(rho)'
      summarize cyclog`v'
      generate double ratiosigmas_`v' = `r(sd)' / sigma_cyclogGDP
      drop `v' cyclog`v'
    }
    drop cyclogGDP sigma_cyclogGDP

    // // Make data timelees
    // keep if _n == 1
    // replace Time = .

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

  // Save file
  save "`tindir'cyc`f'", replace
}
