*********************************************************
* SUDA (Stockholm University Demography Unit)
* Collaborative code 
*********************************************************

/********************************************************
File description: Run after Mplus to convert files to dta
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

log using "$dir_project_logs\04_LCA_`today'`time'.log", replace

*************************************************
*LCA run in MPlus. See MPlus folder for details
*Merge results from Mplus with underlying file
************************************************

*************************************************
*Merge results from Mplus with underlying file
*************************************************

import delimited "\\micro.intra\projekt\P0623$\P0623_Gem\Juta\Mplus\Output\TA.txt", delimiter(" ", collapse) encoding(Big5) 

rename v204 id
rename v203 cl

sort id
keep v198-id

rename v198 cl1_p
rename v199 cl2_p
rename v200 cl3_p
rename v201 cl4_p
rename v202 cl5_p

egen max_p=rowmax( cl1_p - cl5_p )
gen in_cl=1

duplicates report id
save "$dir_project_data/TA_5cl.dta", replace


*************************************************
*YM
*************************************************

clear
import delimited "\\micro.intra\projekt\P0623$\P0623_Gem\Juta\Mplus\Output\YM.txt", delimiter(" ", collapse) encoding(Big5) 

rename v218 id
rename v217 cl

sort id
keep v212-id

rename v212 cl1_p
rename v213 cl2_p
rename v214 cl3_p
rename v215 cl4_p
rename v216 cl5_p

egen max_p=rowmax( cl1_p - cl5_p )
gen in_cl=1

duplicates report id
save "$dir_project_data/YM_5cl.dta", replace

*************************************************
*MM
*************************************************

import delimited "\\micro.intra\projekt\P0623$\P0623_Gem\Juta\Mplus\Output\MM.txt", delimiter(" ", collapse) encoding(Big5) 
de

rename v143 id
rename v142 cl

sort id
keep v137-id

rename v137 cl1_p
rename v138 cl2_p
rename v139 cl3_p
rename v140 cl4_p
rename v141 cl5_p

egen max_p=rowmax( cl1_p - cl5_p )
gen in_cl=1

duplicates report id
save "$dir_project_data/MM_5cl.dta", replace

*/
use "$dir_project_data/MM_.dta", clear

sort id 
merge id using "$dir_project_data/MM_5cl.dta"
tab _merge
tab cl
tab cl, m

rename id lopnr_personnr
sort lopnr_personnr

reshape  long cup wch soc pov llow ltop dtop own dis, i(lopnr_personnr) j(age)

bys cl age: egen cup_cl=mean(cup)
bys cl age: egen wch_cl=mean(wch)
bys cl age: egen soc_cl=mean(soc)
bys cl age: egen pov_cl=mean(pov)
bys cl age: egen llow_cl=mean(llow)
bys cl age: egen ltop_cl=mean(ltop)
bys cl age: egen dtop_cl=mean(dtop)
bys cl age: egen own_cl=mean(own)
bys cl age: egen dis_cl=mean(dis)

tab cl

keep age cl *_cl
duplicates drop

label define class 1 "LC1 (18.36%)" 2 "LC2 (29.78%)" 3 "LC3 (19.24%)" 4 "LC4 (15.44%)" 5 "LC5 (17.18%)", replace
label values cl class

label var cup_cl "couple"
label var wch_cl "with child"

label var soc_cl "social benefits"
label var pov_cl "poverty"
label var dtop_cl "top disp inc"
label var llow_cl "low earned inc"
label var ltop_cl "top earned inc"
label var own_cl "house owner"
label var dis_cl "labour market distress"

save "$dir_project_data/MM_5cl_averages.dta", replace

graph twoway line cup_cl wch_cl age, by(cl) saving("$dir_project_outputs/MM_family.gph", replace)
graph export "$dir_project_outputs/MM_family.pdf", replace
graph twoway line llow_cl dis_cl pov_cl soc_cl age, by(cl)  saving("$dir_project_outputs/MM_disp.gph", replace)
graph export "$dir_project_outputs/MM_disp.pdf", replace
graph twoway line own_cl ltop_cl dtop_cl age, by(cl)  saving("$dir_project_outputs/MM_wealth.gph", replace)
graph export "$dir_project_outputs/MM_wealth.pdf", replace

*************************************************
*LM
*************************************************

clear
import delimited "\\micro.intra\projekt\P0623$\P0623_Gem\Juta\Mplus\Output\LM2.txt", delimiter(" ", collapse) encoding(Big5) 
de

rename v172 id
rename v171 cl

sort id
keep v166-id

rename v166 cl1_p
rename v167 cl2_p
rename v168 cl3_p
rename v169 cl4_p
rename v170 cl5_p

egen max_p=rowmax( cl1_p - cl5_p )
gen in_cl=1

duplicates report id
save "$dir_project_data/LM_5cl.dta", replace

*************************************************
*TR
*************************************************

clear
import delimited "\\micro.intra\projekt\P0623$\P0623_Gem\Juta\Mplus\Output\TR2.txt", delimiter(" ", collapse) encoding(Big5) 
de

rename v173 id
rename v172 cl

sort id
keep v167-id

rename v167 cl1_p
rename v168 cl2_p
rename v169 cl3_p
rename v170 cl4_p
rename v171 cl5_p

egen max_p=rowmax( cl1_p - cl5_p )
gen in_cl=1

duplicates report id
save "$dir_project_data/TR_5cl.dta", replace


*************************************************
*YO
*************************************************


clear
import delimited "\\micro.intra\projekt\P0623$\P0623_Gem\Juta\Mplus\Output\YO2.txt", delimiter(" ", collapse) encoding(Big5) 
de

rename v112 id
rename v111 cl

sort id
keep v106-id

rename v106 cl1_p
rename v107 cl2_p
rename v108 cl3_p
rename v109 cl4_p
rename v110 cl5_p

egen max_p=rowmax( cl1_p - cl5_p )
gen in_cl=1

duplicates report id
save "$dir_project_data/YO_5cl.dta", replace

*************************************************
*MO
*************************************************


clear
import delimited "\\micro.intra\projekt\P0623$\P0623_Gem\Juta\Mplus\Output\MO2.txt", delimiter(" ", collapse) encoding(Big5) 
de

rename v112 id
rename v111 cl

sort id
keep v106-id

rename v106 cl1_p
rename v107 cl2_p
rename v108 cl3_p
rename v109 cl4_p
rename v110 cl5_p

egen max_p=rowmax( cl1_p - cl5_p )
gen in_cl=1

duplicates report id
save "$dir_project_data/MO_5cl.dta", replace

*************************************************
*OO
*************************************************


clear
import delimited "\\micro.intra\projekt\P0623$\P0623_Gem\Juta\Mplus\Output\OO2.txt", delimiter(" ", collapse) encoding(Big5) 
de

rename v112 id
rename v111 cl

sort id
keep v106-id

rename v106 cl1_p
rename v107 cl2_p
rename v108 cl3_p
rename v109 cl4_p
rename v110 cl5_p

egen max_p=rowmax( cl1_p - cl5_p )
gen in_cl=1

duplicates report id
save "$dir_project_data/OO_5cl.dta", replace

