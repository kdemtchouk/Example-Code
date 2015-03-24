************************************************************************************************************
* Exports data to Excel for graphing Alpha vs. Beta vs. z (frequency or residual retirement savings).
* Written by Kirill D on 12/11/14
************************************************************************************************************

clear all
set more off
use "~/Dropbox/EGBias/ALP Data/Analysis/Data/Data for 3D Plots.dta"
*keep if cohort == 1 //specify cohort
drop if missing(alpha_bin) | missing(beta_effort_bin) | missing(beta_stair_bin)

*******************************************************************
* Plots with frequency on the z-axis.
*******************************************************************

tab alpha_bin beta_effort_bin
tabout alpha_bin beta_effort_bin using "~/Dropbox/EGBias/ALP Data/Analysis/Export/3D Plots/Data/Frequency 1.xls", replace

tab alpha_bin beta_stair_bin
tabout alpha_bin beta_stair_bin using "~/Dropbox/EGBias/ALP Data/Analysis/Export/3D Plots/Data/Frequency 2.xls", replace

*******************************************************************
* Method 1. Beta_effort - Plots with residual retirement savings on z-axis.
*******************************************************************

preserve
collapse (mean) wret_resid_effort (count) freq=id, by(alpha_bin beta_effort_bin)
drop freq
reshape wide wret_resid_effort, i(alpha_bin) j(beta_effort_bin)

label variable wret_resid_effort0 "Time Consistent"
label variable wret_resid_effort1 "Present Biased"

export excel using "~/Dropbox/EGBias/ALP Data/Analysis/Export/3D Plots/Data/Retirement Savings.xlsx", sheet(beta_effort_m1) sheetreplace firstrow(varlabels)
restore

*******************************************************************
* Method 1. Beta_stair - Plots with residual retirement savings on z-axis.
*******************************************************************

preserve
collapse (mean) wret_resid_stair (count) freq=id, by(alpha_bin beta_stair_bin)
drop freq
reshape wide wret_resid_stair, i(alpha_bin) j(beta_stair_bin)

label variable wret_resid_stair0 "Time Consistent"
label variable wret_resid_stair1 "Present Biased"

export excel using "~/Dropbox/EGBias/ALP Data/Analysis/Export/3D Plots/Data/Retirement Savings.xlsx", sheet(beta_stair_m1) sheetreplace firstrow(varlabels)
restore

*******************************************************************
* Method 2. Beta_effort - Plots with residual retirement savings on z-axis.
*******************************************************************

preserve
collapse (mean) beta_effort_cons (count) freq=id, by(alpha_bin beta_effort_bin)
drop freq
reshape wide beta_effort_cons, i(alpha_bin) j(beta_effort_bin)

label variable beta_effort_cons0 "Time Consistent"
label variable beta_effort_cons1 "Present Biased"

export excel using "~/Dropbox/EGBias/ALP Data/Analysis/Export/3D Plots/Data/Retirement Savings.xlsx", sheet(beta_effort_m2) sheetreplace firstrow(varlabels)
restore

*******************************************************************
* Method 2. Beta_stair - Plots with residual retirement savings on z-axis.
*******************************************************************

preserve
collapse (mean) beta_stair_cons (count) freq=id, by(alpha_bin beta_stair_bin)
drop freq
reshape wide beta_stair_cons, i(alpha_bin) j(beta_stair_bin)

label variable beta_stair_cons0 "Time Consistent"
label variable beta_stair_cons1 "Present Biased"

export excel using "~/Dropbox/EGBias/ALP Data/Analysis/Export/3D Plots/Data/Retirement Savings.xlsx", sheet(beta_stair_m2) sheetreplace firstrow(varlabels)
restore

/* Export standard errors of method 2 estimates. */
preserve
collapse (mean) beta_effort_cons_se, by(alpha_bin beta_effort_bin)
export excel using "~/Dropbox/EGBias/ALP Data/Analysis/Export/3D Plots/Method 2/Standard Errors (Method 2).xlsx", sheet(beta_effort_m2) sheetreplace firstrow(variables)
restore
preserve
collapse (mean) beta_stair_cons_se, by(alpha_bin beta_stair_bin)
export excel using "~/Dropbox/EGBias/ALP Data/Analysis/Export/3D Plots/Method 2/Standard Errors (Method 2).xlsx", sheet(beta_stair_m2) sheetreplace firstrow(variables)
restore
