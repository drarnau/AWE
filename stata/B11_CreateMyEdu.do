// Create variable
generate MyEdu = .
label variable MyEdu "Education in 3 categories"

// Less than HS graduate
replace MyEdu = 1 if educ >= 2 & educ <= 71
label define labelMyEdu 1 "Less than HS Graduate", add

// Possibly HS graduate
replace MyEdu = 2 if educ == 72
replace MyEdu = 2 if educ == 73 & MyTime >= `=ym(1992,1)'
label define labelMyEdu 2 "Possibly HS Graduate", add

// HS gradute and beyond
replace MyEdu = 3 if educ == 73 & MyTime < `=ym(1992,1)'
replace MyEdu = 3 if educ >= 80 & educ <= 125
label define labelMyEdu 3 "HS Graduate and beyond", add

// Add value labels
label values MyEdu labelMyEdu
