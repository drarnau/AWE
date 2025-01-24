// Define tempfile to append results
tempfile appended

// 1 subsample/column: 1976-2019
* Create subsample
use `bootsfile', clear
drop if Time >= yq(2020,1)
* Compute summary stats
include "F06a_ComputeSummaryStats.do"
* Save
generate column = 1
save `appended', replace

// 2-3 subsample/column: 1976-2019 expansions vs. recessions
* Create subsample
use `bootsfile', clear
merge m:1 Time using "${Recessions}", nogen
drop if Time >= yq(2020,1)
generate column = Recession + 2 // 0: Expansion, 1: Recession
drop Recession
* Compute summary stats
local catvars = "`catvars' column"
include "F06a_ComputeSummaryStats.do"
* Append & save
append using `appended'
save `appended', replace

// 4-9 subsample/column: Decades
* Create subsample
use `bootsfile', clear
drop if Time >= yq(2022,1)
generate decade = year(dofq(Time)) - mod(year(dofq(Time)),10)
tab decade
egen aux = group(decade)
tab aux decade
generate column = aux + 3
tab column decade
drop aux decade
* Compute summary stats
include "F06a_ComputeSummaryStats.do"
* Append & save
append using `appended'
save `appended', replace

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
