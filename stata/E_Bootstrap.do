// Save base datasets
* Individual
use cpsidp Time wtfinl Married sex EmSt* using"${Data}MyCPS.dta", clear
tempfile BaseI
save `BaseI'
* Household
use cpsid Time *tfinl ?EmSt* ?RW* using "${Data}MarriedCPS.dta", clear
tempfile BaseH
save `BaseH'

// Iterate over bootstraps
tempfile BSampleI
tempfile BSampleH
forvalues bk = 1/$K {
  timer on 99
  di "-------------------- Starting Iteration `bk' --------------------"

  qui {
    // Create bootstrapped samples
    * Individual
    use `BaseI', clear
    bsample, cluster(cpsidp)
    save `BSampleI', replace

    * Married
    use `BaseH', clear
    bsample, cluster(cpsid)
    save `BSampleH', replace

    // Define datasets to use
    local inddata = "`BSampleI'"
    local hhdata = "`BSampleH'"

    // Define checks on/off
    local mychecks = 0

    // Compute Flows
    include "C_ComputeFlows.do"

    // Compute Number of Added Workers
    include "D_ComputeNumSpRW.do"

    timer off 99
    timer list
  }

  DisplayTime, seconds(`r(t99)') msg("Time for iteration `bk':")
  timer clear 99
}
