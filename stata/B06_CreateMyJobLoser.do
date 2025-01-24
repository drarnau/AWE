// Create list of sufixes for whyunemp
local mylist = ""
forvalues m = 1/8 {
  local mylist = "`mylist' _m`m'"
}

// Iterate over suffixes
foreach m in "" `mylist' {
  generate MyJobLoser`m' = 1 if whyunemp`m' >= 1 & whyunemp`m' <= 3
  replace MyJobLoser`m' = 0 if MyJobLoser`m' == .  & whyunemp`m' != 0
}

// Assign label to variable
label variable MyJobLoser "Dummy for job loser"

// Assign label to values
label define labelDummy 0 "No" ///
                        1 "Yes"

label values MyJobLoser labelDummy
