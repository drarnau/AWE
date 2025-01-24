// Create monthly variable
gen MyTime = ym(year, month)
format MyTime %tm
sort MyTime
la var MyTime "Survey period"
