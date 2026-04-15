*********************************************************
* SUDA (Stockholm University Demography Unit)
* Collaborative code 
*********************************************************

/********************************************************
File description: Comapre results with segregation on single variable
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

log using "$dir_project_logs\07_robustness_single_variables_`today'`time'.log", replace

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

***************************************
	*Load
	
odbc load LopNr_PersonNr Ruta XKOORDsw YKOORDsw DeSO, table ("Geodata_Individ_2019") dsn("P0623") clear	
rename *,lower
duplicates tag lopnr_personnr, gen(dup)
tab dup
drop if (dup!=0)
drop dup
	
sort lopnr_personnr
capture: drop _merge

merge m:1 lopnr_personnr using "$dir_project_data/Population_PersonNr.dta"
 keep if _merge==3
 drop _merge
 sort lopnr_personnr
 
save "$dir_project_data/Geo_2019.dta", replace 	



foreach i of num 2019/2019 {
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

clear

use "$dir_project_data/LISA_2019.dta", clear
		
count
sort lopnr_personnr
merge lopnr_personnr using "$dir_project_data/Geo_2019.dta"
keep if _merge==3
drop _merge
gen age=year-fodelsear

destring dispinkfam04, replace
gen dispinkeq=dispinkfam04/konsviktf04

xtile dispinkeq_xtile=dispinkeq, nq(5)
xtile dispinkeq_xtile10=dispinkeq, nq(10) 

destring loneink, replace
xtile loneink_xtile=loneink if loneink>0, nq(5) 
xtile loneink_xtile10=loneink if loneink>0, nq(10) 

tab edu_level, gen(edu)

tab dispinkeq_xtile10, gen(disp)
tab loneink_xtile10 , gen(lon)

foreach var of varlist edu* lon* disp* {
bys xkoordsw ykoordsw: egen `var'_sum=sum(`var')	
}


keep if age>=25 & age<=64

keep xkoordsw ykoordsw edu1_sum-edu5_sum lon1_sum-lon10_sum disp1_sum-disp10_sum
drop if missing( xkoordsw)
drop if missing( ykoordsw)
duplicates drop

egen edu_total=rowtotal(edu1_sum-edu5_sum)
egen lon_total=rowtotal(lon1_sum-lon10_sum)
egen disp_total=rowtotal(disp1_sum-disp10_sum)

export delimited using "$dir_project_data/Geo_single_2019_processed.csv", replace	


* clear existing data, close open log files, change settings
capture log close
set more off
clear

clear
import delimited "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Single variables\geocontext_k400_to_400_2019.csv"

cd "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Files\"

keep x y total disp1_sum-disp10_sum k400_disp1_sum-k400_disp10_sum

rename k400_disp1_sum disp1_sum_400
rename k400_disp2_sum disp2_sum_400
rename k400_disp3_sum disp3_sum_400
rename k400_disp4_sum disp4_sum_400
rename k400_disp5_sum disp5_sum_400
rename k400_disp6_sum disp6_sum_400
rename k400_disp7_sum disp7_sum_400
rename k400_disp8_sum disp8_sum_400
rename k400_disp9_sum disp9_sum_400
rename k400_disp10_sum disp10_sum_400

*create proportions for each class for each individualised neighbourhood
foreach gp1 of varlist disp1_sum- disp10_sum {
	foreach gp2 of varlist  disp1_sum- disp10_sum {
		
	egen cell_t=rowtotal(`gp1' `gp2')

	gen gp1_p=`gp1'_400/(`gp1'_400+`gp2'_400)	
	gen gp2_p=`gp2'_400/(`gp1'_400+`gp2'_400)	

	egen GP1=sum(`gp1')
	egen GP2=sum(`gp2')

	egen T_t=rowtotal(GP1-GP2)

	gen GP1_p=GP1/(GP1+GP2)	
	gen GP2_p=GP2/(GP1+GP2)	

	gen double cur = cell_t* (gp1_p-GP1_p)^2/(T_t*(1-GP1_p)*GP1_p)
	egen V_`gp1'_`gp2'= total(cur)

	drop cell_t-cur				
	}
}

keep V_*
duplicates drop
gen id=1
reshape long V_, i(id) j(classes, string)
split classes , p("_")
drop classes id
order classes1 classes3 V_
drop classes2 classes4


split classes1 , p("disp")
split classes3 , p("disp")

keep V_ classes12 classes32

destring classes12, replace
destring classes32, replace

sort classes12 classes32

matrix M=J(10,10, .)
local counter 1

forvalues j=1/10 {
	forvalues i=1/10{
	
	matrix M[`i', `j']=V_[`counter']
	local ++counter
	}
}

putexcel set "matrix_disp10.xlsx", sheet("M2") replace
putexcel A1=matrix(M)

clear
import delimited "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Single variables\geocontext_k400_to_400_2019.csv"

cd "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Files\"

keep x y total lon1_sum-lon10_sum k400_lon1_sum-k400_lon10_sum

rename k400_lon1_sum lon1_sum_400
rename k400_lon2_sum lon2_sum_400
rename k400_lon3_sum lon3_sum_400
rename k400_lon4_sum lon4_sum_400
rename k400_lon5_sum lon5_sum_400
rename k400_lon6_sum lon6_sum_400
rename k400_lon7_sum lon7_sum_400
rename k400_lon8_sum lon8_sum_400
rename k400_lon9_sum lon9_sum_400
rename k400_lon10_sum lon10_sum_400

*create proportions for each class for each individualised neighbourhood
foreach gp1 of varlist lon1_sum- lon10_sum {
	foreach gp2 of varlist  lon1_sum- lon10_sum {
		
	egen cell_t=rowtotal(`gp1' `gp2')

	gen gp1_p=`gp1'_400/(`gp1'_400+`gp2'_400)	
	gen gp2_p=`gp2'_400/(`gp1'_400+`gp2'_400)	

	egen GP1=sum(`gp1')
	egen GP2=sum(`gp2')

	egen T_t=rowtotal(GP1-GP2)

	gen GP1_p=GP1/(GP1+GP2)	
	gen GP2_p=GP2/(GP1+GP2)	

	gen double cur = cell_t* (gp1_p-GP1_p)^2/(T_t*(1-GP1_p)*GP1_p)
	egen V_`gp1'_`gp2'= total(cur)

	drop cell_t-cur				
	}
}

keep V_*
duplicates drop
gen id=1
reshape long V_, i(id) j(classes, string)
split classes , p("_")
drop classes id
order classes1 classes3 V_
drop classes2 classes4


split classes1 , p("lon")
split classes3 , p("lon")

keep V_ classes12 classes32

destring classes12, replace
destring classes32, replace

sort classes12 classes32

matrix M=J(10,10, .)
local counter 1

forvalues j=1/10 {
	forvalues i=1/10{
	
	matrix M[`i', `j']=V_[`counter']
	local ++counter
	}
}

putexcel set "matrix_lon10.xlsx", sheet("M2") replace
putexcel A1=matrix(M)

clear
import delimited "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Single variables\geocontext_k400_to_400_2019.csv"



clear
import delimited "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Single variables\geocontext_k400_to_400_2019.csv"

cd "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Files\"

keep x y total edu1_sum-edu5_sum k400_edu1_sum-k400_edu5_sum

rename k400_edu1_sum edu1_sum_400
rename k400_edu2_sum edu2_sum_400
rename k400_edu3_sum edu3_sum_400
rename k400_edu4_sum edu4_sum_400
rename k400_edu5_sum edu5_sum_400

*create proportions for each class for each individualised neighbourhood
foreach gp1 of varlist edu1_sum- edu5_sum {
	foreach gp2 of varlist   edu1_sum- edu5_sum  {
		
	egen cell_t=rowtotal(`gp1' `gp2')

	gen gp1_p=`gp1'_400/(`gp1'_400+`gp2'_400)	
	gen gp2_p=`gp2'_400/(`gp1'_400+`gp2'_400)	

	egen GP1=sum(`gp1')
	egen GP2=sum(`gp2')

	egen T_t=rowtotal(GP1-GP2)

	gen GP1_p=GP1/(GP1+GP2)	
	gen GP2_p=GP2/(GP1+GP2)	

	gen double cur = cell_t* (gp1_p-GP1_p)^2/(T_t*(1-GP1_p)*GP1_p)
	egen V_`gp1'_`gp2'= total(cur)

	drop cell_t-cur				
	}
}

keep V_*
duplicates drop
gen id=1
reshape long V_, i(id) j(classes, string)
split classes , p("_")
drop classes id
order classes1 classes3 V_
drop classes2 classes4


split classes1 , p("edu")
split classes3 , p("edu")

keep V_ classes12 classes32

destring classes12, replace
destring classes32, replace

sort classes12 classes32

matrix M=J(5,5, .)
local counter 1

forvalues j=1/5 {
	forvalues i=1/5{
	
	matrix M[`i', `j']=V_[`counter']
	local ++counter
	}
}

putexcel set "matrix_edu5.xlsx", sheet("M2") replace
putexcel A1=matrix(M)





