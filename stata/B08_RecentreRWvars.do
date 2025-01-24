// Define types of removed workers
local TypesRW = ""
foreach v of varlist MyRW*_m2 {
  local aux = subinstr("`v'","MyRW","",.)
  local aux = subinstr("`aux'","_m2","",.)
  local TypesRW = "`aux' `TypesRW'"
}

// Iterate over all verions of Removed Worker variables
foreach u of local TypesRW {
  local v = "MyRW`u'"

  // Generate variables
  * Read label
  local auxlbl : var label `v'_m2

  * t
  gen `v'_t = .
  la var `v'_t "`auxlbl' in t"
  * t + 1
  gen `v'_tp1 = .
  la var `v'_tp1 "`auxlbl' in t+1"
  * t - 1
  gen `v'_tm1 = .
  la var `v'_tm1 "`auxlbl' in t-1"
  * t + 2
  gen `v'_tp2 = .
  la var `v'_tp2 "`auxlbl' in t+2"
  * t - 2
  gen `v'_tm2 = .
  la var `v'_tm2 "`auxlbl' in t-2"

  // Assign values
  * mish 2 & 6
  foreach m of numlist 2 6 {
    * t
    replace `v'_t = `v'_m`m' if mish == `m'
    * t + 1
    local n = `m' + 1
    replace `v'_tp1 = `v'_m`n' if mish == `m'
    * t + 2
    local n = `m' + 2
    replace `v'_tp2 = `v'_m`n' if mish == `m'
  }
  * mish 3 & 7
  foreach m of numlist 3 7 {
    * t - 1
    local n = `m' - 1
    replace `v'_tm1 = `v'_m`n' if mish == `m'
    * t
    replace `v'_t = `v'_m`m' if mish == `m'
    * t + 1
    local n = `m' + 1
    replace `v'_tm1 = `v'_m`n' if mish == `m'
  }
  * mish 4 & 8
  foreach m of numlist 4 8 {
    * t - 2
    local n = `m' - 2
    replace `v'_tm2 = `v'_m`n' if mish == `m'
    * t - 1
    local n = `m' - 1
    replace `v'_tm1 = `v'_m`n' if mish == `m'
    * t
    replace `v'_t = `v'_m`m' if mish == `m'
  }
}

// Value labels
label values *RW*_t* labelDummy
