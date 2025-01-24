// Define tempfiles
tempfile benchmark

// Iterate over all `tinflie'_*.dta files in SS rates folder
local files : dir "${ISSrates}" files "`tinfile'_*.dta"
foreach f of local files {
  // Prepare benchmark data
  use "${ISSrates}`f'" if transtype == 0, clear
  rename ?rate bm_?rate
  drop transtype
  save "`benchmark'", replace

  // Load counterfactual data
  use "${ISSrates}`f'" if transtype > 30, clear

  // Merge benchmark data
  merge m:1 Time DeNUN sex using "`benchmark'", nogenerate

  // Compute differences
  foreach v of varlist ?rate {
    generate double diff`v' = bm_`v' - `v'
    drop `v' bm_`v'
  }

  // Save
  save "${ISSrates}diff`f'", replace
}
