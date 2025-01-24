// STATA version used
version 15.1

clear all
program drop _all
cap log close
set more off
set varabbrev off, permanently

// Install packages
ssc install blindschemes, replace
ssc install confirmdir, replace

// Set scheme
set scheme plotplainblind

// Set FRED API key
// set fredkey XXX

// Define main path
global Path ""

// Define folders' paths as global variables
global Data "${Path}data/"
global Code "${Path}stata/"
global IPUMSCPS "${Data}raw/IPUMS-CPS/"
global Tables "${Path}tables/"
global Graphs "${Path}graphs/"
* Check if needed folder exists. If not, create it.
foreach fname in "Tables" "Graphs" {
  confirmdir "${`fname'}"
  if `r(confirmdir)' mkdir "${`fname'}"
}

// Define and create needed data folders
foreach fname in "IFlows_M" "INumSpRW" "IShareSpRW" "IFlows" "ITransitions" "IRates" "ISSrates" {
  // Define global variable for folder
  global `fname' "${Data}`fname'/"

  // Create folder if it does not exist
  confirmdir "${`fname'}"
  if `r(confirmdir)' mkdir "${`fname'}"
}

// Define code parameters
global smoothp = 1600 // Smoothing parameter HP filter

// Load programs
cd $Code
qui do "Z_DisplayTime.ado"
qui do "Z_SeasonallyAdjust.ado"
qui do "Z_QuarterlyAverage.ado"

qui timer on 1

// Prepare auxiliary data --------------------------------------------------------------------------
qui timer on 2
qui do "A01_ImportRecessions.do"
qui do "A02_ImportGDP.do"
qui timer off 2
qui timer list
DisplayTime, seconds(`r(t2)') msg("Time to create auxiliary datasets:")
*---------------------------------------------------------------------------------------------------

// Create MySamples --------------------------------------------------------------------------------
qui timer on 3
* Load IPUMS-CPS data
// use "${IPUMSCPS}XXX.dta", clear
qui include "B_CreateMySamples.do"
qui timer off 3
qui timer list
DisplayTime, seconds(`r(t3)') msg("Time to create MySamples:")
*---------------------------------------------------------------------------------------------------

// Compute Flows -----------------------------------------------------------------------------------
qui timer on 4

* Define datasets to use
local inddata = "${Data}MyCPS.dta"
local hhdata = "${Data}MarriedCPS.dta"
* Define bootstrap number
local bk = 0
qui include "C_ComputeFlows.do"
qui timer off 4
qui timer list
DisplayTime, seconds(`r(t4)') msg("Time to compute Flows:")
*---------------------------------------------------------------------------------------------------

// Compute Number of Workers Whose Spouse is a Removed Worker --------------------------------------
qui timer on 5

* Define dataset to use
local hhdata = "${Data}MarriedCPS.dta"
* Define bootstrap number
local bk = 0
qui include "D_ComputeNumSpRW.do"

qui timer off 5
qui timer list
DisplayTime, seconds(`r(t5)') msg("Time to compute Number of Removed Worker Spouse:")
*---------------------------------------------------------------------------------------------------

// Bootstrap ---------------------------------------------------------------------------------------
qui timer on 6

* Define number of bootstraps
global K = 1000
do "E_Bootstrap.do"

qui timer off 6
qui timer list
DisplayTime, seconds(`r(t6)') msg("Time to bootstrap:")
*---------------------------------------------------------------------------------------------------

// Compute Shares of Workers Whose Spouse is a Removed Worker --------------------------------------
qui timer on 7

run "F_ComputeShareSpouseRW.do"

qui timer off 7
qui timer list
DisplayTime, seconds(`r(t7)') msg("Time to compute Share of Removed Worker Spouse:")
*---------------------------------------------------------------------------------------------------

// Compute Flow Types ------------------------------------------------------------------------------
qui timer on 8

run "G_ComputeFlowTypes.do"

qui timer off 8
qui timer list
DisplayTime, seconds(`r(t8)') msg("Time to compute Flow Types:")
*---------------------------------------------------------------------------------------------------

// Compute Transitions -----------------------------------------------------------------------------
qui timer on 9

run "H_ComputeTransitions.do"

qui timer off 9
qui timer list
DisplayTime, seconds(`r(t9)') msg("Time to compute Transitions:")
*---------------------------------------------------------------------------------------------------

// Compute Regression Coefficients --------------------------------------------------------------
qui timer on 10

run "J_ComputeRegressionCoefficients.do"

qui timer off 10
qui timer list
DisplayTime, seconds(`r(t10)') msg("Time to compute Regression Coefficients:")
*---------------------------------------------------------------------------------------------------

// Compute Rates -----------------------------------------------------------------------------------
qui timer on 11

run "K_ComputeRates.do"

qui timer off 11
qui timer list
DisplayTime, seconds(`r(t11)') msg("Time to compute Rates:")
*---------------------------------------------------------------------------------------------------

// Compute SS Rates --------------------------------------------------------------------------------
qui timer on 12

run "L_ComputeSSrates.do"

qui timer off 12
qui timer list
DisplayTime, seconds(`r(t12)') msg("Time to compute Steady-State Rates:")
*---------------------------------------------------------------------------------------------------

// Compute Differences Data vs. SS -----------------------------------------------------------------
qui timer on 13

run "M_ComputeDiffDataSS.do"

qui timer off 13
qui timer list
DisplayTime, seconds(`r(t13)') msg("Time to compute differences between data and SS:")
*---------------------------------------------------------------------------------------------------

// Compute Differences SS vs. CF -------------------------------------------------------------------
qui timer on 14

run "N_ComputeDiffSSCF.do"

qui timer off 14
qui timer list
DisplayTime, seconds(`r(t14)') msg("Time to compute differences between SS and CF:")
*---------------------------------------------------------------------------------------------------

// Compute Cyclical Analysis -----------------------------------------------------------------------
qui timer on 15

run "Q_Cyclicality.do"

qui timer off 15
qui timer list
DisplayTime, seconds(`r(t15)') msg("Time to compute Cyclical Analysis:")
*---------------------------------------------------------------------------------------------------

// Plots & Tables ----------------------------------------------------------------------------------
qui timer on 16

include "Y_GraphsTables.do"

qui timer off 16
qui timer list
DisplayTime, seconds(`r(t16)') msg("Time to produce Graphs and Tables:")
*---------------------------------------------------------------------------------------------------

qui timer off 1
qui timer list
DisplayTime, seconds(`r(t1)') msg("Total execution time:")
