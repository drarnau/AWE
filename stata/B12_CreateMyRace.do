// Create variable
generate MyRace = .
label variable MyRace "Race in 3 categories"

// White
replace MyRace = 1 if race == 100
label define labelMyRace 1 "White", add

// Black
replace MyRace = 2 if race == 200
label define labelMyRace 2 "Black", add

// Other
replace MyRace = 3 if race >= 300 & race <= 830
label define labelMyRace 3 "Other", add

// Add value labels
label values MyRace labelMyRace
