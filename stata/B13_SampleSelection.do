// Prime Age individual
keep if age > 24 & age < 55

// Non-missing education
drop if MyEdu == .

// Non-missing labour market satus
foreach v of varlist MyEmSt MyEmStC {
  drop if `v' == .
}

// Only Married & spouse present individuals + Singles
drop if MyMarried == .
