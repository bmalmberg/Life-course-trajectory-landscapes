*********************************************************
* SUDA (Stockholm University Demography Unit)
* Collaborative code 
*********************************************************

/********************************************************
Calculate segregation between classes
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

log using "$dir_project_logs\06_calculating_segregation_index_`today'`time'.log", replace


clear
import delimited "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\geocontext_k400_to_25600_2019.csv"

cd "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Files\"

/*
LM1
LM2
LM3
LM4
LM5
MM1
MM2
MM3
MM4
MM5
MO1
MO2
MO3
MO4
MO5
OO1
OO2
OO3
OO4
OO5
TA1
TA2
TA3
TA4
TA5
TR1
TR2
TR3
TR4
TR5
YM1
YM2
YM3
YM4
YM5
YO1
YO2
YO3
YO4
YO5
*/

*Here we will focus only on the groups up to TR - transition to retirement

keep x y total cl1_sum- cl10_sum cl21_sum- cl35_sum k400_cl1_sum- k400_cl10_sum k400_cl21_sum- k400_cl35_sum

rename cl1_sum lm1
rename cl2_sum lm2
rename cl3_sum lm3
rename cl4_sum lm4
rename cl5_sum lm5
rename cl6_sum mm1
rename cl7_sum mm2
rename cl8_sum mm3
rename cl9_sum mm4
rename cl10_sum mm5
*rename cl11_sum mo1
*rename cl12_sum mo2
*rename cl13_sum mo3
*rename cl14_sum mo4
*rename cl15_sum mo5
*rename cl16_sum oo1
*rename cl17_sum oo2
*rename cl18_sum oo3
*rename cl19_sum oo4
*rename cl20_sum oo5
rename cl21_sum ta1
rename cl22_sum ta2
rename cl23_sum ta3
rename cl24_sum ta4
rename cl25_sum ta5
rename cl26_sum tr1
rename cl27_sum tr2
rename cl28_sum tr3
rename cl29_sum tr4
rename cl30_sum tr5
rename cl31_sum ym1
rename cl32_sum ym2
rename cl33_sum ym3
rename cl34_sum ym4
rename cl35_sum ym5
*rename cl36_sum yo1
*rename cl37_sum yo2
*rename cl38_sum yo3
*rename cl39_sum yo4
*rename cl40_sum yo5

rename k400_cl1_sum lm1_400
rename k400_cl2_sum lm2_400
rename k400_cl3_sum lm3_400
rename k400_cl4_sum lm4_400
rename k400_cl5_sum lm5_400
rename k400_cl6_sum mm1_400
rename k400_cl7_sum mm2_400
rename k400_cl8_sum mm3_400
rename k400_cl9_sum mm4_400
rename k400_cl10_sum mm5_400
rename k400_cl21_sum ta1_400
rename k400_cl22_sum ta2_400
rename k400_cl23_sum ta3_400
rename k400_cl24_sum ta4_400
rename k400_cl25_sum ta5_400
rename k400_cl26_sum tr1_400
rename k400_cl27_sum tr2_400
rename k400_cl28_sum tr3_400
rename k400_cl29_sum tr4_400
rename k400_cl30_sum tr5_400
rename k400_cl31_sum ym1_400
rename k400_cl32_sum ym2_400
rename k400_cl33_sum ym3_400
rename k400_cl34_sum ym4_400
rename k400_cl35_sum ym5_400


*create proportions for each class for each individualised neighbourhood
foreach gp1 of varlist lm1- ym5 {
	foreach gp2 of varlist  lm1- ym5 {
	
		
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
order classes1 classes2 V_

matrix M=J(25,25, .)
local counter 1

forvalues j=1/25 {
	forvalues i=1/25{
	
	matrix M[`i', `j']=V_[`counter']
	local ++counter
	}
}

putexcel set "matrix2.xlsx", sheet("M2") replace
putexcel A1=matrix(M)


*Group vs not group
clear
import delimited "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\geocontext_k400_to_25600_2019.csv"

cd "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Files\"

keep x y total cl1_sum- cl10_sum cl21_sum- cl35_sum k400_cl1_sum- k400_cl10_sum k400_cl21_sum- k400_cl35_sum

rename cl1_sum lm1
rename cl2_sum lm2
rename cl3_sum lm3
rename cl4_sum lm4
rename cl5_sum lm5
rename cl6_sum mm1
rename cl7_sum mm2
rename cl8_sum mm3
rename cl9_sum mm4
rename cl10_sum mm5
rename cl21_sum ta1
rename cl22_sum ta2
rename cl23_sum ta3
rename cl24_sum ta4
rename cl25_sum ta5
rename cl26_sum tr1
rename cl27_sum tr2
rename cl28_sum tr3
rename cl29_sum tr4
rename cl30_sum tr5
rename cl31_sum ym1
rename cl32_sum ym2
rename cl33_sum ym3
rename cl34_sum ym4
rename cl35_sum ym5

rename k400_cl1_sum lm1_400
rename k400_cl2_sum lm2_400
rename k400_cl3_sum lm3_400
rename k400_cl4_sum lm4_400
rename k400_cl5_sum lm5_400
rename k400_cl6_sum mm1_400
rename k400_cl7_sum mm2_400
rename k400_cl8_sum mm3_400
rename k400_cl9_sum mm4_400
rename k400_cl10_sum mm5_400
rename k400_cl21_sum ta1_400
rename k400_cl22_sum ta2_400
rename k400_cl23_sum ta3_400
rename k400_cl24_sum ta4_400
rename k400_cl25_sum ta5_400
rename k400_cl26_sum tr1_400
rename k400_cl27_sum tr2_400
rename k400_cl28_sum tr3_400
rename k400_cl29_sum tr4_400
rename k400_cl30_sum tr5_400
rename k400_cl31_sum ym1_400
rename k400_cl32_sum ym2_400
rename k400_cl33_sum ym3_400
rename k400_cl34_sum ym4_400
rename k400_cl35_sum ym5_400


*create proportions for each class for each individualised neighbourhood
foreach gp1 of varlist lm1-ym5 {
	
	egen temp1=rowtotal(lm1-ym5)
	gen gp2=temp-`gp1'
	egen cell_t=rowtotal(`gp1' gp2)
	
	egen temp2=rowtotal(lm1_400-ym5_400)	
	gen gp1_p=(`gp1'_400)/temp2
	gen gp2_p=(temp2-`gp1'_400)/temp2

	egen GP1=sum(`gp1')
	egen TEMP=rowtotal(lm1- ym5)
	egen GP2=sum(TEMP-`gp1')

	egen T_t=rowtotal(GP1-GP2)
	gen GP1_p=GP1/(GP1+GP2)	
	gen GP2_p=GP2/(GP1+GP2)	

	gen double cur = cell_t* (gp1_p-GP1_p)^2/(T_t*(1-GP1_p)*GP1_p)
	egen V_`gp1'= total(cur)

	drop gp2 cell_t-cur	temp* TEMP				
}


keep V_*
duplicates drop
gen id=1
reshape long V_, i(id) j(classes, string)


*Group vs. not group within own life phase

clear
import delimited "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Laten Class Analysis\Data\geocontext_k400_to_25600_2000.csv"

cd "\\micro.intra\Projekt\P0623$\P0623_Gem\Juta\Files\"

keep x y total cl1_sum- cl10_sum cl21_sum- cl35_sum k400_cl1_sum- k400_cl10_sum k400_cl21_sum- k400_cl35_sum

rename cl1_sum lm1
rename cl2_sum lm2
rename cl3_sum lm3
rename cl4_sum lm4
rename cl5_sum lm5
rename cl6_sum mm1
rename cl7_sum mm2
rename cl8_sum mm3
rename cl9_sum mm4
rename cl10_sum mm5
rename cl21_sum ta1
rename cl22_sum ta2
rename cl23_sum ta3
rename cl24_sum ta4
rename cl25_sum ta5
rename cl26_sum tr1
rename cl27_sum tr2
rename cl28_sum tr3
rename cl29_sum tr4
rename cl30_sum tr5
rename cl31_sum ym1
rename cl32_sum ym2
rename cl33_sum ym3
rename cl34_sum ym4
rename cl35_sum ym5

rename k400_cl1_sum lm1_400
rename k400_cl2_sum lm2_400
rename k400_cl3_sum lm3_400
rename k400_cl4_sum lm4_400
rename k400_cl5_sum lm5_400
rename k400_cl6_sum mm1_400
rename k400_cl7_sum mm2_400
rename k400_cl8_sum mm3_400
rename k400_cl9_sum mm4_400
rename k400_cl10_sum mm5_400
rename k400_cl21_sum ta1_400
rename k400_cl22_sum ta2_400
rename k400_cl23_sum ta3_400
rename k400_cl24_sum ta4_400
rename k400_cl25_sum ta5_400
rename k400_cl26_sum tr1_400
rename k400_cl27_sum tr2_400
rename k400_cl28_sum tr3_400
rename k400_cl29_sum tr4_400
rename k400_cl30_sum tr5_400
rename k400_cl31_sum ym1_400
rename k400_cl32_sum ym2_400
rename k400_cl33_sum ym3_400
rename k400_cl34_sum ym4_400
rename k400_cl35_sum ym5_400

*create proportions for each class for each individualised neighbourhood
foreach gp1 of varlist lm1-lm5 {
	
	egen temp1=rowtotal(lm1-lm5)
	gen gp2=temp-`gp1'
	egen cell_t=rowtotal(`gp1' gp2)
	
	egen temp2=rowtotal(lm1_400-lm5_400)	
	gen gp1_p=(`gp1'_400)/temp2
	gen gp2_p=(temp2-`gp1'_400)/temp2

	egen GP1=sum(`gp1')
	egen TEMP=rowtotal(lm1-lm5)
	egen GP2=sum(TEMP-`gp1')

	egen T_t=rowtotal(GP1-GP2)
	gen GP1_p=GP1/(GP1+GP2)	
	gen GP2_p=GP2/(GP1+GP2)	

	gen double cur = cell_t* (gp1_p-GP1_p)^2/(T_t*(1-GP1_p)*GP1_p)
	egen V_`gp1'= total(cur)

	drop gp2 cell_t-cur	temp* TEMP				
}


keep V_*
duplicates drop
gen id=1
reshape long V_, i(id) j(classes, string)
