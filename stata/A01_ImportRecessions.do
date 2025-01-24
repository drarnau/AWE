// Import data from FRED API
* Create FRED folder to store data
global FRED "${Data}/raw/FRED/"
confirmdir "$FRED"
if `r(confirmdir)' mkdir "$FRED"

import fred USRECQ, clear
save "${FRED}USRECQ.dta", replace

// Create time variable
gen Time = qofd(daten)
format Time %tq

// Keep quarters relevant for analysis
drop if Time < yq(1976,1)
drop if Time > yq(2022,4)

// Rename variable of interest
rename USRECQ Recession
drop date*

// Save data
* Create folder to store auxiliary data
global Aux "${Data}Auxiliary/"
confirmdir "$Aux"
if `r(confirmdir)' mkdir "$Aux"

save "${Aux}Recessions.dta",replace
global Recessions "${Aux}Recessions.dta"
