// Define labour market states
local mystates = "E U N"

// Iterate over all Raw_*.dta files in folder IFlows
local files : dir "${IFlows}" files "Raw_*.dta"
foreach f of local files {
  // Load raw flows
  use "${IFlows}`f'", clear

  // Iterate over states yesterday
  foreach y of local mystates {
    // Compute sum of all flows from yesterday
    egen double aux = rowtotal(`y'to?)

    // Iterate over states today
    foreach t of local mystates {
      generate double trans_`y'to`t' = `y'to`t' / aux
    }
    drop aux
  }

  // Drop flows
  drop ?to?
  rename trans_* *

  // Rename flowtype
  rename flowtype transtype
  label variable transtype "Type of transition"

  // Save
  save "${ITransitions}`f'", replace
}
