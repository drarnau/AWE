// Define matching SS files
local ss_cycQSA = "cycTQSA"
local ss_cycQSAsh = "cycQTSAsh"

// Iterate over all `tinflie'_*.dta files in rates folder
local files : dir "${IRates}" files "`tinfile'_*.dta"
foreach f of local files {
  // Load steady-state approximations
  local fs = subinstr("`f'", "`tinfile'", "`ss_`tinfile''", .)
  use "${ISSrates}`fs'", clear

  // Merge with data
  keep if transtype == 0
  rename *_?rate ss_*_?rate
  rename transtype flowtype
  di "${IRates}`f'"
  merge 1:1 Time DeNUN sex flowtype using "${IRates}`f'", nogenerate

  // Compute differences
  foreach s of varlist ss_* {
    local v = subinstr("`s'", "ss_", "", .)
    generate double diff_`v' = abs(`v' - `s')
    drop `v' `s'
  }

  // Save
  save "${IRates}diff`f'", replace
}
