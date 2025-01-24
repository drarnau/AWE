// Sort data
sort Time `catvars' nboot

// Iterate over all variables
ds Time `catvars' nboot, not
foreach v of varlist `r(varlist)' {
  // Point estimate
  by Time `catvars': egen pe_`v' = median(`v')

  // Bootstrap confidence interval lower bound
  local phi = `alpha' / 2
  by Time `catvars': egen lb_`v' = pctile(`v'), p(`phi')

  // Bootstrap confidence interval upper bound
  local phi = 100 - (`alpha' / 2)
  by Time `catvars': egen ub_`v' = pctile(`v'), p(`phi')

  drop `v'
}

// Keep relevant variables & observations
keep if nboot == 0
drop nboot
