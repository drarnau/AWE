program QuarterlyAverage, nclass
	version 15.1 // STATA version

	syntax using/

	// Load data
	use "`using'", clear

	// Check Time
	qui tsreport
	local vTime = r(timevar)
	if (r(tsfmt) != "%tm" ) {
		di as error "QuarterlyAverage: data is not in monthly format."
		error(119)
	}

	// Create quarterly time
 	replace Time = qofd(dofm(`vTime'))
	format %tq Time
	la var Time "Quarter of survey period"

	// Collapse to quarter averages
	ds Time `vTime', not

	* Save all labels
	foreach v of varlist `r(varlist)' {
		local lbl_`v' : var label `v'
		local vlbl_`v': value label `v'
	}

	* Collapse
	collapse `r(varlist)', by(Time)

	* Put labels back
	ds Time, not
	foreach v of varlist `r(varlist)' {
		la var `v' `"`lbl_`v''"'
		label values `v' `vlbl_`v''
	}
end
