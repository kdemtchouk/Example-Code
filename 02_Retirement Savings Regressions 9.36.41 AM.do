************************************************************************************************************
* Regress retirement savings on controls and predict retirement savings (y-hat).
* Written by Kirill D on 12/11/14.
************************************************************************************************************

clear all
set more off
*capture log using "~/Dropbox/EGBias/ALP Data/Analysis/Programs/02_Retirement Savings Regressions log.txt", replace text
use "~/Dropbox/EGBias/ALP Data/Analysis/Data/Survey Results with Estimates.dta"
*keep if cohort == 1 //specify cohort

/* Keep respondents of both surveys, using the same criteria as Matt's regressions. */
gen contrib2_392 = .
replace contrib2_392 = r004_value_392 if whenpaperwork_392 >= 2 & whenpaperwork_392 <= 4 & nochange_392 == 1
replace contrib2_392 = r001_value_392 if whenpaperwork_392 >=2 & whenpaperwork_392 <= 4 & nochange_392 == 2
replace contrib2_392 = r007_value_392 if whenbutton_392 >= 2 & whenbutton_392 <= 4
replace contrib2_392 = r001_value_392 if whenbutton_392 >= 2 & whenbutton_392 <= 4 & r007_value_392 == .
replace contrib2_392 = r001_value_392 if whenbutton_392 == 1
gen diff_392 = contrib2_392 - r001_value_392

gen contrib2_399 = .
replace contrib2_399 = r004_value_399 if whenpaperwork_399 >= 2 & whenpaperwork_399 <= 4 & nochange_399 == 1
replace contrib2_399 = r002_value_399 if whenpaperwork_399 >= 2 & whenpaperwork_399 <= 4 & nochange_399 == 1 & r004_value_399 == .
replace contrib2_399 = r001_value_399 if whenpaperwork_399 >=2 & whenpaperwork_399 <= 4 & nochange_399 == 2
replace contrib2_399 = r007_value_399 if whenbutton_399 >= 2 & whenbutton_399 <= 4
replace contrib2_399 = r001_value_399 if whenbutton_399 >= 2 & whenbutton_399 <= 4 & r007_value_399 == .
replace contrib2_399 = r001_value_399 if whenbutton_399 == 1
gen diff_399 = contrib2_399 - r001_value_399

keep if !missing(diff_392) & !missing(diff_399)

/* Re-define Alpha and Beta bins for 2x2 plots instead of 3x3 plots. */
drop alpha_bin beta_effort_bin beta_stair_bin
label drop alphalabel beta_effortlabel beta_stairlabel

local bin_vars beta_stair beta_effort alpha
foreach var of local bin_vars {
	gen `var'_bin = .
	if "`var'" == "beta_stair" | "`var'" == "beta_effort" {
		replace `var'_bin = 1 if `var' < .98
		replace `var'_bin = 0 if `var' >=.98 & !missing(`var')
		label define `var'label 0 "Time Consistent" 1 "Present Biased"
		label values `var'_bin `var'label
	}
	else if "`var'" == "alpha" {
		replace `var'_bin = 0 if `var' < .98
		replace `var'_bin = 1 if `var' >=.98 & !missing(`var')
		label define `var'label 0 "EG Biased" 1 "Accurate Perceptions"
		label values `var'_bin `var'label
	}
}

***************************************************************
* Method 1. Using Beta_effort.
***************************************************************

global controls1 "delta_effort financial_literacy savingsplan wincome wincome_sq wincome_spouse wincome_spouse_sq i.currentlivingsituation calcage calcage2 female i.highesteducation householdmembers_399 numchildren i.jobstatus i.ethnicity i.hispaniclatino"

reg wretirement_savings $controls1, r
predict wret_resid_effort, resid

***************************************************************
* Method 1. Using Beta_stair.
***************************************************************

global controls2 "delta_stair financial_literacy savingsplan wincome wincome_sq wincome_spouse wincome_spouse_sq i.currentlivingsituation calcage calcage2 female i.highesteducation householdmembers_399 numchildren i.jobstatus i.ethnicity i.hispaniclatino"

reg wretirement_savings $controls2, r
predict wret_resid_stair, resid

/* Add mean winsorized retirement savings to residuals. */
egen mean_wret_effort = mean(wretirement_savings) if !missing(wret_resid_effort) //calculate mean for sample that went into each regression
replace wret_resid_effort = wret_resid_effort + mean_wret_effort

egen mean_wret_stair = mean(wretirement_savings) if !missing(wret_resid_stair)
replace wret_resid_stair = wret_resid_stair + mean_wret_stair

***************************************************************
* Method 2. Using dummies for Beta_effort and Alpha bins. 
***************************************************************

global controls3 "ib(0).alpha_bin#ib(0).beta_effort_bin delta_effort ib(3).financial_literacy ib(1).savingsplan wincome wincome_sq wincome_spouse wincome_spouse_sq ib(1).currentlivingsituation calcage calcage2 ib(0).female ib(13).highesteducation ib(0).householdmembers_399 ib(0).numchildren ib(1).jobstatus ib(1).ethnicity ib(2).hispaniclatino"
reg wretirement_savings $controls3, r

gen beta_effort_cons = .
gen beta_effort_cons_se = .

forval i = 0/1 {
	forval j = 0/1 {
		lincom `i'.alpha_bin#`j'.beta_effort_bin + 1*delta_effort + 40000*wincome + 1600000000*wincome_sq + 20000*wincome_spouse + 400000000*wincome_spouse_sq + 50*calcage + 2500*calcage2 + _cons
		replace beta_effort_cons = r(estimate) if alpha_bin == `i' & beta_effort_bin == `j'
		replace beta_effort_cons_se = r(se) if alpha_bin == `i' & beta_effort_bin == `j'
	}
}

***************************************************************
* Method 2. Using dummies for Beta_stair and Alpha bins. 
***************************************************************

global controls4 "ib(0).alpha_bin#ib(0).beta_stair_bin delta_stair ib(3).financial_literacy ib(1).savingsplan wincome wincome_sq wincome_spouse wincome_spouse_sq ib(1).currentlivingsituation calcage calcage2 ib(0).female ib(13).highesteducation ib(0).householdmembers_399 ib(0).numchildren ib(1).jobstatus ib(1).ethnicity ib(2).hispaniclatino"
reg wretirement_savings $controls4, r

gen beta_stair_cons = .
gen beta_stair_cons_se = .

forval i = 0/1 {
	forval j = 0/1 {
		lincom `i'.alpha_bin#`j'.beta_stair_bin + 0.75*delta_stair + 40000*wincome + 1600000000*wincome_sq + 20000*wincome_spouse + 400000000*wincome_spouse_sq + 50*calcage + 2500*calcage2 + _cons
		replace beta_stair_cons = r(estimate) if alpha_bin == `i' & beta_stair_bin == `j'
		replace beta_stair_cons_se = r(se) if alpha_bin == `i' & beta_stair_bin == `j'
	}
}

/* Save dataset with parameters and residual retirement savings for 3D plots. */
keep prim_key id cohort alpha beta_effort beta_stair alpha_bin beta_stair_bin beta_effort_bin wret_resid_effort ///
wret_resid_stair beta_effort_cons beta_effort_cons_se beta_stair_cons beta_stair_cons_se
saveold "~/Dropbox/EGBias/ALP Data/Analysis/Data/Data for 3D Plots.dta", replace

*capture log close
