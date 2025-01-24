// Create MyEmStC by duplicating MyEmSt
local mylist = ""
forvalues m = 1/8 {
  local mylist = "`mylist' _m`m'"
}
foreach m in "" `mylist' {
  gen MyEmStC`m' = MyEmSt`m'
}

* Add value labels
la values MyEmStC lbl_EmSt

// DeNUnify
local v = "MyEmSt"
// Recoded value is in position 2nd or 6th
foreach m of numlist 2 6 {
  * Establish relavant mishes
  local 1st = `m' - 1
  local 3rd = `m' + 1
  local 4th = `m' + 2

  * UNUU -> UUUU & NUNN -> NNNN
  * UNUE -> UUUE & NUNE -> NNNE
  replace `v'C_m`m' = `v'_m`1st' if ///
          `v'_m`1st' != `v'_m`m' & `v'_m`1st' == `v'_m`3rd' & `v'_m`m' != `v'_m`4th' & ///
          `v'_m`1st' > 10 & `v'_m`m' > 10 & ///
          `v'_m`1st' != . & `v'_m`m' != . & `v'_m`3rd' != . & `v'_m`4th' != . & ///
          MyFlag_m`m' == 1 & MyFlag_m`3rd' == 1 & MyFlag_m`4th' == 1

  * UNU. -> UUU. & NUN. -> NNN.
  replace `v'C_m`m' = `v'_m`1st' if ///
          `v'_m`1st' != `v'_m`m' & `v'_m`1st' == `v'_m`3rd' & `v'_m`4th' == . & ///
          `v'_m`1st' > 10 & `v'_m`m' > 10 & `v'_m`1st' != . & ///
          `v'_m`1st' != . & `v'_m`m' != . & `v'_m`3rd' != . & ///
          MyFlag_m`m' == 1 & MyFlag_m`3rd' == 1

  * Recode information in MyEmStC
  replace `v'C = `v'C_m`m' if mish == `m'
}
// Recoded value is in position 3rd or 7th
foreach m of numlist 3 7 {
  * Establish relavant mishes
  local 1st = `m' - 2
  local 2nd = `m' - 1
  local 4th = `m' + 1

  * UUNU -> UUUU & NNUN -> NNNN
  * EUNU -> EUUU & ENUN -> ENNN
  replace `v'C_m`m' = `v'_m`2nd' if ///
          `v'_m`2nd' != `v'_m`m' & `v'_m`2nd' == `v'_m`4th' & `v'_m`1st' != `v'_m`m' & ///
          `v'_m`2nd' > 10 & `v'_m`m' > 10 & ///
          `v'_m`1st' != . & `v'_m`2nd' != . & `v'_m`m' != . & `v'_m`4th' != . & ///
          MyFlag_m`2nd' == 1 & MyFlag_m`m' == 1 & MyFlag_m`4th' == 1

  * .UNU -> .UUU & .NUN -> .NNN
  replace `v'C_m`m' = `v'_m`2nd' if ///
          `v'_m`2nd' != `v'_m`m' & `v'_m`2nd' == `v'_m`4th' & `v'_m`1st' == . & ///
          `v'_m`2nd' > 10 & `v'_m`m' > 10 & ///
          `v'_m`2nd' != . & `v'_m`m' != . & `v'_m`4th' != . & ///
          MyFlag_m`m' == 1 & MyFlag_m`4th' == 1

  * Recode information in MyEmStC
  replace `v'C = `v'C_m`m' if mish == `m'
}
// Label variable
local auxlbl : var label `v'
la var `v'C "DeNUNified `auxlbl'"
