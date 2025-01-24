// Define timeseries
tsset Time

// Unlinkable months (https://cps.ipums.org/cps/cps_linking_documentation.shtml#unlinkable_samples)
ds Time, not
foreach v of varlist `r(varlist)' {
foreach t of numlist `=ym(1976,1)' `=ym(1977,1)' `=ym(1977,2)' `=ym(1977,5)' `=ym(1977,7)' ///
                     `=ym(1977,8)' `=ym(1977,9)' `=ym(1977,10)' `=ym(1977,11)' `=ym(1977,12)'  ///
                     `=ym(1985,7)' `=ym(1985,10)' `=ym(1995,6)' `=ym(1995,7)' `=ym(1995,8)' ///
                     `=ym(1995,9)' {
  replace `v' = . if Time == `t'


}
}
