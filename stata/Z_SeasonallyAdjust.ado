program SeasonallyAdjust, nclass
	version 15.1 // STATA version

	syntax varname, [SHIMER] [GENerate(name)]

	// Save lbl
	local lbl: variable label `varlist'

	// 12-month moving average
	tssmooth ma Aux = `varlist', weights(.5 1 1 1 1 1 <1> 1 1 1 1 1 .5)

	// Add Shimer procedure if indicated by user
	if ("`shimer'" != "") {
		* Create year and month
		gen AuxY = year(dofm(Time))
		gen AuxM = month(dofm(Time))

		* Compute mid year
		qui su AuxY
		local midY = `r(min)' + floor((`r(max)' - `r(min)') / 2)

		* Compute ratio
		gen AuxR = `varlist' / Aux
		for X in num 1 2 to 12: egen AuxX = mean(AuxR) if AuxM == X
		for X in num 1 2 to 12: replace AuxR = AuxX if AuxM == X
		means AuxR if AuxY == `midY'
		replace AuxR = AuxR / r(mean_g)
		replace Aux = `varlist' / AuxR
	}

	// Generate or replace variable
	if ("`generate'" != "") {
		gen `generate' = Aux
		la var `generate' "`lbl'"
	}
	else {
	  replace `varlist' = Aux
	}

	// Drop auxiliary variables
	drop Aux*
end
