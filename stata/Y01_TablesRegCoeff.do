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
  use *_to? `catvars' grp column RWtype if grp == `g' using `grouped', clear
  drop grp

  // Create file name
  local fn = "`myPrefix'_RegCoeff"
  foreach cv of local catvars {
    summarize `cv'
    local fn = "`fn'_`cv'`r(mean)'"
  }
  drop `catvars'

  // Store values in locals
  levelsof column, local(lcolumn)
  levelsof RWtype, local(lRWtype)

  // Iterate over RWtype
  local lbl: value label RWtype
  foreach rw of local lRWtype {
    // Store row name
    local rname_rw`rw': label `lbl' `rw'

    // Iterate over columns
    foreach c of local lcolumn {
      // Store values
      foreach x in "pe" "pv" "ub" "lb" {
        foreach v of varlist `x'* {
          summarize `v' if RWtype == `rw' & column == `c'
          local aux = `r(mean)'*100
          local `v'_rw`rw'_c`c': di %4.3f `aux'
        }
      }
    }
  }

  // Print LaTeX Table
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
    // Iterate over RWtype
    foreach rw of local lRWtype {
      // Print row title
      di "\noalign{\smallskip}"
      di "\multicolumn{10}{l}{\textbf{`rname_rw`rw''}} \\"
      di "\noalign{\smallskip}"
      di "\hline"

      // Iterate over controls vs no controls
      foreach t in "P" "E" "U" {
        // Print row name
        di "N to `t'"

        // Print point estimates
        foreach c of local lcolumn {
          di _continue "& `pe_to`t'_rw`rw'_c`c'' "
        }
        di "\\"

        // Print confidence intervals
        foreach c of local lcolumn {
          di "& {\scriptsize (`lb_to`t'_rw`rw'_c`c'', `ub_to`t'_rw`rw'_c`c'')}"
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
