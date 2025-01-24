/* COMPUTE steady-state rates
Iterates over all `tinfile'_* files in the ITransitions folder, and computes steady-state participation, employment, and unemployment rates. Saves output in ISSrates/tinfile'_*.dta
*/
foreach tinfile in "TQSA" "QTSAsh" {
  include "L01_ComputeSSrates.do"
}

/* APPEND ALL BOOTSTRAPS
Iterates over all files in ISSrates and appends them in one file with a variable (nboot) indicating the bootstrap number of the observation (0 is the original data).
*/
local myfolder = "${ISSrates}"
foreach tinfile in "TQSA" "QTSAsh" {
  qui include "F04_AppendBoots.do"
}

/* COMPUTE bootstraping coefficients
Computes point estimates and bootstrap 95% confidence intervals.
*/
local alpha = 5
foreach tinfile in "TQSA" "QTSAsh" {
  local catvars = "sex DeNUN transtype"
  use "${ISSrates}Boots`tinfile'.dta", clear
  include "F05_ConfidenceIntervals.do"
  save "${ISSrates}CoefficientsCI`tinfile'.dta", replace
}

/* COMPUTE Summary statistics
Computes summary statistics for the following subsamples: 1976-2019, Expansions, Recessions, 1976-1979, 1980-1989, 1990-1999, 2000-2009, 2010-2019, 2020-2021.
*/
local alpha = 5
local lstats = "mean median min max p25 p75"
foreach tinfile in "TQSA" "QTSAsh" {
  local catvars = "sex DeNUN transtype"
  local bootsfile = "${ISSrates}Boots`tinfile'.dta"
  include "F06_SummaryStats_Q"
  save "${ISSrates}ASummaryStats`tinfile'.dta", replace
}
