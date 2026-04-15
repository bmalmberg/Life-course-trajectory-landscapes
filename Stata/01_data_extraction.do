*********************************************************
* SUDA (Stockholm University Demography Unit)
* Collaborative code 
*********************************************************

/********************************************************
File description: Data extraction
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

log using "$dir_project_logs\01_data_extraction_`today'`time'.log", replace

*****************************************
*Population_PersonNr
*****************************************
	*Load
	
	odbc load LopNr_PersonNr Kon FodelseAr AterPNr DodDatum InvDatum, table ("ArsOberoende") dsn("P0623") clear
	rename *, lower

	describe
	destring fodelsear, replace
	destring kon, replace
	describe
	
	duplicates tag lopnr_personnr, gen(dup)
	tab dup
	drop if (dup!=0)
	drop dup
	
	tab aterpnr, m
	drop if (aterpnr==1) //n=13,412
	drop aterpnr

	lab def sex 1 "male" 2 "female", replace
	lab val kon sex
	
	replace doddatum= floor(doddatum/10000)
	replace invdatum= floor(invdatum/10000)
	
	sort lopnr_personnr
	compress
	save "$dir_project_data/Population_PersonNr.dta", replace
	clear


*****************************************
*LISA
*****************************************

*Load

foreach i of num 1990/1992 {
	odbc load LopNr_PersonNr Sun2000niva FamTypF FamStF SjukRe FamStF SocBidrFam BostBidrFam Civil LoneInk ForvInk DispInkFam AldPens	ForTid ArbLos, table ("LISA_`i'") dsn("P0623") clear
	rename *, lower
	describe
	gen year=`i'

	duplicates tag lopnr_personnr, gen(dup)
	tab dup
	drop if (dup!=0)
	drop dup

	sort lopnr_personnr
	compress
	save "$dir_project_data/LISA_`i'.dta", replace
}

foreach i of num 1993/2003 {
	odbc load LopNr_PersonNr SjukP_Bdag Sun2000niva FamTypF FamStF SocBidrFam BostBidrFam Civil LoneInk ForvInk DispInkFam DispInkPersF KonsViktF ///
	ForTid ArbLos AldPens, table ("LISA_`i'") dsn("P0623") clear
	rename *, lower
	describe
	gen year=`i'

	duplicates tag lopnr_personnr, gen(dup)
	tab dup
	drop if (dup!=0)
	drop dup

	sort lopnr_personnr
	compress
	save "$dir_project_data/LISA_`i'.dta", replace
}

foreach i of num 2004/2015 {
	odbc load LopNr_PersonNr SjukP_Bdag Sun2000niva FamTypF FamStF SocBidrFam BostBidrFam Civil LoneInk ForvInk DispInkFam04 DispInkPersF04 KonsViktF04 ForTid ArbLos AldPens, table ("LISA_`i'") dsn("P0623") clear
	rename *, lower
	describe
	gen year=`i'
	
	duplicates tag lopnr_personnr, gen(dup)
	tab dup
	drop if (dup!=0)
	drop dup
	
	sort lopnr_personnr
	compress
	save "$dir_project_data/LISA_`i'.dta", replace
}

foreach i of num 2016/2018 {
	odbc load LopNr_PersonNr SjukRe Sun2000niva FamTypF FamStF SocBidrFam BostBidrFam Civil LoneInk Raks_Forvink DispInkFam04  KonsViktF04 ForTid ArbLos AldPens, table ("LISA_`i'") dsn("P0623") clear
	rename *, lower
	describe
	gen year=`i'
	
	duplicates tag lopnr_personnr, gen(dup)
	tab dup
	drop if (dup!=0)
	drop dup
	
	sort lopnr_personnr
	compress
	save "$dir_project_data/LISA_`i'.dta", replace
}

foreach i of num 2019/2019 {
	odbc load LopNr_PersonNr SjukRe Sun2020niva FamTypF FamStF SocBidrFam BostBidrFam Civil LoneInk Raks_Forvink DispInkFam04 KonsViktF04 ForTid ArbLos AldPens, table ("LISA_`i'") dsn("P0623") clear
	rename *, lower
	describe
	gen year=`i'
	
	duplicates tag lopnr_personnr, gen(dup)
	tab dup
	drop if (dup!=0)
	drop dup

	sort lopnr_personnr
	compress
	save "$dir_project_data/LISA_`i'.dta", replace
}


foreach i of num 1990/2019 {
	odbc load LopNr_PersonNr LopNr_Fast LopNr_FamId, table ("RTB_`i'") dsn("P0623") clear
	rename *, lower
	describe
	gen year=`i'
	
	duplicates tag lopnr_personnr, gen(dup)
	tab dup
	drop if (dup!=0)
	drop dup

	sort lopnr_personnr
	compress
	save "$dir_project_data/RTB_`i'.dta", replace
}


*Load
foreach i of num 1990/2019 {
	odbc load LopNr_PersonNr FamTypF, table ("LISA_`i'") dsn("P0623") clear
	rename *, lower
	describe
	gen year=`i'

	duplicates tag lopnr_personnr, gen(dup)
	tab dup
	drop if (dup!=0)
	drop dup

	sort lopnr_personnr
	compress
	save "$dir_project_data/LISA_FamTypF_`i'.dta", replace
}


*****************************************
*LISA incomes (added later)
*****************************************

foreach i of num 1990/2019 {

use "$dir_project_data/LISA_`i'.dta", clear
keep year lopnr_personnr dispinkeq loneink 

save "$dir_project_data/LISA_ink_`i'.dta", replace

}

use "$dir_project_data/LISA_ink_1990.dta", clear
append using "$dir_project_data/LISA_ink_1991.dta"
append using "$dir_project_data/LISA_ink_1992.dta"
append using "$dir_project_data/LISA_ink_1993.dta"
append using "$dir_project_data/LISA_ink_1994.dta"
append using "$dir_project_data/LISA_ink_1995.dta"
append using "$dir_project_data/LISA_ink_1996.dta"
append using "$dir_project_data/LISA_ink_1997.dta"
append using "$dir_project_data/LISA_ink_1998.dta"
append using "$dir_project_data/LISA_ink_1999.dta"
append using "$dir_project_data/LISA_ink_2000.dta"
append using "$dir_project_data/LISA_ink_2001.dta"
append using "$dir_project_data/LISA_ink_2002.dta"
append using "$dir_project_data/LISA_ink_2003.dta"
append using "$dir_project_data/LISA_ink_2004.dta"
append using "$dir_project_data/LISA_ink_2005.dta"
append using "$dir_project_data/LISA_ink_2006.dta"
append using "$dir_project_data/LISA_ink_2007.dta"
append using "$dir_project_data/LISA_ink_2008.dta"
append using "$dir_project_data/LISA_ink_2009.dta"
append using "$dir_project_data/LISA_ink_2010.dta"
append using "$dir_project_data/LISA_ink_2011.dta"
append using "$dir_project_data/LISA_ink_2012.dta"
append using "$dir_project_data/LISA_ink_2013.dta"
append using "$dir_project_data/LISA_ink_2014.dta"
append using "$dir_project_data/LISA_ink_2015.dta"
append using "$dir_project_data/LISA_ink_2016.dta"
append using "$dir_project_data/LISA_ink_2017.dta"
append using "$dir_project_data/LISA_ink_2019.dta"


save "$dir_project_data/LISA_ink.dta", replace

*****************************************
*Housing
*****************************************

*Load

foreach i of num 1991/2020 {
	odbc load LopNr_Fast JurFormGrp Typkod, table ("BoFast_`i'") dsn("P0623") clear
	rename *, lower
	describe
	gen year=`i'

	duplicates tag lopnr_fast, gen(dup)
	tab dup
	drop if (dup!=0)
	drop dup

	sort lopnr_fast
	compress
	save "$dir_project_data/BoFast_`i'.dta", replace
}




*****************************************
*Geo coordinates for two reference years
*****************************************

*Load
	
	odbc load LopNr_PersonNr Ruta XKOORDsw YKOORDsw DeSO, table ("Geodata_Individ_2019") dsn("P0623") clear
	rename *, lower
	
	duplicates tag lopnr_personnr, gen(dup)
	tab dup
	drop if (dup!=0)
	drop dup
	
	
sort lopnr_personnr
capture: drop _merge

merge m:1 lopnr_personnr using "$dir_project_data/Population_PersonNr.dta"
 keep if _merge==3
 drop _merge
 
"$dir_project_data/Geo_2019.dta" 	


	odbc load LopNr_PersonNr RutStl Ostruta Nordruta SAMS OstrutaSW NordrutaSW, table ("Geodata_Individ_2000") dsn("P0623") clear
	rename *, lower
	
	duplicates tag lopnr_personnr, gen(dup)
	tab dup
	drop if (dup!=0)
	drop dup
	
	
sort lopnr_personnr
capture: drop _merge

merge m:1 lopnr_personnr using "$dir_project_data/Population_PersonNr.dta"
 keep if _merge==3
 drop _merge
 
save "$dir_project_data/Geo_2000.dta", replace 	

