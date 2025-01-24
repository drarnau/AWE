// Iterate over all `tinfile'_*.dta files in folder ITransitions
local files : dir "${ITransitions}" files "`tinfile'_*.dta"
foreach f of local files {
  // Load data
  use "${ITransitions}`f'", clear

  // Compute Auxiliary Employment
  generate double auxE = (UtoN*NtoE) + (NtoU*UtoE) + (NtoE*UtoE)

  // Compute Auxiliary Unemployment
  generate double auxU = (EtoN*NtoU) + (NtoE*EtoU) + (NtoU*EtoU)

  // Compute Auxiliary Non-participation
  generate double auxN = (EtoU*UtoN) + (UtoE*EtoN) + (UtoN*EtoN)

  // Compute Employment rate
  generate double Erate = 100*(auxE / (auxE+auxU+auxN))

  // Compute Unemployment rate
  generate double Urate = 100*(auxU / (auxE+auxU))

  // Compute Participation rate
  generate double Prate = 100*((auxE+auxU) / (auxE+auxU+auxN))

  // Drop unnecessary variables
  drop aux* ?to?

  // Save file
  save "${ISSrates}`f'", replace
}
