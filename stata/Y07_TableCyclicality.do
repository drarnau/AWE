// Load data
use "${ISSrates}ASummaryStatsdiffcyc`tinfile'.dta", clear

// Format data to be atemporal and keep only correlation with GDP
keep if column == 1
drop column
drop *ratiosigmas*

// Apply selection criteria
`statcom'
`selcom'

// Change labels
include "Y98_SplitRWlabels.do"
`changelbls'

// Create dataset with group indicators
* Create group indicator
egen grp = group(`catvars')
levelsof grp, local(levels)
* Save tempfile
tempfile grouped
save `grouped', replace

// Iterate over groups
foreach g of local levels {
  // Load data
  use * if grp == `g' using `grouped', clear
  drop grp

  // Create file name
  local fn = "`myPrefix'_Cyc_`tinfile'"
  foreach cv of local catvars {
    summarize `cv'
    local fn = "`fn'_`cv'`r(mean)'"
  }
  drop `catvars'

  // Store values in locals
  levelsof transtype, local(ltranstype)

  // Iterate over types of transitions
  local lbl: value label transtype
  foreach tt of local ltranstype {
    // Store row name
    local rname_tt`tt': label `lbl' `tt'

    // Store values
    foreach x in "pe" "pv" "ub" "lb" {
      foreach s in "E" "U" "P" {
        summarize `x'_*_`s'rate if transtype == `tt'
        local aux = 100*`r(mean)'
        local `x'_`s'_tt`tt': di %4.3f `aux'
      }
    }
  }


  // Print LaTeX Table
  set linesize 255
  forval k = 1/1 {
    di "{asis}"
    qui log using "${Tables}`fn'.tex", text replace
    // di "\resizebox{\textwidth}{!}{"
    di "\begin{tabular}{l|c|c|c}"
    di "\hline"
    di "\hline"
    di "& Participation & Employment & Unemployment \\"
    di "& Rate          & Rate       & Rate \\"
    di "\hline"

    // Iterate over counterfactuals
    foreach tt of local ltranstype {
      // Print row name
      di "`rname_tt`tt''"

      // Print point estimates
      foreach s in "E" "U" "P" {
        di _continue "& `pe_`s'_tt`tt'' "
      }
      di _continue "\\"
      di ""

      // Print confidence intervals
      foreach s in "E" "U" "P" {
        di _continue "& {\scriptsize (`lb_`s'_tt`tt'', `ub_`s'_tt`tt'')}"
      }
      di "\\ [0.1cm]"
      di "\hline"
    }

    di "\hline"
    di "\end{tabular}"
    // di "}"
    qui log close
  }
}
