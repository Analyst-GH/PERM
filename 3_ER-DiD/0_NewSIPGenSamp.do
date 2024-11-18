********************************
/*BASE DATA: All COHORTS; REFORMS*/
********************************
/* list revisions here, who did them, and what they were */
* Version 2020-10-21: Gawain. First build
* version 2024-08-15: line 50 add 2023 multigeneration update

 
**********************************************

set more off
global datasave  "\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\mydata\NewSIPBaseData"		/*Save own Data*/

global reformdata "\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\mydata\ReformData2021"
global dataFoB50 "\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\mydata\FoB50"		/*Save own Data*/
global dofolder "\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\do\DataDoFiles" 

/* STEPS:
			1.) include all cohorts 1930-1985, plus parents 
			2.) Match with Information from the parents
			3.) Match information from the Census to parents
*/

/*Variables

	id = Personal Identification Number (some few duplicates)
	bmonth = Month of Birth
	sex = Sex
	dyear = Year of Death
	birthcountry = Country of Birth
*/



odbc load, exec("select * from dbo.GrundUppg") dsn("P0524_LU_Arbetslivet") clear
rename LopNr_P* id

gen bmonth = substr(FodelseArMan, 5, 2)
destring bmonth, replace
destring FodelseArMan, replace force
gen byear = int(FodelseArMan/100)

gen bdate_error = (bmonth==0 | bmonth>12)
replace bmonth = . if bmonth==0 | bmonth>12

gen bdate = mdy(bmonth, 15, byear)
format bdate %td

tab bmonth

destring Kon, gen(male)
recode male (2=0) 

drop if FelPersonNr==1 /* FelPersonNr==1 have no info in any of the registers, so drop them (these have the birthdate errors*/
drop FelPersonNr bdate_error
drop if AterAnv==1 /*have to drop these as they can be two people in the dataset and we have no idea which is which - get different death dates for e.g */

keep id bmonth byear bdate male

label define sexlbl 1 "Male" 0 "Female", replace
label values male sexlbl

save "$datasave\INDIV_TCCny.dta", replace

odbc load, exec("select * from dbo.Fodelselandnamn") dsn("P0524_LU_Arbetslivet") clear
rename LopNr_P* id
rename fodel* birthcountry
duplicates drop id, force //drops 1 observation
merge 1:1 id using "$datasave\INDIV_TCCny.dta"
drop if _merge==1 
drop _merge
save "$datasave\INDIV_TCCny.dta", replace
odbc load, exec("select * from dbo.Fodelseforsamling") dsn("P0524_LU_Arbetslivet") clear
rename LopNr id
*rename Fodelseforskod birthparish
*rename FodelseLan birthcounty
bysort id: gen temp = _N
drop if SenPnr==0 & temp==2
drop temp
keep id Fodelse*
merge 1:1 id using "$datasave\INDIV_TCCny.dta"
drop if _merge==1 
drop _merge
sort id
save "$datasave\INDIV_TCCny.dta", replace

clear
cd "$datasave\"
unicode analyze INDIV_TCCny.dta
unicode encoding set ISO-8859-1
unicode retranslate INDIV_TCCny.dta, replace


odbc load, exec("select * from dbo.doda") dsn("P0524_LU_Arbetslivet") clear
rename LopNr_PersonNr id
bysort id: gen temp = _N
drop if  temp==2
drop temp
merge 1:1 id using "$datasave\INDIV_TCCny.dta"
drop _merge
gen dyear = int(DodDatum/10000)

tostring DodDatum, gen(deathdate)
gen ddate=date(deathdate,"YMD")
format ddate %td
drop deathdate
gen age_deathm=ddate-bdate

sort id
save "$datasave\INDIV_TCCny.dta", replace

/****************************************/
/*** Base sample selection **************/
/****************************************/


use "$datasave\INDIV_TCCny.dta"  , clear


encode birthcountry, gen(corigin)		
drop 		birthcountry 

/****************************************/
/*** Recode place of birth **************/
/****************************************/
 
merge m:1 byear FodelseForsNamn FodelseLan using "$reformdata\pbcomb_kommun4853.dta"
drop if _merge==2
drop _m*
rename byear cohort
rename kommun60 fkommun60
rename kommun53 fkommun53



 
****************************
/*Match Parents ID to KIDS*/
****************************
save $datasave\BaseNewSIP.dta, replace
odbc load, exec("select * from dbo.KopplingBioAdForaldrar") dsn("P0524_LU_Arbetslivet") clear
bysort LopNr_PersonNr: gen counter=_N
drop if counter==2
drop counter
tempfile parentID
save `parentID'

use  $datasave\BaseNewSIP.dta, clear
mmerge  id  using `parentID', type(1:1) umatch(LopNr_PersonNr)
drop if _merge==2
drop _merge

* GH update: add 2023 update to multiegenerational dataset
save $datasave\BaseNewSIP.dta, replace
*do "$dofiles\16_NewSIPFlergen2023"
use "$datasave\Flergen_bio_2023.dta", clear
tempfile parentID
save `parentID'

use  $datasave\BaseNewSIP.dta, clear
mmerge  id  using `parentID', type(1:1) umatch(id)
drop if _merge==2
drop _merge

*mmerge  id  using "$datasave\Flergen_ad_2023.dta", type(1:1) umatch(id)
*drop if _merge==2
*drop _merge


******************
/*Own and parents residence in 1960*/
******************

/* 
	1.) First sample own residence variables in 1960
	1.) second sample parents residence and SES variables in 1960
*/

save $datasave\BaseNewSIP.dta, replace
odbc load, exec("select * from dbo.FoB60") dsn("P0524_LU_Arbetslivet") clear
bysort LopNr_PersonNr: gen counter=_N
drop if counter!=1		/* 34,257 obs dropped, which is what was done in old SIP. These are likely due to manual coding in the 60s (thinks SCB) */ 
drop counter
rename Forsamling parish
rename Kommun municipality
tempfile FOB60
save `FOB60'

use $datasave\BaseNewSIP.dta, clear
mmerge  id  using `FOB60', type(1:1) umatch(LopNr_PersonNr) ukeep(parish municipality) uname(F60_)
drop if _merge==2
drop _merge

mmerge  Lopnr_Mor  using `FOB60', type(n:1) umatch(LopNr_PersonNr) uname(MOR60_) missing(nomatch)
drop if _merge==2
drop _merge

mmerge  Lopnr_Far  using `FOB60', type(n:1) umatch(LopNr_PersonNr) uname(FAR60_) missing(nomatch)
drop if _merge==2
drop _merge


******************
/*Own residence in 1965*/
******************


save $datasave\BaseNewSIP.dta, replace
odbc load, exec("select * from dbo.FoB65") dsn("P0524_LU_Arbetslivet") clear
bysort LopNr_PersonNr: gen counter=_N
drop if counter!=1 		/* 11,714 obs dropped */
drop counter
rename Forsamling parish
rename Kommun municipality
tempfile FOB65
save `FOB65'

use $datasave\BaseNewSIP.dta, clear
mmerge  id  using `FOB65', type(1:1) umatch(LopNr_PersonNr) ukeep(parish municipality) uname(F65_)
drop if _merge==2
drop _merge

save $datasave\BaseNewSIP.dta, replace




******************
/*Merge 8 and 9 year reform data */
******************

/*Note:
 		Cohorts 1943-1954	: Use own Municip. Residence from FoB 1960 
 
*/

/*Adjust for Parish Changes*/

/* Note: 
		We use for birth cohorts > 1948 the parish in 1965. 
		The data forsam6065.dta has all changes between parishes between 1960 and 1965.
		
	-> In order to balance the municip and parishes over time, we replace the 1965 codes with the corresponding 
	1960 codes in case a change occured.
*/



use $datasave\BaseNewSIP.dta, clear
cd $datasave
rename F65_parish parish_65
merge m:1 parish_65 using "forsam6065.dta", keepusing(parish_60b)
drop if _m==2
drop _m

gen ind=(parish_60b==parish_65)
replace parish_65=parish_60b if parish_60b!="" & cohort>1948
replace F65_municipality=substr(parish_60b,1,4) if parish_60b!="" & cohort>1948
rename  parish_65 F65_parish

gen parsame=(MOR60_municipality==FAR60_municipality)
gen parloc=0 if FAR60_municipality=="" & MOR60_municipality=="" 						/*No info on parents location in 1960*/
replace parloc=1 if MOR60_municipality!="" & FAR60_municipality=="" 					/*Only Mothers in FoB1960*/
replace parloc=2 if MOR60_municipality=="" & FAR60_municipality!=""						/*Only Fathers in FoB1960*/ 	
replace parloc=3 if FAR60_municipality!="" & MOR60_municipality!="" & parsame==0		/*Both are included but different place or residence*/
replace parloc=4 if FAR60_municipality!="" & MOR60_municipality!="" & parsame==1		/*Both are included and same place of residence*/


#delimit ;
label define parloc
 		0 "No Info on parents"
		1 "Only Mothers in FoB1960"
		2 "Only Fathers in FoB1960"
		3 "Both in FoB1960, but different place"
		4 "Both in FoB1960, same place"
;
#delimit cr
lab val parloc parloc
lab var parloc "Information Municipality of Residence Parents FoB60"

drop ind 
drop parsame
/*Merge Reform Information*/
 
gen muniid = F60_municipality if cohort>=1943
replace muniid=MOR60_municipality if cohort<1943
replace muniid=FAR60_municipality if cohort<1943 & parloc==2
replace muniid = F65_municipality if cohort>1948

gen parishid = F60_parish if cohort>=1943
replace parishid=MOR60_parish if cohort<1943
replace parishid=FAR60_parish if cohort<1943 & parloc==2
replace parishid = F65_parish if cohort>1948



/* muni_birth missing */
*gen muni_birth=substr(birthparish,1,4)



*************************************************
********		Merge reform data 		**********
*************************************************

destring muniid, force replace ig("")
destring parishid, force replace ig("")


*****************************
	/*8 year reform*/
*****************************


merge m:1 muniid using  "$reformdata\8yearreform.dta"
drop if _merge==2
drop _merge

gen treat8=.
replace treat8=1 if ((cohort+7+7)>=firstyear8year & firstyear8year<9999)					/*Treated if cohort chosen for reform or after*/
replace treat8=0 if ((cohort+7+7)<firstyear8year)  & firstyear8year<.					/*Zero otherwise*/
replace treat8=0 if firstyear8year==0				/*Zero otherwise*/

/* The raw data suggests the following improvements to the reform year coding */
gen firstyear8year_data=firstyear8year
replace firstyear8year_data=comp8_data if comp8_data!=.
gen treat8d=.
replace treat8d=1 if ((cohort+7+7)>=firstyear8year_data & firstyear8year_data<9999)					/*Treated if cohort chosen for reform or after*/
replace treat8d=0 if ((cohort+7+7)<firstyear8year_data)  & firstyear8year<.					/*Zero otherwise*/
replace treat8d=0 if firstyear8year_data==0				/*Zero otherwise*/

 lab var treat8 "Treatment 8 year"
 lab var treat8d "Treatment 8 year (with data led corrections)"

recode firstyear8year firstyear8year_data (0=.)
 
 

 
*****************************
	/*8 year Non-Mandatory Reform*/
*****************************

*preserve
*use "$reformdata\reform89_OCT2020.dta"
rename parishid parish60
merge m:1 parish60 using  "$reformdata\reform89_OCT2020.dta", keepusing(pivot8d pivot8d_corr)
drop if _merge==2
drop _merge

gen treat8NM=.
replace treat8NM=1 if ((cohort)>=pivot8d & pivot8d<9999)					/*Treated if cohort chosen for reform or after*/
replace treat8NM=0 if ((cohort)<pivot8d)  & pivot8d<.					/*Zero otherwise*/
replace treat8NM=0 if pivot8d==.				/*Zero otherwise*/

 
gen pivot8d2=pivot8d
replace pivot8d2=pivot8d_corr if inrange(pivot8d_corr,1900,1999)
replace pivot8d2=. if pivot8d_corr==10
replace pivot8d2=. if pivot8d2==0
drop pivot8d_corr
 
gen treat8NMD=.
replace treat8NMD=1 if ((cohort)>=pivot8d2 & pivot8d2<9999)					/*Treated if cohort chosen for reform or after*/
replace treat8NMD=0 if ((cohort)<pivot8d2)  & pivot8d2<.					/*Zero otherwise*/
replace treat8NMD=0 if pivot8d2==.				/*Zero otherwise*/


 lab var treat8NM "Treatment 8 year Non-mandatory"
 lab var treat8NMD "Treatment 8 year Non-mandatory (data corrected)"

  
*****************************
	/*9 year reform*/
*****************************
gen kommun60=muniid
merge m:1 kommun60 using "$reformdata\slutgiltiga_reformkommuner_fob60.dta"
drop if _merge==2
drop _merge

cap drop treat9
gen treat9=.
replace treat9=1 if (cohort>=firstcohort60 & firstcohort60<.)					/*Treated if cohort chosen for reform or after*/
replace treat9=0 if ((cohort)<firstcohort60) & firstcohort60<.					/*Zero otherwise*/

 

/* from Helena 2015 */
*destring parishid, replace ig("")
*rename parishid parish60
*rename kommun60 muniid
replace treat9=. if parish60==18017 /*hägersten*/
replace treat9=. if parish60==18018 /*brännkyrka*/
replace treat9=. if parish60==18019 /*vantör*/
replace treat9=. if parish60==18020 /*enskede*/
replace treat9=. if parish60==18021 /*skarpnäck*/
replace treat9=. if parish60==18022 /*farsta*/
replace treat9=. if muniid==281 /*södertälje*/
replace treat9=. if muniid==283 /*sundbyberg*/
replace treat9=. if muniid==580 /*linköping*/
replace treat9=. if muniid==680 /*jönköping*/
replace treat9=. if parish60==128007 /*limhamn*/
replace treat9=. if muniid==1283 /*hälsingborg*/
replace treat9=. if parish60==148016 /*örgryte*/
replace treat9=. if parish60==148017 /*lundby*/
replace treat9=. if parish60==148019 /*brämaregården*/
replace treat9=. if parish60==148003 /*gamlestads=st pauli*/
replace treat9=. if parish60==148006 /*härlanda*/
replace treat9=. if muniid==2482 /*skellefteå*/

*replace treat9=. if muniid==231 /*Östertajle Part of södertälje in 1965*/
*replace treat9=. if parish60==18032 /*hägersten in 1965*/
*replace treat9=. if parish60==18033 /*hägersten in 1965*/
 

 cap drop treat9b
gen treat9b=.
replace treat9b=1 if (cohort>=firstcohort60 & firstcohort60<.)					/*Treated if cohort chosen for reform or after*/
replace treat9b=0 if ((cohort)<firstcohort60) & firstcohort60<.					/*Zero otherwise*/

 lab var treat9 "Treatment Comprehensive (with corrections)"
 lab var treat9b "Treatment Comprehensive (without corrections)"


/* The raw data suggests the following improvements to the reform year coding */
 
merge m:1 parish60 using "$reformdata\9yearreform_correction.dta"
drop if _merge==2
drop _merge


cap drop treat9Corr
gen treat9Corr=.
replace treat9Corr=1 if (cohort>=firstcohort60_correction & firstcohort60_correction<.)					/*Treated if cohort chosen for reform or after*/
replace treat9Corr=0 if ((cohort)<firstcohort60_correction) & firstcohort60_correction<.					/*Zero otherwise*/
replace treat9Corr=treat9 if treat9Corr==.

cap drop treat9Corrb
gen treat9Corrb=.
replace treat9Corrb=1 if (cohort>=firstcohort60_correctionb & firstcohort60_correctionb<.)					/*Treated if cohort chosen for reform or after*/
replace treat9Corrb=0 if ((cohort)<firstcohort60_correctionb) & firstcohort60_correctionb<.					/*Zero otherwise*/
replace treat9Corrb=treat9 if treat9Corrb==.

replace firstcohort60_correctionb=firstcohort60 if firstcohort60_correctionb==. & treat9!=.
replace firstcohort60_correction=firstcohort60 if firstcohort60_correction==. & treat9!=.

*****************************
	/*9 year reform -  place of birth */
*****************************

cd "$reformdata\"
mmerge fkommun60  using "slutgiltiga_reformkommuner_fob60.dta", type(n:1) umatch(kommun60 ) missing(nomatch) uname(fkb_)

drop if _merge==2
drop _merge



 cap drop treat9d
gen treat9d=.
replace treat9d=1 if (cohort>=fkb_firstcohort60 & fkb_firstcohort60<.)					/*Treated if cohort chosen for reform or after*/
replace treat9d=0 if ((cohort)<fkb_firstcohort60) & fkb_firstcohort60<.					/*Zero otherwise*/

 lab var treat9d "Treatment Comprehensive (Place of Birth)"

 
/*If no regional information, reform indicator set to missing*/ 
 
 replace treat8=. if muniid==.						/*If no regional information, reform indicator set to missing*/
 replace treat8d=. if muniid==.							/*If no regional information, reform indicator set to missing*/
 replace treat8NM=. if parish60==.				/*If no regional information, reform indicator set to missing*/
 replace treat8NMD=. if parish60==.				/*If no regional information, reform indicator set to missing*/
 replace treat9=. if muniid==.				
 replace treat9b=. if muniid==.				/*If no regional information, reform indicator set to missing*/
 replace treat9Corr=. if muniid==.				/*If no regional information, reform indicator set to missing*/
 replace treat9Corrb=. if muniid==.				/*If no regional information, reform indicator set to missing*/
 replace treat9d=. if muniid==.				/*If no regional information, reform indicator set to missing*/

 
 
  
compress
save $datasave\ReformsNewSIP.dta, replace



 
 *****************************
	/*7 year reform - FoB1960, FoB1950 place of birth */
*****************************
 
 
 use $datasave\ReformsNewSIP.dta, clear

  

rename FodelseForsNamn pnam_source
rename Fodelseforskod parishbid

gen ind=(pnam_source=="")

cap drop _merge

merge m:1 parishbid pnam_source using "$reformdata\reform2016_pb.dta", keepusing(id_schoold) gen(mreform_bp)
drop  if mreform_bp==2

tab cohort mreform_bp if corigin==29
tab ind if corigin==29 & mreform_bp==1 & cohort<1960
drop ind
drop mreform_bp
**Missing place of birth information reason for missing school district in the majority of cases

rename parishbid bparish_scb
rename id_schoold id_spb


**Merge place of residence 1950**

cap drop _merge
merge 1:1 id using "$dataFoB50\FoB50_pob_unique.dta", keepusing( parish46a_T parish50a_T RfamID_TR    sonname_E)
cap drop if _m==2
 
	 cap drop id_schoold
 
cap drop mreform60 
merge m:1 parish60 using "$reformdata\reformfob60koi_nov2015.dta", keepusing(id_schoold) gen(mreform60) 
drop  if mreform60==2

cap drop id_s60
rename id_schoold id_s60 
	  
	 
	cap drop id_schoold
	cap drop id_s50
	cap drop id_s46 
foreach var of varlist  parish46a_T  parish50a {
 cap drop mids 

cap drop parid 
gen parid=`var'
merge m:1 parid using "$reformdata\reformsSept2016.dta", gen(mids) keepusing(id_schoold comp7)
drop   mids parid 
 replace comp7=. if comp7<0

rename id_schoold id_s`var'
rename comp7 comp7`var'

 } 

 rename id_sparish50a id_s50
 rename id_sparish46a id_s46

cap drop id_s 
gen id_s=id_s46 if inrange(cohort,1930,1940)
replace  id_s=id_s50 if inrange(cohort,1941,1943)
replace  id_s=id_s60 if inrange(cohort,1944,1960)		/*Replace by FoB60 (Cohort 1944-1948) and FoB65 (Cohort 1949-1960)*/

cap drop missingCENSUS
gen missingCENSUS=(id_s==.)

replace  id_s=id_spb if id_s==. 
  
 cap drop cidid_s
 gen cidid_s=floor(id_s/10000)
 tab cidid_s
 
  cap drop cidid_s60
 gen cidid_s60=floor(id_s60/10000)
 tab cidid_s60
 
foreach j of varlist   id_s60 id_s  {

 
cap drop  id_schoold
cap drop mids
gen id_schoold=`j'
merge m:1 id_schoold using "$reformdata\dsr_merge_022015unique.dta", gen(mids) keepusing(comp7  ) update

replace comp7=. if comp7<0
 
*cap drop  comp7`j' /* GH change */
*gen  comp7`j'=comp7  /* GH change */
rename comp7 comp7`j'
  
*cap drop treat7`j' /* GH change */
gen treat7`j'=.
replace treat7`j'=1 if (cohort+13>=comp7`j' & comp7`j'<. )
replace treat7`j'=0 if (cohort+13<comp7`j' & comp7`j'<. )
 
 
}  

 

rename  pnam_source FodelseForsNamn
rename  bparish_scb Fodelseforskod

drop mids comp7parish50a_T id_s50 comp7parish46a_T id_s46 mreform60   id_spb parish46a_T parish50a_T _merge
cap drop mreform60  

compress
bys id: gen counter=_N
tab counter
drop if counter>1
drop counter


/*Realskola*/
 
cap drop  id_schoold
cap drop mcompREAL
gen id_schoold=id_s
merge m:1 id_schoold using "$reformdata\realopen_2022.dta", gen(mcompREAL) keepusing(compREAL  )  
 
 cap drop treatR2
 gen treatR2=(cohort>=compREAL & compREAL<.) if id_schoold<.



 
d id_s*  parish60 muniid 
 
 /*Merge rural/urban*/

 
 foreach j of varlist   id_s60 id_s  {

 
cap drop  id_schoold
cap drop mids
gen id_schoold=`j'
merge m:1 id_schoold using "$reformdata\ids_city.dta", gen(mids) keepusing(city  ) update

 
 
rename city city`j'
 
 
}  

cap drop  id_schoold
cap drop mids
 
 foreach j of varlist  cidid_s comp7id_s treat7id_s cityid_s id_s compREAL   treatR2{

 rename  `j' `j'50
 
} 


 cap drop  id_schoold
cap drop mcompREAL
gen id_schoold=id_s60
merge m:1 id_schoold using "$reformdata\realopen_2022.dta", gen(mcompREAL) keepusing(compREAL  )  
 

 cap drop treatR260
 gen treatR260=(cohort>=compREAL & compREAL<.) if id_schoold<.
  rename compREAL compREAL60
  
  
*save $datasave\ReformsNewSIP.dta, replace
*use $datasave\ReformsNewSIP.dta, clear

gen compuni=cohort+19 
merge m:1 id_schoold compuni using "$reformdata\uni_nearest_ids.dta", gen(mcompUNI) keepusing(km_to_nid  )  
 drop if mcompUNI==2
 drop mcompUNI
 rename km_to_nid km_to_nid60
save $datasave\ReformsNewSIP.dta, replace
 
 use $datasave\ReformsNewSIP.dta, clear
merge m:1 id_schoold   using "$reformdata\gymn_unique2022.dta", gen(mcompGYM) keepusing(compGYMN  flickskola)  
 drop if mcompGYM==2
 drop mcompGYM
 
  cap drop treatGYMN
 gen treatGYMN=(cohort>=compGYMN & compGYMN<.) if id_schoold<.

rename treatGYMN treatGYMN60
rename compGYMN compGYMN60
drop if id==.
save $datasave\ReformsNewSIP.dta, replace

 

***********************************************************
*Things that we should add here:
* Sort birthparish to bparish60 for all cohorts 1948-19 (currently 1948,1953 only)
* week extension (FoB1950 place of residence etc)
***********************************************************








/*
****************************
/*Match child ID */
* Haven't done this as it creates a massive dataset as a few have many children! - best to do it on a specific dataset
****************************
save $datasave\BaseNewSIP.dta, replace
odbc load, exec("select * from dbo.BioBarn_NY") dsn("P0524_LU_Arbetslivet") clear
bysort LopNr_PersonNr: gen counter=_n
bysort LopNr_PersonNr: gen counter2=_N
reshape wide FoddArBarn KonBarn LopNr_PersonNrAndraForaldern, i( LopNr_PersonNr) j(counter)
tempfile barnID
save `barnID'

use  $datasave\BaseNewSIP.dta, clear
mmerge  id  using `barnID', type(1:n) umatch(LopNr_PersonNr)
drop if _merge==2
drop _merge
*/

/*
****************************
/*Match siblings */
* Haven't done this as it creates a massive dataset as a few have many siblings! - best to do it on a specific dataset
****************************
odbc load, exec("select * from dbo.Syskon_Koppling") dsn("P0524_LU_Arbetslivet") clear
bysort LopNr_PersonNr: gen counter=_n
bysort LopNr_PersonNr: gen counter2=_N
reshape wide LopNr_Syskon Syskontyp , i( LopNr_PersonNr) j(counter)
tempfile barnID
save `barnID'

use  $datasave\BaseNewSIP.dta, clear
mmerge  id  using `barnID', type(1:1) umatch(LopNr_PersonNr)
drop if _merge==2
drop _merge

*/

