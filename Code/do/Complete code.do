*Cleaning and merging data into analysis dataset
*Written by Sean Harrison August 2018-July 2020

global cd_folder ""
global cd_phenotype_data ""

global cd_data "$cd_folder\Stata\data"
global cd_prs_data "$cd_folder\results\p=8"
global cd_r_code "$cd_folder\Stata\R"
global cd_stata_code "$cd_folder\Stata\do\Automated"
global cd_tables "$cd_folder\Stata\Tables"
global cd_graphs "$cd_folder\Stata\Graphs"

cd "$cd_data"

*Install packages
{
/*
*Running R from Stata
ssc install rsource, replace

Use this code to run R scripts
if "`c(os)'"=="MacOSX" | "`c(os)'"=="UNIX" {
    rsource using my_script.R, rpath("/usr/local/bin/R") roptions(`"--vanilla"')
}
else {  // windows
    rsource using my_script.R, rpath(`"C:\Program Files\R\R-3.5.1\bin\R.exe"') roptions(`"--vanilla"')  // change version number, if necessary
}

*IV regression
ssc install ivreg2

*MR analysis (MR robust)
net install mrrobust, from(https://raw.github.com/remlapmot/mrrobust/master/) replace
mrdeps

*/
}

*Part I
*Create and combine all initial data
{

*Do ONCE
*Load in phenotypes

forvalues i = 1/51 {
	clear all
	set maxvar 15000
	
	*Excel code from "Phenotypes.xlsx" goes here
	use n_eid  n_31_0_0  n_34_0_0  ts_53_0_0  n_54_0_0  n_93_0_0  n_129_0_0  n_130_0_0  n_132_0_0  n_189_0_0  n_680_0_0  n_709_0_0  n_738_0_0  n_845_0_0  n_1031_0_0  n_1239_0_0  n_1249_0_0   n_1558_0_0  n_1568_0_0  n_1578_0_0  n_1588_0_0  n_1598_0_0  n_1608_0_0  n_2020_0_0  n_2050_0_0  n_2060_0_0  n_2070_0_0  n_2080_0_0  n_2090_0_0  n_2100_0_0  n_2110_0_0  n_2443_0_0 n_3731_0_0 n_3786_0_0  n_3894_0_0  n_4056_0_0  n_4080_0_0  n_4526_0_0  n_4537_0_0  n_4548_0_0  n_4559_0_0  n_4570_0_0  n_4581_0_0  n_4598_0_0  n_4609_0_0  n_4620_0_0  n_4631_0_0  n_4642_0_0  n_4653_0_0  n_5364_0_0  n_5375_0_0  n_5386_0_0  n_6138_0_0  n_6141_0_*  n_6142_0_0  n_6160_0_*  n_20001_0_*  n_20002_0_*  n_20024_0_0  n_20116_0_0  n_20117_0_0  n_20122_0_0  n_20160_0_0  n_21000_0_0  n_21001_0_0  n_21003_0_0  n_22000_0_0  n_22001_0_0  n_22009_0_*  n_22127_0_0  n_22140_0_0  n_22506_0_0  n_22507_0_0  n_22601_0_*  n_22617_0_*  n_30690_0_0  s_40006_*  n_40008_*  s_40013_*  s_41202_*  s_41203_*  s_41204_*  s_41205_*  using "$cd_phenotype_data\y\y`i'.dta"
	
	save "z`i'.dta", replace	

}

use "z1.dta", clear
erase "z1.dta"
forvalues i = 2/51 {
	append using "z`i'.dta"
	erase "z`i'.dta"
}

compress

save "Phenotype_data.dta", replace

/*
*Deprivation at birth
do "$cd_stata_code\deprivation_at_birth.do"

*Import withdrawals
import delim "$cd_data\Raw\withdrawals.csv", clear
rename v1 id_phe
save "$cd_data\withdrawals.dta", replace
*/

*Import GRS and combine with phenotypes

import delimited "$cd_prs_data\grs_8.csv", clear
foreach var of varlist _all {
	if "`var'" == "id" {
		rename `var' id_ieu
	}
	else {
		rename `var' grs_`var'
	}
}

*Merge to phenotypic IDs
merge 1:1 id_ieu using "linker2.dta"
keep if _merge == 3
drop _merge
save "$cd_prs_data\grs_8.dta", replace

*Add in phenotypes
use "Phenotype_data.dta", clear
rename n_eid id_phe
merge 1:1 id_phe using "$cd_prs_data\grs_8.dta"
keep if _merge == 3
drop _merge

*And deprivation at birth
merge 1:1 id_phe using "$cd_data\deprivation\workingdata\birth_location_imd_merged_sixfigure.dta", nogen
merge 1:1 id_phe using "$cd_data\deprivation\workingdata\birth_location_imd_rural_urban.dta", nogen
	
drop if id_ieu == ""
	
*Remove recommended drops
foreach var in _recommended _highly_related _relateds _non_white_british {
	merge 1:1 id_ieu using "exclusions`var'.dta"
	keep if _merge == 1
	drop _merge
}

*And withdrawals
merge 1:1 id_phe using "withdrawals.dta"
keep if _merge == 1
drop _merge

order id*

*Create a variable to determine pilot or not
gen pilot = 1 if n_22000 <= 22, a()
replace pilot = 0 if pilot == .

*Drop missing IEU IDs
drop if id_ieu == ""

save "$cd_data\all_8.dta", replace
	
}

*Part II
*Phenotype data
{

*Code to import and merge HES files (run once)
*do "$cd_stata_code\hes.do"

use "all_8.dta", clear

*Deal with HES, then import
*Generate a list of IDs with registration dates for UK Biobank 
*We don't want any ICD codes from AFTER the attendence date
keep id_phe ts_53_
save "date_attending.dta", replace

use "hes.dta", clear

rename eid id_phe
replace epistart = admidate if epistart == .
keep id_phe record_id epistart diag_icd10 diag_*
drop diag_icd10_nb diag_max_arr diag_icd9*
merge m:1 id_phe using "date_attending.dta"
keep if _merge == 3
drop _merge
order ts_53, a(epistart)
drop if epistart > ts_53

*Episodes should now ALL be before Biobank attendence
drop ts epistart

*Generate ICD-10 code phenotypes
local icd_total = 42
forvalues i = 1/`icd_total' {
	gen v`i' = 0
}

*R script creates this .do file
*The R script uses the icd10.csv file that is a copy of all the ICD10 codes in the main Tables.xlsx file
rsource using "$cd_r_code\R code to gen Stata code for ICD coding.R", rpath(`"C:\Program Files\R\R-3.5.1\bin\R.exe"') roptions(`"--vanilla"')  // change version number, if necessary
do "$cd_stata_code\ICD_codes10.do"

label variable v1 "Ischaemic heart disease"
label variable v2 "Trachea, bronchus, and lung cancers"
label variable v3 "Unipolar depressive disorders"
label variable v4 "Major depressive disorder"
label variable v5 "Ischaemic stroke"
label variable v6 "Alzheimer's disease and other dementias"
label variable v7 "Drug use disorders"
label variable v8 "Anxiety disorders"
label variable v9 "Colon and rectum cancers"
label variable v10 "Asthma"
label variable v11 "Breast cancer"
label variable v12 "Migraine"
label variable v13 "Haemorrhagic and other non-ischaemic stroke"
label variable v14 "Alcohol use disorders"
label variable v15 "Osteoarthritis"
label variable v16 "Diabetes mellitus"
label variable v17 "Opioid use disorders"
label variable v18 "Prostate cancer"
label variable v19 "Schizophrenia"
label variable v20 "Chronic kidney diseases"
label variable v21 "Pancreatic cancer"
label variable v22 "Oesophageal cancer"
label variable v23 "Bipolar affective disorder"
label variable v24 "Rheumatoid arthritis"
label variable v25 "Non-Hodgkin lymphoma"
label variable v26 "Dysthymia"
label variable v27 "Aortic aneurysm"
label variable v28 "Brain and nervous system cancers"
label variable v29 "Haemoglobinopathies and haemolytic anaemias"
label variable v30 "Leukaemia"
label variable v31 "Epilepsy"
label variable v32 "Stomach cancer"
label variable v33 "Ovarian cancer"
label variable v34 "Kidney and other urinary organ cancers"
label variable v35 "Eczema"
label variable v36 "Parkinson's disease"
label variable v37 "Bladder cancer"
label variable v38 "Sickle cell disorders"
label variable v39 "Type 2 diabetes"
label variable v40 "Alzheimer's only"
label variable v41 "Stroke (any)"
label variable v42 "Type I Diabetes"

drop diag* record

*Replace all v`i' values with the maximum, so when duplicates are dropped, any instance of the ICD code is kept
forvalues i = 1/`icd_total' {
	bysort id_phe: egen x = max(v`i')
	replace v`i' = x
	drop x
}

duplicates drop id_phe, force

egen count = rowtotal(v*)
drop if count == 0 
drop count

save "hes_icd10.dta", replace

*Merge
use "all_8.dta", clear
merge 1:1 id_phe using "hes_icd10.dta", nogen

*Generate ICD-9 code phenotypes
*Assume all ICD-9 instances are before biobank attendence 
*This is because ICD-9 codes don't have dates, unlike ICD-10 in HES

forvalues i = 1/`icd_total' {
	gen x`i' = 0
}

do "$cd_stata_code\ICD_codes9.do" 

forvalues i = 1/`icd_total' {
	replace v`i' = 1 if x`i' == 1
	drop x`i'
	replace v`i' = 0 if v`i' == .
}

*Drop all the now defunct ICD codes
drop s_41202_* s_41203_* s_41204_* s_41205_*

*Copy all the HES only data, so we know whether the positive result for a health condition came from HES of UKB
forvalues i = 1/`icd_total' {
	qui gen hes_v`i' = v`i'
}

*Cancer registry data for breast cancer
*First get rid of all values that occur AFTER age at registration
forvalues i = 0/31 {
	capture gen s_40006_`i'_0 = ""
	capture gen s_40013_`i'_0 = ""	
	
	replace s_40006_`i'_0 = "" if n_40008_`i'_0 > n_21003_0_0
	replace s_40013_`i'_0 = "" if n_40008_`i'_0 > n_21003_0_0
}

*All remaining cancers *should* be from before registration (or within 1 year)
forvalues i = 0/31 {
*Lung cancer
	replace v2 = 1 if strpos(s_40006_`i'_0,"C32") > 0 | strpos(s_40006_`i'_0,"C33") > 0 | strpos(s_40006_`i'_0,"C34") > 0
	gen x = s_40013_`i'_0
	qui replace x = substr(x,1,3) if length(x) == 4
	replace v2 = 1 if x == "161" | x == "162"
	drop x

*Colon cancer
	replace v9 = 1 if strpos(s_40006_`i'_0,"C18") > 0 | strpos(s_40006_`i'_0,"C19") > 0 | strpos(s_40006_`i'_0,"C20") > 0 | strpos(s_40006_`i'_0,"C21") > 0
	gen x = s_40013_`i'_0
	qui replace x = substr(x,1,3) if length(x) == 4
	replace v9 = 1 if x == "153" | x == "154"
	drop x

*Breast cancer
	replace v11 = 1 if strpos(s_40006_`i'_0,"C50") > 0
	gen x = s_40013_`i'_0
	qui replace x = substr(x,1,3) if length(x) == 4
	replace v11 = 1 if x == "174"
	drop x

*Prostate cancer
	replace v18 = 1 if strpos(s_40006_`i'_0,"C61") > 0
	gen x = s_40013_`i'_0
	qui replace x = substr(x,1,3) if length(x) == 4
	replace v18 = 1 if x == "185"
	drop x

*Pancreatic cancer
	replace v21 = 1 if strpos(s_40006_`i'_0,"C25") > 0
	gen x = s_40013_`i'_0
	qui replace x = substr(x,1,3) if length(x) == 4
	replace v21 = 1 if x == "157"
	drop x

*Oesophageal cancer
	replace v22 = 1 if strpos(s_40006_`i'_0,"C15") > 0
	gen x = s_40013_`i'_0
	qui replace x = substr(x,1,3) if length(x) == 4
	replace v22 = 1 if x == "150"
	drop x

*Brain cancer
	replace v28 = 1 if strpos(s_40006_`i'_0,"C71") > 0 | strpos(s_40006_`i'_0,"C72") > 0
	gen x = s_40013_`i'_0
	qui replace x = substr(x,1,3) if length(x) == 4
	replace v28 = 1 if x == "191" | x == "192"
	drop x

*Stomach cancer
	replace v32 = 1 if strpos(s_40006_`i'_0,"C16") > 0
	gen x = s_40013_`i'_0
	qui replace x = substr(x,1,3) if length(x) == 4
	replace v32 = 1 if x == "151"
	drop x

*Ovarian cancer
	replace v33 = 1 if strpos(s_40006_`i'_0,"C56") > 0
	gen x = s_40013_`i'_0
	qui replace x = substr(x,1,3) if length(x) == 4
	replace v33 = 1 if x == "183"
	drop x

*Kidney cancer
	replace v34 = 1 if strpos(s_40006_`i'_0,"C64") > 0
	gen x = s_40013_`i'_0
	qui replace x = substr(x,1,3) if length(x) == 4
	replace v34 = 1 if x == "189"
	drop x

*Bladder cancer
	replace v37 = 1 if strpos(s_40006_`i'_0,"C67") > 0
	gen x = s_40013_`i'_0
	qui replace x = substr(x,1,3) if length(x) == 4
	replace v37 = 1 if x == "188"
	drop x
}

*Copy all the HES & registry data
forvalues i = 1/`icd_total' {
	qui gen hes_reg_v`i' = v`i'
}

*That's all the ICD code health conditions now in v1-v`icd_total'
*Now need self report to add to that

*Drop ethnicity (White) & cancer registration data
drop n_21000_0_0 s_40006* s_40013* n_40008*

*Add in depression (extended to include the seen doctor for nerves etc.)
/*Use the Tyrell criteria (any of these == 1):
1) Seen GP for depression etc. WITH two weeks depression or unenthusiasm duration
2) Seen psychiatrist for depression etc. WITH two weeks depression or unenthusiasm duration
3) HES criteria

Controls have to have not seen psych/GP for depression etc. AND not have HES to be control AND no self-reported depression

Restricted to centres that asked the questions about depression/unenthusiasm

Everyone else is missing
*/
gen v43 = 1 if v3 == 1, a(v42)
label variable v43 "Depression (Tyrell)"

replace v43 = 1 if (n_2090_0_0 == 1 | n_2100_0_0 == 1) & ((n_4609 >= 2 & n_4609 < .) | (n_5375_0_0 >= 2 & n_5375_0_0 < .))

qui gen x = .
forvalues i = 0/28 {
	replace x = 1 if n_20002_0_`i' == 1286
}

replace v43 = 0 if n_2090_0_0 == 0 & n_2100_0_0 == 0 & v3 == 0 & x != 1
drop x

*The Wray GWAS used the pilot sample of UK Biobank, so exclude pilot participants from depression phenotype
gen v44 = v43 if pilot == 0, a(v43)
label variable v44 "Depression (Tyrell) [Wray]"

*Restricted to centres that asked the questions about depression/unenthusiasm
replace v43 = . if n_54_ < 11011 | n_54_ == 11012
replace v44 = . if n_54_ < 11011 | n_54_ == 11012

*Six cancer codes n_20001_0_[0-5]
*Plus n_22140_0_0 = lung cancer
forvalues i = 0/5 {
	replace v2 = 1 if n_20001_0_`i' == 1001 | n_20001_0_`i' == 1027 | n_20001_0_`i' == 1028
	replace v9 = 1 if n_20001_0_`i' == 1022 | n_20001_0_`i' == 1023
	replace v11 = 1 if n_20001_0_`i' == 1002
	replace v18 = 1 if n_20001_0_`i' == 1044
	replace v21 = 1 if n_20001_0_`i' == 1026
	replace v22 = 1 if n_20001_0_`i' == 1017
	replace v25 = 1 if n_20001_0_`i' == 1053
	replace v28 = 1 if n_20001_0_`i' == 1032 | n_20001_0_`i' == 1033 | n_20001_0_`i' == 1031 | n_20001_0_`i' == 1029
	replace v30 = 1 if n_20001_0_`i' == 1048
	replace v32 = 1 if n_20001_0_`i' == 1018
	replace v33 = 1 if n_20001_0_`i' == 1039
	replace v34 = 1 if n_20001_0_`i' == 1034
	replace v37 = 1 if n_20001_0_`i' == 1035
	drop n_20001_0_`i'
}
replace v2 = 1 if n_22140_0_0 == 1
drop n_22140_0_0

*29 non-cancer codes n_20002_0_[0-28]
forvalues i = 0/28 {
	replace v1 = 1 if n_20002_0_`i' == 1066 | n_20002_0_`i' == 1075 
	replace v3 = 1 if n_20002_0_`i' == 1286
	replace v4 = 1 if n_20002_0_`i' == 1286
	replace v5 = 1 if n_20002_0_`i' == 1583
	replace v6 = 1 if n_20002_0_`i' == 1263
	replace v8 = 1 if n_20002_0_`i' == 1409 | n_20002_0_`i' == 1410
	replace v8 = 1 if n_20002_0_`i' == 1287
	replace v10 = 1 if n_20002_0_`i' == 1111
	replace v12 = 1 if n_20002_0_`i' == 1265
	replace v14 = 1 if n_20002_0_`i' == 1408
	replace v15 = 1 if n_20002_0_`i' == 1465
	replace v16 = 1 if n_20002_0_`i' == 1220 | n_20002_0_`i' == 1223
	replace v17 = 1 if n_20002_0_`i' == 1409
	replace v19 = 1 if n_20002_0_`i' == 1289
	replace v20 = 1 if n_20002_0_`i' == 1519
	replace v23 = 1 if n_20002_0_`i' == 1291
	replace v24 = 1 if n_20002_0_`i' == 1464
	replace v27 = 1 if n_20002_0_`i' == 1492
	replace v29 = 1 if n_20002_0_`i' == 1451
	replace v31 = 1 if n_20002_0_`i' == 1264
	replace v35 = 1 if n_20002_0_`i' == 1452
	replace v36 = 1 if n_20002_0_`i' == 1262
	replace v38 = 1 if n_20002_0_`i' == 1339
	replace v39 = 1 if n_20002_0_`i' == 1223
	replace v41 = 1 if n_20002_0_`i' == 1081 | n_20002_0_`i' == 1583
	replace v42 = 1 if n_20002_0_`i' == 1222
}	
replace v1 = 1 if n_3894_0_0 < .
replace v10 = 1 if n_22127_0_0 == 1 | n_3786_0_0 != .
replace v16 = 1 if n_2443_0_0 == 1
replace v23 = 1 if n_20122 != .
replace v41 = 1 if n_4056_ != .

save "all_8_hes.dta", replace

}

*Part III
*Social and Socioeconomic outcomes
{
********************************************************************************
use "all_8_hes.dta", clear
*Socioeconomic outcomes

foreach var of varlist n_845_ n_738_ {
	replace `var' = . if `var' < 0
}

*Household Income
gen eco_household_income = 15000 if n_738 == 1
replace eco_household_income = 24500 if n_738 == 2
replace eco_household_income = 41500 if n_738 == 3
replace eco_household_income = 76000 if n_738 == 4
replace eco_household_income = 150000 if n_738 == 5
label variable eco_household_income "Household Income (continuous)"

*Equivalised Household Income
gen eco_household_income_equi = eco_household_income/n_709_0_0
label variable eco_household_income_equi "Household Income (continuous) equivalised"

*Current employment status
gen eco_employment_status = .
replace eco_employment_status = 1 if n_6142_ == 1
replace eco_employment_status = 2 if n_6142_ == 2
replace eco_employment_status = 3 if n_6142_ > 2 & n_6142_ < .
label define eco_employment_status 1 "Working" 2 "Retired" 3 "Not in paid work or retired"
label values eco_employment_status eco_employment_status
label variable eco_employment "Employment status"

*Working/retired
gen eco_working_or_retired = 0 if eco_employment_status == 1 | eco_employment_status == 2
replace eco_working_or_retired = 1 if eco_employment_status == 3
label variable eco_working_or_retired "Not working (1) or working/retired (0)"

gen eco_working = 1 if eco_employment_status == 3
replace eco_working = 0 if eco_employment_status == 1
label variable eco_working "Not working (1) or working (0) [retired excluded]"

gen eco_retired = 1 if eco_employment_status == 2 
replace eco_retired = 0 if eco_employment_status == 1
label variable eco_retired "Retired (1) or not (0) [unemployed excluded]"

*Working/retired (<65 only)
gen eco_working_or_retired_65 = eco_working_or_retired if n_21003_0_0 < 65
label variable eco_working_or_retired_65 "Not working (1) or working/retired (0) [<65 only]"

gen eco_working_65 = eco_working if n_21003_0_0 < 65
label variable eco_working_65 "Not working (1) or working (0) [retired excluded] [<65 only]"

gen eco_retired_65 = eco_retired if n_21003_0_0 < 65 
label variable eco_retired_65 "Retired (1) or not (0) [unemployed excluded] [<65 only]"

*Skilled job
*Binary, defined as being in job codes 1-5 (first digit corresponding to first 9 job codes)
*Job codes 6-9 are thus "unskilled"

/*
1	Managers and Senior Officials
2	Professional Occupations
3	Associate Professional and Technical Occupations
4	Administrative and Secretarial Occupations
5	Skilled Trades Occupations
6	Personal Service Occupations
7	Sales and Customer Service Occupations
8	Process, Plant and Machine Operatives
9	Elementary Occupations
*/

tostring n_132_0_0, gen(x)
replace x = substr(x,1,1)
destring x, replace
gen eco_skilled_job = 1 if x <= 5
replace eco_skilled_job = 0 if x > 5 & x < .
label variable eco_skilled "Skilled job (1=job code <= 5)"

*Qualifications (university or not)
*NOTE: Include professional qualifications?
gen eco_degree = 1 if n_6138 == 1
replace eco_degree = 0 if n_6138 == -1 | (n_6138 > 1 & n_6138 < .)
label variable eco_degree "University degree (1=degree)"

*Own or rent
gen eco_own = 1 if n_680_ == 1 | n_680_ == 2
replace eco_own = 0 if n_680_ == 3 | n_680_ == 4 | n_680_ == 5 | n_680_ == 6
label variable eco_own "Own house (1=own)"

********************************************************************************

*Social outcomes (make binary)
gen soc_confide = 1 if n_2110_ >= 3 & n_2110 < .
replace soc_confide = 0 if n_2110 >=0 & n_2110 < 3
label variable soc_confide "1=Able to confide (>=1/week)"

gen soc_friend_visits = 1 if n_1031 >= 1 & n_1031 < 4
replace soc_friend_visits = 0 if n_1031 >= 4 & n_1031 < .
label variable soc_friend_visits "1=Frequent friend/family visits (>=1/week)"

gen soc_cohabitation = 1 if n_6141_0_0 == 1
replace soc_cohabit = 0 if n_6141_0_0 >= 2 & n_6141_0_0 < .
replace soc_cohabit = 0 if n_709_ == 1
label variable soc_cohabit "1=Cohabitating with husband/wife/partner"

gen soc_leisure = 0 if n_6160_0_0 == -7
replace soc_leisure = 1 if n_6160_0_0 > 0 & n_6160_0_0 < .
label variable soc_leisure "1=Has >=1 leisure/social activity"

gen soc_loneliness = 1 if n_2020 == 0
replace soc_loneliness = 0 if n_2020 == 1
label variable soc_loneliness "1=NOT lonely/isolated"

gen soc_happiness = 1 if n_4526 >= 1 & n_4526 <= 3
replace soc_happiness = 0 if n_4526 >= 4 & n_4526 < .
label variable soc_happiness "1=Happy"

gen soc_family_satisfaction = 1 if n_4559 >= 1 & n_4559 <= 3
replace soc_family_satisfaction = 0 if n_4559 >= 4 & n_4559 < . 
label variable soc_family_satisfaction "1=Satisfied with family relationship"

gen soc_financial_satisfaction = 1 if n_4581 >= 1 & n_4581 <= 3
replace soc_financial_satisfaction = 0 if n_4581 >= 4 & n_4581 < . 
label variable soc_financial_satisfaction "1=Satisfied with financial situation"

gen soc_friendship_satisfaction = 1 if n_4570 >= 1 & n_4570 <= 3
replace soc_friendship_satisfaction = 0 if n_4570 >= 4 & n_4570 < . 
label variable soc_friendship_satisfaction "1=Satisfied with friendships"

gen soc_health_satisfaction = 1 if n_4548 >= 1 & n_4548 <= 3
replace soc_health_satisfaction = 0 if n_4548 >= 4 & n_4548 < . 
label variable soc_health_satisfaction "1=Satisfied with health"

gen soc_work_satisfaction = 1 if n_4537 >= 1 & n_4537 <= 3
replace soc_work_satisfaction = 0 if n_4537 >= 4 & n_4537 < 6 
label variable soc_work_satisfaction "1=Satisfied with work/job"

********************************************************************************
*Risks

*BP
gen risk_systolic_bp = n_4080_0_0
replace risk_systolic_bp = n_93_0_0 if risk_systolic_bp == .

*********************************

*Alcohol
*Clarke et. al used weekly/monthly drinks to estimate units/week

/*Info
1568 - red wine = 125 ml (6/bottle) = 1.75 units 
1578 - champagne/white wine = 125 ml (6/bottle) = 1.75 units 
1588 - beer/cider = 1 pint = 2 units
1598 - spirits = 25 ml (25 standard measures in a normal sized bottle - 25 ml is standard) = 1 unit
1608 - fortified wine = 60 ml (12/bottle) = 1.2 units
5364 - other = no idea, could be anything, example is an alcopop = 1 unit
*/

foreach var of varlist n_1568 n_1578 n_1588 n_1598 n_1608 n_5364 {
	replace `var' = . if `var' < 0
}

gen risk_alcohol_week = n_1568*1.75 + n_1578*1.75 + n_1588*2 + n_1598*1 + n_1608*1.2 + n_5364*1

foreach var of varlist n_1568 n_1578 n_1588 n_1598 n_1608 n_5364 {
	gen x_`var' = 0 if `var' == .
	replace x_`var' = `var' if `var' != .
}

gen risk_alcohol_week_nomiss = x_n_1568*1.75 + x_n_1578*1.75 + x_n_1588*2 + x_n_1598*1 + x_n_1608*1.2 + x_n_5364*1

foreach var of varlist n_1568 n_1578 n_1588 n_1598 n_1608 n_5364 {
	drop x_`var'
}

*Remove former drinkers
replace risk_alcohol_week = . if n_3731_ == 1
replace risk_alcohol_week_nomiss = . if n_3731_ == 1

*Remove excess numbers of units (>200)
replace risk_alcohol_week = . if risk_alcohol_week >= 200
replace risk_alcohol_week_nomiss = . if risk_alcohol_week_nomiss >= 200

*Replace missing if ALL drinks are missing
replace risk_alcohol_week_nomiss = . if n_1568 == . & n_1578 == . & n_1588 == . & n_1598 == . & n_1608 == . & n_5364

*Re-fill those who said they don't drink
replace risk_alcohol_week_nomiss = 0 if n_20117_ == 0

*Frequency of alcohol in a month (assume the same number of units per day of drinking...)
gen risk_alcohol_month = .
replace risk_alcohol_month = 0 if n_1558 == 6
replace risk_alcohol_month = 0.5 if n_1558 == 5
replace risk_alcohol_month = 2 if n_1558 == 4
replace risk_alcohol_month = 1.5*4.35 if n_1558 == 3
replace risk_alcohol_month = 3.5*4.35 if n_1558 == 2
replace risk_alcohol_month = 7*4.35 if n_1558 == 1

label variable risk_alcohol_week "Units of alcohol per week, from weekly details"
label variable risk_alcohol_week_nomiss "Units of alcohol per week, from weekly details, missing values set to 0"
label variable risk_alcohol_month "Instances of drinking per month, from n_1558"

*********************************

*Smoking
merge 1:1 id_ieu using "linker_ieu.dta", nogenerate keep(match)
merge 1:1 id_gen using "lifetime_smoking2.dta", nogenerate keep(match) // Robyn's lifetime smoking measure (updated to 11/2018)

*Need smoking initiation
gen phe_smoking_initiation = 1 if phe_lifetime > 0 & phe_lifetime < .
replace phe_smoking_initiation = 0 if phe_lifetime == 0
label var phe_smoking_initiation "Smoking initiation (from lifetime measure)"

*Create a categorical variable of current/former/never smoker
gen smoking = phe_smoking_initiation
replace smoking = 2 if n_1239_0_0 >= 1 & n_1239_0_0 < . & phe_smoking_initiation == 1
label define smoking 0 "Never" 1 "Former" 2 "Current"
label values smoking smoking
label var smoking "Smoking status, 0 = never, 1 = former, 2 = current"

********************************************************************************
*standardise GRS
foreach var of varlist grs* {
	qui sum `var'
	local sd = r(sd)
	local mean = r(mean)
	qui replace `var' = (`var'-`mean')/`sd'
}

********************************************************************************

order id_gen, a(id_phe)

save "all_8_clean.dta", replace
}

*Part IV
*Set up main analysis
{

*Clean variables to analysis set
use "all_8_clean.dta", clear

*Tie GRS to their phenotypes by naming
rename n_21001 phe_body_mass_index
*rename risk_alcohol_week_nomiss ALCOHOL // NEED GRS
*rename risk_systolic_bp BLOOD PRESSURE // NEED GRS
rename phe_lifetime_smoking lifetime_smoking
*rename [tobacco] TOBACCO // NEED GRS
*rename [drug use] DRUG USE // NEED PHENOTYPE & GRS

rename v1 phe_coronary_heart_disease
rename v2 phe_lung_cancer
*rename v3 DEPRESSION // Superseded by v43/44
*rename v4 DEPRESSION // don't use, identical to v3
*rename v5 ISCHAEMIC STROKE // don't use, use general stroke, probably better
*rename v6 DEMENTIA // don't use, <0.1% cases
rename v7 phe_drug_dependence
rename v8 phe_anxiety
*rename v9 COLON CANCER // no GWAS
rename v10 phe_asthma
rename v11 phe_breast_cancer
rename grs_breast grs_breast_cancer
rename v12 phe_migraine
rename grs_migraine grs_migraine
*rename v13 HAEMORRHAGIC STROKE // no GWAS, but also, use general stroke
*rename v14 ALCOHOL USE // no GWAS - see risk factors
rename v15 phe_osteoarthritis
rename v16 phe_type_2_diabetes
*rename v17 OPIOID USE // don't use, <0.1% cases
rename v18 phe_prostate_cancer
rename v19 phe_schizophrenia
rename v20 phe_chronic_kidney_disease
*rename v21 PANCREATIC CANCER // don't use, <0.1% cases
*rename v22 OESOPHAGEAL CANCER // don't use, <0.1% cases
rename v23 phe_bipolar_disorder
rename v24 phe_rheumatoid_arthritis
rename v25 phe_non_hogkin_lymphoma
*rename grs_lymphoma grs_non_hogkin_lymphoma
*rename v26 DYSTHYMIA // don't use, <0.1% cases
rename v27 phe_abdominal_aortic_aneurysm
*rename v28 BRAIN AND NERVOUS SYSTEM CANCER // don't use, <0.1% cases
*rename v29 HAEMOGLOBINOPATHIES AND HAEMOLYTIC ANAEMIAS // don't use, <0.1% cases
rename v30 phe_leukaemia
rename v31 phe_epilepsy
*rename v32 STOMACH CANCER // don't use, <0.1% cases
rename v33 phe_ovarian_cancer
rename v34 phe_kidney_cancer
*rename grs_renal_cell_carcinoma grs_kidney_cancer
rename v35 phe_eczema
rename v36 phe_parkinsons_disease
rename v37 phe_bladder_cancer
*rename grs_bladder grs_bladder_cancer
*rename v38 SICKLE CELL // don't use, <0.1% cases
*rename v39 TYPE 2 DIABETES // don't use, use mellitus and remove known type I diabetes
*rename v40 ALZHEIMER'S ONLY // don't use, <0.1% cases
rename v41 phe_stroke
*rename grs_ischaemic_stroke grs_stroke
rename v42 phe_diabetes_type_1
*The Okbay depression GWAS had <0.01% R2, so remove and only use Wray
drop v43 // Use v44
drop grs_depressive // use the Wray GWAS
rename v44 phe_depression
rename grs_major_depressive_disorder grs_depression

rename n_21003 age
rename n_31_ sex
rename n_189_0_0 eco_tdi
rename n_54_ centre
rename n_30690_0_0 phe_cholesterol

forvalues i=1/40 {
	rename n_22009_0_`i' pc`i'
}

rename risk_systolic_bp phe_systolic_bp
rename risk_alcohol_week_nomiss phe_alcohol_intake
rename lifetime_smoking phe_lifetime_smoking

*Create binary variables for Household Income and TDI
gen eco_household_income_bin = 1 if eco_household_income >= 76000 & eco_household_income < .
replace eco_household_income_bin = 0 if eco_household_income <= 41500
label var eco_household_income_bin ">£52k (1) versus <£52k (0)"

xtile eco_tdi_bin = eco_tdi, nq(3)
replace eco_tdi_bin = 0 if eco_tdi_bin == 1 | eco_tdi_bin == 2
replace eco_tdi_bin = 1 if eco_tdi_bin == 3
label var eco_tdi_bin "3rd tertile of IMD (1) versus tertiles 1 & 2 (0)"

*Restrict exposures to those with a prevalence above 2%

keep id_ieu id_phe centre pilot age sex pc* eco* soc* imd ru11ind dist cov_urban ///
phe_body_mass_index phe_lifetime_smoking phe_alcohol_intake phe_systolic_bp phe_coronary_heart_disease /// 
phe_asthma phe_breast_cancer phe_migraine phe_osteoarthritis phe_type_2_diabetes phe_eczema ///
phe_depression phe_smoking_initiation phe_diabetes_type_1 smoking phe_cholesterol ///
grs*

order phe* eco* soc* pc* grs*, alpha
order id* centre age sex pilot ru11-cov_urban smoking grs* phe* eco* soc* pc1 pc2 pc3 pc4 pc5 pc6 pc7 pc8 pc9 pc*

*TDI at birth into tertiles
xtile dep_birth_cat = imd, nq(3)
order dep_birth_cat, a(sex)
drop ru11ind dist-cov_urban
rename imd dep_birth

*Continuous outcomes ordered first
order eco_household_income eco_tdi, b(eco_degree)

*eco_employment_status is the 3 category variable, drop it
drop eco_employment_status

*Code loneliness as 1 = lonely
recode soc_loneliness (1=0) (0=1)
label var soc_loneliness "1=Lonely/isolated"

*Household Income (retired excluded)
gen eco_household_income_re = eco_household_income if eco_retired == 0, a(eco_household_income)
label var eco_household_income_re "Household Income (retired excluded)"

*Remove type I diabetes from diabetes phenotype
replace phe_type_2_diabetes = . if phe_diabetes_type_1 == 1
drop phe_diabetes_type_1

*Rename BP
rename grs_blood_pressure grs_systolic_bp
order grs*, a(smoking) alpha

compress

save "all_8_analysis.dta", replace
}

*Part V
*Set up split-sample analysis
{
*Split sample GWAS

use "all_8_analysis.dta", clear
keep id_ieu phe* pc* sex
merge 1:1 id_ieu using "ieu_ids.dta"
rename _merge sample
label drop _merge
set seed 123
replace sample = 0 if sample == 3 & runiform() < 0.5
replace sample = 1 if sample == 3

rename id_ieu FID
gen IID = FID, a(FID)

*Deal with rounding errors
*This is to do with making values strings - they need to be 1 or 2, not 0.999999
*Note: this also makes continuous measurements set to 2dp. That's probably fine.
foreach var of varlist phe* {
	gen x = `var'*100
	replace x = x+0.1
	replace x = int(x)
	gen double y = x/100, a(`var')

	drop `var' x
	rename y `var'
}

*All Binary variables need to be 1 (control) 2 (case)
foreach var of varlist phe_asthma phe_breast_cancer phe_coronary phe_depression phe_eczema ///
	phe_migraine phe_osteo phe_smoking_initiation phe_type {
	replace `var' = `var'+1
}

*Missingness needs to be set to NA
foreach var of varlist phe* {
	tostring `var', gen(`var'2)
	order `var'2, a(`var')
	replace `var'2 = "NA" if `var' == .
	drop `var'
	rename `var'2 `var'
}

*Breast cancer should be females only
replace phe_breast_cancer = "NA" if sex == 1

*Include_IDs_1
preserve
drop if sample != 0
keep FID
export delim "Split sample\ids1.txt", replace novarnames delim(" ")
restore

*Include_IDs_2
preserve
drop if sample != 1
keep FID
export delim "Split sample\ids2.txt", replace novarnames delim(" ")
restore

*Phenotypes_1
preserve
drop if sample != 0
keep FID IID phe*
export delim "Split sample\phenotypes1.txt", replace delim(" ")
restore

*Phenotypes_2
preserve
drop if sample != 1
keep FID IID phe*
export delim "Split sample\phenotypes2.txt", replace delim(" ")
restore

*covars_no_chip_1
preserve
drop if sample != 0
keep FID IID sex pc*
export delim "Split sample\covars_no_chip_1.txt", replace delim(" ")
restore

*covars_no_chip_2
preserve
drop if sample != 1
keep FID IID sex pc*
export delim "Split sample\covars_no_chip_2.txt", replace delim(" ")
restore

*Keep track of which sample people were in!
keep FID sample
rename FID id_ieu
drop if sample == 2
replace sample = sample + 1
save "Split sample\sample IDs.dta", replace

}

*Part VI
*Main analysis
{
*IV REG
{
use "all_8_analysis.dta", clear

*Normalise lifetime smoking so results are per SD increase
qui su phe_lifetime_smoking
qui replace phe_lifetime_smoking = (phe_lifetime_smoking-r(mean))/r(sd)

*Create table
gen touse = .
gen exposure = ""
gen outcome = ""
gen type = ""

foreach k in all female male low mid high {
	gen n_`k' = .
	gen beta_`k' = .
	gen se_`k' = .
	gen double p_`k' = .
	gen double p_endog_`k' = .
	gen f_stat_`k' = .

	replace touse = .
	
	if "`k'" == "all" {
		replace touse = 1
	}
	if "`k'" == "female" {
		replace touse = 1 if sex == 0
	}
	if "`k'" == "male" {
		replace touse = 1 if sex == 1
	}
	if "`k'" == "low" {
		replace touse = 1 if dep_birth_cat == 1
	}
	if "`k'" == "mid" {
		replace touse = 1 if dep_birth_cat == 2
	}
	if "`k'" == "high" {
		replace touse = 1 if dep_birth_cat == 3
	}

	local i = 1
	
	*MR analysis
	foreach grs of varlist grs* {
		local phe = substr("`grs'",4,.)
		local phe = "phe`phe'"
		dis "Analysing `phe': `k'"
		
		foreach var of varlist eco* soc* {
			if "`grs'" == "grs_breast_cancer" & "`k'" != "male" {
				qui ivreg2 `var' (`phe' = `grs') age pc* i.centre if sex == 0 & touse == 1, robust endog(`phe')
			}
			else {
				qui ivreg2 `var' (`phe' = `grs') age sex pc* i.centre if touse == 1, robust endog(`phe') 
			}
			local exposure = substr("`phe'",5,.)
			local exposure = subinstr("`exposure'","_"," ",.)
			local outcome = substr("`var'",5,.)
			local f_stat = e(widstat)
			matrix a = e(b)
			matrix b = e(V)
			local beta = a[1,1]
			local se = sqrt(b[1,1])
			local n = e(N)
			local p = 2*normal(-abs(`beta'/`se'))
			local p_endog = e(estatp)
			
			foreach x in exposure outcome  {
				qui replace `x' = "``x''" in `i'
			}
			
			foreach x in beta se n p p_endog f_stat {
				qui replace `x'_`k' = ``x'' in `i'
			}
			
			qui replace type = "IV reg" in `i'
			local i = `i'+1
		}
	}

	*Multivariable adjusted estimates (linear regression)

	foreach phe of varlist phe* {
		
		foreach var of varlist eco_household_income - soc_work_satisfaction {
			if "`phe'" == "phe_breast_cancer" & "`k'" != "male" {
				qui reg `var' `phe' age pc* i.centre if sex == 0 & touse == 1
			}
			else {
				qui reg `var' `phe' age sex pc* i.centre if touse == 1
			}
			local exposure = substr("`phe'",5,.)
			local exposure = subinstr("`exposure'","_"," ",.)
			local outcome = substr("`var'",5,.)
			matrix a = e(b)
			matrix b = e(V)
			local beta = a[1,1]
			local se = sqrt(b[1,1])
			local n = e(N)
			local p = 2*normal(-abs(`beta'/`se'))
			
			foreach x in exposure outcome {
				qui replace `x' = "``x''" in `i'
			}
			
			foreach x in beta se p n {
				qui replace `x'_`k' = ``x'' in `i'
			}
			
			qui replace type = "Multivariable Adjusted" in `i'
			local i = `i'+1
		}
	}
}

save "$cd_tables\Results table raw.dta", replace
********************************************************************************

use "$cd_tables\Results table raw.dta", clear
keep exposure-p_endog_high
drop if exposure == ""
replace outcome = subinstr(outcome,"_"," ",.)

foreach var of varlist beta* se* {
	replace `var' = `var'*5 if exposure == "body mass index" | exposure == "alcohol intake"
	replace `var' = `var'*10 if exposure == "systolic bp"
}

replace exposure = strproper(exposure)
replace exposure = "Body Mass Index (5 kg/m{superscript:2})" if exposure == "Body Mass Index"
replace exposure = "Alcohol Intake (5 units/week)" if exposure == "Alcohol Intake"
replace exposure = "Systolic BP (10 mmHg)" if exposure == "Systolic Bp"
replace exposure = "Lifetime Smoking (SD)" if exposure == "Lifetime Smoking"
replace exposure = "Cholesterol (1 mmol/l)" if exposure == "Cholesterol"

replace outcome = strproper(outcome)

replace outcome = "Cohabiting" if outcome == "Cohabitation"
replace outcome = "Able to Confide" if outcome == "Confide"
replace outcome = "University Education" if outcome == "Degree"
replace outcome = "Satisfied with Family Relationships" if outcome == "Family Satisfaction"
replace outcome = "Satisfied with Financial Situation" if outcome == "Financial Satisfaction"
replace outcome = "Weekly Friend Visits" if outcome == "Friend Visits"
replace outcome = "Satisfied with Friendships" if outcome == "Friendship Satisfaction"
replace outcome = "Satisfied with Health" if outcome == "Health Satisfaction"
replace outcome = "Happy" if outcome == "Happiness"
replace outcome = "Weekly Leisure or Social Activity" if outcome == "Leisure"
replace outcome = "Lonely" if outcome == "Loneliness"
replace outcome = "Own Accommodation Lived In" if outcome == "Own"
replace outcome = "Retired vs Employed (non-employed excluded)" if outcome == "Retired"
replace outcome = "Satisfied with Work" if outcome == "Work Satisfaction"
replace outcome = "Non-employed vs Employed (retired excluded)" if outcome == "Working"
replace outcome = "Non-employed vs Employed/Retired" if outcome == "Working Or Retired"
replace outcome = "TDI at Recruitment" if outcome == "Tdi"
replace outcome = "TDI at Recruitment (binary)" if outcome == "Tdi Bin"
replace outcome = "Household Income (binary)" if outcome == "Household Income Bin"
replace outcome = "Household Income (retired excluded)" if outcome == "Household Income Re"
replace outcome = "Household Income (Equivalised)" if outcome == "Household Income Equi"

replace outcome = "Retired vs Employed (non-employed excluded) [65]" if outcome == "Retired 65"
replace outcome = "Non-employed vs Employed (retired excluded) [65]" if outcome == "Working 65"
replace outcome = "Non-employed vs Employed/Retired [65]" if outcome == "Working Or Retired 65"

gen exposure_type = "Risk Factor" if exposure == "Alcohol Intake (5 units/week)" | exposure == "Body Mass Index (5 kg/m{superscript:2})" | ///
	exposure == "Smoking Initiation" | exposure == "Lifetime Smoking (SD)" | exposure == "Systolic BP (10 mmHg)" | exposure == "Cholesterol (1 mmol/l)"
replace exposure_type = "Health Condition" if exposure_type == ""

gen outcome_type = "Socioeconomic" if outcome == "Non-employed vs Employed (retired excluded)" | outcome == "Non-employed vs Employed/Retired" | outcome == "Retired vs Employed (non-employed excluded)" | ///
	outcome == "Own Accommodation Lived In" | outcome == "Skilled Job" | outcome == "University Education" | outcome == "TDI at Recruitment" | outcome == "Household Income" 
replace outcome_type = "Sensitivity" if strpos(outcome,"[65]") > 0 | outcome == "Household Income (Equivalised)" | outcome == "Household Income (retired excluded)" | strpos(outcome,"binary") > 0
replace outcome_type = "Social" if outcome_type == ""

*Altman-Bland/Fisher tests
*Male-female
gen double p_sex = 2*normal(-abs((beta_female-beta_male)/sqrt(se_female^2+se_male^2)))
*Low-mid
gen double p_low_mid = 2*normal(-abs((beta_low-beta_mid)/sqrt(se_low^2+se_mid^2)))
*Low-high
gen double p_low_high = 2*normal(-abs((beta_low-beta_high)/sqrt(se_low^2+se_high^2)))
*Mid-high
gen double p_mid_high = 2*normal(-abs((beta_mid-beta_high)/sqrt(se_mid^2+se_high^2)))

sort exposure outcome_type outcome type

save "$cd_tables\Results table.dta", replace

}
********************************************************************************

*R2 values
{

use "all_8_analysis.dta", clear

*Create table
gen exposure = ""
gen r2 = .

local i = 1
foreach grs of varlist grs* {
	local phe = substr("`grs'",4,.)
	local phe = "phe`phe'"
	local exposure = substr("`phe'",5,.)
	
	qui replace exposure = subinstr("`exposure'","_"," ",.) in `i'
	
	local continuous = 0
	
	foreach var of varlist phe_body_mass_index phe_systolic_bp phe_cholesterol {
		if "`var'" == "`phe'" {
			local continuous = 1
		}
	}
	*Continuous exposures
	if `continuous' == 1 {
		qui corr `phe' `grs'
		qui replace r2 = r(rho)^2 in `i'
	}
	else {
		qui logit `phe' `grs'
		qui replace r2 = e(r2_p) in `i'
	}
	local i = `i'+1
}

keep exposure r2
drop if exposure == ""

sort exposure

replace exposure = proper(exposure)

rename exposure Exposure

save "$cd_tables\R2 table.dta", replace 
		
}

********************************************************************************
*Extra analysis for rs1051730
{
import delim using "$cd_prs_data\snp_ipd_rs1051730", clear
rename fid id_ieu
drop iid-phenotype
rename rs1051730_a rs1051730

merge 1:1 id_ieu using "all_8_analysis.dta", keep(3) nogen

*Normalise lifetime smoking so results are per SD increase
qui su phe_lifetime_smoking
qui replace phe_lifetime_smoking = (phe_lifetime_smoking-r(mean))/r(sd)

rename phe_lifetime_smoking lifetime_smoking
rename phe_smoking_initiation smoking_initiation
drop grs* phe* pilot

*Create table
gen exposure = "rs1051730"
gen outcome = ""
gen type = ""
gen group = ""
gen n = .
gen beta = .
gen se = .
gen double p = .
gen double p_endog = .
gen f_stat = .
gen touse = .

local i = 1

foreach k in all never_smokers smokers current_smokers former_smokers {
	replace touse = .

	if "`k'" == "all" {
		replace touse = 1
	}
	if "`k'" == "never_smokers" {
		replace touse = 1 if smoking == 0
	}
	if "`k'" == "smokers" {
		replace touse = 1 if smoking >= 1
	}
	if "`k'" == "current_smokers" {
		replace touse = 1 if smoking == 2
	}
	if "`k'" == "former_smokers" {
		replace touse = 1 if smoking == 1
	}

	foreach var of varlist eco* soc* {
		if "`var'" == "eco_household_income" | "`var'" == "eco_household_income_re" | "`var'" == "eco_tdi" | "`var'" == "eco_household_income_equi" {
			qui reg `var' rs1051730 age sex pc* i.centre if touse == 1
			local type = "Linear regression"
		}
		else {
			qui logit `var' rs1051730 age sex pc* i.centre if touse == 1
			local type = "Logistic regression"
		}
		local outcome = substr("`var'",5,.)
		local n = e(N)
		local beta = _b[rs1051730]
		local se = _se[rs1051730]
		local p = 2*normal(-abs(`beta'/`se'))
		
		foreach x in outcome type {
			qui replace `x' = "``x''" in `i'
		}
		
		foreach x in n beta se p {
			qui replace `x' = ``x'' in `i'
		}
		
		qui replace group = subinstr("`k'","_"," ",.) in `i'
		
		local i = `i'+1
		
		if "`k'" != "never_smokers" {
		
			foreach phe of varlist lifetime_smoking smoking_initiation {
				if "`k'" == "all" | "`phe'" == "lifetime_smoking" {
					qui ivreg2 `var' (`phe' = rs1051730) age sex pc* i.centre if touse == 1, robust endog(`phe') 
				
					local type = "IV reg"
					local f_stat = e(widstat)
					matrix a = e(b)
					matrix b = e(V)
					local n = e(N)
					local beta = a[1,1]
					local se = sqrt(b[1,1])
					local p = 2*normal(-abs(`beta'/`se'))
					local p_endog = e(estatp)
					local exposure = "`phe'"
					
					foreach x in outcome type exposure {
						qui replace `x' = "``x''" in `i'
					}
					
					foreach x in n beta se p f_stat p_endog {
						qui replace `x' = ``x'' in `i'
					}
					
					qui replace group = subinstr("`k'","_"," ",.) in `i'
					
					local i = `i'+1
				}
			}
		}
		
	}	
}

keep exposure-f_stat
keep if p != .
	
replace outcome = strproper(outcome)
replace outcome = subinstr(outcome,"_"," ",.)

replace outcome = "Cohabiting" if outcome == "Cohabitation"
replace outcome = "Able to Confide" if outcome == "Confide"
replace outcome = "University Education" if outcome == "Degree"
replace outcome = "Satisfied with Family Relationships" if outcome == "Family Satisfaction"
replace outcome = "Satisfied with Financial Situation" if outcome == "Financial Satisfaction"
replace outcome = "Weekly Friend Visits" if outcome == "Friend Visits"
replace outcome = "Satisfied with Friendships" if outcome == "Friendship Satisfaction"
replace outcome = "Satisfied with Health" if outcome == "Health Satisfaction"
replace outcome = "Happy" if outcome == "Happiness"
replace outcome = "Weekly Leisure or Social Activity" if outcome == "Leisure"
replace outcome = "Lonely" if outcome == "Loneliness"
replace outcome = "Own Accommodation Lived In" if outcome == "Own"
replace outcome = "Retired vs Employed (non-employed excluded)" if outcome == "Retired"
replace outcome = "Satisfied with Work" if outcome == "Work Satisfaction"
replace outcome = "Non-employed vs Employed (retired excluded)" if outcome == "Working"
replace outcome = "Non-employed vs Employed/Retired" if outcome == "Working Or Retired"
replace outcome = "TDI at Recruitment" if outcome == "Tdi"
replace outcome = "TDI at Recruitment (binary)" if outcome == "Tdi Bin"
replace outcome = "Household Income (binary)" if outcome == "Household Income Bin"
replace outcome = "Household Income (retired excluded)" if outcome == "Household Income Re"
replace outcome = "Household Income (Equivalised)" if outcome == "Household Income Equi"

replace outcome = "Retired vs Employed (non-employed excluded) [65]" if outcome == "Retired 65"
replace outcome = "Non-employed vs Employed (retired excluded) [65]" if outcome == "Working 65"
replace outcome = "Non-employed vs Employed/Retired [65]" if outcome == "Working Or Retired 65"

gen outcome_type = "Socioeconomic" if outcome == "Non-employed vs Employed (retired excluded)" | outcome == "Non-employed vs Employed/Retired" | outcome == "Retired vs Employed (non-employed excluded)" | ///
	outcome == "Own Accommodation Lived In" | outcome == "Skilled Job" | outcome == "University Education" | outcome == "TDI at Recruitment" | outcome == "Household Income" 
replace outcome_type = "Sensitivity" if strpos(outcome,"[65]") > 0 | outcome == "Household Income (Equivalised)" | outcome == "Household Income (retired excluded)" | strpos(outcome,"binary") > 0
replace outcome_type = "Social" if outcome_type == ""

replace exposure = "rs1051730 (Lifetime Smoking)" if exposure == "lifetime_smoking"
replace exposure = "rs1051730 (Smoking Initiation)" if exposure == "smoking_initiation"
replace type = "Sensitivity Analysis MR" if type == "IV reg"
replace group = proper(group)

save "$cd_tables\rs1051730 analysis.dta", replace 
	
}
********************************************************************************

*MR analysis
*This code regresses all SNPs against all outcomes for each trait
*Then does all the MR sensitivity analyses (IVW, Egger, median, mode)
{

*Create id list
use "all_8_analysis.dta", clear
keep id_ieu
save "id_list.dta", replace

import delim "$cd_prs_data\snp_ipd_8.csv", delim(",") clear

drop iid-phenotype
rename fid id_ieu

*Remove useless ids
merge 1:1 id_ieu using "id_list.dta", keep(match) nogen

save "snp_ipd.dta", replace

*Need to create smaller datasets for each trait to regress on all outcomes
use "all_8_analysis.dta", clear

keep id_ieu age sex pilot pc* eco* soc*

save "snps\outcomes.dta", replace

*Run the code from R to strip down the SNPs into actual datasets
rsource using "$cd_r_code\mr_snps_to_keep_generation.R", rpath(`"C:\Program Files\R\R-3.5.1\bin\R.exe"') roptions(`"--vanilla"')  // change version number, if necessary
use "snp_ipd.dta", clear
qui do "$cd_stata_code\snps_to_keep.do"

*Need to merge with the betas for each exposure from the GWAS
import delim "$cd_prs_data\exposure_dat_harmonised_8.csv", delim(",") clear
keep if included == 1
keep snp betaexposure seexposure trait
rename beta beta_exposure
rename se se_exposure

*Drop depressive symptoms (not Wray depression)
drop if trait == "Depressive_symptoms"

*Split into merge sets based on trait
qui levelsof trait, local(list)
foreach trait in `list' {
	preserve
	keep if trait == "`trait'"
	/*
	*Note: The rs57440165 SNP causes problems, drop
	if "`trait'" == "breast_carcinoma" {
		drop if snp == "rs57440165"
	}
	*/
	save "snps\merge_`trait'.dta", replace	
	restore
}

foreach trait in `list' {
	use "snps\results_`trait'.dta", clear
	/*
	if "`trait'" == "breast_carcinoma" {
		drop if snp == "rs57440165"
	}
	*/
	merge m:1 snp using "snps\merge_`trait'.dta", nogen
	save "snps\append_`trait'.dta", replace
}

drop in 1/-1

foreach trait in `list' {
	append using "snps\append_`trait'.dta"
}

*Make things look better

replace outcome = strproper(outcome)

replace outcome = "Cohabiting" if outcome == "Cohabitation"
replace outcome = "Able to Confide" if outcome == "Confide"
replace outcome = "University Education" if outcome == "Degree"
replace outcome = "Satisfied with Family Relationships" if outcome == "Family Satisfaction"
replace outcome = "Satisfied with Financial Situation" if outcome == "Financial Satisfaction"
replace outcome = "Weekly Friend Visits" if outcome == "Friend Visits"
replace outcome = "Satisfied with Friendships" if outcome == "Friendship Satisfaction"
replace outcome = "Satisfied with Health" if outcome == "Health Satisfaction"
replace outcome = "Happy" if outcome == "Happiness"
replace outcome = "Weekly Leisure or Social Activity" if outcome == "Leisure"
replace outcome = "Lonely" if outcome == "Loneliness"
replace outcome = "Own Accommodation Lived In" if outcome == "Own"
replace outcome = "Retired vs Employed (non-employed excluded)" if outcome == "Retired"
replace outcome = "Satisfied with Work" if outcome == "Work Satisfaction"
replace outcome = "Non-employed vs Employed (retired excluded)" if outcome == "Working"
replace outcome = "Non-employed vs Employed/Retired" if outcome == "Working Or Retired"
replace outcome = "TDI at Recruitment" if outcome == "Tdi"
replace outcome = "TDI at Recruitment (binary)" if outcome == "Tdi Bin"
replace outcome = "Household Income (binary)" if outcome == "Household Income Bin"
replace outcome = "Household Income (retired excluded)" if outcome == "Household Income Re"
replace outcome = "Household Income (Equivalised)" if outcome == "Household Income Equi"

replace outcome = "Retired vs Employed (non-employed excluded) [65]" if outcome == "Retired 65"
replace outcome = "Non-employed vs Employed (retired excluded) [65]" if outcome == "Working 65"
replace outcome = "Non-employed vs Employed/Retired [65]" if outcome == "Working Or Retired 65"

gen outcome_type = "Socioeconomic" if outcome == "Non-employed vs Employed (retired excluded)" | outcome == "Non-employed vs Employed/Retired" | outcome == "Retired vs Employed (non-employed excluded)" | ///
	outcome == "Own Accommodation Lived In" | outcome == "Skilled Job" | outcome == "University Education" | outcome == "TDI at Recruitment" | outcome == "Household Income" 
replace outcome_type = "Sensitivity" if strpos(outcome,"[65]") > 0 | outcome == "Household Income (Equivalised)" | outcome == "Household Income (retired excluded)" | strpos(outcome,"binary") > 0
replace outcome_type = "Social" if outcome_type == ""

*Make all the exposure betas positive
qui replace beta = -beta if beta_exposure < 0
qui replace beta_exposure = -beta_exposure if beta_exposure < 0

replace trait = subinstr(trait,"_"," ",.)
replace trait = proper(trait)

replace trait = "Systolic Bp" if trait == "Blood Pressure"

*Make the betas consistent with the main analysis
*BMI = 5kg/m2 increase from SD increase - no SD listed in paper, assume the same as UK Biobank (4.75)
*BP = 10 mmHg increase - assume a unit increase in the paper
*Alcohol = 5 unit increase - one SD increase in the GWAS measure was equivalent to a 1 drink increase, assume 1 drink = 2 units

qui replace beta_exposure = beta_exposure*5/4.75 if trait == "Body Mass Index"
qui replace se_exposure = se_exposure*5/4.75 if trait == "Body Mass Index"

qui replace beta_exposure = beta_exposure*10 if trait == "Systolic Bp"
qui replace se_exposure = se_exposure*10 if trait == "Systolic Bp"

qui replace beta_exposure = beta_exposure*5/2 if trait == "Alcohol Intake"
qui replace se_exposure = se_exposure*5/2 if trait == "Alcohol Intake"

qui replace trait = "Body Mass Index (5 kg/m2)" if trait == "Body Mass Index"
qui replace trait = "Systolic BP (10 mmHg)" if trait == "Systolic Bp"
qui replace trait = "Alcohol Intake (5 units/week)" if trait == "Alcohol Intake"
qui replace trait = "Cholesterol (1 mmol/l)" if trait == "Cholesterol" 

replace trait = "Breast Cancer" if trait == "Breast Carcinoma"
replace trait = "Migraine" if trait == "Migraine Disorder"
replace trait = "Depression" if trait == "Major Depressive Disorder"

save "MR data.dta", replace

********

use "MR data.dta", clear

gen exp = ""
gen out = ""
gen genotypes = .
gen ivw = .
gen ivw_se = .
gen ivw_p = .
gen egger_slope = .
gen egger_slope_se = .
gen egger_slope_p = .
gen egger_cons = .
gen egger_cons_se = .
gen egger_cons_p = .
gen heterogeneity_p = .
gen median = .
gen median_se = .
gen median_p = .
gen mode = .
gen mode_se = .
gen mode_p = .

qui levelsof trait, local(trait)
qui levelsof outcome, local(outcome)
local i = 1
foreach exp in `trait' {
	foreach out in `outcome' {
		qui count if outcome == "`out'" & trait == "`exp'"
		if r(N) >= 3 {
			*MR robust takes the outcome first
			qui replace genotypes = r(N) in `i'
			qui replace exp = "`exp'" in `i'
			qui replace out = "`out'" in `i'
			capture qui mregger beta beta_exposure [aw=1/(se^2)] if trait == "`exp'" & outcome == "`out'", ivw heterogi
			if !_rc {
				qui replace heterogeneity_p = r(pval) in `i'
			}
			else {
				qui mregger beta beta_exposure [aw=1/(se^2)] if trait == "`exp'" & outcome == "`out'", ivw
			}
			qui replace ivw = _b[beta_exposure] in `i'
			qui replace ivw_se = _se[beta_exposure] in `i'
			
			qui mregger beta beta_exposure [aw=1/(se^2)] if trait == "`exp'" & outcome == "`out'"
			qui replace egger_slope = _b[slope] in `i'
			qui replace egger_slope_se = _se[slope] in `i'
			qui replace egger_cons = _b[_cons] in `i'
			qui replace egger_cons_se = _se[_cons] in `i'
			qui mrmedian beta se beta_exposure se_exposure if trait == "`exp'" & outcome == "`out'"
			qui replace median = _b[beta] in `i'
			qui replace median_se = _se[beta] in `i'
			qui mrmodal beta se beta_exposure se_exposure if trait == "`exp'" & outcome == "`out'"
			qui replace mode = _b[beta] in `i'
			qui replace mode_se = _se[beta] in `i'
			
			local i = `i' + 1
		}
	}
}
	
foreach var of varlist ivw egger_slope egger_cons median mode {
	qui replace `var'_p = 2*normal(-abs(`var'/`var'_se))
}

keep exp-mode_p
keep if exp != ""

sort exp out
rename exp exposure
rename out outcome
rename genotypes snps

gen outcome_type = "Socioeconomic" if outcome == "Non-employed vs Employed (retired excluded)" | outcome == "Non-employed vs Employed/Retired" | outcome == "Retired vs Employed (non-employed excluded)" | ///
	outcome == "Own Accommodation Lived In" | outcome == "Skilled Job" | outcome == "University Education" | outcome == "TDI at Recruitment" | outcome == "Household Income" , a(outcome)
replace outcome_type = "Sensitivity" if strpos(outcome,"[65]") > 0 | outcome == "Household Income (Equivalised)" | outcome == "Household Income (retired excluded)" | strpos(outcome,"binary") > 0
replace outcome_type = "Social" if outcome_type == ""

save "$cd_tables\MR results.dta", replace

}

*Migraine analysis
*Migraine has an effect on leisure/social activities, which may be due to alcohol causing migraines
*Check to see if removing "pub/social club" as a leisure/social activity changes things
{
use "all_8_clean.dta", clear

rename v12 phe_migraine
rename grs_migraine grs_migraine
rename n_21003 age
rename n_31_ sex
rename n_54_ centre

forvalues i=1/40 {
	rename n_22009_0_`i' pc`i'
}

gen soc_leisure_pub = 0
replace soc_leisure_pub = . if n_6160_0_0 == -3
gen soc_leisure_no_pub = 0 if n_6160_0_0 == -7 | n_6160_0_0 == 2
forvalues i = 0/4 {
	replace soc_leisure_pub = 1 if n_6160_0_`i' == 2
	replace n_6160_0_`i' = . if n_6160_0_`i' == 2
	replace soc_leisure_no_pub = 1 if n_6160_0_`i' > 0 & n_6160_0_`i' < .
}
label variable soc_leisure_pub "1=Goes to pub or social club"
label variable soc_leisure_no_pub "1=Has >=1 leisure/social activity, not pub/social club"

keep id_ieu id_phe centre pilot age sex pc* phe_migraine grs_migraine soc_leisure_pub soc_leisure_no_pub

order phe* soc* pc* grs*, alpha
order id* centre age sex pilot grs* phe* soc* pc1 pc2 pc3 pc4 pc5 pc6 pc7 pc8 pc9 pc*

*Create table
gen touse = .
gen exposure = ""
gen outcome = ""
gen type = ""

foreach k in all female male {
	gen n_`k' = .
	gen beta_`k' = .
	gen se_`k' = .
	gen double p_`k' = .
	gen double p_endog_`k' = .
	gen f_stat_`k' = .

	replace touse = .
	
	if "`k'" == "all" {
		replace touse = 1
	}
	if "`k'" == "female" {
		replace touse = 1 if sex == 0
	}
	if "`k'" == "male" {
		replace touse = 1 if sex == 1
	}

	local i = 1
	
	*MR analysis
	foreach grs of varlist grs* {
		local phe = substr("`grs'",4,.)
		local phe = "phe`phe'"
		dis "Analysing `phe': `k'"
		
		foreach var of varlist soc* {
			qui ivreg2 `var' (`phe' = `grs') age sex pc* i.centre if touse == 1, robust endog(`phe') 
			local exposure = substr("`phe'",5,.)
			local exposure = subinstr("`exposure'","_"," ",.)
			local outcome = substr("`var'",5,.)
			local f_stat = e(widstat)
			matrix a = e(b)
			matrix b = e(V)
			local beta = a[1,1]
			local se = sqrt(b[1,1])
			local n = e(N)
			local p = 2*normal(-abs(`beta'/`se'))
			local p_endog = e(estatp)
			
			foreach x in exposure outcome  {
				qui replace `x' = "``x''" in `i'
			}
			
			foreach x in beta se n p p_endog f_stat {
				qui replace `x'_`k' = ``x'' in `i'
			}
			
			qui replace type = "IV reg" in `i'
			local i = `i'+1
		}
	}
}

keep exposure-p_endog_male
drop if exposure == ""
replace outcome = "Weekly Pub or Social Club Activity" if outcome == "leisure_pub"
replace outcome = "Weekly Leisure or Social Activity (no pub or social activity)" if outcome == "leisure_no_pub"

*Altman-Bland/Fisher tests
*Male-female
gen double p_sex = 2*normal(-abs((beta_female-beta_male)/sqrt(se_female^2+se_male^2)))

sort exposure outcome type

save "$cd_tables\Migraine results table.dta", replace

}

}

*Part VII
*Split-sample analysis
{
*Prep
{
import delim "Split sample\Results\Results\grs_ss.csv", clear
rename id id_ieu

merge 1:1 id_ieu using "all_8_analysis.dta", nogen keep(3)
merge 1:1 id_ieu using "Split sample\Archive\2020-03-24\sample IDs.dta", nogen keep(3)

order sig_cholesterol_1 - sig_coronary_heart_disease_2, last alpha
drop grs*

foreach var of varlist sig* {
	local x = subinstr("`var'","sig_","",.)
	rename `var' `x'
}

*Rename everything
rename bmi_1 body_mass_index_1
rename bmi_2 body_mass_index_2

*GRS renaming and standardisation
foreach var of varlist alcohol_intake_1-type_2_diabetes_2 {
	
	*Restrict GRS to those not in the same sample
	local sample = substr("`var'",-1,1)
	qui replace `var' = . if sample == `sample'
	
	*Standardise
	qui sum `var'
	qui replace `var' = (`var'-r(mean))/r(sd)
	
	*Rename
	rename `var' grs_`var'
}

*Remove men from breast cancer PRS and phenotypes
qui replace grs_breast_cancer_1 = . if sex == 1
qui replace grs_breast_cancer_2 = . if sex == 1
qui replace phe_breast = . if sex == 1

*Depression didn't find any SNPs, remove phenotype
drop phe_depression

*Generate Phe for samples 1 and 2 seperately (saves messing with "if sample == 1/2")
foreach var of varlist phe* {
	gen `var'_2 = `var', a(`var')
	rename `var' `var'_1
	replace `var'_1 = . if sample == 1
	replace `var'_2 = . if sample == 2
}

save "ss_analysis.dta", replace
}

*Analysis
*IV reg
{
use "ss_analysis.dta", clear

*Create table
gen exposure = ""
gen outcome = ""
gen type = ""
gen beta = .
gen se = .
gen double p = .
gen p_endog = .
gen f_stat = .
gen n = .

rename eco_household_income_re eco_household_income_retired

*Normalise lifetime smoking so results are per SD increase
qui su phe_lifetime_smoking_1
qui replace phe_lifetime_smoking_1 = (phe_lifetime_smoking_1-r(mean))/r(sd)
qui replace phe_lifetime_smoking_2 = (phe_lifetime_smoking_2-r(mean))/r(sd)

*IV reg
dis "IV reg begins"
local i = 1

*MR analysis
foreach grs of varlist grs* {
	local phe = substr("`grs'",4,.)
	local phe = "phe`phe'"
	
	dis "Phenotype = `phe'"
	
	foreach var of varlist eco* soc* {
		if "`grs'" == "grs_breast_cancer" {
			qui ivreg2 `var' (`phe' = `grs') age pc* i.centre if sex == 0, robust endog(`phe')
		}
		else {
			qui ivreg2 `var' (`phe' = `grs') age sex pc* i.centre, robust endog(`phe')
		}
		local exposure = substr("`phe'",5,.)
		local exposure = subinstr("`exposure'","_"," ",.)
		local outcome = substr("`var'",5,.)
		local f_stat = e(widstat)
		matrix a = e(b)
		matrix b = e(V)
		local beta = a[1,1]
		local se = sqrt(b[1,1])
		local p = 2*normal(-abs(`beta'/`se'))
		local p_endog = e(estatp)
		local n = e(N)
				
		foreach x in exposure outcome beta se p p_endog n f_stat {
			if "`x'" == "beta" | "`x'" == "se" | "`x'" == "p" | "`x'" == "p_endog" | "`x'" == "n" | "`x'" == "f_stat" {
				qui replace `x' = ``x'' in `i'
			}
			else {
				qui replace `x' = "``x''" in `i'
			}
		}
		qui replace type = "IV reg" in `i'
		local i = `i'+1
	}
	
}

*Multivariable adjusted linear estimates
qui sum beta
local i = r(N)+1

foreach phe of varlist phe* {
	foreach var of varlist eco* soc* {
		if "`phe'" == "phe_breast_cancer" {
			qui reg `var' `phe' age pc* i.centre if sex == 0
		}
		else {
			qui reg `var' `phe' age sex pc* i.centre
		}
		local exposure = substr("`phe'",5,.)
		local exposure = subinstr("`exposure'","_"," ",.)
		local outcome = substr("`var'",5,.)
		matrix a = e(b)
		matrix b = e(V)
		local beta = a[1,1]
		local se = sqrt(b[1,1])
		local p = 2*normal(-abs(`beta'/`se'))
		local n = e(N)
				
		foreach x in exposure outcome beta se p n {
			if "`x'" == "beta" | "`x'" == "se" | "`x'" == "p" | "`x'" == "p_endog" | "`x'" == "n" {
				qui replace `x' = ``x'' in `i'
			}
			else {
				qui replace `x' = "``x''" in `i'
			}
		}
		qui replace type = "Multivariable Adjusted" in `i'
		local i = `i'+1
	}

}

save "$cd_tables\Split results table raw.dta", replace
********************************************************************************

use "$cd_tables\Split results table raw.dta", clear

keep exposure-n
drop if exposure == ""
replace outcome = subinstr(outcome,"_"," ",.)

replace beta = beta*5 if exposure == "body mass index 1" | exposure == "alcohol intake 1" | exposure == "body mass index 2" | exposure == "alcohol intake 2" 
replace se = se*5 if exposure == "body mass index 1" | exposure == "alcohol intake 1" | exposure == "body mass index 2" | exposure == "alcohol intake 2" 

replace beta = beta*10 if exposure == "systolic bp 1" | exposure == "systolic bp 2" 
replace se = se*10 if exposure == "systolic bp 1" | exposure == "systolic bp 2"

replace exposure = strproper(exposure)
replace outcome = strproper(outcome)

forvalues i = 1/2 {
	replace exposure = "Body Mass Index (5 kg/m{superscript:2}) `i'" if exposure == "Body Mass Index `i'"
	replace exposure = "Alcohol Intake (5 units/week) `i'" if exposure == "Alcohol Intake `i'" 
	replace exposure = "Systolic BP (10 mmHg) `i'" if exposure == "Systolic Bp `i'"
	replace exposure = "Lifetime Smoking (SD) `i'" if exposure == "Lifetime Smoking `i'"
	replace exposure = "Cholesterol (1 mmol/l) `i'" if exposure == "Cholesterol `i'"
}

replace outcome = "Cohabiting" if outcome == "Cohabitation"
replace outcome = "Able to Confide" if outcome == "Confide"
replace outcome = "University Education" if outcome == "Degree"
replace outcome = "Satisfied with Family Relationships" if outcome == "Family Satisfaction"
replace outcome = "Satisfied with Financial Situation" if outcome == "Financial Satisfaction"
replace outcome = "Weekly Friend Visits" if outcome == "Friend Visits"
replace outcome = "Satisfied with Friendships" if outcome == "Friendship Satisfaction"
replace outcome = "Satisfied with Health" if outcome == "Health Satisfaction"
replace outcome = "Happy" if outcome == "Happiness"
replace outcome = "Weekly Leisure or Social Activity" if outcome == "Leisure"
replace outcome = "Lonely" if outcome == "Loneliness"
replace outcome = "Own Accommodation Lived In" if outcome == "Own"
replace outcome = "Retired vs Employed (non-employed excluded)" if outcome == "Retired"
replace outcome = "Satisfied with Work" if outcome == "Work Satisfaction"
replace outcome = "Non-employed vs Employed (retired excluded)" if outcome == "Working"
replace outcome = "Non-employed vs Employed/Retired" if outcome == "Working Or Retired"
replace outcome = "TDI at Recruitment" if outcome == "Tdi"
replace outcome = "TDI at Recruitment (binary)" if outcome == "Tdi Bin"
replace outcome = "Household Income (binary)" if outcome == "Household Income Bin"
replace outcome = "Household Income (retired excluded)" if outcome == "Household Income Retired"
replace outcome = "Household Income (Equivalised)" if outcome == "Household Income Equi"

replace outcome = "Retired vs Employed (non-employed excluded) [65]" if outcome == "Retired 65"
replace outcome = "Non-employed vs Employed (retired excluded) [65]" if outcome == "Working 65"
replace outcome = "Non-employed vs Employed/Retired [65]" if outcome == "Working Or Retired 65"

gen exposure_type = ""

forvalues i = 1/2 {
replace exposure_type = "Risk Factor" if exposure == "Alcohol Intake (5 units/week) `i'" | exposure == "Body Mass Index (5 kg/m{superscript:2}) `i'" | ///
	exposure == "Smoking Initiation `i'" | exposure == "Lifetime Smoking (SD) `i'" | exposure == "Systolic BP (10 mmHg) `i'" | exposure == "Cholesterol (1 mmol/l)"
}
replace exposure_type = "Health Condition" if exposure_type == ""

gen outcome_type = "Socioeconomic" if outcome == "Non-employed vs Employed (retired excluded)" | outcome == "Non-employed vs Employed/Retired" | outcome == "Retired vs Employed (non-employed excluded)" | ///
	outcome == "Own Accommodation Lived In" | outcome == "Skilled Job" | outcome == "University Education" | outcome == "TDI at Recruitment" | outcome == "Household Income" 
replace outcome_type = "Sensitivity" if strpos(outcome,"[65]") > 0 | outcome == "Household Income (Equivalised)" | outcome == "Household Income (retired excluded)" | strpos(outcome,"binary") > 0
replace outcome_type = "Social" if outcome_type == ""

save "$cd_tables\SS Results table.dta", replace

}
********************************************************************************

*Meta-analysis
{
use "$cd_tables\SS Results table.dta", clear

*Replace "/" in the outcomes (causes problems)
qui replace outcome = subinstr(outcome,"/"," or ",.)

*Create a sample variable
gen sample = substr(exposure,-1,1), a(outcome)

*The hyphon is also causing problems
replace outcome = "Nonemployed vs Employed (retired excluded)" if outcome == "Non-employed vs Employed (retired excluded)"
replace outcome = "Nonemployed vs Employed or Retired" if outcome == "Non-employed vs Employed or Retired"
replace outcome = "Nonemployed vs Employed (retired excluded) [65]" if outcome == "Non-employed vs Employed (retired excluded) [65]"
replace outcome = "Nonemployed vs Employed or Retired [65]" if outcome == "Non-employed vs Employed or Retired [65]"

*Meta-analyse across the 2 samples
qui levelsof exposure, local(exposure)
qui levelsof outcome, local(outcome)
qui levelsof type, local(type_list)
local N = r(N)
local N2 = `N'*2
set obs `N2'

local k = `N'+1

local i = `N'+1
foreach exp in `exposure' {
	*Only do things for the first sample 
	if substr("`exp'",-1,1) == "1" {
		local length = length("`exp'")-2
		local e1 = "`exp'"
		local e2 = substr("`exp'",1,`length')
		local e2 = "`e2' 2"
		local ex = substr("`exp'",1,`length')
		
		dis "trait = `ex'"
		
		qui replace exposure = "`ex'" if exposure == "`e1'" | exposure == "`e2'"
		
		foreach out in `outcome' {
			
			foreach type of local type_list {
				qui count if exposure == "`ex'" & outcome == "`out'" & type == "`type'"
				if r(N) > 0 {
					qui replace exposure = "`ex'" in `i'
					qui replace outcome = "`out'" in `i'
					qui replace sample = "Combined" in `i'
					qui replace type = "`type'" in `i'
					qui metan beta se if exposure == "`ex'" & outcome == "`out'" & type == "`type'", nograph
					qui replace beta = r(ES) in `i'
					qui replace se = r(seES) in `i'
					
					qui su n if exposure == "`ex'" & outcome == "`out'" & type == "`type'"
					qui replace n = r(sum) if exposure == "`ex'" & outcome == "`out'" & type == "`type'" & n == .
					
					local i = `i' + 1
				}
			}
		}
		
	}
}

*Hyphon/slash back in
replace outcome = "Non-employed vs Employed (retired excluded)" if outcome == "Nonemployed vs Employed (retired excluded)"
replace outcome = "Non-employed vs Employed/Retired" if outcome == "Nonemployed vs Employed or Retired"
replace outcome = "Non-employed vs Employed (retired excluded) [65]" if outcome == "Nonemployed vs Employed (retired excluded) [65]"
replace outcome = "Non-employed vs Employed/Retired [65]" if outcome == "Nonemployed vs Employed or Retired [65]"

*Regenerate types for the combined estimates
replace exposure_type = "Risk Factor" if exposure == "Alcohol Intake (5 units/week)" | exposure == "Body Mass Index (5 kg/m{superscript:2})" | ///
	exposure == "Smoking Initiation" | exposure == "Lifetime Smoking (SD)" | exposure == "Systolic BP" | exposure == "Cholesterol (1 mmol/l)"
replace exposure_type = "Health Condition" if exposure_type == ""

replace outcome_type = "Socioeconomic" if outcome == "Non-employed vs Employed (retired excluded)" | outcome == "Non-employed vs Employed/Retired" | outcome == "Retired vs Employed (non-employed excluded)" | ///
	outcome == "Own Accommodation Lived In" | outcome == "Skilled Job" | outcome == "University Education" | outcome == "TDI at Recruitment" | outcome == "Household Income" 
replace outcome_type = "Sensitivity" if strpos(outcome,"[65]") > 0 | outcome == "Household Income (Equivalised)" | outcome == "Household Income (retired excluded)" | strpos(outcome,"binary") > 0
replace outcome_type = "Social" if outcome_type == ""

keep if exposure != ""

sort type exposure outcome sample

replace p = 2*normal(-abs(beta/se))

save "$cd_tables\SS Results table - all.dta", replace

drop if sample != "Combined"
drop sample

save "$cd_tables\SS Results table - metan.dta", replace
}
********************************************************************************

*R2 values
{

use "ss_analysis.dta", clear

*Create table
gen exposure = ""
gen r2 = .

local i = 1
foreach grs of varlist grs* {
	local phe = substr("`grs'",4,.)
	local phe = "phe`phe'"
	local exposure = substr("`phe'",5,.)
	
	qui replace exposure = subinstr("`exposure'","_"," ",.) in `i'
	
	local continuous = 0
	
	foreach var of varlist phe_body_mass_index* phe_alcohol* phe_lifetime_smoking* phe_systolic_bp* phe_cholesterol* {
		if "`var'" == "`phe'" {
			local continuous = 1
		}
	}
	*Continuous exposures
	if `continuous' == 1 {
		qui corr `phe' `grs'
		qui replace r2 = r(rho)^2 in `i'
	}
	else {
		if "`phe'" == "phe_breast_cancer_1" | "`phe'" == "phe_breast_cancer_2" {
			qui logit `phe' `grs' if sex == 0
			qui replace r2 = e(r2_p) in `i'
		}
		else {
			qui logit `phe' `grs'
			qui replace r2 = e(r2_p) in `i'
		}
	}
	local i = `i'+1
}

keep exposure r2
drop if exposure == ""

sort exposure

replace exposure = proper(exposure)
replace exposure = subinstr(exposure,"c Bp ","c BP ",.)

replace exposure = subinstr(exposure," (5 Kg/M2)","",.)
replace exposure = subinstr(exposure," (5 Units/Week)","",.)
replace exposure = subinstr(exposure," (1Mmol/L)","",.)
replace exposure = subinstr(exposure," (10 Mmhg)","",.)

save "$cd_tables\ss_R2 table.dta", replace 
		
}

********************************************************************************

*MR analysis
*This code regresses all SNPs against all outcomes for each trait
*Then does all the MR sensitivity analyses (IVW, Egger, median, mode)

{

*Create id list
use "ss_analysis.dta", clear
keep id_ieu
save "id_list.dta", replace

import delim "Split sample\Results\Results\snp_ipd_ss.csv", delim(",") clear

drop iid-phenotype
rename fid id_ieu

*Remove useless ids
merge 1:1 id_ieu using "id_list.dta", keep(3) nogen

save "snp_ipd_ss.dta", replace

*Need to create smaller datasets for each trait to regress on all outcomes
use "ss_analysis.dta", clear

keep id_ieu age sex pc* eco* soc*

*Also need to know which sample the participants were in:
merge 1:1 id_ieu using "Split sample\Archive\2020-03-24\sample IDs.dta", nogen keep(3)

save "snps_ss\outcomes.dta", replace

*Run the code from R to strip down the SNPs into datasets
rsource using "$cd_r_code\mr_snps_to_keep_generation.R", rpath(`"C:\Program Files\R\R-3.5.1\bin\R.exe"') roptions(`"--vanilla"')

use "snp_ipd_ss.dta", clear
qui do "$cd_stata_code\snps_to_keep_ss.do"

*Need to merge with the betas for each exposure from the GWAS
import delim "Split sample\Results\Results\exposure_dat_harmonised_ss.csv", delim(",") clear
keep if included == 1
replace trait = subinstr(trait,"sig_","",.)
keep snp betaexposure seexposure trait
rename beta beta_exposure
rename se se_exposure

*Split into merge sets based on trait
qui levelsof trait, local(list)
foreach trait in `list' {
	preserve
	keep if trait == "`trait'"
	save "snps_ss\merge_`trait'.dta", replace	
	restore
}

foreach trait in `list' {
	use "snps_ss\results_`trait'.dta", clear
	merge m:1 snp using "$cd_data\snps_ss\merge_`trait'.dta", nogen
	save "snps_ss\append_`trait'.dta", replace
}

drop in 1/-1

foreach trait in `list' {
	append using "snps_ss\append_`trait'.dta"
}

*Make things look better

replace outcome = strproper(outcome)

replace outcome = "Cohabiting" if outcome == "Cohabitation"
replace outcome = "Able to Confide" if outcome == "Confide"
replace outcome = "University Education" if outcome == "Degree"
replace outcome = "Satisfied with Family Relationships" if outcome == "Family Satisfaction"
replace outcome = "Satisfied with Financial Situation" if outcome == "Financial Satisfaction"
replace outcome = "Weekly Friend Visits" if outcome == "Friend Visits"
replace outcome = "Satisfied with Friendships" if outcome == "Friendship Satisfaction"
replace outcome = "Satisfied with Health" if outcome == "Health Satisfaction"
replace outcome = "Happy" if outcome == "Happiness"
replace outcome = "Weekly Leisure or Social Activity" if outcome == "Leisure"
replace outcome = "Lonely" if outcome == "Loneliness"
replace outcome = "Own Accommodation Lived In" if outcome == "Own"
replace outcome = "Retired vs Employed (non-employed excluded)" if outcome == "Retired"
replace outcome = "Satisfied with Work" if outcome == "Work Satisfaction"
replace outcome = "Non-employed vs Employed (retired excluded)" if outcome == "Working"
replace outcome = "Non-employed vs Employed/Retired" if outcome == "Working Or Retired"
replace outcome = "TDI at Recruitment" if outcome == "Tdi"
replace outcome = "TDI at Recruitment (binary)" if outcome == "Tdi Bin"
replace outcome = "Household Income (binary)" if outcome == "Household Income Bin"
replace outcome = "Household Income (retired excluded)" if outcome == "Household Income Re"
replace outcome = "Household Income (equivalised)" if outcome == "Household Income Equi"

replace outcome = "Retired vs Employed (non-employed excluded) [65]" if outcome == "Retired 65"
replace outcome = "Non-employed vs Employed (retired excluded) [65]" if outcome == "Working 65"
replace outcome = "Non-employed vs Employed/Retired [65]" if outcome == "Working Or Retired 65"

save "ss_MR data.dta", replace

********

use "ss_MR data.dta", clear

replace trait = subinstr(trait,"_"," ",.)
replace trait = proper(trait)

gen exp = ""
gen out = ""
gen genotypes = .
gen ivw = .
gen ivw_se = .
gen ivw_p = .
gen heterogeneity_p = .
gen egger_slope = .
gen egger_slope_se = .
gen egger_slope_p = .
gen egger_cons = .
gen egger_cons_se = .
gen egger_cons_p = .
gen median = .
gen median_se = .
gen median_p = .
gen mode = .
gen mode_se = .
gen mode_p = .

*Make the betas consistent with the main analysis
*BMI = 5kg/m2 increase
*BP = 10 mmHg increase
*Alcohol = 5 unit increase

qui replace beta_exposure = beta_exposure*5 if trait == "Bmi 1"
qui replace se_exposure = se_exposure*5 if trait == "Bmi 1"
qui replace beta_exposure = beta_exposure*5 if trait == "Bmi 2"
qui replace se_exposure = se_exposure*5 if trait == "Bmi 2"

qui replace beta_exposure = beta_exposure*10 if trait == "Systolic Bp 1"
qui replace se_exposure = se_exposure*10 if trait == "Systolic Bp 1"
qui replace beta_exposure = beta_exposure*10 if trait == "Systolic Bp 2"
qui replace se_exposure = se_exposure*10 if trait == "Systolic Bp 2"

qui replace beta_exposure = beta_exposure*5 if trait == "Alcohol Intake 1"
qui replace se_exposure = se_exposure*5 if trait == "Alcohol Intake 1"
qui replace beta_exposure = beta_exposure*5 if trait == "Alcohol Intake 2"
qui replace se_exposure = se_exposure*5 if trait == "Alcohol Intake 2"

qui replace trait = "Body Mass Index (5 kg/m2) 1" if trait == "Bmi 1"
qui replace trait = "Body Mass Index (5 kg/m2) 2" if trait == "Bmi 2"
qui replace trait = "Systolic BP (10 mmHg) 1" if trait == "Systolic Bp 1"
qui replace trait = "Systolic BP (10 mmHg) 2" if trait == "Systolic Bp 2"
qui replace trait = "Alcohol Intake (5 units/week) 1" if trait == "Alcohol Intake 1"
qui replace trait = "Alcohol Intake (5 units/week) 2" if trait == "Alcohol Intake 2"
qui replace trait = "Cholesterol (1 mmol/l) 1" if trait == "Cholesterol 1" 
qui replace trait = "Cholesterol (1 mmol/l) 2" if trait == "Cholesterol 2" 

*Make all the exposure betas positive
qui replace beta = -beta if beta_exposure < 0
qui replace beta_exposure = -beta_exposure if beta_exposure < 0

qui levelsof trait, local(trait)
qui levelsof outcome, local(outcome)
local i = 1
foreach exp in `trait' {
	foreach out in `outcome' {
		qui count if outcome == "`out'" & trait == "`exp'"
		if r(N) >= 3 {
			*MR robust takes the outcome before the phenotype
			qui replace genotypes = r(N) in `i'
			qui replace exp = "`exp'" in `i'
			qui replace out = "`out'" in `i'
			capture qui mregger beta beta_exposure [aw=1/(se^2)] if trait == "`exp'" & outcome == "`out'", ivw heterogi
			if !_rc {
				qui replace heterogeneity_p = r(pval) in `i'
			}
			else {
				qui mregger beta beta_exposure [aw=1/(se^2)] if trait == "`exp'" & outcome == "`out'", ivw
			}			
			qui replace ivw = _b[beta_exposure] in `i'
			qui replace ivw_se = _se[beta_exposure] in `i'
			qui mregger beta beta_exposure [aw=1/(se^2)] if trait == "`exp'" & outcome == "`out'"
			qui replace egger_slope = _b[slope] in `i'
			qui replace egger_slope_se = _se[slope] in `i'
			qui replace egger_cons = _b[_cons] in `i'
			qui replace egger_cons_se = _se[_cons] in `i'
			qui mrmedian beta se beta_exposure se_exposure if trait == "`exp'" & outcome == "`out'"
			qui replace median = _b[beta] in `i'
			qui replace median_se = _se[beta] in `i'
			qui mrmodal beta se beta_exposure se_exposure if trait == "`exp'" & outcome == "`out'"
			qui replace mode = _b[beta] in `i'
			qui replace mode_se = _se[beta] in `i'
			
			local i = `i' + 1
		}
	}
}
	
foreach var of varlist ivw egger_slope egger_cons median mode {
	qui replace `var'_p = 2*normal(-abs(`var'/`var'_se))
}

keep exp-mode_p
keep if exp != ""

replace exp = subinstr(exp,"1 ","1",.)
replace exp = subinstr(exp,"2 ","2",.)

replace exp = "Type 2 Diabetes 1" if exp == "Type 2Diabetes 1"
replace exp = "Type 2 Diabetes 2" if exp == "Type 2Diabetes 2"

save "$cd_tables\ss_MR results.dta", replace

}


}

*Part VIII
*Tables
{

*Table 1: Summary
{
use "all_8_analysis.dta", clear

gen Variable = ""
gen All = ""
gen N_All = ""
gen Men = ""
gen N_Men = ""
gen Women = ""
gen N_Women = ""
order Variable-N_Women, first

qui replace Variable = "N" in 1
qui replace Variable = "Age at recruitment, years [Mean (SD)]" in 2
qui replace Variable = "" in 3
qui replace Variable = "Health Conditions" in 4
qui replace Variable = "Asthma [N (%)]" in 5
qui replace Variable = "Breast cancer [N (%)]" in 6
qui replace Variable = "Coronary heart disease [N (%)]" in 7
qui replace Variable = "Depression* [N (%)]" in 8
qui replace Variable = "Eczema [N (%)]" in 9
qui replace Variable = "Migraine [N (%)]" in 10
qui replace Variable = "Osteoarthritis [N (%)]" in 11
qui replace Variable = "Type 2 diabetes** [N (%)]" in 12
qui replace Variable = "" in 13
qui replace Variable = "Risk Factors" in 14
qui replace Variable = "Alcohol intake per week, units of alcohol [Mean (SD)]" in 15
qui replace Variable = "Body mass index, kg/m2 [Mean (SD)]" in 16
qui replace Variable = "Cholesterol, mmol/l [Mean (SD)]" in 17
qui replace Variable = "Ever smoked [N (%)]" in 18
qui replace Variable = "Lifetime tobacco smoking [Mean (SD)]" in 19
qui replace Variable = "Systolic blood pressure, mmHg [Mean (SD)]" in 20
qui replace Variable = "" in 21
qui replace Variable = "Outcomes" in 22
qui replace Variable = "Socioeconomic" in 23
qui replace Variable = "Average total household income before tax [Mean (SD)]" in 24
qui replace Variable = "<£18,000 [N (%)]" in 25
qui replace Variable = "£18,000 to £30,999 [N (%)]" in 26
qui replace Variable = "£31,000 to £51,999 [N (%)]" in 27
qui replace Variable = "£52,000 to £100,000 [N (%)]" in 28
qui replace Variable = ">£100,000 [N (%)]" in 29
qui replace Variable = "Townsend deprivation index (TDI) at recruitment [Mean (SD)]" in 30
qui replace Variable = "Non-employed [N (%)]" in 31
qui replace Variable = "Non-employed (retired excluded) [N (%)]" in 32
qui replace Variable = "Retired [N (%)]" in 33
qui replace Variable = "Skilled job [N (%)]" in 34
qui replace Variable = "Degree level education [N (%)]" in 35
qui replace Variable = "Own accommodation lived in [N (%)]" in 36
qui replace Variable = "" in 37
qui replace Variable = "Social" in 38
qui replace Variable = "Able to confide (weekly or more frequently) [N (%)]" in 39
qui replace Variable = "Frequency of friend/family visits (weekly or more frequently) [N (%)]" in 40
qui replace Variable = "Cohabiting [N (%)]" in 41
qui replace Variable = "Leisure/social activity [N (%)]" in 42
qui replace Variable = "Lonely or isolated [N (%)]" in 43
qui replace Variable = "Happy [N (%)]" in 44
qui replace Variable = "Satisfied with family relationship [N (%)]" in 45
qui replace Variable = "Satisfied with financial situation [N (%)]" in 46
qui replace Variable = "Satisfied with friendships [N (%)]" in 47
qui replace Variable = "Satisfied with health [N (%)]" in 48
qui replace Variable = "Satisfied with work/job [N (%)]" in 49

*Number of participants
qui sum sex
local x = r(N)
local x: dis %9.0fc `x'
local x = strtrim("`x'")
local x1 = r(N)*r(mean)
local x1: dis %9.0fc `x1'
local x1 = strtrim("`x1'")
local x2 = r(N)*(1-r(mean))
local x2: dis %9.0fc `x2'
local x2 = strtrim("`x2'")
qui replace All = "`x'" in 1
qui replace Men = "`x1'" in 1
qui replace Women = "`x2'" in 1

*Age
local i = 2
foreach var of varlist age {
	qui sum `var'
	local mean = r(mean)
	local mean: dis %9.1f `mean'
	local mean = strtrim("`mean'")
	local N = r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local sd = r(sd)
	local sd: dis %9.2f `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace All = "`x'" in `i'
	qui replace N_All = "`N'" in `i'
	
	qui sum `var' if sex == 1
	local mean = r(mean)
	local mean: dis %9.1f `mean'
	local mean = strtrim("`mean'")
	local N = r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local sd = r(sd)
	local sd: dis %9.2f `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace Men = "`x'" in `i'
	qui replace N_Men = "`N'" in `i'

	qui sum `var' if sex == 0
	local mean = r(mean)
	local mean: dis %9.1f `mean'
	local mean = strtrim("`mean'")
	local N = r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local sd = r(sd)
	local sd: dis %9.2f `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace Women = "`x'" in `i'
	qui replace N_Women = "`N'" in `i'
	
	local i = `i' + 1
}

*Traits (health conditions)
local i = 5
foreach var of varlist phe_asthma phe_breast_cancer phe_coronary_heart_disease phe_depression ///
	phe_eczema phe_migraine phe_osteoarthritis phe_type_2_diabetes {
		
	qui sum `var'
	local N = r(mean)*r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local percent = r(mean)*100
	local percent: dis %9.2f `percent'
	local percent = strtrim("`percent'")
	local x = "`N' (`percent')"
	qui replace All = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_All = "`N2'" in `i'
	
	qui sum `var' if sex == 1
	local N = r(mean)*r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local percent = r(mean)*100
	local percent: dis %9.2f `percent'
	local percent = strtrim("`percent'")
	local x = "`N' (`percent')"
	qui replace Men = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Men = "`N2'" in `i'

	qui sum `var' if sex == 0
	local N = r(mean)*r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local percent = r(mean)*100
	local percent: dis %9.2f `percent'
	local percent = strtrim("`percent'")
	local x = "`N' (`percent')"
	qui replace Women = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Women = "`N2'" in `i'
		
	local i = `i'+1
}

*Risks
*Continuous
local i = 15
foreach var of varlist phe_alcohol_intake phe_body_mass_index phe_cholesterol {
	qui sum `var'
	local mean = r(mean)
	local mean: dis %9.1f `mean'
	local mean = strtrim("`mean'")
	local sd = r(sd)
	local sd: dis %9.2f `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace All = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_All = "`N2'" in `i'
	
	qui sum `var' if sex == 1
	local mean = r(mean)
	local mean: dis %9.1f `mean'
	local mean = strtrim("`mean'")
	local sd = r(sd)
	local sd: dis %9.2f `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace Men = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Men = "`N2'" in `i'

	qui sum `var' if sex == 0
	local mean = r(mean)
	local mean: dis %9.1f `mean'
	local mean = strtrim("`mean'")
	local sd = r(sd)
	local sd: dis %9.2f `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace Women = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Women = "`N2'" in `i'
	
	local i = `i' + 1
}

*Binary
foreach var of varlist phe_smoking_initiation {
	qui sum `var'
	local N = r(mean)*r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local percent = r(mean)*100
	local percent: dis %9.2f `percent'
	local percent = strtrim("`percent'")
	local x = "`N' (`percent')"
	qui replace All = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_All = "`N2'" in `i'
	
	qui sum `var' if sex == 1
	local N = r(mean)*r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local percent = r(mean)*100
	local percent: dis %9.2f `percent'
	local percent = strtrim("`percent'")
	local x = "`N' (`percent')"
	qui replace Men = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Men = "`N2'" in `i'

	qui sum `var' if sex == 0
	local N = r(mean)*r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local percent = r(mean)*100
	local percent: dis %9.2f `percent'
	local percent = strtrim("`percent'")
	local x = "`N' (`percent')"
	qui replace Women = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Women = "`N2'" in `i'
	
	local i = `i'+1
}

*Continuous
foreach var of varlist phe_lifetime_smoking phe_systolic_bp   {
	qui sum `var'
	local mean = r(mean)
	local mean: dis %9.1f `mean'
	local mean = strtrim("`mean'")
	local sd = r(sd)
	local sd: dis %9.2f `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace All = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_All = "`N2'" in `i'
	
	qui sum `var' if sex == 1
	local mean = r(mean)
	local mean: dis %9.1f `mean'
	local mean = strtrim("`mean'")
	local sd = r(sd)
	local sd: dis %9.2f `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace Men = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Men = "`N2'" in `i'

	qui sum `var' if sex == 0
	local mean = r(mean)
	local mean: dis %9.1f `mean'
	local mean = strtrim("`mean'")
	local sd = r(sd)
	local sd: dis %9.2f `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace Women = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Women = "`N2'" in `i'
	
	local i = `i' + 1
}

*Outcomes
local i = 24

*Household Income
foreach var of varlist eco_household_income {
	qui sum `var'
	local mean = r(mean)
	local mean: dis %9.0fc `mean'
	local mean = strtrim("`mean'")
	local mean = "£`mean'"
	local sd = r(sd)
	local sd: dis %9.2fc `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace All = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_All = "`N2'" in `i'
	
	qui sum `var' if sex == 1
	local mean = r(mean)
	local mean: dis %9.0fc `mean'
	local mean = strtrim("`mean'")
	local mean = "£`mean'"
	local sd = r(sd)
	local sd: dis %9.2fc `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace Men = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Men = "`N2'" in `i'

	qui sum `var' if sex == 0
	local mean = r(mean)
	local mean: dis %9.0fc `mean'
	local mean = strtrim("`mean'")
	local mean = "£`mean'"
	local sd = r(sd)
	local sd: dis %9.2fc `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace Women = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Women = "`N2'" in `i'
	
	local i = `i' + 1
}		

*Household Income categories
foreach var of varlist eco_household_income {
	foreach k in 15000 24500 41500 76000 150000 {
		qui sum `var'
		local N_tot = r(N)
		qui sum `var' if `var' == `k'
		local N = r(N)
		local N: dis %9.0fc `N'
		local N = strtrim("`N'")
		local percent = r(N)*100/`N_tot'
		local percent: dis %9.2f `percent'
		local percent = strtrim("`percent'")
		local x = "`N' (`percent')"
		qui replace All = "`x'" in `i'
		
		local N2 = r(N)
		local N2: dis %9.0fc `N2'
		local N2 = strtrim("`N2'")
		qui replace N_All = "`N2'" in `i'
		
		qui sum `var' if sex == 1
		local N_tot = r(N)
		qui sum `var' if `var' == `k' & sex == 1
		local N = r(N)
		local N: dis %9.0fc `N'
		local N = strtrim("`N'")
		local percent = r(N)*100/`N_tot'
		local percent: dis %9.2f `percent'
		local percent = strtrim("`percent'")
		local x = "`N' (`percent')"
		qui replace Men = "`x'" in `i'
		
		local N2 = r(N)
		local N2: dis %9.0fc `N2'
		local N2 = strtrim("`N2'")
		qui replace N_Men = "`N2'" in `i'

		qui sum `var' if sex == 0
		local N_tot = r(N)
		qui sum `var' if `var' == `k' & sex == 0
		local N = r(N)
		local N: dis %9.0fc `N'
		local N = strtrim("`N'")
		local percent = r(N)*100/`N_tot'
		local percent: dis %9.2f `percent'
		local percent = strtrim("`percent'")
		local x = "`N' (`percent')"
		qui replace Women = "`x'" in `i'
		
		local N2 = r(N)
		local N2: dis %9.0fc `N2'
		local N2 = strtrim("`N2'")
		qui replace N_Women = "`N2'" in `i'
		
		local i = `i'+1
	}
}
*TDI
foreach var of varlist eco_tdi {
	qui sum `var'
	local mean = r(mean)
	local mean: dis %9.1f `mean'
	local mean = strtrim("`mean'")
	local sd = r(sd)
	local sd: dis %9.2f `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace All = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_All = "`N2'" in `i'
	
	qui sum `var' if sex == 1
	local mean = r(mean)
	local mean: dis %9.1f `mean'
	local mean = strtrim("`mean'")
	local sd = r(sd)
	local sd: dis %9.2f `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace Men = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Men = "`N2'" in `i'

	qui sum `var' if sex == 0
	local mean = r(mean)
	local mean: dis %9.1f `mean'
	local mean = strtrim("`mean'")
	local sd = r(sd)
	local sd: dis %9.2f `sd'
	local sd = strtrim("`sd'")
	local x = "`mean' (`sd')"
	qui replace Women = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Women = "`N2'" in `i'
	
	local i = `i' + 1
}	

*Employment to own/rent
foreach var of varlist eco_working_or_retired eco_working eco_retired eco_skilled eco_degree eco_own {
	qui sum `var'
	local N = r(mean)*r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local percent = r(mean)*100
	local percent: dis %9.2f `percent'
	local percent = strtrim("`percent'")
	local x = "`N' (`percent')"
	qui replace All = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_All = "`N2'" in `i'
	
	qui sum `var' if sex == 1
	local N = r(mean)*r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local percent = r(mean)*100
	local percent: dis %9.2f `percent'
	local percent = strtrim("`percent'")
	local x = "`N' (`percent')"
	qui replace Men = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Men = "`N2'" in `i'

	qui sum `var' if sex == 0
	local N = r(mean)*r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local percent = r(mean)*100
	local percent: dis %9.2f `percent'
	local percent = strtrim("`percent'")
	local x = "`N' (`percent')"
	qui replace Women = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Women = "`N2'" in `i'
		
	local i = `i'+1
}

*Social
local i = 39
foreach var of varlist soc_confide soc_friend_visits soc_cohabitation soc_leisure soc_loneliness ///
	soc_happiness soc_family_satisfaction soc_financial_satisfaction soc_friendship_satisfaction /// 
	soc_health_satisfaction soc_work_satisfaction {
	qui sum `var'
	local N = r(mean)*r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local percent = r(mean)*100
	local percent: dis %9.2f `percent'
	local percent = strtrim("`percent'")
	local x = "`N' (`percent')"
	qui replace All = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_All = "`N2'" in `i'
	
	qui sum `var' if sex == 1
	local N = r(mean)*r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local percent = r(mean)*100
	local percent: dis %9.2f `percent'
	local percent = strtrim("`percent'")
	local x = "`N' (`percent')"
	qui replace Men = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Men = "`N2'" in `i'

	qui sum `var' if sex == 0
	local N = r(mean)*r(N)
	local N: dis %9.0fc `N'
	local N = strtrim("`N'")
	local percent = r(mean)*100
	local percent: dis %9.2f `percent'
	local percent = strtrim("`percent'")
	local x = "`N' (`percent')"
	qui replace Women = "`x'" in `i'
	
	local N2 = r(N)
	local N2: dis %9.0fc `N2'
	local N2 = strtrim("`N2'")
	qui replace N_Women = "`N2'" in `i'
		
	local i = `i'+1
}

keep Var-N_Women
keep in 1/49

save "$cd_tables\Table 1.dta", replace
}

*Supplementary table 7 - all main analysis results &
*Supplementary table 11 - secondary analyses results
{
use "$cd_tables\Results table.dta", clear
replace exposure = "Body Mass Index (5 kg/m2)" if exposure == "Body Mass Index (5 kg/m{superscript:2})"
sort exposure outcome_type outcome type
replace type = "Main Analysis MR" if type == "IV reg"

rename exposure Exposure
rename outcome Outcome
rename type Type
rename beta_all Beta
rename se_all SE
rename p_all P
rename p_endog_all P_Endog
rename f_stat_all F_Stat
rename n_all N

*Supplementary table 7 - all main analysis results
preserve
drop if outcome_type == "Sensitivity"
keep Exposure-F_Stat
save "$cd_tables\Supplementary Table 7 - Results.dta", replace
restore

*Supplementary table 11 - secondary analyses results
preserve
drop Beta-P_En exposure_type outcome_type
order p_sex, a(p_endog_male)
drop if Type == "Multivariable Adjusted"
drop Type F_Stat f_stat* N
replace Outcome = subinstr(Outcome, "[65]", "[65+ years excluded]",.)
save "$cd_tables\Supplementary Table 11 - Secondary Results.dta", replace
restore

*Supplementary table 12 - sensitivity analysis results
use "$cd_tables\Results table.dta", clear
replace exposure = "Body Mass Index (5 kg/m2)" if exposure == "Body Mass Index (5 kg/m{superscript:2})"
sort exposure outcome_type outcome type
replace type = "Sensitivity Analysis MR" if type == "IV reg"

keep if outcome_type == "Sensitivity"
keep exposure - f_stat_all

rename n_all n
rename beta_all beta
rename se_all se
rename p_all p
rename p_endog_all p_endog
rename f_stat_all f_stat

append using "$cd_tables\rs1051730 analysis.dta" 
replace type = "Sensitivity Analysis MR" if type == "MR Analysis"
drop outcome_type
order group, a(outcome)
replace group = "All" if group == ""
replace outcome = subinstr(outcome, "[65]", "[65+ years excluded]",.)

rename exposure Exposure
rename outcome Outcome
rename type Type
rename beta Beta
rename se SE
rename p P
rename p_endog P_Endog
rename f_stat F_Stat
rename n N
rename group Group

save "$cd_tables\Supplementary Table 12 - Sensitivity Results.dta", replace

}

*Supplementary table 8 - Summary MR results
{
use "$cd_tables\MR results.dta", clear
rename exposure Exposure
rename outcome Outcome
rename snps SNPs
drop outcome_type
order heterogeneity_p, a(SNPs)

replace Outcome = subinstr(Outcome, "[65]", "[65+ years excluded]",.)

save "$cd_tables\Supplementary Table 8 - Summary MR Results.dta", replace

}

*Supplementary table 9 - Split-sample results
{
use "$cd_tables\SS Results table - metan.dta", clear
drop _LCI-_WT
replace type = "Split-Sample MR" if type == "IV reg"
replace exposure = "Body Mass Index (5 kg/m2)" if exposure == "Body Mass Index (5 kg/m{superscript:2})"
sort exposure outcome type
drop p
gen double p = 2*normal(-abs(beta/se)), a(se)

rename exposure Exposure
rename outcome Outcome
rename type Type
rename beta Beta
rename se SE
rename p P
rename p_endog P_Endog
rename f_stat F_Stat
rename n N
order N, a(Type)

drop exposure_type outcome_type P_Endog F_Stat

replace Outcome = subinstr(Outcome, "[65]", "[65+ years excluded]",.)

save "$cd_tables\Supplementary Table 9 - Split Results.dta", replace

}

*Table 2: Results (sig)
{
*Main analysis
use "$cd_tables\Supplementary Table 7 - Results.dta", clear
gen analysis = 1

*Add in split sample analysis
append using "$cd_tables\Supplementary Table 9 - Split Results.dta"
drop if Type == "Multivariable Adjusted" & analysis == .
drop analysis

qui replace Exposure = "Lifetime Smoking (SD)" if Exposure == "Lifetime Smoking (SD increase)"

drop if Outcome == "Household Income (Equivalised)" | Outcome == "Household Income Equi" | Outcome == "Household Income (retired excluded)" | strpos(Outcome,"(binary)") > 0 | strpos(Outcome,"[65+") > 0

gen x = 1
replace x = 2 if Type == "Multivariable Adjusted"	
	
sort Exposure Outcome x Type
drop x

gen y = P if Type == "Main Analysis MR" | Type == "Split-Sample MR"

bysort Exposure Outcome: egen x = min(y)
qui levelsof Outcome
local outcomes = r(r)
keep if x < 0.05/`outcomes'
drop x y

drop F_Stat

gen l95 = Beta-1.96*SE, a(Beta)
gen u95 = Beta+1.96*SE, a(l95)
drop SE

*Add in blank rows for depression & lifetime smoking for split sample (since they don't have split sample results)
qui count if Exposure == "Depression" | Exposure == "Lifetime Smoking (SD)"
local count = r(N)
local n = c(N) + 1
local obs = c(N) + (`count')/2 
set obs `obs'

qui levelsof Outcome if Exposure == "Depression", local(list)

foreach out in `list' {
	qui replace Exposure = "Depression" in `n'
	qui replace Type = "Split-Sample MR" in `n'
	qui replace Outcome = "`out'" in `n'
	local n = `n' + 1
}

qui levelsof Outcome if Exposure == "Lifetime Smoking (SD)", local(list)

foreach out in `list' {
	qui replace Exposure = "Lifetime Smoking (SD)" in `n'
	qui replace Type = "Main Analysis MR" in `n'
	qui replace Outcome = "`out'" in `n'
	local n = `n' + 1
}

gen x = 1
replace x = 2 if Type == "Multivariable Adjusted"	
	
sort Exposure Outcome x Type
drop x

gen beta1 = ""
gen p1 = .
gen beta2 = ""
gen p2 = .
gen beta3 = ""
gen p3 = .

local max = c(N)/3
forvalues i = 1/`max' {
	forvalues j = 1/3 {
		local j`j' = (`i'-1)*3+`j'
		local beta`j' = Beta[`j`j'']
		local l95`j' = l95[`j`j'']
		local u95`j' = u95[`j`j'']
		if Outcome[`j`j''] == "Household Income" {
			local beta`j': di %4.0fc `beta`j''
			local beta`j' = "£`beta`j''"
			local l95`j': di %4.0fc `l95`j''
			local l95`j' = "£`l95`j''"
			local u95`j': di %4.0fc `u95`j''
			local u95`j' = "£`u95`j''"
		}
		else if Outcome[`j`j''] == "TDI at Recruitment" {
			local beta`j': di %3.2f `beta`j''
			local beta`j' = "`beta`j''"
			local l95`j': di %3.2f `l95`j''
			local l95`j' = "`l95`j''"
			local u95`j': di %3.2f `u95`j''
			local u95`j' = "`u95`j''"
		}
		else {
			local beta`j' = `beta`j''*100
			local beta`j': di %3.1f `beta`j''
			local beta`j' = "`beta`j''%"
			local l95`j' = `l95`j''*100
			local l95`j': di %3.1f `l95`j''
			local l95`j' = "`l95`j''%"
			local u95`j' = `u95`j''*100
			local u95`j': di %3.1f `u95`j''
			local u95`j' = "`u95`j''%"
		}
		local beta`j' = "`beta`j'' (`l95`j'' to `u95`j'')"
		qui replace beta`j' = "`beta`j''" in `j1'
		qui replace p`j' = P[`j`j''] in `j1'
		
		qui replace beta`j' = "" if p`j' == .
	}
}

*N needs filling-in, as only the main-analysis is kept
*Just fill in with the row beneath, they are all the same (and Multivariable adjusted is fully observed)
qui replace N = N[_n+1] if N == .

keep if beta3 != ""
drop Type
drop Beta-P
order P_Endog, last

save "$cd_tables\Table 2 - Results (sig).dta", replace

}

*Supplementary table 1: Prevalence of conditions in UK Biobank
*Partial table
{
use "all_8_clean.dta", clear

gen men = ""
gen women = ""
gen Var = ""

replace v16 = . if v42 == 1

local i = 1
foreach var of varlist v* {
	qui sum `var' if n_31_ == 1
	if r(mean)*100 < 10 {
		local men = r(mean)*100
		local men: dis %2.1f `men'
	}
	else {
		local men = r(mean)*100
		local men: dis %3.1f `men'
	}
	local N = r(N)*r(mean)
	local N: dis %9.0fc `N'
	local men = "`N' (`men')"
	qui replace men = "`men'" in `i'
	
	qui sum `var' if n_31_ == 0
	if r(mean)*100 < 10 {
		local women = r(mean)*100
		local women: dis %2.1f `women'
	}
	else {
		local women = r(mean)*100
		local women: dis %3.1f `women'
	}
	local N = r(N)*r(mean)
	local N: dis %9.0fc `N'
	local women = "`N' (`women')"
	qui replace women = "`women'" in `i'
		
	qui replace Var = "`var'" in `i'
	local i = `i'+1
}


replace Var = "CHD" if Var == "v1"
replace Var = "Lung Cancer" if Var == "v2"
replace Var = "Depression" if Var == "v3"
replace Var = "Depression" if Var == "v4"
replace Var = "Ischaemic Stroke" if Var == "v5"
replace Var = "Dementia" if Var == "v6"
replace Var = "Drug Dependence" if Var == "v7"
replace Var = "Anxiety" if Var == "v8"
replace Var = "Colon Cancer" if Var == "v9"
replace Var = "Asthma" if Var == "v10"
replace Var = "Breast Cancer" if Var == "v11"
replace Var = "Migraine" if Var == "v12"
replace Var = "Haemorrhagic Stroke" if Var == "v13"
replace Var = "Alcohol Use" if Var == "v14"
replace Var = "Osteoarthritis" if Var == "v15"
replace Var = "Type 2 Diabetes" if Var == "v16"
replace Var = "Opiod Use" if Var == "v17"
replace Var = "Prostate Cancer" if Var == "v18"
replace Var = "Schizophrenia" if Var == "v19"
replace Var = "Chronic Kidney Disease" if Var == "v20"
replace Var = "Pancreatic Cancer" if Var == "v21"
replace Var = "Oesophageal Cancer" if Var == "v22"
replace Var = "Bipolar Disorder" if Var == "v23"
replace Var = "Rheumatoid Arthritis" if Var == "v24"
replace Var = "Non-Hodkin Lymphoma" if Var == "v25"
replace Var = "Dysthymia" if Var == "v26"
replace Var = "Abdominal Aortic Aneurysm" if Var == "v27"
replace Var = "Brain & Nervous System Cancer" if Var == "v28"
replace Var = "Haemoglobinopathies & Haemolytic Anaemias" if Var == "v29"
replace Var = "Leukaemia" if Var == "v30"
replace Var = "Epilepsy" if Var == "v31"
replace Var = "Stomach Cancer" if Var == "v32"
replace Var = "Ovarian Cancer" if Var == "v33"
replace Var = "Kidney Cancer" if Var == "v34"
replace Var = "Eczema" if Var == "v35"
replace Var = "Parkinson's Disease" if Var == "v36"
replace Var = "Bladder Cancer" if Var == "v37"
replace Var = "Sickle Cell" if Var == "v38"
replace Var = "Type 2 Diabetes (old)" if Var == "v39"
replace Var = "Alzheimer's Disease" if Var == "v40"
replace Var = "Stroke" if Var == "v41"
replace Var = "Type 1 Diabetes" if Var == "v42"
replace Var = "Depression (Tyrell)" if Var == "v43"
replace Var = "Depression (Tyrell, pilot removed)" if Var == "v44"

*Depression is now at v43 (Depression [Tyrell]), so recode depression v3 and v4
foreach var in women men {
	qui replace `var' = `var'[43] in 3
	qui replace `var' = `var'[43] in 4
}

keep women men Var
drop if women == ""

*drop v4, v39 - v43
drop in 39/44
drop in 4

save "$cd_tables\Supplementary Table 1 - prevalences.dta", replace
}

*Supplementary table 2: PRS
{
import delim "$cd_tables\Table 2 (R).csv", clear delim(",") case(preserve)
save "$cd_tables\Table 2 (R).dta", replace

import delim "$cd_prs_data\exposure_dat_harmonised_8.csv", delim(",") clear
drop if included == 0
keep trait samplesize-ncontrol idexposure data_source
bysort trait: egen Number_of_SNPs = count(trait)

*Sample size varies by SNP, which is unfortunate
*Replace with the biggest?
replace sample = "" if sample == "NA"
destring sample, replace
bysort idexposure: egen x = max(sample)
replace sample = x
drop x

duplicates drop idexposure samplesize Number, force

replace trait = proper(trait)
replace trait = subinstr(trait,"_"," ",.)
replace data_source = "MR Base" if data_source == "mrbase"

rename idexposure GWAS_ID
rename data_source GWAS_Source
rename trait Exposure

order Exposure GWAS_ID GWAS_Source 

foreach var of varlist Exposure-GWAS_Source ncase-ncontrol {
	qui replace `var' = "" if `var' == "NA"
}

replace Exposure = "Breast Cancer" if Exposure == "Breast Carcinoma"
drop if Exposure == "Depressive Symptoms" //Non-Wray depression measure
replace Exposure = "Depression" if Exposure == "Major Depressive Disorder"
replace Exposure = "Migraine" if Exposure == "Migraine Disorder"

*Merge to get R2
merge 1:1 Exposure using "$cd_tables\R2 table.dta", nogen 

rename r2 R2

*Fill in Author-Pubmed Link
merge 1:1 GWAS_ID using "$cd_tables\Table 2 (R).dta", nogen
drop if Exposure == ""
order Exposure Number GWAS_ID GWAS_Sour Author Conso Year Pub

replace Consortium = "BGAC & DRIVE" if Exposure == "Breast Cancer"
replace Consortium = "IHGC" if Exposure == "Migraine"
replace Consortium = "TreatOA" if Exposure == "Osteoarthritis"
replace Consortium = "GSCAN" if Exposure == "Ever Smoked" | Exposure == "Former Smoker" | Exposure == "Alcohol Intake"

replace GWAS_ID = "" if GWAS_Source == "GSCAN (excl. UK Biobank & 23andMe)"

foreach var of varlist ncase ncon {
	destring `var', replace
}

rename sample Sample_Size
rename ncase N_Cases
rename ncontrol N_Controls

sort Exposure

replace N_Cases = . if Exposure == "Systolic Bp"
replace N_Controls = . if Exposure == "Systolic Bp"

save "$cd_tables\Supplementary Table 2 - PRS.dta", replace

}

*Supplementary table 3: SNPs
{

import delim "$cd_prs_data\exposure_dat_harmonised_8.csv", delim(",") clear
drop x1 x exposure pval_ori mr_keepexposure clumped priority clump_num samplesize-ncontrol
drop if included == 0
drop included
capture drop unitsexposure_dat

sort trait snp
replace trait = proper(trait)
replace trait = subinstr(trait,"_"," ",.)
replace trait = "Systolic BP" if trait == "Blood Pressure"
replace data_source = "MR Base" if data_source == "mrbase"

rename snp SNP
rename idexposure GWAS_ID
rename effect_alleleex Effect_Allele
rename other_alleleex Other_Allele
rename eafex EAF
rename beta Beta
rename see SE
rename pval P
rename units Units
rename data_source GWAS_Source
rename trait Exposure

order Exposure GWAS_ID GWAS_Source SNP Effect_Allele Other_Allele EAF Beta SE P Units 

foreach var of varlist Effect_ Other EAF Units {
	qui replace `var' = "" if `var' == "NA"
}

destring EAF, replace
format EAF %3.2f
format Beta %4.3f

drop if Exposure == "Depressive Symptoms"
replace Exposure = "Depression" if Exposure == "Major Depressive Disorder"
sort Exposure SNP

replace GWAS_ID = "" if GWAS_Source == "GSCAN (excl. UK Biobank & 23andMe)"

drop P
gen double P = 2*normal(-abs(Beta/SE)),a(SE)

replace Units = "1 drink" if Exposure == "Alcohol Intake"
replace Units = "SD (kg/m2)" if Units == "SD (kg/m^2)"
replace Units = "log odds" if Exposure == "Depression" | Units == "" | Exposure == "Breast Carcinoma"

save "$cd_tables\Supplementary Table 3 - SNPs.dta", replace

}

*Supplementary table 5: PRS (split sample)
{
*Sample size, cases, controls
use "ss_analysis.dta", clear
keep phe*
gen exposure = ""
gen Sample_size = .
gen N_Cases = .
gen N_Controls = .
local i = 1
foreach var of varlist _all {
	if strpos("`var'","phe") >0 {
		local exp = proper(subinstr(substr("`var'",5,.),"_"," ",.))
		qui replace exposure = "`exp'" in `i'
		qui count if `var' != .
		qui replace Sample = r(N) in `i'
		qui count if `var' == 0
		if r(N) != 0 {
			qui replace N_Controls = r(N) in `i'
			qui replace N_Cases = Sample[`i']-N_Controls[`i'] in `i'
		}
		local i = `i'+1
	}
}

foreach var of varlist N_Cases N_Con {
	qui replace `var' = . if exposure == "Alcohol Intake 1" | exposure == "Alcohol Intake 2" | exposure == "Lifetime Smoking 1" | exposure == "Lifetime Smoking 2"
}

keep exposure-N_Controls
drop if exposure == ""
replace exposure = proper(exposure)
replace exposure = subinstr(exposure,"c Bp ","c BP ",.)
replace exposure = subinstr(exposure,"Sample ","",.)
replace exposure = subinstr(exposure,"Bmi","Body Mass Index",.)

sort exposure

replace exposure = subinstr(exposure," (5 Kg/M2)","",.)
replace exposure = subinstr(exposure," (5 Units/Week)","",.)
replace exposure = subinstr(exposure," (1Mmol/L)","",.)
replace exposure = subinstr(exposure," (10 Mmhg)","",.)

save "$cd_tables\Supplementary Table 5 (Ns).dta", replace 

*Main table
use "$cd_tables\ss_MR results.dta", clear
replace exp = "Alcohol Intake 1" if exp == "Alcohol Intake"
keep exp genotypes
rename exp exposure
rename genotypes SNPs
duplicates drop exposure, force
replace exposure = proper(exposure)
replace exposure = subinstr(exposure,"c Bp","c BP",.)

replace exposure = subinstr(exposure," (5 Kg/M2)","",.)
replace exposure = subinstr(exposure," (5 Units/Week)","",.)
replace exposure = subinstr(exposure," (1Mmol/L)","",.)
replace exposure = subinstr(exposure," (10 Mmhg)","",.)

*Add in R2
merge 1:1 exposure using "$cd_tables\ss_R2 table.dta", nogen

*Add in Ns
merge 1:1 exposure using "$cd_tables\Supplementary Table 5 (Ns).dta"
drop if _merge == 2
drop _merge
order r2, last

gen sample = 1, a(exposure)
replace exposure = subinstr(exposure," 1","",.)
replace sample = 2 if strpos(exposure,"2")>0
replace exposure = subinstr(exposure," 2","",.)

replace exposure = "Type 2 Diabetes" if exposure == "Type Diabetes"

rename exposure Exposure

*Add in SNPs for osteoarthritis, sample 2, since it was <3
qui replace SNPs = 1 if Exposure == "Osteoarthritis" & sample == 2

save "$cd_tables\Supplementary Table 5 - SS PRS.dta", replace

}

*Supplementary table 6: SNPs (Split sample)
{

import delim "Split sample\Results\Results\exposure_dat_harmonised_ss.csv", delim(",") clear
drop x1 x exposure pval_ori mr_keepexposure clumped priority clump_num samplesize-ncontrol
drop if included == 0
drop included

sort trait snp
replace trait = subinstr(trait,"Type_2_d","Type_II_d",.)
replace trait = subinstr(trait,"1_","1",.)
replace trait = subinstr(trait,"2_","2",.)
replace trait = proper(trait)
replace trait = subinstr(trait,"_"," ",.)
replace trait = subinstr(trait,"Sig ","",.)
replace data_source = "MR Base" if data_source == "mrbase"

rename snp SNP
rename idexposure GWAS_ID
rename effect_alleleex Effect_Allele
rename other_alleleex Other_Allele
rename eafex EAF
rename beta Beta
rename see SE
rename pval P
rename units Units
rename data_source GWAS_Source
rename trait Exposure

order Exposure GWAS_ID GWAS_Source SNP Effect_Allele-Units 
order SE, b(P)

*Regenerate P as a double
drop P
gen double P = 2*normal(-abs(Beta/SE)),a(SE)

foreach var of varlist Effect_ Other Units {
	qui replace `var' = "" if `var' == "NA"
}

format EAF %3.2f
format Beta %4.3f

drop GWAS_Source GWAS_ID

replace Exposure = subinstr(Exposure,"c Bp ","c BP ",.)
replace Exposure = subinstr(Exposure,"Bmi","Body Mass Index",.)

gen sample = 1, a(Exposure)
replace Exposure = subinstr(Exposure," 1","",.)
replace sample = 2 if strpos(Exposure,"2")>0
replace Exposure = subinstr(Exposure," 2","",.)

replace Exposure = subinstr(Exposure,"Type Ii","Type 2",.)

sort Exposure sample SNP

replace Units = "Absolute risk difference"
replace Units = "Units of alcohol" if Exposure == "Alcohol Intake"
replace Units = "kg/m2" if Exposure == "Body Mass Index"
replace Units = "mmHg" if Exposure == "Systolic BP"
replace Units = "mmol/l" if Exposure == "Cholesterol"

save "$cd_tables\Supplementary Table 6 - SS SNPs.dta", replace

}

*Supplementary table 10: Summary MR results (Split sample)
{
use "$cd_tables\ss_MR results.dta", clear

*Need to meta-analyse, so will have 3 samples (1, 2, combined)
*Just meta-analyse IVW

rename exp exposure
rename out outcome

*Create a sample variable
gen sample = substr(exposure,-1,1), a(outcome)

*Need to meta-analyse across the 2 samples, should be simple
qui levelsof exposure, local(exposure)
qui levelsof outcome, local(outcome)
local N = r(N)
local N2 = `N'*2
set obs `N2'

local k = `N'+1

local i = `N'+1
foreach exp in `exposure' {
	*Only do things for the first sample 
	if substr("`exp'",-1,1) == "1" {
		local length = length("`exp'")-2
		local e1 = "`exp'"
		local e2 = substr("`exp'",1,`length')
		local e2 = "`e2' 2"
		local ex = substr("`exp'",1,`length')
		
		dis "trait = `ex'"
		
		qui replace exposure = "`ex'" if exposure == "`e1'" | exposure == "`e2'"
		
		foreach out in `outcome' {
			qui replace exposure = "`ex'" in `i'
			qui replace outcome = "`out'" in `i'
			qui replace sample = "Combined" in `i'
			qui metan ivw ivw_se if exposure == "`ex'" & outcome == "`out'", nograph
			qui replace ivw = r(ES) in `i'
			qui replace ivw_se = r(seES) in `i'
			
			local i = `i' + 1
		}
	}
}

qui replace ivw_p = 2*normal(-abs(ivw/ivw_se)) if sample == "Combined"

replace outcome = "Cohabiting" if outcome == "Cohabitation"
replace outcome = "Able to Confide" if outcome == "Confide"
replace outcome = "University Education" if outcome == "Degree"
replace outcome = "Satisfied with Family Relationships" if outcome == "Family Satisfaction"
replace outcome = "Satisfied with Financial Situation" if outcome == "Financial Satisfaction"
replace outcome = "Weekly Friend Visits" if outcome == "Friend Visits"
replace outcome = "Satisfied with Friendships" if outcome == "Friendship Satisfaction"
replace outcome = "Satisfied with Health" if outcome == "Health Satisfaction"
replace outcome = "Happy" if outcome == "Happiness"
replace outcome = "Weekly Leisure or Social Activity" if outcome == "Leisure"
replace outcome = "Lonely" if outcome == "Loneliness"
replace outcome = "Own Accommodation Lived In" if outcome == "Own"
replace outcome = "Retired vs Employed (non-employed excluded)" if outcome == "Retired"
replace outcome = "Satisfied with Work" if outcome == "Work Satisfaction"
replace outcome = "Non-employed vs Employed (retired excluded)" if outcome == "Working"
replace outcome = "Non-employed vs Employed/Retired" if outcome == "Working Or Retired"
replace outcome = "TDI at Recruitment" if outcome == "Tdi"
replace outcome = "TDI at Recruitment (binary)" if outcome == "Tdi Bin"
replace outcome = "Household Income (binary)" if outcome == "Household Income Bin"
replace outcome = "Household Income (retired excluded)" if outcome == "Household Income Re"
replace outcome = "Household Income (equivalised)" if outcome == "Household Income Equi"

rename exposure Exposure
rename outcome Outcome
rename genotypes SNPs

replace Exposure = subinstr(Exposure,"c Bp ","c BP ",.)
replace Exposure = subinstr(Exposure,"Bmi","Body Mass Index",.)

sort Exposure sample Outcome
drop if Exposure == ""

drop _*

order heterogeneity_p, a(SNPs)

replace Outcome = subinstr(Outcome, "[65]", "[65+ years excluded]",.)

save "$cd_tables\Supplementary Table 10 - Summary MR Results (Split sample).dta", replace

}

*Supplementary table 13: Genetic correlations
{
use "all_8_analysis.dta", clear
keep id_phe grs*

merge 1:1 id_phe using "ss_analysis.dta"
keep grs*

gen trait = "Asthma" in 1
replace trait = "Breast Cancer" in 2
replace trait = "Coronary Heart Disease" in 3
replace trait = "Depression" in 4
replace trait = "Eczema" in 5
replace trait = "Migraine" in 6
replace trait = "Osteoarthritis" in 7
replace trait = "Type 2 Diabetes" in 8
replace trait = "Alcohol Intake" in 9
replace trait = "Body Mass Index" in 10
replace trait = "Cholesterol" in 11
replace trait = "Lifetime Smoking" in 12
replace trait = "Smoking Initiation" in 13
replace trait = "Systolic BP" in 14

replace trait = "Asthma" in 16
replace trait = "Breast Cancer" in 17
replace trait = "Coronary Heart Disease" in 18
replace trait = "Depression" in 19
replace trait = "Eczema" in 20
replace trait = "Migraine" in 21
replace trait = "Osteoarthritis" in 22
replace trait = "Type 2 Diabetes" in 23
replace trait = "Alcohol Intake" in 24
replace trait = "Body Mass Index" in 25
replace trait = "Cholesterol" in 26
replace trait = "Lifetime Smoking" in 27
replace trait = "Smoking Initiation" in 28
replace trait = "Systolic BP" in 29

replace trait = "Asthma" in 31
replace trait = "Breast Cancer" in 32
replace trait = "Coronary Heart Disease" in 33
replace trait = "Depression" in 34
replace trait = "Eczema" in 35
replace trait = "Migraine" in 36
replace trait = "Osteoarthritis" in 37
replace trait = "Type 2 Diabetes" in 38
replace trait = "Alcohol Intake" in 39
replace trait = "Body Mass Index" in 40
replace trait = "Cholesterol" in 41
replace trait = "Lifetime Smoking" in 42
replace trait = "Smoking Initiation" in 43
replace trait = "Systolic BP" in 44

gen split = "All" in 1/14
replace split = "1" in 16/29
replace split = "2" in 31/44

gen n = .

forvalues i = 1/14 {
	gen v`i' = .
}

gen grs_lifetime_smoking = 0
gen grs_depression_1 = 0
gen grs_depression_2 = 0

corr grs_asthma grs_breast_cancer grs_coronary_heart_disease grs_depression grs_eczema grs_migraine grs_osteoarthritis grs_type_2_diabetes grs_alcohol_intake grs_body_mass_index grs_cholesterol grs_lifetime_smoking grs_smoking_initiation grs_systolic_bp
matrix a = r(C)
forvalues i = 1/14 {
	forvalues k = 1/14 {
		qui replace v`i' = a[`i',`k'] in `k'
	}
}

count if grs_asthma != .
qui replace n = r(N) in 1/14

corr grs_asthma_1 grs_breast_cancer_1 grs_coronary_heart_disease_1 grs_depression_1 grs_eczema_1 grs_migraine_1 grs_osteoarthritis_1 grs_type_2_diabetes_1 grs_alcohol_intake_1 grs_body_mass_index_1 grs_cholesterol_1 grs_lifetime_smoking_1 grs_smoking_initiation_1 grs_systolic_bp_1
matrix a = r(C)
forvalues i = 1/14 {
	forvalues k = 1/14 {
		local m = `k'+15
		qui replace v`i' = a[`i',`k'] in `m'
	}
}

count if grs_asthma_1 != .
qui replace n = r(N) in 16/29

corr grs_asthma_2 grs_breast_cancer_2 grs_coronary_heart_disease_2 grs_depression_2 grs_eczema_2 grs_migraine_2 grs_osteoarthritis_2 grs_type_2_diabetes_2 grs_alcohol_intake_2 grs_body_mass_index_2 grs_cholesterol_2 grs_lifetime_smoking_2 grs_smoking_initiation_2 grs_systolic_bp_2
matrix a = r(C)
forvalues i = 1/14 {
	forvalues k = 1/14 {
		local m = `k'+30
		qui replace v`i' = a[`i',`k'] in `m'
	}
}

count if grs_asthma_2 != .
qui replace n = r(N) in 31/44

keep trait-v14
keep in 1/44

drop in 15
drop in 29

forvalues i = 1/14 {
	gen v`i'_se = (1-v`i'^2)/sqrt(n)
}

set obs 56
forvalues i = 29/42 {
	local j = `i'+14
	qui replace trait = trait[`i'] in `j'
}
replace split = "Both splits" in 43/56
replace split = "Main analysis" in 1/14

replace n = 336997 in 43/56
levelsof(trait), local(traits)

foreach trait of local traits {
	forvalues i = 1/14 {
		capture qui metan v`i' v`i'_se if trait == "`trait'" & (split == "1" | split == "2"), nograph
		qui replace v`i' = r(ES) if trait == "`trait'" & split == "Both splits"
		qui su v`i' if trait == "`trait'" & (split == "1" | split == "2")
		if r(mean) == 1 {
			qui replace v`i' = 1 if trait == "`trait'" & split == "Both splits"
		}
	}
}

drop v1_se - _WT

save "$cd_tables\Supplementary Table 13 - Genetic Correlations.dta", replace

}

*Combine tables in Excel sheet
{
use "$cd_tables\Table 1.dta", clear
export excel "$cd_tables\Tables.xlsx", replace sheet("Table 1")

use "$cd_tables\Table 2 - Results (sig).dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table 2")

use "$cd_tables\Supplementary Table 1 - prevalences.dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table S1")

use "$cd_tables\Supplementary Table 2 - PRS.dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table S2")

use "$cd_tables\Supplementary Table 3 - SNPs.dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table S3")

use "$cd_tables\Supplementary Table 5 - SS PRS.dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table S5")

use "$cd_tables\Supplementary Table 6 - SS SNPs.dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table S6")

use "$cd_tables\Supplementary Table 7 - Results.dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table S7")

use "$cd_tables\Supplementary Table 8 - Summary MR Results.dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table S8")

use "$cd_tables\Supplementary Table 9 - Split Results.dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table S9")

use "$cd_tables\Supplementary Table 10 - Summary MR Results (Split sample).dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table S10")

use "$cd_tables\Supplementary Table 11 - Secondary Results.dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table S11")

use "$cd_tables\Supplementary Table 12 - Sensitivity Results.dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table S12")

use "$cd_tables\Supplementary Table 13 - Genetic Correlations.dta", clear
export excel "$cd_tables\Tables.xlsx", sheetreplace sheet("Table S13")
}

*Sig results for for differences in sex/dep at birth
{
use "$cd_tables\Results table.dta", clear
keep if type == "IV reg"  
keep p_sex-p_mid_high exposure outcome
egen x = rowmin(p*)
keep if x <= 0.01

foreach var of varlist p_sex-p_mid_high {
	qui replace `var' = . if `var' > 0.01
}

save "$cd_tables\Sex, dep sig.dta", replace
}

}

*Part IX
*Data for R graphs
{

*Heat maps of results
{

use "$cd_tables\Results table.dta", clear
replace outcome = "Deprivation at Recruitment" if outcome == "TDI at Recruitment"
replace outcome = "Deprivation at Recruitment (binary)" if outcome == "TDI at Recruitment (binary)"
keep if type == "IV reg"
drop type
drop se_all
rename beta_all beta
rename p_all p
sort exposure outcome

replace exposure = "BMI" if exposure == "Body Mass Index (5 kg/m{superscript:2})"
replace exposure = "CHD" if exposure == "Coronary Heart Disease"
replace exposure = "Cholesterol" if exposure == "Cholesterol (1 mmol/l)"
replace exposure = "Systolic BP" if exposure == "Systolic BP (10 mmHg)"
replace exposure = "Alcohol Intake" if exposure == "Alcohol Intake (5 units/week)"

gen p2 = -log10(p)
replace p2 = -p2 if beta < 0

*Star for significance
gen value = "*" if p < 0.0026

keep exposure outcome p2 outcome_type value

rename exposure Exposure
rename outcome Outcome

*Drop sensitivity analysis
drop if outcome_type == "Sensitivity"
replace outcome_type = "Social Contact and Wellbeing" if outcome_type == "Social"

export delim "$cd_tables\Main results P.csv", replace

*By sex and dep at birth

foreach k in female male low mid high {
	use "$cd_tables\Results table.dta", clear
	replace outcome = "Deprivation at Recruitment" if outcome == "TDI at Recruitment"
	replace outcome = "Deprivation at Recruitment (binary)" if outcome == "TDI at Recruitment (binary)"
	keep exposure outcome outcome_type type beta_`k'-p_`k'
	keep if type == "IV reg"
	drop type
	drop se
	sort exposure outcome

	replace exposure = "BMI" if exposure == "Body Mass Index (5 kg/m{superscript:2})"
	replace exposure = "CHD" if exposure == "Coronary Heart Disease"
	replace exposure = "Cholesterol" if exposure == "Cholesterol (1 mmol/l)"
	replace exposure = "Systolic BP" if exposure == "Systolic BP (10 mmHg)"
	replace exposure = "Alcohol Intake" if exposure == "Alcohol Intake (5 units/week)"
	
	gen p2 = -log10(p)
	replace p2 = -p2 if beta < 0
	
	*Star for significance
	gen value = "*" if p_`k' < 0.0026

	keep exposure outcome p2 outcome_type value
	
	rename exposure Exposure
	rename outcome Outcome
	
	*Drop sensitivity analysis
	drop if outcome_type == "Sensitivity" 
	replace outcome_type = "Social Contact and Wellbeing" if outcome_type == "Social"
	
	export delim "$cd_tables\Results P (`k').csv", replace
}

*Also for MR results
use "$cd_tables\MR results.dta", clear
replace outcome = "Deprivation at Recruitment" if outcome == "TDI at Recruitment"
replace outcome = "Deprivation at Recruitment (binary)" if outcome == "TDI at Recruitment (binary)"

sort exposure outcome

replace exposure = "BMI" if exposure == "Body Mass Index (5 kg/m2)"
replace exposure = "CHD" if exposure == "Coronary Heart Disease"
replace exposure = "Systolic BP" if exposure == "Systolic BP (10 mmHg)"
replace exposure = "Alcohol Intake" if exposure == "Alcohol Intake (5 units/week)"

gen p2 = -log10(ivw_p)
replace p2 = -p2 if ivw < 0

*Star for significance
gen value = "*" if ivw_p < 0.0026

keep exposure outcome p2 outcome_type value

rename exposure Exposure
rename outcome Outcome

drop if outcome_type == "Sensitivity" 
replace outcome_type = "Social Contact and Wellbeing" if outcome_type == "Social"

export delim "$cd_tables\MR results P.csv", replace

********************************************************************************

*Also for Split sample
use "$cd_tables\SS Results table - metan.dta", clear
replace outcome = "Deprivation at Recruitment" if outcome == "TDI at Recruitment"
replace outcome = "Deprivation at Recruitment (binary)" if outcome == "TDI at Recruitment (binary)"
keep exposure-p outcome_type
keep if type == "IV reg"
drop type
drop se
sort exposure outcome

*Drop sensitivity analysis (65+ removed)
drop if strpos(outcome,"65") > 0

replace exposure = "Alcohol" if exposure == "Alcohol Intake (5 units/week)"
replace exposure = "BMI" if exposure == "Body Mass Index (5 kg/m{superscript:2})"
replace exposure = "CHD" if exposure == "Coronary Heart Disease"
replace exposure = "Cholesterol" if exposure == "Cholesterol (1 mmol/l)"
replace exposure = "Lifetime Smoking" if exposure == "Lifetime Smoking (SD)"
replace exposure = "Systolic BP" if exposure == "Systolic BP (10 mmHg)"

gen p2 = -log10(p)
replace p2 = -p2 if beta < 0

*Star for significance
gen value = "*" if p < 0.0026

keep exposure outcome p2 outcome_type value

rename exposure Exposure
rename outcome Outcome

drop if outcome_type == "Sensitivity" 
replace outcome_type = "Social Contact and Wellbeing" if outcome_type == "Social"

export delim "$cd_tables\Split results P.csv", replace

}

********************************************************************************

*Summary MR analysis & plots in R (MR-Base)
{
*Main analysis
use "MR data.dta", clear
replace outcome = "Deprivation at Recruitment" if outcome == "TDI at Recruitment"
replace outcome = "Deprivation at Recruitment (binary)" if outcome == "TDI at Recruitment (binary)"

rename snp SNP
rename effect_allele effect_allele_outcome
rename eaf eaf_outcome
rename beta beta_outcome
rename se se_outcome
rename p pval_outcome
rename cases ncases_outcome
rename controls ncontrol_outcome
drop n_total

rename beta_exposure beta_exposure
rename se_exposure se_exposure

rename trait exposure

gen id_exposure = exposure

gen id_outcome = outcome

replace exposure = proper(subinstr(exposure,"_"," ",.))

export delim "$cd_graphs\mr_analysis.csv", replace delim(",")

********************************************************************************

*Split-sample
use "ss_MR data.dta", clear
replace outcome = "Deprivation at Recruitment" if outcome == "TDI at Recruitment"
replace outcome = "Deprivation at Recruitment (binary)" if outcome == "TDI at Recruitment (binary)"

rename snp SNP
rename effect_allele effect_allele_outcome
rename eaf eaf_outcome
rename beta beta_outcome
rename se se_outcome
rename p pval_outcome
rename cases ncases_outcome
rename controls ncontrol_outcome
drop n_total

rename beta_exposure beta_exposure
rename se_exposure se_exposure

rename trait exposure

gen id_exposure = exposure

gen id_outcome = outcome

replace exposure = proper(subinstr(exposure,"_"," ",.))

export delim "$cd_graphs\split_sample.csv", replace delim(",")
}


********************************************************************************

*Forest plots (in R)
{

*Main analysis
use "$cd_tables\Supplementary Table 7 - Results.dta", clear
append using "$cd_tables\Supplementary Table 12 - Sensitivity Results.dta"
replace Type = "Main Analysis MR" if Type == "Sensitivity Analysis MR"
drop if strpos(Exposure,"rs1051730") > 0
drop Group
gen analysis = 1

*Add in split sample analysis
append using "$cd_tables\Supplementary Table 9 - Split Results.dta"
drop if Type == "Multivariable Adjusted" & analysis == .
replace Type = "Main Analysis MR" if Type == "MR" & analysis == 1
replace Type = "Split-Sample MR" if Type == "MR" & analysis == .
drop analysis

drop if Outcome == "Household Income Equi" | Outcome == "Household Income (Equivalised)" | Outcome == "Household Income (retired excluded)" | strpos(Outcome,"[65]") > 0 | strpos(Outcome,"65+") > 0 
replace Outcome = "Deprivation at Recruitment" if Outcome == "TDI at Recruitment"
replace Outcome = "Deprivation at Recruitment (binary)" if Outcome == "TDI at Recruitment (binary)"

gen x = 1
replace x = 2 if Type == "Multivariable Adjusted"	
	
sort Exposure Outcome x Type
drop x

*Add in missing data with values of 0
qui levelsof Exposure, local(Exposure)
qui levelsof Outcome, local(Outcome)
qui levelsof Type, local(Type)

foreach e of local Exposure {
	foreach o of local Outcome {
		foreach t of local Type {
			qui count if Exposure == "`e'" & Outcome == "`o'" & Type == "`t'"
			if r(N) == 0 {
				local obs = c(N)+1
				set obs `obs'
				qui replace Exposure = "`e'" in `obs'
				qui replace Out = "`o'" in `obs'
				qui replace Type = "`t'" in `obs'
				qui replace Beta = . in `obs'
				qui replace SE = . in `obs'
				qui replace P = . in `obs'
			}
		}
	}
}			

gen x = 1 if Type == "Main Analysis"
replace x = 2 if Type == "Multivariable Adjusted"
replace x = 3 if Type == "Split-Sample"

foreach var of varlist _all {
	local x = lower("`var'")
	rename `var' `x'
}

gen outcome_type = "Socioeconomic" if outcome == "Non-employed vs Employed (retired excluded)" | outcome == "Non-employed vs Employed/Retired" | outcome == "Retired vs Employed (non-employed excluded)" | ///
	outcome == "Own Accommodation Lived In" | outcome == "Skilled Job" | outcome == "University Education" | outcome == "Deprivation at Recruitment" | outcome == "Household Income" 
replace outcome_type = "Sensitivity" if strpos(outcome,"[65]") > 0 | outcome == "Household Income (Equivalised)" | outcome == "Household Income (retired excluded)" | strpos(outcome,"binary") > 0
replace outcome_type = "Social Contact and Wellbeing" if outcome_type == ""

replace outcome_type = "cont" if outcome == "Household Income" | outcome == "Deprivation at Recruitment" | outcome == "Household Income (retired excluded)" | outcome == "Household Income (Equivalised)"

gen exposure_type = "Risk Factor" if exposure == "Alcohol Intake (5 units/week)" | exposure == "Body Mass Index (5 kg/m2)" | ///
	exposure == "Smoking Initiation" | exposure == "Lifetime Smoking (SD)" | exposure == "Systolic BP (10 mmHg)" | exposure == "Cholesterol (1 mmol/l)"
replace exposure_type = "Health Condition" if exposure_type == ""

sort exposure_type outcome_type exposure outcome x
drop x

*Change to percentages
replace beta = 100*beta if outcome_type != "cont"
replace se = 100*se if outcome_type != "cont"

*Change Household Income to be in '000s
foreach var of varlist beta se {
	replace `var' = `var'/1000 if outcome == "Household Income" | outcome == "Household Income (retired excluded)" | outcome == "Household Income (Equivalised)"
}

gen lower = beta-1.96*se
gen upper = beta+1.96*se

*Effect estimate variable - sort of decimal places
foreach var of varlist beta lower upper {
	tostring `var', gen(`var'_x) force
	
	replace `var'_x = substr(`var'_x,1,3) if `var' > 0 & `var' < 1
	replace `var'_x = substr(`var'_x,1,4) if `var' < 0 & `var' > -1
	replace `var'_x = subinstr(`var'_x,".","0.",.) if `var' > -1 & `var' < 1
	
	replace `var'_x = substr(`var'_x,1,4) if `var' >= 1 & `var' < 100
	replace `var'_x = substr(`var'_x,1,5) if `var' <= -1 & `var' > -100
	
	replace `var'_x = substr(`var'_x,1,5) if `var' >= 100 & `var' < 1000
	replace `var'_x = substr(`var'_x,1,6) if `var' <= -100 & `var' > -1000
	
	replace `var'_x = substr(`var'_x,1,6) if `var' >= 100 & `var' < 1000
	replace `var'_x = substr(`var'_x,1,7) if `var' <= -100 & `var' > -1000
}
	
gen x1 = beta_x
gen x2 = " ("
gen x3 = lower_x
gen x4 = " to "
gen x5 = upper_x	
gen x6 = ")"
egen effect = concat(x1-x6)
drop x1-x6 beta_x upper_x lower_x

*Have a group to say how wide the plot needs to be
bysort exposure outcome_type: egen x = max(abs(beta)) if strpos(type,"Summary") == 0
gen group = 0 if x < 5
forvalues i = 1/9 {
	replace group = `i' if x < `i'*10 & group == .
}
replace group = 10 if group == .
drop x

foreach var of varlist beta upper lower {
	tostring `var', replace force
	replace `var' = "NA" if `var' == "."
}

sort exposure outcome type

replace outcome_type = "Socioeconomic" if strpos(outcome,"binary") > 0

replace outcome = "Non-employed vs Employed or Retired" if outcome == "Non-employed vs Employed/Retired"

save "$cd_tables\metan_r.dta", replace
export delim "$cd_tables\metan_r.csv", delim(",") replace

}
}

*Part X
*Run the R script to create all R graphs
{

rsource using "$cd_r_code\R_graphs.R", rpath(`"C:\Program Files\R\R-3.5.1\bin\R.exe"') roptions(`"--vanilla"')

}

