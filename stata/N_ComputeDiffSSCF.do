/* COMPUTE differences
Iterates over all files in the ISSrates that contain seasonally-adjusted quarterly data and computes differences in participation, employment, unemployment rates for types of individual flows.
*/
foreach tinfile in "TQSA" "QTSAsh" {
  include "N01_ComputeDifferencesSSCF.do"
}

/* APPEND ALL BOOTSTRAPS
Iterates over all diff* files in ISSrates and appends them in one file with a variable (nboot) indicating the bootstrap number of the observation (0 is the original data).
*/
local myfolder = "${ISSrates}"
foreach tinfile in "diffTQSA" "diffQTSAsh" {
  include "F04_AppendBoots.do"
}

/* COMPUTE bootstraping coefficients
Computes point estimates and bootstrap 95% confidence intervals.
*/
local alpha = 5
local catvars = "sex DeNUN transtype"
foreach tinfile in "diffTQSA" "diffQTSAsh" {
  use "${ISSrates}Boots`tinfile'.dta", clear
  include "F05_ConfidenceIntervals.do"
  save "${ISSrates}CoefficientsCI`tinfile'.dta", replace
}

/* COMPUTE Summary statistics
Computes summary statistics for the following subsamples: 1976-2019, Expansions, Recessions, 1976-1979, 1980-1989, 1990-1999, 2000-2009, 2010-2019, 2020-2021.
*/
local alpha = 5
local lstats = "mean median min max p25 p75"
foreach tinfile in "diffTQSA" "diffQTSAsh" {
  local catvars = "sex DeNUN transtype"
  local bootsfile = "${ISSrates}Boots`tinfile'.dta"
  include "F06_SummaryStats_Q"
  save "${ISSrates}ASummaryStats`tinfile'.dta", replace
}
