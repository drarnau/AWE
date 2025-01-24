// Define matching SS files
local ss_QSA = "TQSA"
local ss_QSAsh = "QTSAsh"

// Iterate over all `tinflie'_*.dta files in rates folder
local files : dir "${IRates}" files "`tinfile'_*.dta"
foreach f of local files {
  // Load steady-state approximations
  local fs = subinstr("`f'", "`tinfile'", "`ss_`tinfile''", .)
  use "${ISSrates}`fs'", clear

  // Merge with data
  rename ?rate ss_?rate
  rename transtype flowtype
  merge 1:1 Time DeNUN sex flowtype using "${IRates}`f'", nogenerate

  // Compute differences
  foreach v of varlist ?rate {
    generate double diff`v' = abs(`v' - ss_`v')
    drop `v' ss_`v'
  }

  // Save
  save "${IRates}diff`f'", replace
}
