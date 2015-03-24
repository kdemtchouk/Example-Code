********************************************************************************************************************
* This program runs conditional logit regressions to model consumer choice with the Nielsen Bill Scrape data.
* These regressions distinguish between plans across carriers. Voice limits, data limits, and prices are regressors.
* Written by Kirill D. on 6/16/14.
********************************************************************************************************************

clear all
set more off
global rawdata = "\\crsfsas2\data115\MF-Columbus\Stata\Data\import"
global statadata = "\\crsfsas2\data115\MF-Columbus\Stata\Data\datasets"
global output = "\\crsfsas2\data115\MF-Columbus\Stata\Data\export"

*capture log using "\\crsfsas2\data115\MF-Columbus\Stata\Code\03_Analysis\Nielsen Bill Scrape\Choice Regressions with Price log.txt", replace text

use "$statadata/master/nielsen_bill_scrape.dta", clear

/* Drop families with more than 5 lines. */
codebook panelistid if numoflines > 5
drop if numoflines > 5

/* Replace data limit with 0 if user doesn't have a data plan. */
replace data_limit = 0 if wwonlynmcl=="" 

/* Identify top 2 current voice/data plan combinations by family size & carrier. Use frequency among primary account holders. */
tostring data_limit, gen(data_string)
replace data_string = data_string +" MB" if !unltd_data
replace data_string = "(Data Plan Unknown)" if data_limit==.
replace data_string = "(No Data Plan)" if data_limit==0
replace data_string = "Unlimited MB" if unltd_data
gen full_plan_name = vocplnnmcl + " " + data_string
*bys numoflines: tab full_plan_name if primacctid=="Primary Account Holder" & carrierid=="AT&T", sort
*bys numoflines: tab full_plan_name if primacctid=="Primary Account Holder" & carrierid=="Sprint", sort
*bys numoflines: tab full_plan_name if primacctid=="Primary Account Holder" & carrierid=="T-Mobile", sort
*bys numoflines: tab full_plan_name if primacctid=="Primary Account Holder" & carrierid=="Verizon Wireless", sort

/* Flag top 2 current plans by family size & carrier. */
gen top_plan = 0
replace top_plan = 1 if carrierid=="AT&T" & numoflines==1 & vocplnnmcl=="Nation 450/5000" & wwonlynmcl=="Data Unlimited for iPhone"
replace top_plan = 1 if carrierid=="AT&T" & numoflines==1 & vocplnnmcl=="Nation 450/5000" & wwonlynmcl=="DATAPRO 2GB IP"
replace top_plan = 1 if carrierid=="AT&T" & numoflines==2 & vocplnnmcl=="Nation 550 FamilyTalk" & wwonlynmcl=="Data Unlimited for iPhone"
replace top_plan = 1 if carrierid=="AT&T" & numoflines==2 & vocplnnmcl=="Nation 700 FamilyTalk" & wwonlynmcl=="Data Unlimited for iPhone"
replace top_plan = 1 if carrierid=="AT&T" & numoflines==3 & vocplnnmcl=="Nation 700 FamilyTalk" & wwonlynmcl=="DATAPRO 2GB IP"
replace top_plan = 1 if carrierid=="AT&T" & numoflines==3 & vocplnnmcl=="Nation 700 FamilyTalk" & wwonlynmcl=="Data Unlimited for iPhone"
replace top_plan = 1 if carrierid=="AT&T" & numoflines==4 & vocplnnmcl=="Nation 700 FamilyTalk" & wwonlynmcl=="Data Unlimited for iPhone"
replace top_plan = 1 if carrierid=="AT&T" & numoflines==4 & vocplnnmcl=="Nation 700 FamilyTalk" & wwonlynmcl=="DATAPRO 2GB IP"
replace top_plan = 1 if carrierid=="AT&T" & numoflines==5 & vocplnnmcl=="Nation 700 FamilyTalk" & wwonlynmcl=="Data Unlimited for iPhone"
replace top_plan = 1 if carrierid=="AT&T" & numoflines==5 & vocplnnmcl=="Nation 700 FamilyTalk" & wwonlynmcl=="DATAPRO 2GB IP"

replace top_plan = 1 if carrierid=="Sprint" & numoflines==1 & vocplnnmcl=="Everything Data 450" & wwonlynmcl=="12.5GB Data SMHS Value"
replace top_plan = 1 if carrierid=="Sprint" & numoflines==1 & vocplnnmcl=="Simply Everything" & wwonlynmcl=="Premium Data add-on charge"
replace top_plan = 1 if carrierid=="Sprint" & numoflines==2 & vocplnnmcl=="Everything Data Share 1500" & wwonlynmcl=="2.5GB Data SMHS Value"
replace top_plan = 1 if carrierid=="Sprint" & numoflines==2 & vocplnnmcl=="Everything Data 450" & wwonlynmcl=="12.5GB Data SMHS Value"
replace top_plan = 1 if carrierid=="Sprint" & numoflines==3 & vocplnnmcl=="Everything Data Share 1500" & wwonlynmcl=="2.5GB Data SMHS Value"
replace top_plan = 1 if carrierid=="Sprint" & numoflines==3 & vocplnnmcl=="Everything Messaging Share 1500" & wwonlynmcl=="500MB Data SMHS Classic"
replace top_plan = 1 if carrierid=="Sprint" & numoflines==4 & vocplnnmcl=="Everything Data Share 1500" & wwonlynmcl=="2.5GB Data SMHS Value"
replace top_plan = 1 if carrierid=="Sprint" & numoflines==4 & vocplnnmcl=="Everything Messaging Share 1500" & wwonlynmcl=="500MB Data SMHS Classic"
replace top_plan = 1 if carrierid=="Sprint" & numoflines==5 & vocplnnmcl=="Everything Data Share 1500" & wwonlynmcl=="2.5GB Data SMHS Value"
replace top_plan = 1 if carrierid=="Sprint" & numoflines==5 & vocplnnmcl=="Everything Messaging Share 1500" & wwonlynmcl=="500MB Data SMHS Classic"

replace top_plan = 1 if carrierid=="T-Mobile" & numoflines==1 & vocplnnmcl=="Value Unlimited-Talk+Text" & wwonlynmcl=="2GB Data Value"
replace top_plan = 1 if carrierid=="T-Mobile" & numoflines==1 & vocplnnmcl=="Value Unlimited-Talk+Text" & wwonlynmcl=="Value Unlimited Data"
replace top_plan = 1 if carrierid=="T-Mobile" & numoflines==2 & vocplnnmcl=="Value Family Unlimited-Talk+Text" & wwonlynmcl=="2GB Data Value"
replace top_plan = 1 if carrierid=="T-Mobile" & numoflines==2 & vocplnnmcl=="Value Family Unlimited-Talk+Text" & wwonlynmcl=="2.5GB Data SMHS Value"
replace top_plan = 1 if carrierid=="T-Mobile" & numoflines==3 & vocplnnmcl=="Value Family Unlimited-Talk+Text" & wwonlynmcl=="2GB Data Value"
replace top_plan = 1 if carrierid=="T-Mobile" & numoflines==3 & vocplnnmcl=="Value Family Unlimited-Talk+Text" & wwonlynmcl=="500MB Data SMHS Value"
replace top_plan = 1 if carrierid=="T-Mobile" & numoflines==4 & vocplnnmcl=="Value Family Unlimited-Talk+Text" & wwonlynmcl=="2GB Data Value"
replace top_plan = 1 if carrierid=="T-Mobile" & numoflines==4 & vocplnnmcl=="Value Family Unlimited-Talk+Text" & wwonlynmcl=="500MB Data SMHS Value"
replace top_plan = 1 if carrierid=="T-Mobile" & numoflines==5 & vocplnnmcl=="Value Family Unlimited-Talk+Text" & wwonlynmcl=="500MB Data SMHS Value"
replace top_plan = 1 if carrierid=="T-Mobile" & numoflines==5 & vocplnnmcl=="Value Family Unlimited-Talk+Text" & wwonlynmcl=="2GB Data Value"

replace top_plan = 1 if carrierid=="Verizon Wireless" & numoflines==1 & vocplnnmcl=="Share Everything Unlimited Talk & Text 2GB" & wwonlynmcl=="SHARE EVERY UNL TLK&TXT 2GB"
replace top_plan = 1 if carrierid=="Verizon Wireless" & numoflines==1 & vocplnnmcl=="Share Everything Unlimited Talk & Text 1GB" & wwonlynmcl=="SHARE EVERY UNL TLK&TXT 1GB"
replace top_plan = 1 if carrierid=="Verizon Wireless" & numoflines==2 & vocplnnmcl=="Share Everything Unlimited Talk & Text 4GB" & wwonlynmcl=="SHARE EVERY UNL TLK&TXT 4GB"
replace top_plan = 1 if carrierid=="Verizon Wireless" & numoflines==2 & vocplnnmcl=="Share Everything Unlimited Talk & Text 2GB" & wwonlynmcl=="SHARE EVERY UNL TLK&TXT 2GB"
replace top_plan = 1 if carrierid=="Verizon Wireless" & numoflines==3 & vocplnnmcl=="Share Everything Unlimited Talk & Text 4GB" & wwonlynmcl=="SHARE EVERY UNL TLK&TXT 4GB"
replace top_plan = 1 if carrierid=="Verizon Wireless" & numoflines==3 & vocplnnmcl=="Share Everything Unlimited Talk & Text 2GB" & wwonlynmcl=="SHARE EVERY UNL TLK&TXT 2GB"
replace top_plan = 1 if carrierid=="Verizon Wireless" & numoflines==4 & vocplnnmcl=="Share Everything Unlimited Talk & Text 4GB" & wwonlynmcl=="SHARE EVERY UNL TLK&TXT 4GB"
replace top_plan = 1 if carrierid=="Verizon Wireless" & numoflines==4 & vocplnnmcl=="Share Everything Unlimited Talk & Text 6GB" & wwonlynmcl=="SHARE EVERY UNL TLK&TXT 6GB"
replace top_plan = 1 if carrierid=="Verizon Wireless" & numoflines==5 & vocplnnmcl=="Share Everything Unlimited Talk & Text 6GB" & wwonlynmcl=="SHARE EVERY UNL TLK&TXT 6GB"
replace top_plan = 1 if carrierid=="Verizon Wireless" & numoflines==5 & vocplnnmcl=="Share Everything Unlimited Talk & Text 8GB" & wwonlynmcl=="SHARE EVERY UNL TLK&TXT 8GB"

/* Convert data use into GB and voice use into hundreds of minutes. */
replace data_limit = data_limit/1000 //from MB to GB
replace voice_limit = voice_limit/100 //from minutes to hundreds of minutes
replace wwkbusg = wwkbusg/(1024^2) //from KB to GB
replace anymnsusd = anymnsusd/100 //from minutes to hundreds of minutes

/* Generate age and income variables. */
gen age = round(ageid_full)
gen income = .
*use midpoint of income buckets
replace income = 7500 if incomerndid_full == "< $15,000"
replace income = 25000 if incomerndid_full == "$15,000 - $34,999"
replace income = 42500 if incomerndid_full == "$35,000 - $49,999"
replace income = 62500 if incomerndid_full == "$50,000 - $74,999"
replace income = 87500 if incomerndid_full == "$75,000 - $99,999"
replace income = 120000 if incomerndid_full == "$100,000 +"

/* Generate price as sum of monthly voice plan charge and total data package charge. */
gen price = vocmrcchg + ttldatpkgchg
replace price = price + 20 if carrierid=="T-Mobile" & strpos(vocplnnmcl,"Value")>0 //add $20 to account for Tiger plans that do not subsidize phones

/* Drop families where any line has negative prices. */
bys panelistid: gen neg_price = (price<0)
bys panelistid: egen max_neg_price = max(neg_price)
codebook panelistid if max_neg_price
drop if max_neg_price
drop neg_price max_neg_price

/* Drop families with average price per line of less than $15. */
bys panelistid: egen avg_price = mean(price)
bys panelistid: gen low_price = (avg_price<15)
codebook panelistid if low_price
drop if low_price
drop low_price avg_price

/* Calculate 95th percentile of voice use by family size among users with unlimited voice. Calculate 95th percentile of data use by carrier. */
bys unltd_voice numoflines: egen unltd_voice_limit = pctile(anymnsusd), p(95)
bys carrierid: egen unltd_data_limit = pctile(wwkbusg), p(95)

/* Impose a voice/data cap on unlimited voice/data plans. */
replace data_limit = unltd_data_limit if unltd_data
replace voice_limit = unltd_voice_limit if unltd_voice
tempfile master family_level choice_set
save `master', replace

/* Calculate choice set composed of top 2 current plans by family size and carrier. */
keep if top_plan
collapse (min) voice_limit shared_data (mean) price data_limit, by(carrierid full_plan_name numoflines)
replace voice_limit = voice_limit/numoflines
replace data_limit = data_limit/numoflines if shared_data
drop shared_data
sort carrierid numoflines full_plan_name
*export excel "$output\Nielsen Bill Scrape\Current Plan Price List.xlsx", firstrow(variables) replace
rename numoflines lines_for_this_price
save `choice_set', replace

/* Calculate price, voice limit, and data limit per line for each household. Average age across lines in a plan.*/
use `master', clear

*Identify households where voice plan varies across lines. Calculate data limit for households mixing shared data plans with non-shared data plans.
encode vocplnnmcl, gen(plan_name_num)
bys panelistid: egen stdev_plan_name = sd(plan_name_num)
replace stdev_plan_name = 0 if stdev_plan_name == .
codebook panelistid if stdev_plan_name>0
replace top_plan = 0 if stdev_plan_name>0
bys panelistid: egen shared_data_min = min(shared_data)
bys panelistid: egen shared_data_max = max(shared_data)
*if a mix of shared data plans and individual data plans, calculate per line data limit for lines with shared data
bys panelistid shared_data: egen shared_lines = count(1)
gen shared_limit = data_limit/shared_lines if shared_data
replace data_limit = shared_limit if shared_data & shared_data_min!=shared_data_max & stdev_plan_name>0
replace shared_data = 0 if shared_data_min!=shared_data_max & stdev_plan_name>0
drop plan_name_num shared_limit

*Change name of plan for households where voice or data plan varies by line. This is for later identifying whether each household picked one of the plans in the choice set.
replace wwonlynmcl = "(No Data Plan)" if wwonlynmcl==""
encode wwonlynmcl, gen(data_name_num)
bys panelistid: egen stdev_data_name = sd(data_name_num)
replace stdev_data_name = 0 if stdev_data_name == .
codebook panelistid if stdev_data_name>0
replace full_plan_name = carrierid + " Voice Plan Varies " + data_string if stdev_plan_name>0 & stdev_data_name==0
replace full_plan_name = vocplnnmcl + " (Data Plan Varies)" if stdev_data_name>0 & stdev_plan_name==0
replace full_plan_name = carrierid + " Voice Plan Varies (Data Plan Varies)" if stdev_plan_name>0 & stdev_data_name>0
replace full_plan_name = carrierid + " Voice Plan Varies (Data Plan Varies)" if panelistid==142198 //flag this family manually because one voice plan is missing
replace top_plan = 0 if stdev_data_name>0
drop stdev_data_name data_name_num stdev_plan_name data_string
replace wwonlynmcl = "" if wwonlynmcl=="(No Data Plan)"

collapse (min) shared_data (mean) price age income anymnsusd wwkbusg voice_limit data_limit, by(panelistid zip carrierid full_plan_name numoflines current top_plan)
replace voice_limit = voice_limit/numoflines
replace data_limit = data_limit/numoflines if shared_data
drop shared_data
drop if strpos(full_plan_name,"(No Data Plan)")>0 //drop families without a single data plan
gen choice = 1
bys carrierid full_plan_name numoflines: egen alt_price = mean(price)
save `family_level', replace

/* Generate list of all panelist IDs with average age and income. Cross with choice set. */
use `master', clear
collapse (mean) age income, by(panelistid zip numoflines current)
cross using `choice_set'
keep if numoflines == lines_for_this_price
drop lines_for_this_price
gen choice = 0
append using `family_level'
gsort panelistid carrier full_plan_name -choice
replace alt_price = price if choice==0
duplicates drop panelistid carrier full_plan_name,force //drop duplicate observation when one of the top current plans was chosen
order choice panelistid carrier full_plan_name
sort panelistid carrier full_plan_name

/* Merge with DMA-level network quality data. Keep observations that have quality data. */
sort zip carrierid
merge m:1 zip carrierid using "$statadata/raw/dma_level_rootmetrics_by_zip.dta", nogen keep(3)
rename carrierid carrier
sort panelistid carrier
encode carrier, gen(carrier_num)

/* Drop if less than 100 quality tests for all 4 carriers in that DMA. */
codebook panelistid if min_tests_in_zip < 100 & choice
drop if min_tests_in_zip < 100
drop min_tests_in_zip

/* Identify income groups. */
gen low_income = (income < 35000) & !missing(income)
gen med_income = (income >= 35000 & income < 100000) & !missing(income)
gen high_income = (income >= 100000) & !missing(income)

/* Identify age groups. */
gen low_age = (age>=0 & age<=30) & !missing(age)
gen med_age = (age>30 & age<55) & !missing(age)
gen high_age = (age>=55 & age<=150) & !missing(age)

/* Define relevant quality variables. */
gen call_success_rate = 1-call_failure_rate
gen lte_non_coverage = 1-_lte_coverage
//email_average_speed already defined
//data_access_time already defined
rename (pd50 call_out_drop_rate p50_lte_rsrp) (data_down_median dropped_call_rate median_lte_rsrp)
gen ln_data_down_median =ln(data_down_median)
gen ln_data_down_mean =ln(data_down_mean)

/* Flag families with number of plans in their choice set. 8 means they chose a plan in the choiceset. 9 means they did not. */
bys panelistid: egen choice_count=count(panelistid)

/* Create dummy variables that take on the value of the quality/price/limit variable only if that observation ///
   falls into the specified income group and are 0 otherwise. */
local incomegroups low high
local qualvars call_success_rate ln_data_down_mean median_lte_rsrp price voice_limit data_limit

foreach incomegroup of local incomegroups {
	foreach qualvar of local qualvars {
		local quality_dummy = "`qualvar'"+"_"+substr("`incomegroup'",1,1)+"i"
		di "`quality_dummy'"
		gen `quality_dummy' = 0
		replace `quality_dummy' = `qualvar' if `incomegroup'_income==1
	}
}

/* Create dummy variables that take on the value of the quality/price/limit variable only if that observation ///
   falls into the specified age group and are 0 otherwise. */
local agegroups low high
local qualvars call_success_rate ln_data_down_mean median_lte_rsrp price voice_limit data_limit

foreach agegroup of local agegroups {
	foreach qualvar of local qualvars {
		local quality_dummy = "`qualvar'"+"_"+substr("`agegroup'",1,1)+"a"
		di "`quality_dummy'"
		gen `quality_dummy' = 0
		replace `quality_dummy' = `qualvar' if `agegroup'_age==1
	}
}

/* Create second cluster variable composed of DMA & Carrier. */
egen dma_carrier_prelim = group(dma_name carrier) if choice==1
bys panelistid: egen dma_carrier = min(dma_carrier_prelim)
drop dma_carrier_prelim


********************************************************************************************************
* Regressions
********************************************************************************************************

/* Base homogeneous specification. */
local indepvars price voice_limit data_limit call_success_rate ln_data_down_mean median_lte_rsrp 
clogit choice i.carrier_num `indepvars', vce(cluster dma_name) group(panelistid)
*outreg2 using "$output\Nielsen Bill Scrape\Choice Regressions with Price Coefficients.xls", replace
codebook panelistid if choice==1

/* Add email average download time. */
local indepvars price voice_limit data_limit call_success_rate ln_data_down_mean median_lte_rsrp email_average_speed
clogit choice i.carrier_num `indepvars', vce(cluster dma_name) group(panelistid)
*outreg2 using "$output\Nielsen Bill Scrape\Choice Regressions with Price Coefficients.xls", append

/* Base heterogeneous specification. */
local indepvars price_li price price_hi voice_limit_la voice_limit_li voice_limit voice_limit_ha voice_limit_hi ///
data_limit_la data_limit_li data_limit data_limit_ha data_limit_hi ///
call_success_rate ln_data_down_mean median_lte_rsrp 

clogit choice i.carrier_num `indepvars', vce(cluster dma_name) group(panelistid)
*outreg2 using "$output\Nielsen Bill Scrape\Choice Regressions with Price Coefficients.xls", append

/* Add income heterogeneity to network quality variables. */
local indepvars price_li price price_hi voice_limit_la voice_limit_li voice_limit voice_limit_ha voice_limit_hi ///
data_limit_la data_limit_li data_limit data_limit_ha data_limit_hi ///
call_success_rate_li call_success_rate call_success_rate_hi /// 
ln_data_down_mean_li ln_data_down_mean ln_data_down_mean_hi ///
median_lte_rsrp_li median_lte_rsrp median_lte_rsrp_hi

clogit choice i.carrier_num `indepvars', vce(cluster dma_name) group(panelistid)
*outreg2 using "$output\Nielsen Bill Scrape\Choice Regressions with Price Coefficients.xls", append


*capture log close
