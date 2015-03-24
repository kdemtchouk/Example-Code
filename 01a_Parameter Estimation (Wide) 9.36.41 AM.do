************************************************************************************************************
* Estimates Beta, Beta Hat, and Delta for a particular cohort, using their responses to Surveys 1 and 2.
* Exports data to calculate Alpha in Matlab and merges back Alpha estimates.
* Produces a dataset with one observation for each respondent, combining responses for Surveys 1 and 2.
* Written by Kirill D on 11/5/14.
************************************************************************************************************

clear all
set more off
tempfile master survey_2

/* Open Survey 1 results. */
use "~/Dropbox/EGBias/ALP Data/Analysis/Import/ms392.dta"
encode prim_key, gen(user)

********************************************************************
* Survey 1 Estimates of Alpha.
********************************************************************

/* Export .csv with data necessary to calculate Alpha in Matlab. */
preserve
keep user a001 a002 a003 a004 a005
reshape long a00, i(user) j(question)
keep if a00 != .
outsheet user question a00 using "~/Dropbox/EGBias/ALP Data/Analysis/Export/alphadata.csv", comma nolabel nonames replace
restore

/* Create Stata dataset of calculated Alphas. */
preserve
insheet using "~/Dropbox/EGBias/ALP Data/Analysis/Import/alphas_1_21.csv", clear
sort user
saveold "~/Dropbox/EGBias/ALP Data/Analysis/Data/Alphas.dta", replace
restore

/* Merge estimated Alphas onto main dataset. */
merge 1:1 user using "~/Dropbox/EGBias/ALP Data/Analysis/Data/ManyAlphas.dta" // 2015-03-07 Now includes dropset alphas
// Don't comment out these asserts -- if they are violated, something wrong! - ML:11-Dec
assert a001 == . if _merge == 1
assert _merge != 2
drop _merge
drop if prim_key == ""
gen alpha_neg_flag = (alpha<0)
replace alpha = 0 if alpha < 0

********************************************************************
* Survey 1 (Real Effort) Estimates of Beta, Beta Hat, and Delta.
********************************************************************

/* Re-label PB elicitation questions in accordance with RCT Registry/AnalysisPlan.pdf. */
label var pb_006_1 "Job 4* Cutoff"
label var pb_006_2 "Job 1* Cutoff"
label var pb_006_3 "Job 2* Cutoff"
label var pb_006_4 "Job 3* Cutoff"
label var pb_007 "Job 5 Prediction"

/* Calculate Beta, Beta Hat, and Delta according to RCT Registry/AnalysisPlan.pdf. */
gen delta_effort = (pb_006_4 - pb_006_1)/(pb_006_3 - pb_006_1)
gen beta_effort = ((pb_006_3 - pb_006_1)^2)/((pb_006_2 - pb_006_1)*(pb_006_4 - pb_006_1))
gen beta_hat_effort = (pb_006_3 - pb_006_1)/(pb_007 - 20)
save `master', replace

********************************************************************
* Survey 2 (Time Staircase) Estimates of Beta, Beta Hat, and Delta.
********************************************************************

/* Open Survey 2 results. */
use "~/Dropbox/EGBias/ALP Data/Analysis/Import/ms399.dta"

/* Reorder variables indicating dollar amount of Option (b) to correspond to order of responses. */
order fl_block1_amounts_10_-fl_block1_amounts_9_, after(bl1_a31) sequential
order fl_block2_amounts_1_-fl_block2_amounts_9_, after(bl2_b31) sequential
order fl_block3_amounts_10_-fl_block3_amounts_9_, after(bl3_c31) sequential

/* Dollar amounts are string variables. Convert to numeric. */
forval i = 1/3 {
	forval j = 1/31 {
		destring fl_block`i'_amounts_`j'_, replace
	}
	destring fl_block`i'_base, replace
}

/* Calculate indifference points for Blocks 1-3. */
forval i = 1/3 {
	if `i' == 1 {
		local j a
	}
	else if `i' == 2 {
		local j b
	}
	else if `i' == 3 {
		local j c
	}
	
	//value of 1 corresponds to choosing Option A
	//value of 2 corresponds to choosing Option B
	gen bl`i'_lower_bound = .
	gen bl`i'_upper_bound = .

	//respondents who never accepted Option (b) have an upper bound greater than the maximum offered amount
	//give them an upper bound greater than the maximum offer by the same increment that the maximum offer is greater than the 2nd greatest offer
	replace bl`i'_lower_bound = fl_block`i'_amounts_23_ if bl`i'_`j'23 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_23_ + (fl_block`i'_amounts_23_ - fl_block`i'_amounts_22_) if bl`i'_`j'23 == 1
	//flag these respondents
	gen bl`i'_no_upper_bound = 0
	replace bl`i'_no_upper_bound = 1 if bl`i'_`j'23 == 1

	//now consider normal cases
	replace bl`i'_lower_bound = fl_block`i'_amounts_22_ if bl`i'_`j'23 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_23_ if bl`i'_`j'23 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_24_ if bl`i'_`j'24 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_22_ if bl`i'_`j'24 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_18_ if bl`i'_`j'24 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_24_ if bl`i'_`j'24 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_20_ if bl`i'_`j'20 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_18_ if bl`i'_`j'20 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_19_ if bl`i'_`j'20 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_20_ if bl`i'_`j'20 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_21_ if bl`i'_`j'21 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_19_ if bl`i'_`j'21 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_17_ if bl`i'_`j'21 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_21_ if bl`i'_`j'21 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_31_ if bl`i'_`j'31 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_17_ if bl`i'_`j'31 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_29_ if bl`i'_`j'31 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_31_ if bl`i'_`j'31 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_30_ if bl`i'_`j'30 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_29_ if bl`i'_`j'30 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_25_ if bl`i'_`j'30 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_30_ if bl`i'_`j'30 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_28_ if bl`i'_`j'28 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_25_ if bl`i'_`j'28 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_26_ if bl`i'_`j'28 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_28_ if bl`i'_`j'28 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_27_ if bl`i'_`j'27 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_26_ if bl`i'_`j'27 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_1_ if bl`i'_`j'27 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_27_ if bl`i'_`j'27 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_16_ if bl`i'_`j'16 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_1_ if bl`i'_`j'16 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_14_ if bl`i'_`j'16 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_16_ if bl`i'_`j'16 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_15_ if bl`i'_`j'15 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_14_ if bl`i'_`j'15 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_10_ if bl`i'_`j'15 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_15_ if bl`i'_`j'15 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_13_ if bl`i'_`j'13 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_10_ if bl`i'_`j'13 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_11_ if bl`i'_`j'13 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_13_ if bl`i'_`j'13 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_12_ if bl`i'_`j'12 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_11_ if bl`i'_`j'12 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_2_ if bl`i'_`j'12 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_12_ if bl`i'_`j'12 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_8_ if bl`i'_`j'8 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_2_ if bl`i'_`j'8 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_7_ if bl`i'_`j'8 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_8_ if bl`i'_`j'8 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_9_ if bl`i'_`j'9 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_7_ if bl`i'_`j'9 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_3_ if bl`i'_`j'9 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_9_ if bl`i'_`j'9 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_6_ if bl`i'_`j'6 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_3_ if bl`i'_`j'6 == 1

	replace bl`i'_lower_bound = fl_block`i'_amounts_4_ if bl`i'_`j'6 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_6_ if bl`i'_`j'6 == 2

	replace bl`i'_lower_bound = fl_block`i'_amounts_5_ if bl`i'_`j'5 == 1
	replace bl`i'_upper_bound = fl_block`i'_amounts_4_ if bl`i'_`j'5 == 1

	//respondents who never declined Option (b) are assumed to have a lower bound equal to the constant amount of Option (a)
	replace bl`i'_lower_bound = fl_block`i'_base if bl`i'_`j'5 == 2
	replace bl`i'_upper_bound = fl_block`i'_amounts_5_ if bl`i'_`j'5 == 2
	//flag these respondents
	gen bl`i'_no_lower_bound = 0
	replace bl`i'_no_lower_bound = 1 if bl`i'_`j'5 == 2

	egen bl`i'_indiff_point = rowmean(bl`i'_lower_bound bl`i'_upper_bound) if !bl`i'_no_upper_bound
	egen bl`i'_indiff_point2 = rowmean(bl`i'_lower_bound bl`i'_upper_bound)
}

/* Calculate Beta, Beta Hat, and Delta. Create two different sets of variables with and without imputed values for those who never took Option (b). */
gen delta_stair = fl_block2_base / bl2_indiff_point
gen delta_stair2 = fl_block2_base / bl2_indiff_point2
gen delta_impute = (bl2_no_upper_bound)

gen beta_stair = fl_block1_base / (delta_stair * bl1_indiff_point)
gen beta_stair2 = fl_block1_base / (delta_stair2 * bl1_indiff_point2)
gen beta_impute = (bl1_no_upper_bound)

gen beta_hat_stair = fl_block3_base / (delta_stair * bl3_indiff_point)
gen beta_hat_stair2 = fl_block3_base / (delta_stair2 * bl3_indiff_point2)
gen beta_hat_impute = (bl3_no_upper_bound)

/* Append "_399" to variable names. */
foreach var of varlist tsstart-cs_001 {
	rename `var' `var'_399
}
tempfile 399_results
save `survey_2', replace

/* Open Survey 1 results and merge on Survey 2 results by respondent ID. */
use `master'
merge 1:1 prim_key using `survey_2', nogen
drop user
encode prim_key, gen(id)

/* Generate cohort indicator. */
gen cohort = (pilot==3) //Cohort 1
replace cohort = 2 if pilot==4 //Cohort 2
drop if cohort == 0 //Drop pilot users

/* Rename and/or generate demographic variables. */
rename b001a income
rename b002 married
rename b003a income_spouse
rename b004 retirement_savings
rename b007 nonretire_savings
rename b011 residence
rename b013 mortgage
rename b015	secured_debt_cat
rename b016 unsecured_debt_cat
rename pb_010 risk_tolerance

gen secured_debt = 500 if secured_debt_cat==1
replace secured_debt = 5000 if secured_debt_cat==2
replace secured_debt = 30000 if secured_debt_cat==3
replace secured_debt = 75000 if secured_debt_cat==4
replace secured_debt = 175000 if secured_debt_cat==5
replace secured_debt = 250000 if secured_debt_cat==6

gen unsecured_debt = 500 if unsecured_debt_cat==1
replace unsecured_debt = 5000 if unsecured_debt_cat==2
replace unsecured_debt = 30000 if unsecured_debt_cat==3
replace unsecured_debt = 75000 if unsecured_debt_cat==4
replace unsecured_debt = 175000 if unsecured_debt_cat==5
replace unsecured_debt = 250000 if unsecured_debt_cat==6

gen calcage2 = calcage^2
gen calcage10 = calcage-mod(calcage,10)
gen lincome = ln(income+1)
gen lretirement_savings = ln(retirement_savings+1)
recode householdmembers 4=3 5=3 6=3 7=3 8=3 9=3  // Group together 3+ household members
recode highesteducation 3=8 4=8 5=8 6=8 7=8 // Group together less than high school

gen spouse=0
replace spouse=1 if !missing(income_spouse)
replace income_spouse=0 if income_spouse==.
replace mortgage=0 if mortgage==.
replace residence=0 if residence==.
gen networth= retirement_savings + nonretire_savings + residence - mortgage - secured_debt -unsecured_debt
gen lnetworth= ln(networth+500000)

winsor retirement_savings, gen(wretirement_savings) p(.05) highonly
winsor networth, gen(wnetworth) p(.05)

/* Hypothetical retirement savings calculations. */
rename b024 financial_confidence
rename r003 whenpaperwork_392
rename r003_399 whenpaperwork_399
rename r003b nochange_392
rename r003b_399 nochange_399
rename r006 whenbutton_392
rename r006_399 whenbutton_399

gen r001_value_392 = .
replace r001_value_392 = r001_amount if r001_frequency == 1
replace r001_value_392 = 12*r001_amount if r001_frequency == 2
replace r001_value_392 = 26*r001_amount if r001_frequency == 3
replace r001_value_392 = 52*r001_amount if r001_frequency == 4
label var r001_value_392 "Survey 1 No-match annual contribution"
sum r001_value_392, detail

gen r002_value_392 = .
replace r002_value_392 = r002_amount if r002_frequency == 1
replace r002_value_392 = 12*r002_amount if r002_frequency == 2
replace r002_value_392 = 26*r002_amount if r002_frequency == 3
replace r002_value_392 = 52*r002_amount if r002_frequency == 4
label var r002_value_392 "Survey 1 Annual contribution with match"
sum r002_value_392, detail

gen r004_value_392 = .
replace r004_value_392 = r004_amount if r004_frequency == 1
replace r004_value_392 = 12*r004_amount if r004_frequency == 2
replace r004_value_392 = 26*r004_amount if r004_frequency == 3
replace r004_value_392 = 52*r004_amount if r004_frequency == 4
label var r004_value_392 "Survey 1 Annual contribution with match"
sum r004_value_392, detail

gen r007_value_392 = .
replace r007_value_392 = r007_amount if r007_frequency == 1
replace r007_value_392 = 12*r007_amount if r007_frequency == 2
replace r007_value_392 = 26*r007_amount if r007_frequency == 3
replace r007_value_392 = 52*r007_amount if r007_frequency == 4
label var r007_value_392 "Survey 1 Annual contribution with match second pass; only press a button"
sum r007_value_392, detail

gen r001_value_399 = .
replace r001_value_399 = r001_amount_399 if r001_frequency_399 == 1
replace r001_value_399 = 12*r001_amount_399 if r001_frequency_399 == 2
replace r001_value_399 = 26*r001_amount_399 if r001_frequency_399 == 3
replace r001_value_399 = 52*r001_amount_399 if r001_frequency_399 == 4
label var r001_value_399 "Survey 2 No-match annual contribution"
sum r001_value_399, detail

gen r002_value_399 = .
replace r002_value_399 = r002_amount_399 if r002_frequency_399 == 1
replace r002_value_399 = 12*r002_amount_399 if r002_frequency_399 == 2
replace r002_value_399 = 26*r002_amount_399 if r002_frequency_399 == 3
replace r002_value_399 = 52*r002_amount_399 if r002_frequency_399 == 4
label var r002_value_399 "Survey 1 Annual contribution with match"
sum r002_value_399, detail

gen r004_value_399 = .
replace r004_value_399 = r004_amount_399 if r004_frequency_399 == 1
replace r004_value_399 = 12*r004_amount_399 if r004_frequency_399 == 2
replace r004_value_399 = 26*r004_amount_399 if r004_frequency_399 == 3
replace r004_value_399 = 52*r004_amount_399 if r004_frequency_399 == 4
label var r004_value_399 "Survey 2 Annual contribution with match"
sum r004_value_399, detail

gen r007_value_399 = .
replace r007_value_399 = r007_amount_399 if r007_frequency_399 == 1
replace r007_value_399 = 12*r007_amount_399 if r007_frequency_399 == 2
replace r007_value_399 = 26*r007_amount_399 if r007_frequency_399 == 3
replace r007_value_399 = 52*r007_amount_399 if r007_frequency_399 == 4
label var r007_value_399 "Survey 2 Annual contribution with match second pass; only press a button"
sum r007_value_399, detail

gen contribution_392 = r004_value_392
gen contribution_399 = r004_value_399
gen contribution_change_392 = r004_value_392 - r001_value_392
gen contribution_change_399 = r004_value_399 - r001_value_399
replace contribution_392 = r001_value_392 if whenpaperwork_392 ==1 | nochange_392==2
replace contribution_399 = r001_value_399 if whenpaperwork_399 ==1 | nochange_399==2 
replace contribution_change_392 = 0 if whenpaperwork_392 ==1 | nochange_392==2
replace contribution_change_399 = 0 if whenpaperwork_399 ==1 | nochange_399==2
winsor contribution_392, gen(wcontribution_392) p(.05)
winsor contribution_399, gen(wcontribution_399) p(.05)
winsor contribution_change_392, gen(wcontribution_change_392) p(.05)
winsor contribution_change_399, gen(wcontribution_change_399) p(.05)
gen diffindiff = contribution_change_399 - contribution_change_392
winsor diffindiff, gen(wdiffindiff) p(.05)
gen w2diffindiff= wcontribution_change_399 - wcontribution_change_392

gen diffpostmatch =  r004_value_399 - r001_value_392 if whenpaperwork_392~=1 & whenpaperwork_399~=1
replace diffpostmatch = r001_value_399 - r001_value_392 if whenpaperwork_392~=1 & (whenpaperwork_399==1 | nochange_399==2)
replace diffpostmatch = r004_value_399 - r001_value_392 if (whenpaperwork_392==1 | nochange_392==2) & whenpaperwork_399~=1
replace diffpostmatch = r001_value_399 - r001_value_392 if (whenpaperwork_392==1 | nochange_392==2) & (whenpaperwork_399==1 | nochange_399==2)
winsor diffpostmatch, gen(wdiffpostmatch) p(.05)

/* Generate bins for parameters. */
local bin_vars beta_stair beta_stair2 beta_effort beta_hat_stair beta_hat_stair2 beta_hat_effort alpha

foreach var of local bin_vars {
	gen `var'_bin = .
	replace `var'_bin = 0 if `var' < .98
	replace `var'_bin = 1 if `var' >=.98 & `var' <= 1.025
	replace `var'_bin = 2 if `var' > 1.025 & !missing(`var')
	if "`var'" == "beta_stair" | "`var'" == "beta_stair2" | "`var'" == "beta_effort" {
		label define `var'label 0 "Present Biased" 1 "Time Consistent" 2 "Future Biased"
		label values `var'_bin `var'label
	}
	else if "`var'" == "beta_hat_stair" | "`var'" == "beta_hat_stair2" | "`var'" == "beta_hat_effort" {
		label define `var'label 0 "Beta < Beta_hat" 1 "Beta = Beta_hat" 2 "Beta > Beta_hat"
		label values `var'_bin `var'label
	}
	else if "`var'" == "alpha" {
		label define `var'label 0 "Underestimates EG" 1 "Accurately Estimates EG" 2 "Overestimates EG"
		label values `var'_bin `var'label
	}
}

/* Further variable definitions from Josh. (11/27/14) */
gen high_stakes_alpha = (amount_randomizer == 20)
bysort high_stakes_alpha: sum payout_alpha 

gen egboc = (a006 - totalamount_alpha)/15 if high_stakes_alpha==0 // Overconfidence in EGB accuracy
replace egboc = (a006 - totalamount_alpha)/75 if high_stakes_alpha==1
winsor beta_effort, gen(wbeta_effort) p(.05)
winsor delta_effort, gen(wdelta_effort) p(.05)
winsor beta_hat_effort, gen(wbeta_hat_effort) p(.05)
winsor beta_stair, gen(wbeta_stair) p(.05)
winsor delta_stair, gen(wdelta_stair) p(.05)
winsor beta_hat_stair, gen(wbeta_hat_stair) p(.05)
winsor beta_stair2, gen(wbeta_stair2) p(.05)
winsor delta_stair2, gen(wdelta_stair2) p(.05)
winsor beta_hat_stair2, gen(wbeta_hat_stair2) p(.05)

label define PB 0 "Present-biased" 1 "Time-consistent" 2 "Future-biased"
label define EX 0 "Exponential Discounter" 1 "No Time Preference" 2 "Exponential Increase"
label define EGB 0 "Not EG-Biased" 1 "Partial EG-Bias" 2 "Complete EG-Bias"

gen shorttermloan=0 if ba_010a_399 ~=1 
replace shorttermloan=1 if ba_010a_399 ==1 
gen bankruptcy=0 if ba_010b_399 ~=1 
replace bankruptcy=1 if ba_010b_399 ==1 

gen iq = (ba_011a_399==4) + (ba_011b_399==4) + (ba_011c_399==4) + (ba_011d_399==2) + (ba_011e_399==6) ///
	if ba_011a_399~=. & ba_011b_399~=. & ba_011c_399~=. & ba_011d_399~=. & ba_011e_399~=.

rename ba_003a_399 postpone
rename ba_003b_399 forfuture
rename ba_003c_399 dowhenplan
gen patience_index = - postpone + forfuture + dowhenplan

gen financialhead = 0 if ba_004_399 ~=.
replace financialhead = 1 if ba_004_399 ==1  

rename ba_005_399 taxstatus
rename ba_006_month_399 taxmonth
replace taxmonth = 11 if taxmonth== 12
replace taxmonth = 11 if ba_006_399 ==2

gen passivefundgood =ba_008a_399 if ba_008a_399!=6

/* Further variable definitions from Josh. (12/11/14) */
gen savingsplan=0 if r009~=.
replace savingsplan=1 if r009==1
label var savingsplan "Does your current employer offer a tax-deferred retirement savings plan such as a 401(k) or a 403(b)?"

winsor income, gen(wincome) p(.05) highonly
winsor income_spouse, gen(wincome_spouse) p(.05) highonly
gen wincome_sq = wincome*wincome
gen wincome_spouse_sq = wincome_spouse* wincome_spouse

gen female = 0 if gender==1
replace female =1 if gender==2

rename ba_001_399 numchildren

gen financial_literacy =  (b018==3) + (b019==2) + (b020==1)

gen jobstatus = .
replace jobstatus=1 if currentjobstatuss1==1
replace jobstatus=2 if currentjobstatuss2==2
replace jobstatus=3 if currentjobstatuss3==3
replace jobstatus=4 if currentjobstatuss4==4
replace jobstatus=5 if currentjobstatuss5==5
replace jobstatus=6 if currentjobstatuss6==6
replace jobstatus=7 if currentjobstatuss7==7
label define job_status_labels 1 "Working now" 2 "Unemployed and looking" 3 "Temporarily not working" 4 "Disabled" 5 "Retired" 6 "Homemaker" 7 "Other"
label values jobstatus job_status_labels

compress
saveold "~/Dropbox/EGBias/ALP Data/Analysis/Data/Survey Results with Estimates.dta", replace
