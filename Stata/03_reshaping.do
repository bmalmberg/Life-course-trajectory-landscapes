*********************************************************
* SUDA (Stockholm University Demography Unit)
* Collaborative code 
*********************************************************

/********************************************************
File description: Reshaping
********************************************************/

* clear existing data, close open log files, change settings
capture log close
set more off
clear

global dir_user "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis"
global dir_project ""

global dir_project_data "$dir_user\Data"
global dir_project_logs "$dir_user\Logs"
global dir_project_code "$dir_user\Scripts"
global dir_project_outputs "$dir_user\Outputs"

set seed 12345

*****************************************
*Start log
*****************************************
local today=subinstr("`c(current_date)'"," ","",.)
local time=subinstr("`c(current_time)'",":","",.)

log using "$dir_project_logs\03_reshaping_`today'`time'.log", replace

*****************************************
*
*****************************************

use "$dir_project_data/LISA_processed.dta", clear
sort lopnr_personnr  year

duplicates tag lopnr_personnr year, gen(dup)
	tab dup year
	drop if (dup!=0)
	drop dup

tsset lopnr_personnr year
tsfill, full

replace disposible_median=0 if !missing(dispinkeq) & disposible_median!=1
replace dispinkeq_top=0 if !missing(dispinkeq) & dispinkeq_top!=1

gen alive=0 if !missing(doddatum)
replace alive=1 if missing(doddatum)
replace alive=1 if year<doddatum
replace alive=0 if year<fodelsear

tab year
tab age

capture: drop alive

bys lopnr_personnr: egen kon_filled=max(kon)
bys lopnr_personnr: egen fodelsear_filled=max(fodelsear)
bys lopnr_personnr: egen doddatum_filled=max(doddatum)
bys lopnr_personnr: egen invdatum_filled=max(invdatum)

gen alive=0 if !missing(doddatum_filled)
replace alive=1 if year<doddatum_filled
replace alive=0 if year<fodelsear_filled

drop kon fodelsear doddatum invdatum

drop age
gen age_filled=year- fodelsear_filled

compress
save "$dir_project_data/LISA_processed.dta", replace

gen ta=1 if age_filled>=16 & age_filled<=29
gen ym=1 if age_filled>=25 & age_filled<=39
gen mm=1 if age_filled>=35 & age_filled<=49
gen lm=1 if age_filled>=45 & age_filled<=59
gen tr=1 if age_filled>=55 & age_filled<=69
gen yo=1 if age_filled>=65 & age_filled<=79
gen mo=1 if age_filled>=75 & age_filled<=89
gen oo=1 if age_filled>=85 & age_filled<=99

preserve 

keep if ta==1
tab age_filled
save "$dir_project_data/TA.dta", replace
restore 
preserve 

keep if ym==1
tab age_filled
save "$dir_project_data/YM.dta", replace
restore
preserve 

keep if mm==1
tab age_filled
save "$dir_project_data/MM.dta", replace
restore
preserve 

keep if lm==1
tab age_filled
save "$dir_project_data/LM.dta", replace
restore
preserve 

keep if tr==1
tab age_filled
save "$dir_project_data/TR.dta", replace
restore
preserve 

keep if yo==1
tab age_filled
save "$dir_project_data/YO.dta", replace
restore
preserve 

keep if mo==1
tab age_filled
save "$dir_project_data/MO.dta", replace
restore
preserve 

keep if oo==1
tab age_filled
save "$dir_project_data/OO.dta", replace


*********************************************
*********************************************
*********************************************

use "$dir_project_data/TA.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/TA.dta", replace

use "$dir_project_data/YM.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/YM.dta", replace

use "$dir_project_data/MM.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/MM.dta", replace

use "$dir_project_data/LM.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/LM.dta", replace

use "$dir_project_data/TR.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/TR.dta", replace

use "$dir_project_data/YO.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/YO.dta", replace

use "$dir_project_data/MO.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/MO.dta", replace

use "$dir_project_data/OO.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/OO.dta", replace
*/

use "$dir_project_data/TA.dta", clear

gen  distress=0 if !missing(sjuk)| !missing(unempl)
replace distress=1 if sjuk==1| unempl==1
tab edu_level, gen( edu_level )
drop edu_level
drop year

keep lopnr_personnr distress edu_level* couple with_child child social_allowance poverty  loneink_low  retired loneink_top dispinkeq_top egnahem alive age_filled distress

rename lopnr_personnr id
rename couple cup
rename with_child wch
rename child ch
rename poverty pov
rename loneink_top ltop
rename loneink_low llow
rename dispinkeq_top dtop
rename social_allowance soc
rename egnahem own
rename retired pen
rename distress dis
rename edu_level1 edu1
rename edu_level2 edu2
rename edu_level3 edu3
rename edu_level4 edu4
rename edu_level5 edu5

reshape wide edu1 edu2 edu3 edu4 edu5 cup wch ch pov ltop llow dtop soc own pen alive dis , i(id) j(age_filled)
drop alive* pen* edu1*
compress
save "$dir_project_data/TA_.dta", replace
stata2mplus using "$dir_project_data/TA"

use "$dir_project_data/YM.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/YM.dta", replace

gen  distress=0 if !missing(sjuk)| !missing(unempl)
replace distress=1 if sjuk==1| unempl==1

keep lopnr_personnr year distress edu_level couple with_child child social_allowance poverty  loneink_low  retired loneink_top dispinkeq_top egnahem alive age_filled distress

tab edu_level, gen( edu_level )
drop edu_level
drop year

rename lopnr_personnr id
rename couple cup
rename with_child wch
rename child ch
rename poverty pov
rename loneink_top ltop
rename loneink_low llow
rename dispinkeq_top dtop
rename social_allowance soc
rename egnahem own
rename retired pen
rename distress dis
rename edu_level1 edu1
rename edu_level2 edu2
rename edu_level3 edu3
rename edu_level4 edu4
rename edu_level5 edu5

reshape wide edu1 edu2 edu3 edu4 edu5 cup wch ch pov ltop llow dtop soc own pen alive dis , i(id) j(age_filled)

drop alive* pen* edu1*
compress
save "$dir_project_data/YM_.dta", replace
*stata2mplus using "$dir_project_data/YM"


use "$dir_project_data/MM.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/MM.dta", replace

gen  distress=0 if !missing(sjuk)| !missing(unempl)
replace distress=1 if sjuk==1| unempl==1

keep lopnr_personnr year distress couple with_child social_allowance poverty  loneink_low  retired loneink_top dispinkeq_top egnahem alive age_filled distress

drop year

rename lopnr_personnr id
rename couple cup
rename with_child wch
rename poverty pov
rename loneink_top ltop
rename loneink_low llow
rename dispinkeq_top dtop
rename social_allowance soc
rename egnahem own
rename retired pen
rename distress dis

reshape wide cup wch pov ltop llow dtop soc own pen alive dis , i(id) j(age_filled)

drop alive* pen*
compress
save "$dir_project_data/MM_.dta", replace
*stata2mplus using "$dir_project_data/MM"

use "$dir_project_data/LM.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/LM.dta", replace

gen  distress=0 if !missing(sjuk)| !missing(unempl)
replace distress=1 if sjuk==1| unempl==1

keep lopnr_personnr year distress couple with_child social_allowance poverty  loneink_low  retired loneink_top dispinkeq_top egnahem alive age_filled distress

drop year

rename lopnr_personnr id
rename couple cup
rename with_child wch
rename poverty pov
rename loneink_top ltop
rename loneink_low llow
rename dispinkeq_top dtop
rename social_allowance soc
rename egnahem own
rename retired pen
rename distress dis

reshape wide cup wch pov ltop llow dtop soc own pen alive dis , i(id) j(age_filled)


*We dont want to include people who are dead already at the start of the observation period!
drop if alive45==0
drop alive45
compress
save "$dir_project_data/LM2_.dta", replace
stata2mplus using "$dir_project_data/LM2"


use "$dir_project_data/TR.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/TR.dta", replace

gen  distress=0 if !missing(sjuk)| !missing(unempl)
replace distress=1 if sjuk==1| unempl==1

keep lopnr_personnr year distress couple with_child social_allowance poverty  loneink_low  retired loneink_top dispinkeq_top egnahem alive age_filled distress

drop year

rename lopnr_personnr id
rename couple cup
rename with_child wch
rename poverty pov
rename loneink_top ltop
rename loneink_low llow
rename dispinkeq_top dtop
rename social_allowance soc
rename egnahem own
rename retired pen
rename distress dis

reshape wide cup wch pov ltop llow dtop soc own pen alive dis , i(id) j(age_filled)
tab alive55
drop if alive55==0
drop alive55
compress
save "$dir_project_data/TR2_.dta", replace
stata2mplus using "$dir_project_data/TR2"

use "$dir_project_data/YO.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/YO.dta", replace

keep lopnr_personnr year couple with_child poverty retired dispinkeq_top egnahem alive age_filled 

drop year

rename lopnr_personnr id
rename couple cup
rename with_child wch
rename poverty pov
rename dispinkeq_top dtop
rename egnahem own
rename retired pen

de

reshape wide cup wch pov dtop own pen alive  , i(id) j(age_filled)

tab alive65
drop if alive65==0
drop alive65
compress
save "$dir_project_data/YO2_.dta", replace
stata2mplus using "$dir_project_data/YO2"

use "$dir_project_data/MO.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/MO.dta", replace

keep lopnr_personnr year couple with_child  poverty retired dispinkeq_top egnahem alive age_filled 

drop year

rename lopnr_personnr id
rename couple cup
rename with_child wch
rename poverty pov
rename dispinkeq_top dtop
rename egnahem own
rename retired pen

reshape wide cup wch pov dtop  own pen alive  , i(id) j(age_filled)


tab alive75
drop if alive75==0
drop alive75
compress
save "$dir_project_data/MO2_.dta", replace
stata2mplus using "$dir_project_data/MO2"


use "$dir_project_data/OO.dta", clear
*tsset lopnr_personnr age_filled
*tsfill, full
*save "$dir_project_data/OO.dta", replace

keep lopnr_personnr year  couple with_child  poverty retired dispinkeq_top egnahem alive age_filled 

drop year

rename lopnr_personnr id
rename couple cup
rename with_child wch
rename poverty pov
rename dispinkeq_top dtop
rename egnahem own
rename retired pen

reshape wide cup wch pov dtop  own pen alive  , i(id) j(age_filled)

tab alive85
drop if alive85==0
drop alive85
compress
save "$dir_project_data/OO2_.dta", replace

stata2mplus using "$dir_project_data/OO2", replace


