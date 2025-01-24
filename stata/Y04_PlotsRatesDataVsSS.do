// Define matching SS files
local ss_QSA = "TQSA"
local ss_QSAsh = "QTSAsh"

// y-axis interval
local yinterval = 5

// Define colors for each type of transition
include "Y99_PlotsColors.do"

// Load SS approximations
use "${ISSrates}CoefficientsCI`ss_`tinfile''.dta", clear

// Prepare for appending
rename transtype flowtype
generate SSaprox = 1

// Append with data
append using "${IRates}CoefficientsCI`tinfile'.dta"
replace SSaprox = 0 if SSaprox == .

// Merge Recessions data
merge m:1 Time using "${Recessions}", nogenerate

// Drop pandemic and after
drop if Time >= yq(2020,1)

// Plot only benchmark
keep if flowtype == 0

// Store levels of flowtype
levelsof flowtype, local(lflowtype)

// Save tempfile
tempfile allcoefs
save `allcoefs', replace

// Iterate over DeNUN, sex, and flowtype
forvalues d = 0/1 { // DeNUN
forvalues s = 1/2 { // sex
foreach ft of local lflowtype { // flowtype
  // Deterime color
  local myc = max(0, `ft' - mod(`ft', 10))
  local myc = "`c`myc''"

  // Load subsample
  use * if DeNUN == `d' & sex == `s' & flowtype == `ft' using `allcoefs', clear

  // Iterate over variables
  foreach pe of varlist pe_* {
    // Define variable-related names
    local lb = subinstr("`pe'","pe_","lb_",.)
    local ub = subinstr("`pe'","pe_","ub_",.)
    local vname = subinstr("`pe'","pe_","",.)

    // Recession bounds
    * Lower
    local ymin = 0
    generate r_lb = Recession * `ymin' if Recession == 1
    * Upper
    if ("`vname'" == "Urate") {
      local ymax = 10
    }
    else {
      local ymax = 100
    }
    generate r_ub = Recession * `ymax' if Recession == 1

    // Determine jump in y-axis
    local yjump = (`ymax'-`ymin')/5

    twoway (rbar r_lb r_ub Time, fcolor(gray%5) lcolor(gray%0)) ///
           (rarea `lb' `ub' Time if SSaprox == 0, fcolor(`myc'%20) lcolor(`myc'%0)) ///
           (line `pe' Time if SSaprox == 0, cmissing(n) lcolor(`myc') lpattern(solid)) ///
           (rarea `lb' `ub' Time if SSaprox == 1, fcolor(`myc'%10) lcolor(`myc'%0)) ///
           (line `pe' Time if SSaprox == 1, cmissing(n) lcolor(`myc') lpattern(dash)), ///
           ytitle("") xtitle("") tlabel(, format(%tqCCYY)) legend(off) ///
           ylabel(`ymin'(`yjump')`ymax')
           graph export ///
           "${Graphs}`myPrefix'_`tinfile'_`vname'_DeNUN`d'_sex`s'_flowtype`ft'.png", ///
           width(1600) height(1200) replace
    drop r_*
  }
}
}
}
