// Define tempfile to store results
tempfile myfile

local kv = 0 // Counter versions of EmSt
local k = 0 // Counter iterations
// Iterate over versions of EmSt
foreach v in "" "C" {
  // Iterate over sex
  forvalues s = 1/2 {
    // Update iterations counter
    local k = `k' + 1

    // Load data
    use Time wtfinl Married sex EmSt`v' EmSt`v'Lm using "`inddata'" ///
      if sex == `s' & Married == 1, clear

    // Read labels and value labels of sex
    local l_sex : variable label sex
    local lbl_sex : value label sex
    drop sex Married

    // Read variable levels and label
    levelsof EmSt`v', local(vlevels)
    local label : value label EmSt`v'

    // Iterate over states yesterday
    foreach y of local vlevels {
      // Read first letter of value label
      local ylabel : label `label' `y'
      local ylabel = substr("`ylabel'",1,1)

      // Iterate over states today
      foreach t of local vlevels {
        // Read first letter of value label
        local tlabel : label `label' `t'
        local tlabel = substr("`tlabel'",1,1)

        // Create dummy
        generate `ylabel'to`tlabel' = 1 if EmSt`v'Lm == `y' & EmSt`v' == `t'
      }
    }

    // Count flows
    collapse (count) *to* [pw=wtfinl], by(Time)

    // Set 0s to missing
    do "C01a_ZerosToMissingFlows.do"

    // Generate DeNUN variable
    generate DeNUN = `kv'

    // Generate sex
    generate sex = `s'
    label variable sex "`l_sex'"
    label values sex `lbl_sex'

    // Append & save
    if (`k' > 1) {
      append using `myfile'
    }
    save `myfile', replace
  }
  // Update counter versions of EmSt
  local kv = `kv' + 1
}

// Label DeNUN variable
label variable DeNUN "Indicates DeNUNified version"
label values DeNUN lbl_dummy
