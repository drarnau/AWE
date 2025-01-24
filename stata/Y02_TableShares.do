// Labels
local lbl_inN = "Share of Non-participants among Married"
local lbl_NtoP = "Share of $ N$ to $ P$ among Non-participants"
local lbl_AWinNtoP = "Share of Added Workers among $ N$ to $ P$"

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
  use *_share* `catvars' grp column RWtype if grp == `g' using `grouped', clear
  drop grp

  // Create file name
  local fn = "`myPrefix'_Shares_`tinfile'"
  foreach cv of local catvars {
    summarize `cv'
    local fn = "`fn'_`cv'`r(mean)'"
  }
  drop `catvars'

  // Store values in locals
  summarize column
  local mincol = `r(min)'
  local maxcol = `r(max)'
  levelsof RWtype, local(lRWtype)
  summarize RWtype
  local minrw = `r(min)'

  // Iterate over RWtype
  local lbl: value label RWtype
  foreach rw of local lRWtype {
    // Store row name
    local rname_rw`rw': label `lbl' `rw'

    // Iterate over columns
    forvalues c = `mincol'/`maxcol' {
      // Store values
      foreach x in "pe" "pv" "ub" "lb" {
        foreach v of varlist `x'* {
          summarize `v' if RWtype == `rw' & column == `c'
          local aux = `r(mean)'
          local `v'_rw`rw'_c`c': di %4.3f `aux'
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
    di "\begin{tabular}{c|c|c|c|c|c|c|c|c}"
    di "\hline"
    di "\hline"
    di "1976 & & & 1976 & 1980 & 1990 & 2000 & 2010 & 2020 \\"
    di "to & Expansions & Recessions & to & to & to & to & to & to \\"
    di "2019 & & & 1979 & 1989 & 1999 & 2009 & 2019 & 2021 \\"
    di "\hline"
    // Iterate over shares
    foreach sh in "inN" "NtoP" "AWinNtoP" {
      // Print row title
      di "\noalign{\smallskip}"
      di "\multicolumn{9}{l}{\textbf{`lbl_`sh''}} \\"
      di "\noalign{\smallskip}"
      di "\hline"
      di ""

      // Iterate over RWtype depending on type of share
      if ("`sh'" == "AWinNtoP") {
        local mylst = "`lRWtype'"
      }
      else {
        local mylst = "`minrw'"
      }
      foreach rw of local mylst {
        // Print subtitle
        if ("`sh'" == "AWinNtoP") {
          di "\noalign{\smallskip}"
          di "\multicolumn{9}{l}{`rname_rw`rw''} \\"
          di "\noalign{\smallskip}"
          di "\hline"
          di ""
        }

        // Print point estimates
        forvalues c = `mincol'/`maxcol' {
          di _continue "`pe_share`sh'_rw`rw'_c`c''"
          if (`c' < `maxcol') {
            di _continue " &"
          }
        }
        di "\\"

        // Print confidence intervals
        forvalues c = `mincol'/`maxcol' {
          di "{\scriptsize (`lb_share`sh'_rw`rw'_c`c'', `ub_share`sh'_rw`rw'_c`c'')}"
          if (`c' < `maxcol') {
            di _continue " &"
          }
        }
        di "\\ [0.1cm]"
        di "\hline"

        // // Print p-value
        // foreach c of local lcolumn {
        //   di "{\scriptsize `pv_share`sh'_rw`rw'_c`c''}"
        //   if (`c' < `maxcol') {
        //     di _continue " &"
        //   }
        // }
        // di "\\ [0.1cm]"
        // di "\hline"
      }
    }
    di "\hline"
    di "\end{tabular}"
    di "}"
    qui log close
  }
}
