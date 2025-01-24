// Define matching SS files
local ss_QSA = "TQSA"
local ss_QSAsh = "QTSAsh"

// Define tempfiles
tempfile mydata

// Iterate over all `tinflie'_*.dta files in rates folder
local files : dir "${IRates}" files "`tinfile'_*.dta"
foreach f of local files {
  // Load data
  use "${IRates}`f'" if Time < yq(2022,1), clear

  // Compute total sum of squares
  sort DeNUN sex flowtype Time
  foreach v of varlist ?rate {
    by DeNUN sex flowtype: egen auxmean = mean(`v')
    generate auxdiff = (`v' - auxmean)^2
    by DeNUN sex flowtype: egen TSS_`v' = sum(auxdiff)
    drop aux*
  }

  // Save data
  save "`mydata'", replace

  // Load steady-state approximations
  local fs = subinstr("`f'", "`tinfile'", "`ss_`tinfile''", .)
  use "${ISSrates}`fs'" if Time < yq(2022,1), clear

  // Merge with data
  rename ?rate ss_?rate
  rename transtype flowtype
  merge 1:1 Time DeNUN sex flowtype using "`mydata'", nogenerate

  // Compute residual sum of squares
  foreach v of varlist ?rate {
    generate auxdiff = (`v' - ss_`v')^2
    bysort DeNUN sex flowtype: egen RSS_`v' = sum(auxdiff)
    drop aux*
  }

  // Compute coefficient of determination
  foreach v of varlist ?rate {
    generate R2_`v' = 1 - (RSS_`v' / TSS_`v')
  }

  // Drop unnecessesary variables
  drop ss_* ?rate TSS_* RSS_*

  // Save
  save "${IRates}r2`f'", replace
}
