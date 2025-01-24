// Find occupation for those without (NIU = 9999)
* Create auxiliary variable
generate AuxOcc = occ2010

* Find closest occupation with past priority
local ms_m1 = "2 3 4 5 6 7 8"
local ms_m2 = "1 3 4 5 6 7 8"
local ms_m3 = "2 4 1 5 6 7 8"
local ms_m4 = "3 5 2 6 1 7 8"
local ms_m5 = "4 6 3 7 2 8 1"
local ms_m6 = "5 7 4 8 3 2 1"
local ms_m7 = "6 8 5 4 3 2 1"
local ms_m8 = "7 6 5 4 3 2 1"
forvalues m = 1/8 {
	foreach n of local ms_m`m' {
		replace AuxOcc = occ2010_m`n' if mish == `m' & AuxOcc == 9999 & ///
																		 occ2010_m`n' != 9999 & occ2010_m`n' != .
	}
}
// Create flag for replaced NIUs
generate MyOccFlag = (AuxOcc != occ2010)
label variable MyOccFlag "MyOcc NIU replaced with panel information"
label values MyOccFlag labelDummy

// NOTE: Categories from https://cps.ipums.org/cps-action/variables/OCC2010
// Create variable
generate MyOcc = .
label variable MyOcc "Current or last known or future Occupation"

// Management in Business, Science, and Arts
replace MyOcc = 1 if AuxOcc >= 0010 & AuxOcc <= 0430
label define labelMyOcc 1 "Management in Business, Science, and Arts"

// Business Operations Specialists
replace MyOcc = 2 if AuxOcc >= 0500 & AuxOcc <= 0730
label define labelMyOcc 2 "Business Operations Specialists", add

// Financial Specialists
replace MyOcc = 3 if AuxOcc >= 0800 & AuxOcc <= 0950
label define labelMyOcc 3 "Financial Specialists", add

// Computer and Mathematical
replace MyOcc = 4 if AuxOcc >= 1000 & AuxOcc <= 1240
label define labelMyOcc 4 "Computer and Mathematical", add

// Architecture and Engineering
replace MyOcc = 5 if AuxOcc >= 1300 & AuxOcc <= 1540
label define labelMyOcc 5 "Architecture and Engineering", add

// Technicians
replace MyOcc = 6 if AuxOcc >= 1550 & AuxOcc <= 1560
label define labelMyOcc 6 "Technicians", add

// Life, Physical, and Social Science
replace MyOcc = 7 if AuxOcc >= 1600 & AuxOcc <= 1980
label define labelMyOcc 7 "Life, Physical, and Social Science", add

// Community and Social Services
replace MyOcc = 8 if AuxOcc >= 2000 & AuxOcc <= 2060
label define labelMyOcc 8 "Community and Social Services", add

// Legal
replace MyOcc = 9 if AuxOcc >= 2100 & AuxOcc <= 2150
label define labelMyOcc 9 "Legal", add

// Education, Training, and Library
replace MyOcc = 10 if AuxOcc >= 2200 & AuxOcc <= 2550
label define labelMyOcc 10 "Education, Training, and Library", add

// Arts, Design, Entertainment, Sports, and Media
replace MyOcc = 11 if AuxOcc >= 2600 & AuxOcc <= 2920
label define labelMyOcc 11 "Arts, Design, Entertainment, Sports, and Media", add

// Healthcare Practitioners and Technicians
replace MyOcc = 12 if AuxOcc >= 3000 & AuxOcc <= 3540
label define labelMyOcc 12 "Healthcare Practitioners and Technicians", add

// Healthcare Support
replace MyOcc = 13 if AuxOcc >= 3600 & AuxOcc <= 3650
label define labelMyOcc 13 "Healthcare Support", add

// Protective Service
replace MyOcc = 14 if AuxOcc >= 3700 & AuxOcc <= 3950
label define labelMyOcc 14 "Protective Service", add

// Food Preparation and Serving
replace MyOcc = 15 if AuxOcc >= 4000 & AuxOcc <= 4150
label define labelMyOcc 15 "Food Preparation and Serving", add

// Building and Grounds Cleaning and Maintenance
replace MyOcc = 16 if AuxOcc >= 4200 & AuxOcc <= 4250
label define labelMyOcc 16 "Building and Grounds Cleaning and Maintenance", add

// Personal Care and Service
replace MyOcc = 17 if AuxOcc >= 4300 & AuxOcc <= 4650
label define labelMyOcc 17 "Personal Care and Service", add

// Sales and Related
replace MyOcc = 18 if AuxOcc >= 4700 & AuxOcc <= 4965
label define labelMyOcc 18 "Sales and Related", add

// Office and Administrative Support
replace MyOcc = 19 if AuxOcc >= 5000 & AuxOcc <= 5940
label define labelMyOcc 19 "Office and Administrative Support", add

// Farming, Fisheries, and Forestry
replace MyOcc = 20 if AuxOcc >= 6005 & AuxOcc <= 6130
label define labelMyOcc 20 "Farming, Fisheries, and Forestry", add

// Construction
replace MyOcc = 21 if AuxOcc >= 6200 & AuxOcc <= 6765
label define labelMyOcc 21 "Construction", add

// Extraction
replace MyOcc = 22 if AuxOcc >= 6800 & AuxOcc <= 6940
label define labelMyOcc 22 "Extraction", add

// Installation, Maintenance, and Repair
replace MyOcc = 23 if AuxOcc >= 7000 & AuxOcc <= 7630
label define labelMyOcc 23 "Installation, Maintenance, and Repair", add

// Production
replace MyOcc = 24 if AuxOcc >= 7700 & AuxOcc <= 8965
label define labelMyOcc 24 "Production", add

// Transportation and Material Moving
replace MyOcc = 25 if AuxOcc >= 9000 & AuxOcc <= 9750
label define labelMyOcc 25 "Transportation and Material Moving", add

// Military
replace MyOcc = 26 if AuxOcc >= 9800 & AuxOcc <= 9830
label define labelMyOcc 26 "Military", add

// No Occupation
replace MyOcc = 27 if AuxOcc == 9999
label define labelMyOcc 27 "No Occupation", add

// Add value labels
label values MyOcc labelMyOcc

// Drop unnecessary variables
drop Aux* occ2010_m*
