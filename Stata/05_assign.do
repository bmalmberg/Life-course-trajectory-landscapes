*********************************************************
* SUDA (Stockholm University Demography Unit)
* Collaborative code 
*********************************************************

/********************************************************
File description: Assign classes to individuals
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

log using "$dir_project_logs\05_assign_`today'`time'.log", replace

*****************************************
*
*****************************************


use "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\TA_5cl.dta", clear

keep id cl max_p
gen phase="TA"
save "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\TA_5cl_append.dta", replace

use "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\YM_5cl.dta", clear

keep id cl max_p

gen phase="YM"
sort id

save "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\YM_5cl_append.dta", replace

use "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\MM_5cl.dta", clear

keep id cl max_p

gen phase="MM"
sort id

save "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\MM_5cl_append.dta", replace

use "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\LM_5cl.dta", clear

keep id cl max_p
gen phase="LM"

sort id

save "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\LM_5cl_append.dta", replace
use "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\TR_5cl.dta", clear

keep id cl max_p

gen phase="TR"
sort id

save "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\TR_5cl_append.dta", replace

use "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\YO_5cl.dta", clear
keep id cl max_p

use "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\TR_5cl.dta", clear

keep id cl max_p
gen phase="TR"

sort id

save "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\TR_5cl_append.dta", replace

use "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\YO_5cl.dta", clear

keep id cl max_p

gen phase="YO"

sort id

save "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\YO_5cl_append.dta", replace

use "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\MO_5cl.dta", clear

keep id cl max_p

gen phase="MO"

sort id

save "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\MO_5cl_append.dta", replace

use "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\OO_5cl.dta", clear

keep id cl max_p

use "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\OO_5cl.dta", clear

keep id cl max_p

gen phase="OO"

sort id

save "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\OO_5cl_append.dta", replace

clear

use "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\TA_5cl_append.dta"

append using "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\YM_5cl_append.dta"

append using "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\MM_5cl_append.dta"

append using "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\LM_5cl_append.dta"

append using "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\TR_5cl_append.dta"

append using "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\YO_5cl_append.dta"

append using "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\MO_5cl_append.dta"

append using "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\OO_5cl_append.dta"

sort id

order id

tostring cl, generate(cl_s)
cl_s generated as str1

gen cl_phase=phase+cl_s

rename id lopnr_personnr

sort lopnr_personnr
capture: drop _merge
merge m:1 lopnr_personnr using "$dir_project_data/Population_PersonNr.dta"
count
drop _merge

sort lopnr_personnr
save "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\assign_file.dta"


use "$dir_project_data/Geo_2019.dta", replace
	
	
merge 1:m lopnr_personnr using "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\assign_file.dta"

keep if _merge==3

drop _merge

gen age=2019- fodelsear

sort lopnr_personnr cl_phase
save "$dir_project_data/Geo_2019.dta", replace
		
use  "$dir_project_data/Geo_2019.dta", clear

gen cl_final=cl_phase
replace cl_final="" if fodelsear>2001
drop if phase=="TA" & (age<16 | age>27)
drop if phase=="YM" & (age<28 | age>37)
drop if phase=="MM" & (age<38 | age>47)
drop if phase=="LM" & (age<48 | age>57)
drop if phase=="TR" & (age<58 | age>67)
drop if phase=="YO" & (age<68 | age>77)
drop if phase=="MO" & (age<78 | age>87)
drop if phase=="OO" & age<88

save "$dir_project_data/Geo_2019_processed.dta", replace
use "$dir_project_data/Geo_2019_processed.dta", replace
	
tab cl_final, gen(cl)

foreach var of varlist cl1- cl40 {
bys xkoordsw ykoordsw: egen `var'_sum=sum(`var')	
}

keep xkoordsw ykoordsw ruta cl1_sum- cl40_sum
duplicates drop
egen population2019=rowtotal( cl1_sum - cl40_sum )
 	save "$dir_project_data/Geo_2019_processed.dta", replace
export delimited using "$dir_project_data/Geo_2019.csv", replace	
	
	
use "$dir_project_data/Geo_2000.dta", replace
	
merge 1:m lopnr_personnr using "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\assign_file.dta"

keep if _merge==3

drop _merge

gen age=2000- fodelsear

sort lopnr_personnr cl_phase
save "$dir_project_data/Geo_2000.dta", replace
		
use  "$dir_project_data/Geo_2000.dta", clear

gen cl_final=cl_phase
replace cl_final="" if fodelsear>1983
drop if phase=="TA" & (age<16 | age>27)
drop if phase=="YM" & (age<28 | age>37)
drop if phase=="MM" & (age<38 | age>47)
drop if phase=="LM" & (age<48 | age>57)
drop if phase=="TR" & (age<58 | age>67)
drop if phase=="YO" & (age<68 | age>77)
drop if phase=="MO" & (age<78 | age>87)
drop if phase=="OO" & age<88

save "$dir_project_data/Geo_2000_processed.dta", replace
use "$dir_project_data/Geo_2000_processed.dta", replace
	
tab cl_final, gen(cl)

foreach var of varlist cl1- cl40 {
bys ostruta nordruta: egen `var'_sum=sum(`var')	
}

keep ostruta nordruta rutstl cl1_sum- cl40_sum
duplicates drop
egen population2000=rowtotal( cl1_sum - cl40_sum )


drop if ostruta==0
drop if nordruta==0
 	save "$dir_project_data/Geo_2000_processed.dta", replace
export delimited using "$dir_project_data/Geo_2000.csv", replace	
	
