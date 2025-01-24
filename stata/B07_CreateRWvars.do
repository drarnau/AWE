// Define DeNUNified label
local label = ""
local labelC = "DeNUNified "

// Iterate over nun and denun versions
foreach nun in "" "C" {
	// Loop over all possible transitions
  foreach mt of numlist 2/4 6/8 {
    local my = `mt' - 1
    // Identify all E workers
    generate MyRWall`nun'_m`mt' = 0 if MyEmSt`nun'_m`my' == 10 & MyFlag_m`mt' == 1
		generate MyRWjloser`nun'_m`mt' = MyRWall`nun'_m`mt'

    // Identify all E-> U workers
    replace MyRWall`nun'_m`mt' = 1 if MyRWall`nun'_m`mt' == 0 & MyEmSt`nun'_m`mt' == 20

		// Identify job losers among E -> workers
		replace MyRWjloser`nun'_m`mt' = 1 if MyRWall`nun'_m`mt' == 1 & MyJobLoser_m`mt' == 1

    // Label variables and values
		* All
    label variable MyRWall`nun'_m`mt' "`label`nun''Removed worker: E->U"
    label values MyRWall`nun'_m`mt' labelDummy

		* Job losers
		label variable MyRWjloser`nun'_m`mt' "`label`nun''Job loser removed worker (E->U)"
		label values MyRWjloser`nun'_m`mt' labelDummy
	}
}
