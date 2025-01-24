// Tempfiles
* to store initial file with all boots
tempfile allboots
* to store appended stats
tempfile appendstats

// Save all boots
save `allboots', replace

// Iterate over stats
local z = 0 // Counter stats iteration
foreach s of local lstats {
  // Update stats counter
  local z = `z' + 1

  // Store value label
  local vl`z' = "`s'"

  // Load boots
  use `allboots', clear

  // Collapse all variables
  ds Time `catvars' nboot, not
  collapse (`s') `r(varlist)', by(`catvars' nboot)

  // Iterate over all variables
  ds `catvars' nboot, not
  foreach v of varlist `r(varlist)' {
    // Point estimate
    by `catvars': egen pe_`v' = median(`v')

    // Bootstrap confidence interval lower bound
    local phi = `alpha' / 2
    by `catvars': egen lb_`v' = pctile(`v'), p(`phi')

    // Bootstrap confidence interval upper bound
    local phi = 100 - (`alpha' / 2)
    by `catvars': egen ub_`v' = pctile(`v'), p(`phi')

    // Pseudo p-value
    by `catvars': egen pv_`v' = mean((`v' <= 0) / (`v' < .))

    drop `v'
  }

  // Keep relevant variables & observations
  keep if nboot == 0
  drop nboot

  // Store type of stat
  generate stattype = `z'

  // Append and save
  if (`z' > 1) {
    append using `appendstats'
  }
  save `appendstats', replace
}

// Label stattype
forvalues x = 1/`z' {
  label define lbl_stattype `x' "`vl`x''", add
}
label variable stattype "Statistic: mean, median..."
label values stattype lbl_stattype
