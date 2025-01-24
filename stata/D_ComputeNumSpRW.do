/* COLLAPSE Number of workers in each INDIVIDUAL flow whose spouse is a removed worker
Computes the number of workers in each individual flow whose spouse is a removed worker for husbands and wives, each variable EmSt, each definition of unemployed removed worker (all and only job losers), and contemporaneous and including leads and lags.
*/
include "D01_CollapseSpRWIndFlows.do"
save "${INumSpRW}Raw_`bk'", replace
