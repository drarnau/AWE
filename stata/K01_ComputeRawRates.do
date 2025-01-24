// Iterate over all Raw_*.dta files in flows folder
local files : dir "${IFlows}" files "Raw_*.dta"
foreach f of local files {
  // Load file
  use "${IFlows}`f'", clear

  // Compute auxiliary stocks
  foreach s in "E" "U" "N" {
    egen double aux`s' = rowtotal(?to`s'), missing
  }

  // Compute rates
  * Participation
  generate double Prate = 100*((auxE + auxU) / (auxE + auxU + auxN))
  * Employment
  generate double Erate = 100*(auxE / (auxE + auxU + auxN))
  * Unemployment
  generate double Urate = 100*(auxU / (auxE + auxU))

  // Drop unnecessary variables
  drop aux* ?to?

  // Sort by Time
  sort Time DeNUN sex flowtype

  // Save
  save "${IRates}`f'", replace
}
