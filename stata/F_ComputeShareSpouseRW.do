/* COMPUTE Raw shares
Iterates over all files in the IFlows_M folder, merges flows with number of workers whose spouse is a removed worker (INumSpRW), save ther merged files in IFlows_M, and computes shares of workers whose spouse is a removed worker in all individual transitions.
*/
do "F01_ComputeRawShareSpouseRW.do"
do "F01a_ComputeRawShareRW.do"

/* SEASONALLY ADJUST Raw shares
Iterates over all Raw_* files in the IShareSpRW folder, and seasonally adjusts all relevant variables (those not in `catvars'). Saves output in IShareSpRW/SA_*.dta
*/
local myfolder = "${IShareSpRW}"
local catvars = "sex DeNUN RWtype"
local SAmethod = ""
foreach x in "" "a" {
  local tinfile = "`x'Raw"
  local toutfile = "`x'SA"
  include "F02_SeasonallyAdjust.do"
}

/* SEASONALLY ADJUST as Shimer Raw shares
Iterates over all Raw_* files in the IShareSpRW folder, and seasonally adjusts following Shimer's method all relevant variables (those not in `catvars'). Saves output in IShareSpRW/SAsh_*.dta
*/
local myfolder = "${IShareSpRW}"
local catvars = "sex DeNUN RWtype"
local SAmethod = "shimer"
foreach x in "" "a" {
  local tinfile = "`x'Raw"
  local toutfile = "`x'SAsh"
  include "F02_SeasonallyAdjust.do"
}

/* QUARTERLY AVERAGE seasonally-adjusted shares
Iterates over all SA_* and SAsh_* files in the IShareSpRW folder, and transforms the data into quarterly averages. Saves output in IShareSpRW/QSA_*.dta and /QSAsh_*.dta.
*/
local myfolder = "${IShareSpRW}"
local catvars = "sex DeNUN RWtype"
foreach x in "" "a" {
  foreach tinfile in "`x'SA" "`x'SAsh" {
    local toutfile = "Q`tinfile'"
    include "F03_QuarterlyAverage.do"
  }
}

/* APPEND ALL BOOTSTRAPS
Iterates over all files in IShareSpRW and appends them in one file with a variable (nboot) indicating the bootstrap number of the observation (0 is the original data).
*/
local myfolder = "${IShareSpRW}"
foreach x in "" "a" {
  foreach tinfile in "Q`x'SA" "Q`x'SAsh" {
    include "F04_AppendBoots.do"
  }
}

/* COMPUTE bootstraping coefficients
Computes point estimates and bootstrap 95% confidence intervals.
*/
local alpha = 5
local catvars = "sex DeNUN RWtype"
foreach x in "" "a" {
  foreach tinfile in "Q`x'SA" "Q`x'SAsh" {
    use "${IShareSpRW}Boots`tinfile'.dta", clear
    include "F05_ConfidenceIntervals.do"
    save "${IShareSpRW}CoefficientsCI`tinfile'.dta", replace
  }
}

/* COMPUTE Summary statistics
Computes summary statistics for the following subsamples: 1976-2019, Expansions, Recessions, 1976-1979, 1980-1989, 1990-1999, 2000-2009, 2010-2019, 2020-2021.
*/
local alpha = 5
local lstats = "mean median min max p25 p75"
foreach x in "" "a" {
  foreach tinfile in "Q`x'SA" "Q`x'SAsh" {
    local catvars = "sex DeNUN RWtype"
    local bootsfile = "${IShareSpRW}Boots`tinfile'.dta"
    include "F06_SummaryStats_Q"
    save "${IShareSpRW}ASummaryStats`tinfile'.dta", replace
  }
}
