// Find industry for those without (NIU = 0, Unkown = 997, Industry not reported = 998)
* Create auxiliary variable
generate AuxInd = ind1950

* Find closest industry with past priority
local ms_m1 = "2 3 4 5 6 7 8"
local ms_m2 = "1 3 4 5 6 7 8"
local ms_m3 = "2 4 1 5 6 7 8"
local ms_m4 = "3 5 2 6 1 7 8"
local ms_m5 = "4 6 3 7 2 8 1"
local ms_m6 = "5 7 4 8 3 2 1"
local ms_m7 = "6 8 5 4 3 2 1"
local ms_m8 = "7 6 5 4 3 2 1"
forvalues m = 1/8 {
	foreach n of local ms_m`m' {
		replace AuxInd = ind1950_m`n' if mish == `m' & ///
																		(AuxInd == 0 | AuxInd == 997 | AuxInd == 998) & ///
																		(ind1950_m`n'!=0 | ind1950_m`n'!=997 | ind1950_m`n'!=998) & ///
																		ind1950_m`n' != .
	}
}
// Create flag for replaced observations
generate MyIndFlag = (AuxInd != ind1950)
label variable MyIndFlag "MyInd NIU, Unkown, not reported replaced with panel information"
label values MyIndFlag labelDummy

// NOTE: Categories from https://cps.ipums.org/cps-action/variables/IND1950
// Create variable
generate MyInd = .
label variable MyInd "Current or last known or future Industry"

// Agriculture, Forestry, and Fishing
replace MyInd = 1 if AuxInd >= 105 & AuxInd <= 126
label define labelMyInd 1 "Agriculture, Forestry, and Fishing", add

// Mining
replace MyInd = 2 if AuxInd >= 206 & AuxInd <= 236
label define labelMyInd 2 "Mining", add

// Construction
replace MyInd = 3 if AuxInd == 246
label define labelMyInd 3 "Construction", add

// Manufacturing
replace MyInd = 4 if AuxInd >= 306 & AuxInd <= 499
label define labelMyInd 4 "Manufacturing", add

// Transportation, Communication, and Other Utilities
replace MyInd = 5 if AuxInd >= 506 & AuxInd <= 598
label define labelMyInd 5 "Transportation, Communication, and Other Utilities", add

// Wholesale and Retail Trade
replace MyInd = 6 if AuxInd >= 606 & AuxInd <= 699
label define labelMyInd 6 "Wholesale and Retail Trade", add

// Finance, Insurance, and Real Estate
replace MyInd = 7 if AuxInd >= 716 & AuxInd <= 746
label define labelMyInd 7 "Finance, Insurance, and Real Estate", add

// Business and Repair Services
replace MyInd = 8 if AuxInd >= 806 & AuxInd <= 817
label define labelMyInd 8 "Business and Repair Services", add

// Personal services
replace MyInd = 9 if AuxInd >= 826 & AuxInd <= 849
label define labelMyInd 9 "Personal services", add

// Entertainment and Recreation Services
replace MyInd = 10 if AuxInd >= 856 & AuxInd <= 859
label define labelMyInd 10 "Entertainment and Recreation Services", add

// Professional and Related Services
replace MyInd = 11 if AuxInd >= 868 & AuxInd <= 899
label define labelMyInd 11 "Professional and Related Services", add

// Public Administration
replace MyInd = 12 if AuxInd >= 906 & AuxInd <= 936
label define labelMyInd 12 "Public Administration", add

// No Industry
replace MyInd = 13 if AuxInd == 0 | AuxInd == 997 | AuxInd == 998
label define labelMyInd 13 "No industry", add

// Add value labels
label values MyInd labelMyInd

// Drop unnecessary variables
drop Aux* ind1950_m*
