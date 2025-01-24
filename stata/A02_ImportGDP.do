// Import data from FRED API
* Create FRED folder to store data
global FRED "${Data}/raw/FRED/"
confirmdir "$FRED"
if `r(confirmdir)' mkdir "$FRED"

import fred GDPC1, clear
save "${FRED}GDPC1.dta", replace

// Create time variable
generate Time = qofd(daten)
format Time %tq
tsset Time

// Keep quarters relevant for analysis
drop if Time < yq(1976,1)
drop if Time > yq(2021,4)

// Rename variable of interest
rename GDPC1 GDP
drop date*

// Create log GDP
generate double logGDP = log(GDP)

// Create cyclical component GDP
tsfilter hp double cyclogGDP = logGDP, smooth($smoothp)

// Save standard deviation cyclical component logGDP
summarize cyclogGDP
generate double sigma_cyclogGDP = `r(sd)'

// Drop useless vairables
drop GDP logGDP

// Save data
* Create folder to store auxiliary data
global Aux "${Data}Auxiliary/"
confirmdir "$Aux"
if `r(confirmdir)' mkdir "$Aux"

save "${Aux}GDP.dta",replace
global GDP "${Aux}GDP.dta"
