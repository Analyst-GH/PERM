
****************************
/*GENERATE education measures */

****************************
/* list revisions here, who did them, and what they were */
* Version 2020-10-21: Gawain. First build


**********************************************
** Global macros
set more off
global datasave  "\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\mydata\NewSIPBaseData"		/*Save own Data*/
global mydata  "\\micro.intra\projekt\P0524$\P0524_gem\TN_MK_MF_School_reform_health_SES\mydata"
global dataFoB50 "\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\mydata\FoB50"		/*Save own Data*/


/*Merge education register and census education data */

* base sample * 
use id male cohort using $datasave\BaseNewSIP.dta ,   clear

save  $datasave\EducNewSIP.dta, replace
clear

******************
/*Merge Fob1970 education*/
******************
odbc load, exec("select * from dbo.FoB70") dsn("P0524_LU_Arbetslivet") clear
bysort LopNr_PersonNr: gen counter=_N
drop if counter!=1 		/* 356 obs dropped */
drop counter
tempfile FOB70
save `FOB70'

use $datasave\EducNewSIP.dta, clear
mmerge  id  using `FOB70', type(1:1) umatch(LopNr_PersonNr) ukeep( SkolUtbAlm) 
drop if _merge==2
drop _merge

save $datasave\EducNewSIP.dta, replace


******************
/*Merge Own and Parent's education register data*/
******************
odbc load, exec("select * from dbo.Utbildning_Ackumulerad") dsn("P0524_LU_Arbetslivet") clear
* merge with use $data\ID_EDUAGG.dta, clear and check if same
*global data  "\\micro.intra\projekt\P0524$\P0524_gem\TN_MK_MF_School_reform_health_SES\"
*cd "\\micro.intra\projekt\P0524$\P0524_gem\TN_MK_MF_School_reform_health_SES\"
*bysort LopNr_PersonNr: gen counter=_N
*drop if counter!=1 		/* 18 obs dropped */
*drop counter
*mmerge LopNr_PersonNr using "ID_EDUAGG.dta", type(1:n) umatch(id)  uname(OLD_) 
* Using the aggregated data makes it difficult to replicate our results as these change over time, maybe should just use latest year and then go back 5 years filling in the missing observations?

destring SUN2000Niva, force gen(sun2000edu_2)
bysort LopNr_PersonNr: egen sun2000edu_3=max(sun2000edu_2 )
destring SUN2000Niva_old, force gen(SUN2000Niva_old_2)
bysort LopNr_PersonNr: egen SUN2000Niva_old_3=max(SUN2000Niva_old_2 )

bysort LopNr_PersonNr: gen dup=_n
drop if dup>1		/* 9 obs dropped */
drop SUN2000Niva SUN2000Niva_old sun2000edu_2 SUN2000Niva_old_2
rename sun2000edu_3 SUN2000Niva
rename SUN2000Niva_old_3 SUN2000Niva_old
drop dup
tempfile edu
save `edu'

use $datasave\EducNewSIP.dta, clear
mmerge  id  using `edu', type(1:1) umatch(LopNr_PersonNr) ukeep(ExamAr SUN2000Niva SUN2000Niva_old) 
drop if _merge==2
drop _merge

save $datasave\EducNewSIP.dta, replace


odbc load, exec("select * from dbo.Individ_1990") dsn("P0524_LU_Arbetslivet") clear
destring Sun2000Niva, force gen(sun2000edu_2)
bysort LopNr_PersonNr: egen sun2000edu_3=max(sun2000edu_2 )
destring Sun2000Niva_old, force gen(SUN2000Niva_old_2)
bysort LopNr_PersonNr: egen SUN2000Niva_old_3=max(SUN2000Niva_old_2 )

bysort LopNr_PersonNr: gen dup=_n
drop if dup>1		/* 25 obs dropped */
drop Sun2000Niva Sun2000Niva_old sun2000edu_2 SUN2000Niva_old_2
rename sun2000edu_3 SUN2000Niva
rename SUN2000Niva_old_3 SUN2000Niva_old
drop dup
tempfile edu
save `edu'

/*
use $datasave\EducNewSIP.dta, clear
mmerge  id  using `edu', type(1:1) umatch(LopNr_PersonNr) ukeep(Examar SUN2000Niva SUN2000Niva_old) uname(UR90_)
drop if _merge==2 
drop _merge
save $datasave\EducNewSIP.dta, replace



odbc load, exec("select * from dbo.Individ_2000") dsn("P0524_LU_Arbetslivet") clear
destring Sun2000Niva, force gen(sun2000edu_2)
bysort LopNr_PersonNr: egen sun2000edu_3=max(sun2000edu_2 )
destring Sun2000Niva_old, force gen(SUN2000Niva_old_2)
bysort LopNr_PersonNr: egen SUN2000Niva_old_3=max(SUN2000Niva_old_2 )

bysort LopNr_PersonNr: gen dup=_n
drop if dup>1		/* 10 obs dropped */
drop Sun2000Niva Sun2000Niva_old sun2000edu_2 SUN2000Niva_old_2
rename sun2000edu_3 SUN2000Niva
rename SUN2000Niva_old_3 SUN2000Niva_old
drop dup
tempfile edu
save `edu'

use $datasave\EducNewSIP.dta, clear
mmerge  id  using `edu', type(1:1) umatch(LopNr_PersonNr) ukeep(Examar SUN2000Niva SUN2000Niva_old) uname(UR00_)
drop if _merge==2 
drop _merge
save $datasave\EducNewSIP.dta, replace


odbc load, exec("select * from dbo.Individ_2010") dsn("P0524_LU_Arbetslivet") clear
destring Sun2000Niva, force gen(sun2000edu_2)
bysort Person_LopNr: egen sun2000edu_3=max(sun2000edu_2 )
destring Sun2000Niva_old, force gen(SUN2000Niva_old_2)
bysort Person_LopNr: egen SUN2000Niva_old_3=max(SUN2000Niva_old_2 )

bysort Person_LopNr: gen dup=_n
drop if dup>1		/* 50,935 obs dropped */
drop Sun2000Niva Sun2000Niva_old sun2000edu_2 SUN2000Niva_old_2
rename sun2000edu_3 SUN2000Niva
rename SUN2000Niva_old_3 SUN2000Niva_old
drop dup
tempfile edu
save `edu'

use $datasave\EducNewSIP.dta, clear
mmerge  id  using `edu', type(1:1) umatch(Person_LopNr) ukeep(Examar SUN2000Niva SUN2000Niva_old) uname(UR10_)
drop if _merge==2 
drop _merge
save $datasave\EducNewSIP.dta, replace


*/
/*OWN EDUCATION
	Four variables:
	-> 1: yrseducFOB - Years of Schooling (FOB) (valid for those born before 1953)
    -> 2: postschooling - Years of Post Schooling (LISA)
	-> 3: yearseduc_FOB - Years of Education (yrseducFOB+postschooling) 
	-> 4: yrseducLISA - Years of Education (LISA)
	-> 5: yrseducMP - Years of Education (same algorithm as Meghir and Palme 2005) (LISA)
*/

use $datasave\EducNewSIP.dta, clear
rename SUN2000Niva educLISA
rename SkolUtbAlm utb70
destring utb70, replace
/* Years of Schooling based on FoB70*/
gen yrseducFOB=12 if  	utb70<99			/*Set everything to Gymn except without skolutbildining*/
replace yrseducFOB=7 if utb70==11				/*Replace 7Year Folkskola*/
replace yrseducFOB=8 if utb70==21				/*Replace 8Year Folkskola*/
replace yrseducFOB=9 if utb70==31				/*Replace 9Year Folkskola/Grundskola*/
replace yrseducFOB=9 if utb70==41				/*Replace Realskola*/
replace yrseducFOB=11 if utb70>=61 & utb70<70				/*11 Years Gymnasium if Ekonomisk lin. according to SUN2000*/
replace yrseducFOB=11 if utb70==62				/*11 Years Gymnasium if Ekonomisk lin. according to SUN2000*/
replace yrseducFOB=11 if utb70==65				/*11 Years Gymnasium if Ekonomisk lin. according to SUN2000*/
replace yrseducFOB=11 if utb70==67				/*11 Years Gymnasium if Ekonomisk lin. according to SUN2000*/
replace yrseducFOB=11 if utb70==69				/*11 Years Gymnasium if Ekonomisk lin. according to SUN2000*/
replace yrseducFOB=. if utb70==.
replace yrseducFOB=. if utb70==99
replace yrseducFOB=. if utb70==89
lab var yrseducFOB "Years of Schooling (census 1970)"

/* Years of Post Schooling based on LISA*/
gen postschooling=0 if educLISA<400
replace postschooling=1 if 	educLISA==317 | educLISA==313 | educLISA==310	/* One Year Vocational Training*/
replace postschooling=2 if 	educLISA==327 | educLISA==323 | educLISA==320	/* Two Year Vocational Training*/
replace postschooling=3 if 	educLISA==337 | educLISA==333 | educLISA==330	/* Two Year Vocational Training*/

replace postschooling=1 if 	educLISA>400 & educLISA<430							/* One Year Post Secondary Education*/
replace postschooling=2 if 	educLISA>=520 & educLISA<530										/* Two Years Post Secondary Education*/
replace postschooling=3 if 	educLISA>=530 & educLISA<540											/* Three Years Post Secondary Education*/
replace postschooling=4 if 	educLISA>=540 & educLISA<550											/* Four Years Post Secondary Education*/
replace postschooling=5 if 	educLISA>=550 & educLISA<560											/* Five Years Post Secondary Education*/
replace postschooling=7 if 	educLISA>=600 & educLISA<640						/* Lic. university education */
replace postschooling=9 if 	educLISA==640										/* PhD university education */

cap drop  yearseduc_FOB
gen yearseduc_FOB=yrseducFOB
replace yearseduc_FOB=yrseducFOB+postschooling if postschooling!=.
lab var yearseduc_FOB "Years of education (Census 1970 schooling + Postschooling)"

/*years of Education using LISA (aggregated)*/
gen yrseducLISA=.
replace yrseducLISA=7 if  	educLISA<200							/* (old) primary school */
replace yrseducLISA=9 if 	educLISA==206 							/* (new) primary school */
replace yrseducLISA=9.5 if educLISA==204 | educLISA==200 	/* (old) secondary school */
replace yrseducLISA=10 if 	educLISA>300 & educLISA<320 	/* very short high school */
replace yrseducLISA=11 if 	educLISA>=320 & educLISA<330	/* short high school */
replace yrseducLISA=12 if 	educLISA>=330 & educLISA<400	/* long high school */
replace yrseducLISA=14 if 	educLISA>400 & educLISA<530		/* short university */
replace yrseducLISA=15.5 if educLISA>=530 & educLISA<600	/* long university */
replace yrseducLISA=19 if 	educLISA>=600 & educLISA<640		/* PhD university education */
replace yrseducLISA=21 if 	educLISA==640	
lab var yrseducLISA "Years of Education (Aggregated Education Register)"

/*years of Education using LISA (non-aggregated)
capture drop educLISA
gen educLISA=UR10_SUN2000Niva
replace educLISA=UR00_SUN2000Niva if educLISA==.
replace educLISA=UR00_SUN2000Niva if UR00_SUN2000Niva>educLISA & UR00_SUN2000Niva<999
replace educLISA=UR90_SUN2000Niva if educLISA==.
replace educLISA=UR90_SUN2000Niva if UR90_SUN2000Niva>educLISA & UR90_SUN2000Niva<999


gen yrseducLISA2=.
replace yrseducLISA2=7 if  	educLISA<200							/* (old) primary school */
replace yrseducLISA2=9 if 	educLISA==206 							/* (new) primary school */
replace yrseducLISA2=9.5 if educLISA==204 | educLISA==200 	/* (old) secondary school */
replace yrseducLISA2=10 if 	educLISA>300 & educLISA<320 	/* very short high school */
replace yrseducLISA2=11 if 	educLISA>=320 & educLISA<330	/* short high school */
replace yrseducLISA2=12 if 	educLISA>=330 & educLISA<400	/* long high school */
replace yrseducLISA2=14 if 	educLISA>400 & educLISA<530		/* short university */
replace yrseducLISA2=15.5 if educLISA>=530 & educLISA<600	/* long university */
replace yrseducLISA2=19 if 	educLISA>=600 & educLISA<640		/* PhD university education */
replace yrseducLISA2=21 if 	educLISA==640	
lab var yrseducLISA2 "Years of Education (Register years 1990, 2000, 2010)"
drop UR90_Examar UR90_SUN2000Niva UR90_SUN2000Niva_old UR00_Examar UR00_SUN2000Niva UR00_SUN2000Niva_old UR10_Examar UR10_SUN2000Niva UR10_SUN2000Niva_old
*/

/*Generate Education Variables*/
cap drop yrseducMP
gen yrseducMP=.
replace yrseducMP=7 if  	SUN2000Niva_old<2						/* (old) primary school */
replace yrseducMP=9 if 		SUN2000Niva_old==2 							/* (new) primary school */
replace yrseducMP=11.5 if 	SUN2000Niva_old==3		/* short high school */
replace yrseducMP=13 if 	SUN2000Niva_old==4			/* long high school */
replace yrseducMP=15 if 	SUN2000Niva_old==5			/* short university */
replace yrseducMP=17 if 	SUN2000Niva_old==6			/* long university */
replace yrseducMP=21 if 	SUN2000Niva_old==7			/* PhD university education */
lab var yrseducMP "Years of Education (MP 2005)"

cap drop yrseduc_MP
gen yrseduc_MP=.
replace yrseduc_MP=7.33 if yrseducLISA==7
replace yrseduc_MP=9.62 if yrseducLISA>=9 & yrseducLISA<10
replace yrseduc_MP=10.39 if yrseducLISA>=10 & yrseducLISA<12
replace yrseduc_MP=12.19 if yrseducLISA==12
replace yrseduc_MP=13.87 if yrseducLISA==14
replace yrseduc_MP=16.77 if yrseducLISA==15.5
replace yrseduc_MP=19.57 if yrseducLISA>=19 & yrseducLISA<22
lab var yrseducMP "Years of Education (MP 2005 alternative)"

* drop variables no longer needed
drop ExamAr  SUN2000Niva_old 



 /*Years of Education as In Palme 2005
gen less9=( yrseduc_MP<9) if  yrseduc_MP<.
gen  exact9=(yrseduc_MP>=9 & yrseduc_MP<10) if yrseduc_MP<.
gen more9=(yrseduc_MP>10) if yrseduc_MP<.
 
 
lab var less9 "less than 9 years of schooling"
lab var exact9 "9 years of schooling"
lab var  more9 "More than 9 years of schooling"
*/
 save $datasave\EducNewSIP.dta, replace

/*Merge Occupation for Imputation if missing Census 1970*/


odbc load, exec("select * from dbo.FoB60") dsn("P0524_LU_Arbetslivet") clear
bysort LopNr_PersonNr: gen counter=_N
drop if counter!=1		/* 34,257 obs dropped, which is what was done in old SIP. These are likely due to manual coding in the 60s (thinks SCB) */ 
drop counter

tempfile FOB60
save `FOB60'
 
 
/*Update Information for missing values using Flergenerations Registret*/

global   par_varlist "prof_E   occup_id_E"

use id $par_varlist using  "$dataFoB50\FoB50_pob.dta", clear

bysort id: gen counter=_N
drop if counter!=1 		/* 356 obs dropped */
drop counter
tempfile FOB50
save `FOB50'

 use $datasave\EducNewSIP.dta, clear
 
mmerge  id  using `FOB50', type(1:1)   ukeep($par_varlist)  
 

**Add profession from 1960 Census

 cap drop _m
mmerge  id  using `FOB60', type(1:1) umatch(LopNr_PersonNr) ukeep(SEI Utbild Yrke) uname(FoB60_)
drop if _m==2
drop _merge	

**1950 Census Occupation comes as string - use translation into 1960 codes
** For each 1950 occupation -> mode in 1960 to classify occupation by SEI and YRKE

merge m:1 prof_E   occup_id_E using "$dataFoB50\FoB50_Yrke60_crw.dta", keepusing(FoB60_Yrke FoB60_SEI) update
drop if _m==2
drop _merge	
 
**Reform Status for schooling variable 
 
cap drop _merge	
merge 1:1 id using "$datasave\ReformsNewSIP.dta", keepusing(treat7id_s)  
drop if _m==2
cap drop _merge	
 
 
cap drop _merge	
merge 1:1 id using "$datasave\ReformsNewSIP.dta", keepusing(treat8d)  
drop if _m==2
cap drop _merge	 
 
  /*Adjust Years of Education for 6 Years + further corrections*/ 
 
 gen yrseducLISA_B=yrseducLISA
 
  replace yrseducLISA_B=9  if yrseducLISA_B==9.5	 								/*Re-Adjust for Old Realskola*/

 
cap drop yrseducFOB_B
 gen yrseducFOB_B=yrseducFOB
*replace yrseducFOB_B=yrseducFOB+.5   if utb70==41	& inrange(cohort,1911,1954)									/*Adjust for Old Realskola*/
replace yrseducFOB_B=12   if inrange(educLISA,400,799) & yrseducFOB<11	& inrange(cohort,1911,1954)				/*Set Gymn always if Post-Sec Uni Degreee*/
replace yrseducFOB_B=12  if  educLISA==336 			& inrange(cohort,1911,1954)									/*Set Gymn 12 despite of FoB70*/
replace yrseducFOB_B=11  if  educLISA==326 		& inrange(cohort,1911,1954)										/*Set Gymn 11 despite of FoB70*/ 

**For Impuation cells need to be sufficiently large (curse of dim.) - 10 year cohort bins
**For changes cohort bins, exchange 10 in next line

	gen cohort10=floor(cohort/10)*10	
	replace cohort10=. if cohort10>1950
	replace cohort10=1910 if cohort10<1910
	tab  cohort cohort10	
	
	cap drop higheduc60
	gen higheduc60=(FoB60_Utbild!="000") if FoB60_Utbild!=""	
	
** Impute based on 10-year cohort bins, gender, 1950 Yrke in 1960 Categories, High Eduaction in 1960
	
	bys cohort10  FoB60_Yrke  male  FoB60_SEI  higheduc6: egen yrseducFOB_IMP=mode(yrseducFOB_B) 
	bys cohort10   FoB60_Yrke  male  FoB60_SEI  higheduc6: egen postschooling_IMP=mean(postschooling) 
	*bys cohort   FoB60_Yrke  male  FoB60_SEI  higheduc6: egen postschooling_IMP2=mode(postschooling) 
	

 replace yrseducFOB_B=6 if utb70==11 &  treat7id_s ==0	& inrange(cohort,1911,1954)							/*Replace 6 Year Folkskola*/
 replace yrseducFOB_IMP=6 if yrseducFOB_IMP==7 &  treat7id_s ==0	 							/*Replace 6 Year Folkskola (Fathers)*/
 
cap drop yearseduc_FOB_B
gen yearseduc_FOB_B=yrseducFOB_B+postschooling


cap drop yearseduc_FOB_C
gen yearseduc_FOB_C=yearseduc_FOB_B if cohort<=1954
replace yearseduc_FOB_C=yrseducLISA   if inrange(cohort,1955,1985)
*replace yearseduc_FOB_C=8   if yrseducLISA==7 & treat8d==1 & inrange(cohort,1955,1985)
  
 
cap drop yearseduc_FOB_IMP
gen yearseduc_FOB_IMP=yearseduc_FOB_C  
replace yearseduc_FOB_IMP=yrseducFOB_IMP+postschooling_IMP if   yearseduc_FOB_C==. & inrange(cohort,1890,1929)			/*Only impute for early cohorts*/

drop prof_E occup_id_E FoB60_SEI FoB60_Utbild FoB60_Yrke treat7id_s cohort10 higheduc60 treat8d
binscatter yearseduc_FOB_IMP cohort, discrete linet(none)
drop male cohort
compress
 save $datasave\EducNewSIP.dta, replace
 
