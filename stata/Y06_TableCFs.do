// Combine Benchmark levels and CF difference
* Prepare Benchmark Steady-State levels
use * if transtype == 0 using "${ISSrates}ASummaryStats`tinfile'.dta", clear
tempfile benchmark
save `benchmark', replace

* Append CF difference
use * if transtype > 0 using "${ISSrates}ASummaryStatsdiff`tinfile'.dta", clear
`selcom' // Select counterfactual
rename *diff* **
append using `benchmark'
`statcom'

* Change labels
include "Y98_SplitRWlabels.do"
`changelbls'

// Create dataset with group indicators
* Create group indicator
egen grp = group(`catvars')
levelsof grp, local(levels)
* Save tempfile
tempfile grouped
save `grouped', replace

// Store list of relevant variables
local lvars = ""
foreach pe of varlist pe_* {
  local v = subinstr("`pe'","pe_","",.)
  local lvars = "`v' `lvars'"
}

// Iterate over groups
foreach g of local levels {
  // Itereate over relevant variables
  foreach v of local lvars {
    // Load data
    use ??_?rate `catvars' grp column transtype stattype if grp == `g' using `grouped', clear
    drop grp

    // Create file name
    local fn = "`myPrefix'_CFs_`tinfile'_`v'"
    foreach cv of local catvars {
      summarize `cv'
      local fn = "`fn'_`cv'`r(mean)'"
    }
    drop `catvars'

    // Store values in locals
    levelsof column, local(lcolumn)
    levelsof transtype, local(ltranstype) // Includes benchmark
    levelsof transtype if transtype > 0, local(lmytrans) // Excludes benchmark
    levelsof stattype, local(lstattype)

    // Iterate over stattype
    local lbl: value label transtype
    foreach s of local lstattype {
      // Store row name
      local aux: label lbl_stattype `s'
      local rname_s`s' = strproper("`aux'")

      // Iterate over types of transitions
      foreach tt of local ltranstype {
        // Store row name
        local rname_tt`tt': label `lbl' `tt'
        
        // Iterate over columns
        foreach c of local lcolumn {
          // Store values
          foreach x in "pe" "pv" "ub" "lb" {
            summarize `x'_`v' if stattype == `s' & transtype == `tt' & column == `c'
            local aux = `r(mean)'
            local `x'_s`s'_tt`tt'_c`c': di %4.3f `aux'
          }
        }
      }
    }

    // Print LaTeX Table
    set linesize 255
    forval k = 1/1 {
      di "{asis}"
      qui log using "${Tables}`fn'.tex", text replace
      di "\resizebox{\textwidth}{!}{"
      di "\begin{tabular}{l|c|c|c|c|c|c|c|c|c}"
      di "\hline"
      di "\hline"
      di "& 1976 & & & 1976 & 1980 & 1990 & 2000 & 2010 & 2020 \\"
      di "& to & Expansions & Recessions & to & to & to & to & to & to \\"
      di "& 2019 & & & 1979 & 1989 & 1999 & 2009 & 2019 & 2021 \\"
      di "\hline"
      // Steady state mean level
      * Print row name
      di "SS"

      * Print point estimates
      foreach c of local lcolumn {
        di _continue "& `pe_s1_tt0_c`c'' "
      }
      di "\\"

      // Print confidence intervals
      foreach c of local lcolumn {
        di "& {\scriptsize (`lb_s1_tt0_c`c'', `ub_s1_tt0_c`c'')}"
      }
      di "\\ [0.1cm]"
      di "\hline"

      // Iterate over counterfactuals
      foreach tt of local lmytrans {
        // Print row title
        di "\noalign{\smallskip}"
        di "\multicolumn{10}{l}{\textbf{`rname_tt`tt''}} \\"
        di "\noalign{\smallskip}"
        di "\hline"

        // Iterate over stattype
        foreach s of local lstattype {
          // Print row name
          di "`rname_s`s''"

          // Print point estimates
          foreach c of local lcolumn {
            di _continue "& `pe_s`s'_tt`tt'_c`c'' "
          }
          di "\\"

          // Print confidence intervals
          foreach c of local lcolumn {
            di "& {\scriptsize (`lb_s`s'_tt`tt'_c`c'', `ub_s`s'_tt`tt'_c`c'')}"
          }
          di "\\ [0.1cm]"
          di "\hline"
        }
      }
      di "\hline"
      di "\end{tabular}"
      di "}"
      qui log close
    }
  }
}
