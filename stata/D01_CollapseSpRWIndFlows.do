// Define tempfile to store results
tempfile myfile

// Define labels
* d (DeNUN)
local ld0 = "" // Not DeNUN
local ld1 = "C" // DeNUN

* s (sex)
local ls1 = "h" // Husband
local lz1 = "w" // Spouse: Wife
local ls2 = "w" // Wife
local lz2 = "h" // Spouse: Husband


local k = 0 // Counter iterations
// Iterate over versions DeNUN of EmSt
forvalues d = 0/1 {
  // Iterate over sex
  forvalues s = 1/2 {
    // Iterate over time frame
    local kt = 0 // Counter types
    forvalues tf = 0/1 {
      // Iterate over worker status
      foreach ws in "jloser" "all" {
        // Update iterations counter
        local k = `k' + 1
        // Update counter types
        local kt = `kt' + 1

        // Load data
        use Time `ls`s''Wtfinl `ls`s''EmSt`lv`v'' `ls`s''EmSt`lv`v''Lm `lz`s''RW`ws'* ///
          using "`hhdata'", clear

        // Define RW type
        if (`tf' == 0) {
          generate myRW = 1 if `lz`s''RW`ws'_t == 1
        }
        if (`tf' == 1) {
          generate myRW = 1 if `lz`s''RW`ws'_t == 1 | ///
                               `lz`s''RW`ws'_tp2 == 1 | `lz`s''RW`ws'_tp1 == 1 | ///
                               `lz`s''RW`ws'_tm2 == 1 | `lz`s''RW`ws'_tm1 == 1
        }

        // Read variable levels and label
        levelsof `ls`s''EmSt`lv`v'', local(vlevels)
        local label : value label `ls`s''EmSt`lv`v''

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
            generate `ylabel'to`tlabel'spRW = 1 if `ls`s''EmSt`lv`v'' == `y' & ///
                                                   `ls`s''EmSt`lv`v''Lm == `t' & ///
                                                   myRW == 1
          }
        }

        // Count those with a removed worker spouse
        collapse (count) *to* [pw=`ls`s''Wtfinl], by(Time)

        // Set 0s to missing
        do "C01a_ZerosToMissingFlows.do"

        // Generate DeNUN variable
        generate DeNUN = `d'

        // Generate sex
        generate sex = `s'

        // Generate type
        generate RWtype = `kt'

        // Append & save
        if (`k' > 1) {
          append using `myfile'
        }
        save `myfile', replace
      }
    }
  }
}

// Label DeNUN variable
label variable DeNUN "Indicates DeNUNified version"
label values DeNUN lbl_dummy

// Label sex
label variable sex "Sex of worker in the flow"
label define lbl_sex 1 "Male" ///
                     2 "Female"
label values sex lbl_sex

// Label RWtype
label variable RWtype "Type of removed worker"
label define lbl_RWtype 0 "Benchmark" ///
                        1 "Contemporaneous job losers only" ///
                        2 "Contemporaneous all unemployed" ///
                        3 "Leads and lags job losers only" ///
                        4 "Leads and lags all unemployed"
label values RWtype lbl_RWtype
