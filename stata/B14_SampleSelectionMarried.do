// Only Married & spouse present individuals
keep if MyMarried == 1

// Only head and spouses
keep if relate >= 101 & relate <= 202

// Only one head and spouse per household
sort cpsid mish
gen AuxHead = (relate == 101)
gen AuxSpouse = (relate == 201 | relate == 202)

foreach r in "Head" "Spouse" {
  by cpsid mish: egen AuxN`r' = total(Aux`r')
}
keep if AuxNHead == 1 & AuxNSpouse == 1
drop Aux*

// Only one male and one female
forval s = 1/2 {
  gen Aux`s' = (sex == `s')
  by cpsid mish: egen AuxN`s' = total(Aux`s')
}
keep if AuxN1 == 1 & AuxN2 == 1
drop Aux*
