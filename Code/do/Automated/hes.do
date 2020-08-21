*Folder paths
global hes_path ""
global data_path ""

cd $hes_path
import delim "ukb_hesin_1_10.tsv",clear
save "1.dta", replace

import delim "ukb_hesin_11_20.tsv",clear
save "2.dta", replace

import delim "ukb_hesin_21_30.tsv",clear
save "3.dta", replace

import delim "ukb_hesin_31_40.tsv",clear
save "4.dta", replace

import delim "ukb_hesin_41_53.tsv",clear
save "5.dta", replace

use "1.dta", clear
rename eid eid_1
forvalues i = 2/5 {
	merge 1:1 _n using "`i'.dta"
	rename eid eid_`i'
	drop _merge
}
order eid*, first
rename eid_1 eid
drop eid_*
save "hesin.dta", replace

foreach file in ukb_hesin_birth ukb_hesin_diag10 ukb_hesin_OPER {
	import delim "`file'.tsv", clear
	save "`file'.dta", replace
}

********************************************************************************
*The diag file needs some mods (Padraig's code)
use "ukb_hesin_diag10.dta"
sort eid rec arr

//Following code makes sure that arr_index is consecutive within record_ids, and corrects if not
//This is important as arr_index is important for subsequent code
gen flag_arr=1 if record==record[_n-1] & arr==arr[_n-1]
recode arr (0=1) (1=0) if flag_arr==1 //Not clear which method of the observations should be coded as zero/one so this recording is arbitrary but probably not material
drop flag_arr

//Main data manipulation follows
sort eid rec arr
egen max_arr_index=max(arr_index), by (record_id) //Useful as a rough check on data manipulations
gen diag_max_arr=max_arr_index+1
drop max_arr_index
foreach num of numlist 0/19 {
	gen diag`num'="" if diag_max==`num'
}
sort eid rec arr
replace diag0=diag_icd10 if arr==0 //will want to call this diag 2 in due course...so that in main file the diagnosis is diag1

//Code below puts, for reach record, all diagnosis codes on the the arr_index=0 line

foreach num of numlist 1/19 {
	replace diag`num'=diag_icd10[_n+`num'] if arr_index[_n+`num']==`num'
}

drop diag_icd10
rename diag_icd10_nb notes_diag_data
sort eid rec arr
keep if arr==0 //Keep only records with list of all diagnoses per record

//Final sort before saving
sort eid rec arr
foreach num of numlist 0/19 {
	foreach i of numlist 2/21 {
		cap rename diag`num' diag_`i'
	}
}

save "ukb_hesin_diag10_clean.dta", replace

********************************************************************************
*The operations file needs some mods (Padraig's code)
use "ukb_hesin_OPER.dta", clear
sort eid record arr

//Following code makes sure that arr_index is consecutive within record_ids, and corrects if not
//This is important as arr_index is important for subsequent code

gen flag_arr=1 if record==record[_n-1] & arr==arr[_n-1]
recode arr (0=1) (1=0) if flag_arr==1 //Not clear which method of the observations should be coded as zero/one so this recording is arbitrary but probably not material
drop flag_arr

//Main data manipulation follows:
egen max_arr_index=max(arr_index), by (record_id) //Useful as a rough check on data manipulations

gen oper_max_arr=max_arr_index+1

drop max_arr_index

*gen oper_0=oper4 

rename oper4 operations
foreach num of numlist 1/23 {
	gen oper`num'="" if oper_max==`num'
}
sort eid rec arr

foreach num of numlist 1/23 {
	replace oper`num'=operations[_n+`num'] if arr_index[_n+`num']==`num'
}

rename operations oper0
rename oper4_nb notes_to_oper0
order eid oper_max oper*
sort eid rec arr
keep if arr==0
sort eid rec arr

//Not quite working...leaving oper23 behind....
foreach num of numlist 0/23 {
	foreach i of numlist 2/24 {
		cap rename oper`num' oper_`i'
	}
}

drop oper23

save  "ukb_hesin_OPER_clean.dta", replace

********************************************************************************
*Combine
use "hesin.dta", clear
merge 1:1 record using "ukb_hesin_diag10_clean.dta"
drop _merge
merge 1:1 record using "ukb_hesin_OPER_clean.dta"
drop _merge

gen date_epistart=date(epistart, "YMD", 2050)
format date_epistart %td
drop epistart
rename date_epistart epistart


gen date_epiend=date(epiend, "YMD", 2050)
format date_epiend %td
drop epiend
rename date_epiend epiend


gen date_admidate=date(admidate, "YMD", 2050)
format date_admidate %td
drop admidate
rename date_admidate admidate

order eid record epistart epiend admidate
sort eid record

rename diag_icd10 diag_1

save "$data_path\hes.dta", replace
