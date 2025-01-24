/* COMPUTE differences
Iterates over all files in the IRates that contain seasonally-adjusted quarterly data, merges it with correspondent file in ISSrates  and computes differences in participation, employment, unemployment rates for types of individual flows.
*/
foreach tinfile in "QSA" "QSAsh" {
  include "M01_ComputeDifferencesDataSS.do"
}

/* COMPUTE R^2
Iterates over all files in the IRates that contain seasonally-adjusted quarterly data, merges it with correspondent file in ISSrates  and computes R^2 in participation, employment, unemployment rates for types of individual flows.
*/
foreach tinfile in "QSA" "QSAsh" {
  include "M02_ComputeR2DataSS.do"
}

/* APPEND ALL BOOTSTRAPS
Iterates over all diff* files in IRates and appends them in one file with a variable (nboot) indicating the bootstrap number of the observation (0 is the original data).
*/
local myfolder = "${IRates}"
foreach tinfile in "diffQSA" "diffQSAsh" "r2QSA" "r2QSAsh" {
  include "F04_AppendBoots.do"
}

/* COMPUTE bootstraping coefficients
Computes point estimates and bootstrap 95% confidence intervals.
*/
local alpha = 5
local catvars = "sex DeNUN flowtype"
foreach tinfile in "diffQSA" "diffQSAsh" "r2QSA" "r2QSAsh" {
  use "${IRates}Boots`tinfile'.dta", clear
  include "F05_ConfidenceIntervals.do"
  save "${IRates}CoefficientsCI`tinfile'.dta", replace
}

/* COMPUTE Summary statistics
Computes summary statistics for the following subsamples: 1976-2019, Expansions, Recessions, 1976-1979, 1980-1989, 1990-1999, 2000-2009, 2010-2019, 2020-2021.
*/
local alpha = 5
local lstats = "mean median min max p25 p75"
foreach tinfile in "diffQSA" "diffQSAsh" "r2QSA" "r2QSAsh" {
  local catvars = "sex DeNUN flowtype"
  local bootsfile = "${IRates}Boots`tinfile'.dta"
  include "F06_SummaryStats_Q"
  save "${IRates}ASummaryStats`tinfile'.dta", replace
}
