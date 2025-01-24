// Save subsample
tempfile subsample
save `subsample', replace

// Keep singles and married
keep if transtype == 0

// Iterate over variables
foreach pe of varlist pe_* {
  // Define variable-related names
  local lb = subinstr("`pe'","pe_","lb_",.)
  local ub = subinstr("`pe'","pe_","ub_",.)
  local vname = subinstr("`pe'","pe_","",.)

  // Recession bounds
  * Lower
  summarize `lb'
  local ymin = `yinterval' * floor(`r(min)'/`yinterval')
  generate r_lb = Recession * `ymin' if Recession == 1
  * Upper
  summarize `ub'
  local ymax = `yinterval' * ceil(`r(max)'/`yinterval')
  generate r_ub = Recession * `ymax' if Recession == 1

  // Determine jump in y-axis
  local yjump = (`ymax'-`ymin')/5

  twoway (rbar r_lb r_ub Time, fcolor(gray%15) lcolor(gray%0)) ///
         (rarea `lb' `ub' Time if transtype == 0, fcolor(`c0'%10) lcolor(`c0'%0)) ///
         (line `pe' Time if transtype == 0, cmissing(n) lcolor(`c0') lpattern(solid)), ///
         ytitle("") xtitle("") tlabel(, format(%tqCCYY)) legend(off) ///
         ylabel(`ymin'(`yjump')`ymax')
         graph export "${Graphs}`myPrefix'_`tinfile'_Benchmark_`vname'_DeNUN`d'_sex`s'.png", ///
               width(1600) height(1200) replace
    drop r_*
}

// Load subsample
use `subsample', clear
