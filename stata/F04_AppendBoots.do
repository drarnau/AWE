// Define filename containing original and bootstraps
local fname = "`myfolder'Boots`tinfile'.dta"

// Initialise counter
local k = 0

// Iterate over all `tinfile'_*.dta files in folder `myfolder'
local files : dir "`myfolder'" files "`tinfile'_*.dta"
foreach f of local files {
  // Update counter
  local k = `k' + 1

  // Load data
  use "`myfolder'`f'", clear

  // Extract bootstrap number
  local bnum = subinstr("`f'","`tinfile'_","",.)
  local bnum = subinstr("`bnum'",".dta","",.)

  // Identify bootstrap
  generate nboot = `bnum'
  label variable nboot "Bootstrap number"

  // Append & save
  if (`k' > 1) {
    append using "`fname'"
  }
  save "`fname'", replace
}
