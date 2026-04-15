*********************************************************
* SUDA (Stockholm University Demography Unit)
* Collaborative code 
*********************************************************

/********************************************************
File description: Coding
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

log using "$dir_project_logs\02_coding_`today'`time'.log", replace

/***********************************************
*Start with full population variables
************************************************/

*Mean income

foreach i of num 1990/2019 {
	use "$dir_project_data/LISA_`i'.dta", clear
	
	capture: drop age vikt fam_ppl viktfam dispinkeq_mean dispinkeq 
	
	count
	sort lopnr_personnr
	merge lopnr_personnr using "$dir_project_data/RTB_`i'.dta"
	tab _merge
	rename _merge _mergeRTB
	sort lopnr_personnr
	merge lopnr_personnr using "$dir_project_data/Population_PersonNr.dta"
	tab _merge
	keep if _merge==3
	drop _merge

	gen age=year-fodelsear
	drop if age<0
	
	*Create indiviudal consumtion weights (1990-2004 weights)
	
	*0.56 0-3
	*0.66 4-10
	*0.76 11-17
	*1.16 ensamstående vuxna
	*en vuxna 0.96 en vuxna

	gen vikt=0.56 if age>=0 & age<=3
	replace vikt=0.66 if age>=4 & age<=10
	replace vikt=0.76 if age>=11 & age<=17
	replace vikt=0.96 if age>=18
	replace vikt=1.16 if substr(famstf, 1, 1)=="4"
	egen fam_ppl=count(lopnr_personnr), by(lopnr_famid)
	egen viktfam=sum(vikt), by(lopnr_famid)

	tab _mergeRTB
	*Those with _mergeRTB==2 are aged 0-15 and hence not in LISA
	drop if _mergeRTB==2
	drop _mergeRTB
	
	destring loneink, replace
	egen loneink_med=median(loneink)
	
	if (year<2004) {
	capture: drop  dispinkeq konsvikt 
	gen dispinkeq=dispinkfam/viktfam
	} 
	if (year>=2004) {
	capture: drop dispinkeq konsvikt04 
		if (year<2016) {	
			gen dispinkeq=dispinkfam04/viktfam
			}
		if (year>=2016) {	
			destring dispinkfam04, replace
			gen dispinkeq=dispinkfam04/viktfam
		}
	}

	egen dispinkeq_med=median(dispinkeq)

	save "$dir_project_data/LISA_`i'.dta", replace
}

*Education

foreach i of num 1990/2019 {
	use "$dir_project_data/LISA_`i'.dta", clear
	
	capture: drop sun_1 edu_level
	
	if (year<2019) {
	gen sun_1=substr(sun2000niva, 1, 1)
	} 
	if (year>=2019) {
	gen sun_1=substr(sun2020niva, 1, 1)
	}
	
	gen edu_level=0 if sun_1=="0" | sun_1=="1"
	replace edu_level=1 if sun_1=="2"
	replace edu_level=2 if sun_1=="3"
	replace edu_level=3 if sun_1=="4" 
	replace edu_level=4 if sun_1=="5" | sun_1=="6"
	replace edu_level=. if sun_1=="9"
	
	label define edu_level 0 "less than lowe sec" 1 "lower sec" 2 "upper sec" 3 "tertiary short" 4 "tertiary long" 
	label values edu_level edu_level
	
	save "$dir_project_data/LISA_`i'.dta", replace
}

*Household status

foreach i of num 1990/2019 {
	use "$dir_project_data/LISA_`i'.dta", clear
	sort lopnr_personnr
	merge lopnr_personnr using "$dir_project_data/LISA_FamTypF_`i'.dta"
	tab _merge
	keep if _merge==3
	drop _merge
	
	capture: drop age
	gen age=year-fodelsear
	drop if age<0 

	*In a couple
	gen couple=1 if substr(famtypf, 1, 1)=="1" | substr(famtypf, 1, 1)=="2"
	replace couple=0 if !missing(famtypf) & couple!=1

	*With child
	gen with_child=1 if substr(famtypf, 1, 2)=="12" | substr(famtypf, 1, 2)=="13" | substr(famtypf, 1, 2)=="22" | substr(famtypf, 1, 2)=="23"  | substr(famtypf, 1, 2)=="31" | substr(famtypf, 1, 2)=="32" | substr(famtypf, 1, 2)=="41" | substr(famtypf, 1, 2)=="42"
	replace with_child=0 if !missing(famtypf) & with_child!=1

	*Child
	gen child=1 if  substr(famstf, 1, 1)=="3"
	replace child=0 if !missing(famstf) & child!=1
	
	save "$dir_project_data/LISA_`i'.dta", replace

}

*Household economic status

foreach i of num 1990/1992 {
	use "$dir_project_data/LISA_`i'.dta", clear
	de
	
	destring socbidrfam, replace
	destring sjukre, replace
	destring arblos, replace
	destring loneink, replace
	destring aldpens, replace
	destring forvink, replace
	destring fortid, replace	
	
	*egen loneink_med=median(loneink)

	gen social_allowance=1 if socbidrfam > 0
	replace social_allowance=0 if !missing(socbidrfam) & social_allowance!=1

	***At risk of poverty***
	gen poverty=1 if dispinkeq<0.6*dispinkeq_med
	replace poverty=0 if !missing(dispinkeq) & poverty!=1

	***Larger than median disposible income***
	gen disposible_median=1 if dispinkeq>dispinkeq_med
	replace disposible_median=0 if !missing(dispinkeq)
	***Distress***
	 
	*sickness
	egen sjukper=xtile( sjukre ), nq(100)
	gen sjuk=0 if !missing(sjukre)
	replace sjuk=1 if sjukper>=87
	
	*unemployment
	gen unempl=0 if !missing(arblos)
	replace unempl=1 if arblos>0

	*Employment and earned income
	*Low
	gen loneink_low=0 if !missing(loneink)
	replace loneink_low=1 if loneink<0.4*loneink_med
	*High
	gen loneink_high=0 if !missing(loneink)
	replace loneink_high=1 if loneink>0.75*loneink_med
	*Retirement and life
	gen retired=0 if !missing(arblos)
	replace retired=1 if fortid+aldpens>0.49*(forvink+fortid+aldpens+arblos)

	save "$dir_project_data/LISA_`i'.dta", replace

	}

foreach i of num 1993/2015 {
	use "$dir_project_data/LISA_`i'.dta", clear
	de
	destring socbidrfam, replace
	destring sjukp_bdag, replace
	destring arblos, replace
	destring loneink, replace
	destring aldpens, replace
	destring forvink, replace
	destring fortid, replace	
	
	*egen loneink_med=median(loneink)

	gen social_allowance=1 if socbidrfam > 0
	replace social_allowance=0 if !missing(socbidrfam) & social_allowance!=1

	***At risk of poverty***
	gen poverty=1 if dispinkeq<0.6*dispinkeq_med
	replace poverty=0 if !missing(dispinkeq) & poverty!=1

	***Larger than median disposible income***
	gen disposible_median=1 if dispinkeq>dispinkeq_med

	***Distress***
	 
	*sickness
	gen sjuk=0 if !missing(sjukp_bdag)
	replace sjuk=1 if sjukp_bdag>0
	
	*unemployment
	gen unempl=0 if !missing(arblos)
	replace unempl=1 if arblos>0

	*Employment and earned income
	*Low
	gen loneink_low=0 if !missing(loneink)
	replace loneink_low=1 if loneink<0.4*loneink_med
	*High
	gen loneink_high=0 if !missing(loneink)
	replace loneink_high=1 if loneink>0.75*loneink_med
	*Retirement and life
	gen retired=0 if !missing(arblos)
	replace retired=1 if fortid+aldpens>0.49*(forvink+fortid+aldpens+arblos)
	
	save "$dir_project_data/LISA_`i'.dta", replace

	}
	
	
foreach i of num 2016/2019 {
	use "$dir_project_data/LISA_`i'.dta", clear
	de
	destring socbidrfam, replace
	destring sjukre, replace
	destring arblos, replace
	destring loneink, replace
	destring aldpens, replace
	destring raks_forvink, replace
	destring fortid, replace	
	
	*egen loneink_med=median(loneink)

	gen social_allowance=1 if socbidrfam > 0
	replace social_allowance=0 if !missing(socbidrfam) & social_allowance!=1

	***At risk of poverty***
	gen poverty=1 if dispinkeq<0.6*dispinkeq_med
	replace poverty=0 if !missing(dispinkeq) & poverty!=1

	***Larger than median disposible income***
	gen disposible_median=1 if dispinkeq>dispinkeq_med
	
	***Distress***
	 
	*sickness
	gen sjuk=0 if !missing(sjukre)
	replace sjuk=1 if sjukre>0
	
	*unemployment
	gen unempl=0 if !missing(arblos)
	replace unempl=1 if arblos>0

	*Employment and earned income
	*Low
	gen loneink_low=0 if !missing(loneink)
	replace loneink_low=1 if loneink<0.4*loneink_med
	*High
	gen loneink_high=0 if !missing(loneink)
	replace loneink_high=1 if loneink>0.75*loneink_med
	*Retirement and life
	gen retired=0 if !missing(arblos)
	replace retired=1 if fortid+aldpens>0.49*(raks_forvink+fortid+aldpens+arblos)	
	
	save "$dir_project_data/LISA_`i'.dta", replace
	}

	

foreach i of num 1990/2019 {
	use "$dir_project_data/LISA_`i'.dta", clear
	egen loneink_d=xtile(loneink), nq(10)
	gen loneink_top=0 if !missing(loneink)
	replace loneink_top=1 if loneink_d==10
	
	egen dispinkeq_d=xtile(dispinkeq ), nq(10)
	gen dispinkeq_top=0 if !missing(dispinkeq )
	replace dispinkeq_top=1 if dispinkeq_d==10
	
	save "$dir_project_data/LISA_`i'_processed.dta", replace
}

foreach i of num 1990/2019 {
	use "$dir_project_data/LISA_`i'_processed.dta", clear
	
	keep lopnr_personnr year kon fodelsear doddatum invdatum dispinkeq edu_level age couple with_child child social_allowance poverty disposible_median sjuk unempl loneink_low loneink_high retired loneink_top dispinkeq_top	
	
	save "$dir_project_data/LISA_`i'_processed.dta", replace
}


*Tenure
foreach i of num 1990/2019 {
use "$dir_project_data/LISA_`i'_processed.dta", clear
capture: drop _merge
sort lopnr_personnr
merge lopnr_personnr using "$dir_project_data/RTB_`i'.dta"

tab _merge
sort _merge
drop if _merge==2

sort lopnr_fast
drop _merge
scalar add=`i'+1
local k=add
merge lopnr_fast using "$dir_project_data/BoFast_`k'.dta"

tab _merge
drop if _merge==2

destring jurformgrp, replace
destring typkod, replace

gen lantbruk=typkod>=100 & typkod<=210
gen fritidshus=(typkod==211) | (typkod==221 & (jurformgrp==0 |jurformgrp==1 | jurformgrp==2 | jurformgrp==3 |jurformgrp==4 | jurformgrp==5 | jurformgrp==6 |jurformgrp==9 | jurformgrp==10))
gen egnahem=(typkod==213 | typkod==220 | typkod==222 | typkod==223) & jurformgrp==4
gen brf=((typkod==213 | typkod==220 | typkod==222 | typkod==223 | typkod==320 | typkod==321 | typkod==325) & jurformgrp==7) | typkod==520
gen allmn=(typkod==213 | typkod==220 | typkod==222 | typkod==223 | typkod==320 | typkod==321 | typkod==325) & jurformgrp==8
gen privhyr=(typkod==320 | typkod==321 | typkod==325) & (jurformgrp==4 | jurformgrp==6)
gen egnahem_ovrig=(typkod>=212 & typkod<=299 & typkod!=.) & egnahem==0 & brf==0 & allmn==0 & fritidshus==0
gen hyr_ovrig=typkod>=300 & typkod!=520 & typkod!=. & egnahem==0 & brf==0 & allmn==0 & fritidshus==0 & privhyr==0

drop brf allmn privhyr egnahem_ovrig hyr_ovrig 
save "$dir_project_data/LISA_`i'_processed.dta", replace

}	

*Putting the files together
use "$dir_project_data/LISA_1990_processed.dta", clear	
sort lopnr_personnr

foreach i of num 1991/2019 {
	append 	using "$dir_project_data/LISA_`i'_processed.dta"
	sort lopnr_personnr
	compress
}
capture: drop _merge lantbruk fritidshus lopnr_fast lopnr_famid jurformgrp typkod
save "$dir_project_data/LISA_processed.dta", replace
	
	