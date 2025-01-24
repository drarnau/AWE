// Iterate over all Raw_*.dta files in flows folder
local files : dir "${IFlows_M}" files "Raw_*.dta"
foreach f of local files {
  // Merge benchmark with spRW
  use "${IFlows_M}`f'", clear
  merge 1:m Time sex DeNUN using "${INumSpRW}`f'", nogenerate

  // Store merged data to compute flow types
  local fname = subinstr("`f'","Raw","Merged",.)
  save "${IFlows_M}`fname'", replace

  // Compute share
  foreach rv of varlist *to*spRW {
    // Define associated transition
    local v = subinstr("`rv'","spRW","",.)

    // Compute share
    generate share`v' = (`rv' / `v') * 100 if `rv' < `v'
    // NOTE Individual flows: In 2020m4 (pandemic hits) the share is bigger than 100%.
    // Looks reasonable everywhere else, I guess there is an issue with CPS weights.
    // I check unweighted number of observations: computation looks correct.

    label variable share`v' "Share of workers in `v' whose spouse is a removed worker"
  }

  // Drop unnecessary variables
  drop ?to? ?to?spRW

  // Save file
  save "${IShareSpRW}`f'", replace
}
