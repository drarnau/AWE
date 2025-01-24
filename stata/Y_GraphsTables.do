/* TABLES Regression Coefficients with all transitions together */
include "Y01a_SplitRWtypes.do"
foreach x in "AllUne" "JobLos" {
  local myPrefix = "Y01_`x'"
  local catvars = "DeNUN sex controls"
  use "${ITransitions}ARegCoeffColumns`x'.dta", clear
  include "Y01_TablesRegCoeff.do"
}

/* TABLES Shares including shares of added workers*/
local catvars = "DeNUN sex"
foreach tinfile in "QaSAsh" {
  include "Y02a_SplitRWtypes.do"
  foreach trw in "AllUne" "JobLos" {
    local myPrefix = "Y02_`trw'"
    use "${IShareSpRW}ASummaryStats`tinfile'`trw'.dta", clear
    keep if stattype == 1 // NOTE: Code can handle just ONE stat: Use mean
    include "Y02_TableShares.do"
  }
}

/* PLOT Transitions*/
foreach tinfile in "TQSA" {
  local myPrefix = "Y03"
  include "Y03_PlotsTransitions_Q.do"
}

/* PLOT Rates Data vs SS aproximation */
foreach tinfile in "QSA" {
  local myPrefix = "Y04"
  include "Y04_PlotsRatesDataVsSS.do"
}

/* PLOT Counterfactuals */
foreach tinfile in "diffTQSA" {
  local myPrefix = "Y05"
  local catvars = "sex DeNUN transtype"
  include "Y05_PlotsCFs.do"
}

/* TABLES Counterfactuals */
local catvars = "DeNUN sex"
local tinfile = "QTSAsh"
local statcom = "keep if stattype == 1 | stattype >= 4"
local changelbls = "label values transtype lbl_RWsplit"
* AW does NOT enter, Job Losers Only
local myPrefix = "Y06no_JobLos"
local selcom = "keep if transtype == 31 | transtype == 33"
include "Y06_TableCFs.do"
* AW does NOT enter, All Unemployed
local myPrefix = "Y06no_AllUne"
local selcom = "keep if transtype == 32 | transtype == 34"
include "Y06_TableCFs.do"
* AW enters with same probability, All Unemployed
local myPrefix = "Y06same_AllUne"
local selcom = "keep if transtype == 42 | transtype == 44"
include "Y06_TableCFs.do"

/* TABLES counterfactual cyclicality */
local catvars = "DeNUN sex"
local tinfile = "QTSAsh"
local statcom = "keep if stattype == 1"
local changelbls = "label values transtype lbl_RWsplit"
* AW does NOT enter, All Unemployed
local myPrefix = "Y07no_AllUne"
local selcom = "keep if transtype == 32 | transtype == 34"
include "Y07_TableCyclicality.do"

/* PLOT Counterfactuals DeNUN vs NOT*/
foreach tinfile in "diffTQSA" {
  local myPrefix = "Y08"
  local catvars = "sex transtype"
  include "Y08_PlotsCFs_DeNUN.do"
}
