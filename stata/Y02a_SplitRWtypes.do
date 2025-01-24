// Load data
use "${IShareSpRW}ASummaryStats`tinfile'.dta", clear
include "Y98_SplitRWlabels.do"
label values RWtype lbl_RWsplit
tempfile all
save `all', replace

// All Unemployed
use `all', clear
keep if RWtype == 2 | RWtype == 4
save "${IShareSpRW}ASummaryStats`tinfile'AllUne.dta", replace

// Job Losers Only
use `all', clear
keep if RWtype == 1 | RWtype == 3
save "${IShareSpRW}ASummaryStats`tinfile'JobLos.dta", replace
