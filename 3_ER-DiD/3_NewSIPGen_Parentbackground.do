
****************************
/*GENERATE PARENTAL BACKGROUND */
/* This file generates parental education and SES using Census 60 and 70 */
****************************
/* list revisions here, who did them, and what they were */
* Version 2020-10-21: Gawain. First build
* Version 2020-12-03: Martin. Keep Fathers utb70 (line 168)


**********************************************
** Global macros
set more off
global datasave  "\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\mydata\NewSIPBaseData"		/*Save own Data*/
global mydata  "\\micro.intra\projekt\P0524$\P0524_gem\TN_MK_MF_School_reform_health_SES\mydata"


* base sample * 
use $datasave\EducNewSIP.dta, clear
tempfile edu
save `edu'
use id Lopnr_Far Lopnr_Mor MOR60_Yrke FAR60_Yrke FAR60_SEI using $datasave\BaseNewSIP.dta ,   clear

save  $datasave\ParentBNewSIP.dta, replace

*use  $datasave\EducNewSIP.dta, clear
mmerge  Lopnr_Far  using `edu', type(n:1) umatch(id) ukeep(yrseducLISA yrseducFOB utb70) uname(FAR_)
drop if _merge==2
drop _merge

mmerge  Lopnr_Mor  using `edu', type(n:1) umatch(id) ukeep(yrseducLISA yrseducFOB utb70) uname(MOR_)
drop if _merge==2
drop _merge 


/*PARENT'S EDUCATION, OCCUPATION & SES
	Four variables:
	-> 1: yrseducFOB(F/M) - Years of Schooling (FOB 1970) (valid for those born before 1953)
	-> 2: yrseducLISA(F/M) - Years of Education (LISA)
	-> 3: OCC(M/F) - Occupation 
	-> 4: SEI(M/F) - Social Economic Indicator 
	*/

/*Mother Occupational Codes 1960*/

replace MOR60_Yrke="" if MOR60_Yrke=="0"
gen codeocc=substr(MOR60_Yrke,1,1)
destring codeocc, replace
destring MOR60_Yrke, gen(yrke60)
*Set missing if yrke=Personer med ej identifierbara yrken
replace codeocc=. if codeocc==999
replace yrke60=. if codeocc==999
*generate one group for tillverkningsarbete
replace codeocc=7 if codeocc==7|codeocc==8

*generate naturvetenskapligt, tekniskt group
replace codeocc=0 if yrke60<100 &  yrke60>0

*Missings 
replace codeocc=999 if yrke60==0
*replace codeocc=. if syss60==9

#delimit ;
label define codeocc
0 "Scientific, Medical, Technical"
1 "Administrative"
2 "Accounting, Administrative"
3 "Sales"
4 "Agricultural"
5 "Mining"
6 "Transport, Communication"
7 "Crafts"
9 "Service"
999 "No occupation"
, replace
;
#delimit cr
lab val codeocc codeocc
 tab codeocc

cap drop occ1-occ999
tab codeocc, gen(occ)
forvalues i = 1(1)10 {
rename occ`i' occ`i'm
}

lab var occ1m "Scientific, Medical, Technical"
lab var occ2m "Administrative"
lab var occ3m "Accounting"
lab var occ4m "Sales"
lab var occ5m "Agricultural"
lab var occ6m "Mining"
lab var occ7m "Transport, Communication"
lab var occ8m "Crafts"
lab var occ9m "Service"
lab var occ10m "No occupation"

drop MOR60_Yrke yrke60 codeocc*





/*Father Occupational Codes 1960*/

replace FAR60_Yrke="" if FAR60_Yrke=="0"
gen codeocc=substr(FAR60_Yrke,1,1)
destring codeocc, replace
destring FAR60_Yrke, gen(yrke60)
*Set missing if yrke=Personer med ej identifierbara yrken
replace codeocc=. if codeocc==999
replace yrke60=. if codeocc==999
*generate one group for tillverkningsarbete
replace codeocc=7 if codeocc==7|codeocc==8

*generate naturvetenskapligt, tekniskt group
replace codeocc=0 if yrke60<100 &  yrke60>0

*Missings 
replace codeocc=999 if yrke60==0
*replace codeocc=. if syss60==9

#delimit ;
label define codeocc
0 "Scientific, Medical, Technical"
1 "Administrative"
2 "Accounting, Administrative"
3 "Sales"
4 "Agricultural"
5 "Mining"
6 "Transport, Communication"
7 "Crafts"
9 "Service"
999 "No occupation"
, replace
;
#delimit cr
lab val codeocc codeocc
 tab codeocc

cap drop occ1-occ999
tab codeocc, gen(occ)
forvalues i = 1(1)10 {
rename occ`i' occ`i'f
}

lab var occ1f "Scientific, Medical, Technical"
lab var occ2f "Administrative"
lab var occ3f "Accounting"
lab var occ4f "Sales"
lab var occ5f "Agricultural"
lab var occ6f "Mining"
lab var occ7f "Transport, Communication"
lab var occ8f "Crafts"
lab var occ9f "Service"
lab var occ10f "No occupation"

drop FAR60_Yrke yrke60 codeocc*


/* Father High SES Indicator Variables */
cap drop hife
gen hife=(inrange(FAR_utb70,41,89)) if FAR_utb70<.
lab var hife "Highly Educated Father"

cap drop hisesf
destring FAR60_SEI, force replace
gen hisesf=( inrange(FAR60_SEI,3,6)  )  
replace hisesf=. if FAR60_SEI==.
lab var hisesf "High SES Father"


drop FAR60_SEI 
*drop FAR_utb70 

compress
 save $datasave\ParentBNewSIP.dta, replace  

