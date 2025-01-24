/* COLLAPSE Individual Flows
Computes individual flows for single and married, and men and women, DeNUN and non-DeNUN versions.
*/
include "C01_CollapseIndFlows.do"
save "${IFlows_M}Raw_`bk'.dta", replace
