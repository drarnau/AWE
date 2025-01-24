// Labels to aid translation into categorical variables
* DeNUN
local lbld0 = ""
local lbld1 = "C"
* Sex (s) and spouse's sex (z)
local lbls1 = "h"
local lblz1 = "w"
local lbls2 = "w"
local lblz2 = "h"
* Controls
local lblc0 = ""
local lblc1 = "`ctrls'"

// Load data
use "${Data}MarriedCPS.dta", clear

// Identify recessions
rename Time mTime
* Quarterly time
gen Time = qofd(dofm(mTime))
format %tq Time
* Merge Recessions data
merge m:1 Time using "${Recessions}", nogen
drop Time
rename mTime Time

// Define columns
* 1976-2019
generate clmn1 = 1 if Time < ym(2020,1)
* 2-3 subsample/column: 1976-2019 expansions vs. recessions
generate clmn2 = 1 if Time < ym(2020,1) & Recession == 0
generate clmn3 = 1 if Time < ym(2020,1) & Recession == 1
* 4-9 subsample/column: Decades
drop if Time >= ym(2022,1)
generate decade = year(dofm(Time)) - mod(year(dofm(Time)),10)
local k = 4
forvalues dcd = 1970(10)2020 {
  generate clmn`k' = 1 if decade == `dcd'
  local k = `k' + 1
}
drop decade Recession

// Iterate over DeNUN categories & sex
forvalues d = 0/1 {
forvalues s = 1/2 {
  // Name useful variables
  local sEmSt = "`lbls`s''EmSt`lbld`d''"
  local zEmSt = "`lblz`s''EmSt`lbld`d''"
  local RW = "`lblz`s''RW"

  // Define independent variables
  * N to E
  generate auxE = 0 if `sEmSt'Lm == 30 & `zEmSt'Lm == 10
  replace auxE = 1 if `sEmSt'Lm == 30 & `zEmSt'Lm == 10 & `sEmSt' == 10
  * N to U
  generate auxU = 0 if `sEmSt'Lm == 30 & `zEmSt'Lm == 10
  replace auxU = 1 if `sEmSt'Lm == 30 & `zEmSt'Lm == 10 & `sEmSt' == 20
  * N to P (E or U)
  generate auxP = 0 if `sEmSt'Lm == 30 & `zEmSt'Lm == 10
  replace auxP = 1 if `sEmSt'Lm == 30 & `zEmSt'Lm == 10 & (`sEmSt' == 10 | `sEmSt' == 20)

  // Define dependent variables
  * Contemporaneous job losers only
  generate auxRW1 = `RW'jloser_t
  * Contemporaneous all unemployed
  generate auxRW2 = `RW'all_t
  * Leads and lags job losers only
  generate auxRW3 = 0 if (`RW'jloser_t == 0 | `RW'jloser_tp1 == 0 | `RW'jloser_tp2 == 0 | ///
                                              `RW'jloser_tm1 == 0 | `RW'jloser_tm2 == 0)
  replace auxRW3 = 1 if (`RW'jloser_t == 1 | `RW'jloser_tp1 == 1 | `RW'jloser_tp2 == 1 | ///
                                             `RW'jloser_tm1 == 1 | `RW'jloser_tm2 == 1)
  * Leads and lags all unemployed
  generate auxRW4 = 0 if (`RW'all_t == 0 | `RW'all_tp1 == 0 | `RW'all_tp2 == 0 | ///
                                           `RW'all_tm1 == 0 | `RW'all_tm2 == 0)
  replace auxRW4 = 1 if (`RW'all_t == 1 | `RW'all_tp1 == 1 | `RW'all_tp2 == 1 | ///
                                          `RW'all_tm1 == 1 | `RW'all_tm2 == 1)

  // Iterate over columns
  forvalues clmn = 1/9 {
  forvalues c = 0/1 { // Iterate over controls
  forvalues rw = 1/4 { // Iterate over dependent variables
  foreach ivar in "E" "U" "P" { // Iterate over independent variable
    // Regression
    regress aux`ivar' auxRW`rw' `lblc`c'' ///
      if clmn`clmn' == 1 [pw = `lbls`s''Wtfinl]

    // Store coefficients
    * Point estimate
    local pe_`ivar'_d`d'_s`s'_rw`rw'_c`c'_clmn`clmn' = ///
      _b[auxRW`rw']
    * p-value
    local pv_`ivar'_d`d'_s`s'_rw`rw'_c`c'_clmn`clmn' = ///
      2*ttail(e(df_r),abs((_b[auxRW`rw']/_se[auxRW`rw'])))
    * Lower bound (95%)
    local lb_`ivar'_d`d'_s`s'_rw`rw'_c`c'_clmn`clmn' = ///
      _b[auxRW`rw'] - invttail(e(df_r),0.025)*_se[auxRW`rw']
    * Upper bound (95%)
    local ub_`ivar'_d`d'_s`s'_rw`rw'_c`c'_clmn`clmn' = ///
      _b[auxRW`rw'] + invttail(e(df_r),0.025)*_se[auxRW`rw']
  }
  }
  }
  }

  // Drop auxiliary variables
  drop aux*
}
}

// Create dataset to store results
keep if _n == 1
expand 9
generate column = _n
keep column
* DeNUN
expand 2, generate(DeNUN)
* sex
expand 2, generate(sex)
replace sex = sex + 1
* controls
expand 2, generate(controls)
* RWtypes
expand 4, generate(RWtype)
bysort column DeNUN sex controls: replace RWtype = _n

// Fill dataset
foreach ivar in "E" "U" "P" { // Iterate over independent variable
foreach stat in "pe" "pv" "lb" "ub" { // Iterate over statistics
  // Generate empty variable
  generate `stat'_to`ivar' = .

  forvalues d = 0/1 {
  forvalues s = 1/2 {
  forvalues c = 0/1 {
  forvalues rw = 1/4 {
  forvalues clmn = 1/9 {
    replace `stat'_to`ivar' = ``stat'_`ivar'_d`d'_s`s'_rw`rw'_c`c'_clmn`clmn'' if ///
      column == `clmn' & RWtype == `rw' & controls == `c' & sex == `s' & DeNUN == `d'
  }
  }
  }
  }
  }
}
}

// Label DeNUN variable
label variable DeNUN "Indicates DeNUNified version"
label values DeNUN lbl_dummy

// Label sex
label variable sex "Sex of worker in the flow"
label define lbl_sex 1 "Male" ///
                     2 "Female"
label values sex lbl_sex

// Label RWtype
label variable RWtype "Type of removed worker"
label define lbl_RWtype 0 "Benchmark" ///
                        1 "Contemporaneous job losers only" ///
                        2 "Contemporaneous all unemployed" ///
                        3 "Leads and lags job losers only" ///
                        4 "Leads and lags all unemployed"
label values RWtype lbl_RWtype

// Label controls
label variable controls "Regression includes controls"
label values controls lbl_dummy

// Label variable column
label variable column "Subsample used to compute stats"
label define lbl_column 1 "1976-2019" ///
                        2 "Expansions" ///
                        3 "Recessions" ///
                        4 "1976-1979" ///
                        5 "1980-1989" ///
                        6 "1990-1999" ///
                        7 "2000-2009" ///
                        8 "2010-2019" ///
                        9 "2020-2021"
label values column lbl_column

// Save
save "${ITransitions}ARegCoeffColumns.dta", replace
