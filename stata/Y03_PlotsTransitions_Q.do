// y-axis interval
local yinterval = 5

// Define colors for each type of transition
include "Y99_PlotsColors.do"

// Load data
use "${ITransitions}CoefficientsCI`tinfile'.dta", clear
* Merge Recessions data
merge m:1 Time using "${Recessions}", nogen
* Drop pandemic and after
drop if Time >= yq(2020,1)
* Save tempfile
tempfile allcoefs
save `allcoefs', replace

// Iterate over DeNUN
forvalues d = 0/1 {
  // Iterate over sex
  forvalues s = 1/2 {
    // Load subsample
    use * if DeNUN == `d' & sex == `s' using `allcoefs', clear

    // Benchmark
    include "Y03a_PlotsTransitions_Q_Benchmark.do"
  }
}
