/* CREATE MyTime
Creates MyTime to proprely classify survey period using Stata format.
*/
do "B01_CreateMyTime.do"

// Drop unused variables & observations
drop asecflag hwtfinl month pernum serial
drop if age < 16

/* Link across panel dimension
Creates multiple variables containing the `myvars' of each individual in the different months in the sample.
Applies consistency checks on age, race, and sex.
*/
local myvars = "empstat whyunemp ind1950 occ2010" // variables to copy across mish
include "B02_LinkMonths.do"

/* CREATE MyEmSt
Creates the MyEmSt variable which classifies individuals into labor market statuses:
- Employed.
- Unemployed = Job Loser + Job Leaver + Entrant.
- NILF.
*/
do "B03_CreateMyEmSt.do"
drop empstat_m*

/* CREATE MyEmStC
Uses the deNUNification criteria to create a corrected version of MyEmSt.
*/
do "B04_CreateMyEmStC.do"
drop panlwt

/* CREATE MyEmStLm (Last month)
Creates a variable indicating the MyEmSt last month.
*/
do "B05_CreateMyEmStLm.do"

/* CREATE MyJobLoser
Creates a dummy variable indicating whether an unemployed person is a job loser or not using the information in WHYUNEMP.
*/
do "B06_CreateMyJobLoser.do"
drop whyunemp_m*

/* CREATE Removed Worker Identifiers
Creates dummy variables (named MyRW*) identifying removed workers:
- MyRWall: All moving E->U
- MyRWjloser: Moving E->U and being job loser

0s are defined as those employed in previous month.
Hence, the mean of the Removed-Worker variables is the probability of being the removed worker.
*/
do "B07_CreateRWvars.do"

/*
Modifies the Removed-Worker variables to be centred around the EmSt period.
It creates a dummy for the worker being removed in t, t-1, t+1, t-2, and t+2.
*/
do "B08_RecentreRWvars.do"

// Remove DeNUNified version if equal to original
foreach u in "all" "jloser" {
  local AuxCount = 0
  foreach t in "" "m2" "m1" "p1" "p2" {
    count if MyRW`u'_t`t' != MyRW`u'C_t`t'
    local AuxCount = `AuxCount' + `r(N)'
  }
  if (`AuxCount' == 0) {
    drop MyRW`u'C_t*
  }
}
drop MyRW*_m*
drop MyJobLoser_m*
drop MyEmSt*_m*
drop MyFlag*

/* CREATE MyOcc
Uses the panel dimention to assign occupation to as many as NIU in occ2010 as possible.
MyOccFlag is 1 for those observations that have an assigned occupation through the panel dimension.
Classifies occupations in 27 groups as defined in https://cps.ipums.org/cps-action/variables/OCC2010
*/
do "B09_CreateMyOcc.do"

/* CREATE MyInd
Uses the panel dimention to assign occupation to as many as NIU, Unkown, not reported, in ind1950 as possible.
MyIndFlag is 1 for those observations that have an assigned industry through the panel dimension.
Classifies industry in 13 groups as defined in https://cps.ipums.org/cps-action/variables/IND1950
*/
do "B10_CreateMyInd.do"

/* CREATE MyEdu
Classifies education in 5 categories:
- Less than HS graduate.
- HS Graduate.
- Some college.
- College graduate.
- Advanced degree.
*/
do "B11_CreateMyEdu.do"

/* CREATE MyRace
Classifies race in 3 categories:
- White.
- Black.
- Other.
*/
do "B12_CreateMyRace.do"
drop race

/* CREATE MyMarried
Dummy for married with spouse present.
*/
generate MyMarried = 1 if marst == 1
replace MyMarried = 0 if marst >= 3 & marst <= 7
label variable MyMarried "Dummy for married spouse present or single (= 0)"
label define lbl_dummy 0 "No" ///
                       1 "Yes"
label values MyMarried lbl_dummy

/* APPLY sample selection
Applies sample selection criteria
*/
do "B13_SampleSelection.do"
tempfile tempCPS
compress
save `tempCPS'

/* CREATE MyCPS
Indivial-level data that contains both married and singles. Married are the same that consitute MarriedCPS.dta
*/
* Married sample
do "B14_SampleSelectionMarried.do"
tempfile MarriedCPS
save `MarriedCPS'

* Add single sample
use `tempCPS', clear
keep if MyMarried == 0
append using `MarriedCPS'
compress

// Rename MyVars
rename My* *
save "${Data}MyCPS.dta", replace

/* CREATE MarriedCPS
Transforms the data set to a household-based structure.
Each observation is a married household.
*/
keep if Married == 1
include "B15_CreateHHobs.do"
compress
save "${Data}MarriedCPS.dta", replace
