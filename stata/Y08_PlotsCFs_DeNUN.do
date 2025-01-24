// Define colors for each type of transition
include "Y99_PlotsColors.do"

// Load data
use "${ISSrates}CoefficientsCI`tinfile'.dta", clear

// Merge Recessions data
merge m:1 Time using "${Recessions}", nogen

// Choose desired counterfactuals
keep if transtype == 32 | transtype == 34
keep if sex == 2

// Create dataset with group indicators
* Create group indicator
egen grp = group(`catvars')
levelsof grp, local(levels)
* Save tempfile
tempfile grouped
save `grouped', replace

// Iterate over groups
foreach g of local levels {
  use * if grp == `g' using `grouped', clear

  // Choose color based on transtype
  summarize transtype
  local clr = mod(`r(mean)', 10)

  // Create file name
  local fn = "`myPrefix'_CFs_`tinfile'"
  foreach cv of local catvars {
    summarize `cv'
    local fn = "`fn'_`cv'`r(mean)'"
  }

  foreach pe of varlist pe_* {
    // Define variable-related names
    local lb = subinstr("`pe'","pe_","lb_",.)
    local ub = subinstr("`pe'","pe_","ub_",.)
    local vname = subinstr("`pe'","pe_","",.)

    // Recession bounds
    * Override bounds
    summarize transtype
    if (`r(mean)' < 40) { // No entry
      local ymax = 2
      local ymin = -0.25
      local yjump = 0.5
    }
    else { // Same probability of entry
      local ymax = 1
      local ymin = -0.25
      local yjump = 0.25
    }
    * Lower
    summarize `lb'
    // local ymin = floor(`r(min)')
    generate r_lb = Recession * `ymin' if Recession == 1
    * Upper
    summarize `ub'
    // local ymax = ceil(`r(max)')
    generate r_ub = Recession * `ymax' if Recession == 1

    // Plot
    twoway (rbar r_lb r_ub Time, fcolor(gray%5) lcolor(gray%0)) ///
           (rarea `lb' `ub' Time if DeNUN == 0, ///
            fcolor(`cr`clr''%20) lcolor(`cr`clr''%0)) ///
           (line `pe' Time if DeNUN == 0, ///
            cmissing(n) lcolor(`cr`clr'') lpattern(dash)) ///
           (rarea `lb' `ub' Time if DeNUN == 1, ///
            fcolor(`cr`clr''%20) lcolor(`cr`clr''%0)) ///
           (line `pe' Time if DeNUN == 1, ///
            cmissing(n) lcolor(`cr`clr'') lpattern(solid)), ///
           yline(0, lcolor(black)) ///
           ylabel(`ymin'(`yjump')`ymax') ///
           ytitle("") xtitle("") tlabel(, format(%tqCCYY)) legend(off)
           graph export "${Graphs}`fn'_`vname'.png", ///
                width(1600) height(1200) replace
    drop r_*
  }
}
