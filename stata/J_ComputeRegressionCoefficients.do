/* COMPUTE Summary statistics
Computes the AWE with and without controlling for the observables defined in `ctrls' using a window defined by `mw' for the following subsamples: 1976-2019, Expansions, Recessions, 1976-1979, 1980-1989, 1990-1999, 2000-2009, 2010-2019, 2020-2021. All coefficients are stored in "ITransitions/ARegCoeffColumns.dta".
*/
local ctrls = "i.hAge i.wAge i.hEdu i.wEdu i.hRace i.wRace i.statecensus i.hOcc i.wOcc i.hInd i.wInd i.wNchild i.hNchild"
include "J01_RegCoeffColumns.do"
