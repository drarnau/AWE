/* COMPUTE Raw rates
Iterates over all files in the IFlows and computes the participation, employment, unemployment rates for types of individual flows.
*/
do "K01_ComputeRawRates.do"

/* SEASONALLY ADJUST Raw rates
Iterates over all Raw_* files in the IRates folder, and seasonally adjusts all relevent variables (those not in `catvars'). Saves output in IRates/SA_*.dta
*/
local myfolder = "${IRates}"
local tinfile = "Raw"
local catvars = "sex DeNUN flowtype"
local SAmethod = ""
local toutfile = "SA"
include "F02_SeasonallyAdjust.do"

/* SEASONALLY ADJUST as Shimer Raw rates
Iterates over all Raw_* files in the IRates folder, and seasonally adjusts following Shimer's method all relevent variables (those not in `catvars'). Saves output in IRates/SAsh_*.dta
*/
local myfolder = "${IRates}"
local tinfile = "Raw"
local catvars = "sex DeNUN flowtype"
local SAmethod = "shimer"
local toutfile = "SAsh"
include "F02_SeasonallyAdjust.do"

/* QUARTERLY AVERAGE seasonally-adjusted rates
Iterates over all SA_* and SAsh_* files in the IRates folder, and transforms the data into quarterly averages. Saves output in IRates/QSA_*.dta and /QSAsh_*.dta.
*/
local myfolder = "${IRates}"
local catvars = "sex DeNUN flowtype"
foreach tinfile in "SA" "SAsh" {
  local toutfile = "Q`tinfile'"
  include "F03_QuarterlyAverage.do"
}

/* APPEND ALL BOOTSTRAPS
Iterates over all files in IRates and appends them in one file with a variable (nboot) indicating the bootstrap number of the observation (0 is the original data).
*/
local myfolder = "${IRates}"
foreach tinfile in "QSA" "QSAsh" {
  include "F04_AppendBoots.do"
}

/* COMPUTE bootstraping coefficients
Computes point estimates and bootstrap 95% confidence intervals.
*/
local alpha = 5
local catvars = "sex DeNUN flowtype"
foreach tinfile in "QSA" "QSAsh" {
  use "${IRates}Boots`tinfile'.dta", clear
  include "F05_ConfidenceIntervals.do"
  save "${IRates}CoefficientsCI`tinfile'.dta", replace
}

/* COMPUTE Summary statistics
Computes summary statistics for the following subsamples: 1976-2019, Expansions, Recessions, 1976-1979, 1980-1989, 1990-1999, 2000-2009, 2010-2019, 2020-2021.
*/
local alpha = 5
local lstats = "mean median min max p25 p75"
foreach tinfile in "QSA" "QSAsh" {
  local catvars = "sex DeNUN flowtype"
  local bootsfile = "${IRates}Boots`tinfile'.dta"
  include "F06_SummaryStats_Q"
  save "${IRates}ASummaryStats`tinfile'.dta", replace
}
