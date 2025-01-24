// Define temporary files
* to append different types of flows
tempfile appended

// Iterate over all Raw_*.dta files in folder Flows
local files : dir "${IFlows_M}" files "Raw_*.dta"
foreach f of local files {
  // Add married (Benchmark)
  * Load married flows
  use "${IFlows_M}`f'", clear
  * Generate flow type
  generate flowtype = 0
  * Append & save
  save `appended', replace

  // Add spouse is a removed worker
  * Load number of spouse is RW in each flow
  use "${INumSpRW}`f'", clear
  * Rename variables
  rename *spRW *
  * Store value-lables
  levelsof RWtype, local(levels)
  foreach l of local levels {
    local vl`l': label lbl_RWtype `l'
  }
  * Generate flow type
  generate flowtype = 10 + RWtype
  drop RWtype
  * Append & save
  append using `appended'
  save `appended', replace

  // Add flows without those whose spouse is a removed worker
  * Load flows & number of spouse is RW in each flow
  local mf = subinstr("`f'","Raw","Merged",.)
  use "${IFlows_M}`mf'", clear
  * Compute flows
  foreach v of varlist ?to? {
    generate double nw`v' = `v' - `v'spRW if `v' >= `v'spRW
    // NOTE Individual flows: In 2020m4 (pandemic hits) the share is bigger than 100%.
    // Looks reasonable everywhere else, I guess there is an issue with CPS weights.
    // I check unweighted number of observations: computation looks correct.
    drop `v' `v'spRW
    rename nw`v' `v'
  }
  * Generate flow type
  generate flowtype = 20 + RWtype
  drop RWtype
  * Append & save
  append using `appended'
  save `appended', replace

  // Add no added worker counterfactual flows
  * Load flows & number of spouse is RW in each flow
  use "${IFlows_M}`mf'", clear
  * Compure flows
  gen aux = (NtoE > NtoEspRW) & (NtoU > NtoUspRW) & (NtoN > NtoNspRW)
  foreach t in "E" "U" {
    generate double nwNto`t' = Nto`t' - Nto`t'spRW if aux == 1
    drop Nto`t'
    rename nwNto`t' Nto`t'
  }
  generate double nwNtoN = NtoN + NtoEspRW + NtoUspRW if aux == 1
  drop NtoN
  rename nwNtoN NtoN
  drop aux *spRW
  * Generate flow type
  generate flowtype = 30 + RWtype
  drop RWtype
  * Append & save
  append using `appended'
  save `appended', replace

  // Add same probability added worker counterfactual flows
  * Load flows & number of spouse is RW in each flow
  use "${IFlows_M}`mf'", clear
  foreach v of varlist Nto? {
    generate double nw`v' = `v' - `v'spRW if `v' >= `v'spRW
    // NOTE Individual flows: In 2020m4 (pandemic hits) the share is bigger than 100%.
    // Looks reasonable everywhere else, I guess there is an issue with CPS weights.
    // I check unweighted number of observations: computation looks correct.
    drop `v' `v'spRW
    rename nw`v' `v'
  }
  drop *spRW
  * Generate flow type
  generate flowtype = 40 + RWtype
  drop RWtype
  * Append & save
  append using `appended'
  save `appended', replace

  // Label flowtype
  label variable flowtype "Type of flow"
  label define lbl_flowtype 0 "Benchmark"
  foreach l of local levels {
    local i = 10 + `l'
    label define lbl_flowtype `i' "spRW: `vl`l''", add
    local i = 20 + `l'
    label define lbl_flowtype `i' "spNotRW: `vl`l''", add
    local i = 30 + `l'
    label define lbl_flowtype `i' "CFnoAWE: `vl`l''", add
    local i = 40 + `l'
    label define lbl_flowtype `i' "CFsameAWE: `vl`l''", add
  }
  label values flowtype lbl_flowtype

  // Save
  save "${IFlows}`f'", replace
}
