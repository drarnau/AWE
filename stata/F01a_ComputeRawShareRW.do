// Iterate over all Merged_*.dta files in flows folder
local files : dir "${IFlows_M}" files "Merged_*.dta"
foreach f of local files {
  // Load data
  use "${IFlows_M}`f'", clear

  // Compute share in N
  egen auxsum = rowtotal(?to?)
  egen auxN = rowtotal(Nto?)
  generate shareinN = 100*(auxN / auxsum)

  // Compute share in N to E or N to U
  generate auxNtoP = NtoE + NtoU
  generate shareNtoP = 100*(auxNtoP / auxN)

  // Compute share AW in NtoP
  generate auxspRW = NtoEspRW + NtoUspRW
  generate shareAWinNtoP = 100*(auxspRW / auxNtoP)

  // Drop unnecessary variables
  drop ?to? ?to?spRW aux*

  // Save file
  local fname = subinstr("`f'","Merged","aRaw",.)
  save "${IShareSpRW}`fname'", replace
}
