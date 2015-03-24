************************************************************************************************************
* Outputs CDFs and bar graphs of parameter estimates.
* Written by Kirill D on 11/9/14.
************************************************************************************************************

clear all
set more off
use "~/Dropbox/EGBias/ALP Data/Analysis/Data/Survey Results with Estimates.dta"
*keep if cohort == 1 //specify cohort
drop wbeta_effort wdelta_effort wbeta_hat_effort wbeta_stair wdelta_stair wbeta_hat_stair //drop winsorized parameters in permanent dataset

********************************************************************
* CDFs of Beta, Beta Hat, and Alpha.
********************************************************************

local cdf_vars beta_stair beta_effort beta_hat_stair beta_hat_effort alpha
local num 1

foreach var of local cdf_vars {
	preserve
	tabstat `var', stat(N) save //count non-missing values of the variable for the graph's subtitle
	matrix stats=r(StatTotal)
	local num_obs=stats[1,1]
	//cap top and/or bottom X% of observations to make CDFs visually comparable
	if "`var'" == "beta_stair" {
		winsor `var', gen(w`var') p(0.05) highonly
	}
	else if "`var'" == "beta_effort" {
		winsor `var', gen(w`var') p(0.075) highonly
	}
	else if "`var'" == "beta_hat_stair" {
		winsor `var', gen(w`var') p(0.05) highonly
	}
	else if "`var'" == "beta_hat_effort" {
		winsor `var', gen(w`var') p(0.25) highonly
	}
	else if "`var'" == "alpha" {
		winsor `var', gen(w`var') p(0.01)
	}
	cumul w`var', gen(w`var'_pctile)
	sort w`var'_pctile
	line w`var'_pctile w`var', ytitle("") title("CDF of `var'") subtitle("N = `num_obs'") xlab(, grid) ylab(, grid)
	graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/CDFs/CDF `num'.pdf", replace
	restore
	local num = `num' + 1
}

********************************************************************
* Bar graphs of Beta, Beta Hat, and Alpha bins.
********************************************************************

/* Count non-missing values of the variable for the graph's subtitle. */
tabstat beta_stair_bin beta_effort_bin beta_hat_stair beta_hat_effort alpha_bin, stat(N) save
matrix stats=r(StatTotal)

/* Make bar graphs. */
local num_obs=stats[1,1]
graph bar (count), over(beta_stair_bin) title("Distribution of Beta_stair") subtitle("N = `num_obs'")
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Parameter Bar Plots/Beta stair bin.pdf", replace

local num_obs=stats[1,2]
graph bar (count), over(beta_effort_bin) title("Distribution of Beta_effort") subtitle("N = `num_obs'")
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Parameter Bar Plots/Beta effort bin.pdf", replace

local num_obs=stats[1,3]
graph bar (count), over(beta_hat_stair_bin) title("Distribution of Beta_hat_stair") subtitle("N = `num_obs'")
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Parameter Bar Plots/Beta hat stair bin.pdf", replace

local num_obs=stats[1,4]
graph bar (count), over(beta_hat_effort_bin) title("Distribution of Beta_hat_effort") subtitle("N = `num_obs'")
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Parameter Bar Plots/Beta hat effort bin.pdf", replace

local num_obs=stats[1,5]
graph bar (count), over(alpha_bin) title("Distribution of Alpha") subtitle("N = `num_obs'")
graph export "~/Dropbox/EGBias/ALP Data/Analysis/Export/Parameter Bar Plots/Alpha bin.pdf", replace
