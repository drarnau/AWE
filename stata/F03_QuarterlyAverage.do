// Tempfiles
* to store data with groups
tempfile grouped
* to store appended data
tempfile appended
* to quarterly average
tempfile ready2QA

// Iterate over all Raw_*.dta files in folder `myfolder'
local files : dir "`myfolder'" files "`tinfile'_*.dta"
foreach f of local files {
  // Load data
  use "`myfolder'`f'", clear

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

    // Quarterly Average
    save `ready2QA', replace
    QuarterlyAverage using `ready2QA'

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
