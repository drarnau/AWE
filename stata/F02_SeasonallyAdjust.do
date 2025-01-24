// Tempfiles
* to store data with groups
tempfile grouped
* to store appended data
tempfile appended

// Iterate over all Raw_*.dta files in folder `myfolder'
local files : dir "`myfolder'" files "`tinfile'_*.dta"
foreach f of local files {
  // Load data
  use "`myfolder'`f'", clear

  // Create groupd of categories
  egen grp = group(`catvars')
  levelsof grp, local(levels)

  // Save tempfile
  save `grouped', replace

  // Iterate over each subgroup
  local k = 0 // Initialise 1st iteration counter
  foreach g of local levels {
    use * if grp == `g' using `grouped', clear
    drop grp

    // Seasonally adjust relevant variables
    ds Time `catvars', not
    foreach v of varlist `r(varlist)' {
      SeasonallyAdjust `v', `SAmethod'
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
  save "`myfolder'`of'", replace
}
