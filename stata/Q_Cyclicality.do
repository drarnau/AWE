/* COMPUTE cyclical moments
Iterates over all files in specified folder, computes cyclcical component of logged rates, correlation of these with GDP and ratios of standard deviations.
*/
local tindir = "${IRates}"
local catvars = "sex DeNUN flowtype"
local timecom = "drop if Time > yq(2021,4)"
local selcom = "keep if flowtype == 0"
foreach tinfile in "QSA" "QSAsh" {
  include "Q01_ComputeCyclicalMoments.do"
}

local tindir = "${ISSrates}"
local catvars = "sex DeNUN transtype"
local timecom = "drop if Time > yq(2021,4)"
local selcom = "keep if transtype == 0 | transtype > 30"
foreach tinfile in "TQSA" "QTSAsh" {
  include "Q01_ComputeCyclicalMoments.do"
}

/* Compute differences between data and steady-state approximation
Iterates over all files in the IRates that contain seasonally-adjusted quarterly data, merges it with correspondent file in ISSrates and computes differences in cyclical moments in participation, employment, and unemployment rates.
*/
foreach tinfile in "cycQSA" "cycQSAsh" {
  include "Q02_ComputeDifferencesDataSS.do"
}

/* COMPUTE differences between steady-state approximation and counterfactuals
Iterates over all files in the ISSrates that contain seasonally-adjusted quarterly data and computes differences in cyclical moments in participation, employment, unemployment rates for types of individual flows.
*/
foreach tinfile in "cycTQSA" "cycQTSAsh" {
  include "Q03_ComputeDifferencesSSCF.do"
}

/* APPEND ALL BOOTSTRAPS
Iterates over all diff* files in IRates and ISSrates and appends them in one file with a variable (nboot) indicating the bootstrap number of the observation (0 is the original data).
*/
local myfolder = "${IRates}"
foreach tinfile in "diffcycQSA" "diffcycQSAsh" {
  include "F04_AppendBoots.do"
}

local myfolder = "${ISSrates}"
foreach tinfile in "diffcycTQSA" "diffcycQTSAsh" {
  include "F04_AppendBoots.do"
}

/* COMPUTE bootstraping coefficients
Computes point estimates and bootstrap 95% confidence intervals.
*/
local alpha = 5
local catvars = "sex DeNUN flowtype"
foreach tinfile in "diffcycQSA" "diffcycQSAsh" {
  use "${IRates}Boots`tinfile'.dta", clear
  include "F05_ConfidenceIntervals.do"
  save "${IRates}CoefficientsCI`tinfile'.dta", replace
}

local alpha = 5
local catvars = "sex DeNUN transtype"
foreach tinfile in "diffcycTQSA" "diffcycQTSAsh" {
  use "${ISSrates}Boots`tinfile'.dta", clear
  include "F05_ConfidenceIntervals.do"
  save "${ISSrates}CoefficientsCI`tinfile'.dta", replace
}

/* COMPUTE Summary statistics
Computes summary statistics for the following subsamples: 1976-2019, Expansions, Recessions, 1976-1979, 1980-1989, 1990-1999, 2000-2009, 2010-2019, 2020-2021.
*/
local alpha = 5
local lstats = "mean median min max p25 p75"
foreach tinfile in "diffcycQSA" "diffcycQSAsh" {
  local catvars = "sex DeNUN flowtype"
  local bootsfile = "${IRates}Boots`tinfile'.dta"
  include "F06_SummaryStats_Q"
  save "${IRates}ASummaryStats`tinfile'.dta", replace
}

local alpha = 5
local lstats = "mean median min max p25 p75"
foreach tinfile in "diffcycTQSA" "diffcycQTSAsh" {
  local catvars = "sex DeNUN transtype"
  local bootsfile = "${ISSrates}Boots`tinfile'.dta"
  include "F06_SummaryStats_Q"
  save "${ISSrates}ASummaryStats`tinfile'.dta", replace
}
