/* COMPUTE Raw transitions
Iterates over all files in the IFlows folder and computes all individual transitions.
*/
do "H01_ComputeRawITransitions.do"

/* SEASONALLY ADJUST Raw transitions
Iterates over all Raw_* files in the ITransitions folder, and seasonally adjusts all relevent variables (those not in `catvars'). Saves output in ITransitions/SA_*.dta
*/
local myfolder = "${ITransitions}"
local tinfile = "Raw"
local catvars = "sex DeNUN transtype"
local SAmethod = ""
local toutfile = "SA"
include "F02_SeasonallyAdjust.do"

/* SEASONALLY ADJUST as Shimer Raw transitions
Iterates over all Raw_* files in the ITransitions folder, and seasonally adjusts following Shimer's method all relevent variables (those not in `catvars'). Saves output in ITransitions/SA_*.dta
*/
local myfolder = "${ITransitions}"
local tinfile = "Raw"
local catvars = "sex DeNUN transtype"
local SAmethod = "shimer"
local toutfile = "SAsh"
include "F02_SeasonallyAdjust.do"

/* QUARTERLY AVERAGE seasonally-adjusted transitions
Iterates over all SA_* files in the ITransitions folder, and transforms the data into quarterly averages. Saves output in ITransitions/QSA_*.dta
*/
local myfolder = "${ITransitions}"
local tinfile = "SA"
local catvars = "sex DeNUN transtype"
local toutfile = "QSA"
include "F03_QuarterlyAverage.do"

/* CORRECT FOR TIME-AGGREGATION BIAS Shimer seasonally-adjusted
Iterates over all SAsh_* files in the ITransitions folder and corrects for time aggregation bias all individual transitions. Saves output in ITransitions/TSAsh_*.dta
*/
local tinfile = "SAsh"
local catvars = "DeNUN sex transtype"
local toutfile = "TSAsh"
include "H02_TAITransitions.do"

/* CORRECT FOR TIME-AGGREGATION BIAS quarterly seasonally-adjusted
Iterates over all QSA_* files in the ITransitions folder and corrects for time aggregation bias all individual transitions. Saves output in ITransitions/TQSA_*.dta
*/
local tinfile = "QSA"
local catvars = "DeNUN sex transtype"
local toutfile = "TQSA"
include "H02_TAITransitions.do"

/* QUARTERLY AVERAGE corrected shimer seasonally-adjusted transitions
Iterates over all TSAsh_* files in the ITransitions folder, and transforms the data into quarterly averages. Saves output in ITransitions/QTSAsh_*.dta
*/
local myfolder = "${ITransitions}"
local tinfile = "TSAsh"
local catvars = "sex DeNUN transtype"
local toutfile = "QTSAsh"
include "F03_QuarterlyAverage.do"

/* APPEND ALL BOOTSTRAPS
Iterates over all files in ITransitions and appends them in one file with a variable (nboot) indicating the bootstrap number of the observation (0 is the original data).
*/
local myfolder = "${ITransitions}"
foreach tinfile in "TQSA" "QTSAsh" {
  qui include "F04_AppendBoots.do"
}

/* COMPUTE bootstraping coefficients
Computes point estimates and bootstrap 95% confidence intervals.
*/
local alpha = 5
foreach tinfile in "TQSA" "QTSAsh" {
  local catvars = "sex DeNUN transtype"
  use "${ITransitions}Boots`tinfile'.dta", clear
  include "F05_ConfidenceIntervals.do"
  save "${ITransitions}CoefficientsCI`tinfile'.dta", replace
}

/* COMPUTE Summary statistics
Computes summary statistics for the following subsamples: 1976-2019, Expansions, Recessions, 1976-1979, 1980-1989, 1990-1999, 2000-2009, 2010-2019, 2020-2021.
*/
local alpha = 5
local lstats = "mean median min max p25 p75"
foreach tinfile in "TQSA" "QTSAsh" {
  local catvars = "sex DeNUN transtype"
  local bootsfile = "${ITransitions}Boots`tinfile'.dta"
  include "F06_SummaryStats_Q"
  save "${ITransitions}ASummaryStats`tinfile'.dta", replace
}
