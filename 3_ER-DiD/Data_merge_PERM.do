********************************
/*DATA MERGE and SAMPLE SELECTION*/
********************************
set more off
capture log close
graph set window fontface "Times New Roman"
set scheme s1mono
set matsize 11000

global size size(large)
global ls labsize(medlarge)
global legs size(medlarge) 

**Folder Data

global data  "\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\"				/*Original Data*/
global mydata  "\\micro.intra\projekt\P0524$\P0524_gem\TN_MK_MF_School_reform_health_SES\mydata"
global anadata  "\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\Data"
global datasave  "\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\mydata\NewSIPBaseData"		/*Save own Data*/
global anadata2 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\Data"


/* STEPS:
			1.) Extract Cohorts of Relevance for the Analyses
					First Cohort:	Start cohort 1932		(first cohort with linkage in intergenerational register)
					Last Cohort:	Last Cohort 1952		(last cohort with schooling in Census 1970 and Education Variables)
			2.) Education
			3.) Income when aged 40-45
			
*/

****************************
/*MERGE BASIC VARIABLES*/
****************************

**Draw Baseline Population

set more off
use  $datasave\ReformsNewSIP.dta  if inrange(cohort,1932,1952) ,   clear
 
merge 1:1 id using $datasave\EducNewSIP.dta
keep if _merge==3
drop _merge

merge 1:1 id using $datasave\ParentBNewSIP.dta
keep if _merge==3
drop _merge
   

/*Sample Restrictions*/ 
  
*keep if   inrange(cohort,1938,1954)			/*Keep only reform cohorts*/  

/*Keep if non-missing education and essential covariates*/

*keep if yearseduc_FOB<.
*keep if male<.
*keep if cohort<.

**Baseline Sample
  gen  sex=male

	lab var hife "Fathers Education more than compulsory"
	lab var sex "Male"
	lab var muniid "Preferred municipality assignment"
	lab var postschooling "Post-Secondary / Tertiary Education"
	lab var yearseduc_FOB "Years of Education"

	replace age_deathm=age_deathm/365
save $anadata\anaPERM.dta, replace

/*Labor Earnings Samples*/
* need new earnings data file for cohorts 1937 - 1975
use $datasave\earn6816.dta, clear
*keep if year>1984 & year<1997
tempfile earn
save `earn'

use id cohort dyear  using $anadata\anaPERM.dta, clear
merge 1:m id using `earn', keepusing(cpi year CSFVI INKA ARBINK)
drop if _m==2
drop _m

replace CSFVI=CSFVI+INKA
gen age=year-cohort
replace CSFVI=. if year==dyear
replace ARBINK=. if year==dyear

gen ARBINK_defl=ARBINK/cpi
* Björklund 2012 LE sibling correlations
*replace ARBINK_defl=. if ARBINK_defl<=0.1 
*capture drop lnARBINK_defl
*gen lnARBINK_defl=ln(ARBINK_defl)
bysort id: egen earn3644=mean(ARBINK_defl) if inrange(age,36,44)
bysort id: egen earn3655=mean(ARBINK_defl) if inrange(age,36,55)
bysort id: egen earn2555=mean(ARBINK_defl) if inrange(age,25,55)


drop dyear ARBINK CSFVI INKA cpi year  



collapse   earn3644   earn3655 earn2555  cohort, by( id  )
save $anadata\earnPERM.dta, replace
 
use  $anadata\anaPERM.dta, clear
keep id FodelseForsNamn firstcohort60  cohort  age_deathm male bmonth  yrseducFOB yrseducLISA yearseduc_FOB postschooling  treat9 treat9Corr treat9Corrb  firstcohort60_correction firstcohort60_correctionb hife  muniid hisesf FAR_yrseducFOB FAR_yrseducLISA MOR_yrseducFOB MOR_yrseducLISA corigin occ*

merge 1:1 id using  $anadata\earnPERM.dta
drop if _m==2
drop _m

 
 lab var earn3644 "Earnings (36-44)"
 lab var earn3655 "Earnings (36-55)"
 lab var earn2555 "Earnings (25-55)"



gen late=(cohort>1942)
 
lab var male "Male"
lab var FAR_yrseducFOB "Father's Years of Education"
lab var MOR_yrseducFOB "Mother's Years of Education"
lab var cohort "Birth Cohort"  


* keep cohorts 1932 - 1952 for whom all have income in 1968 onwards aged 36 and are aged 64 by 2016
				* Dummy variable for large cities - these may not have much variation
				gen storstad9 = 0
				replace storstad9 = 1 if muniid==0180 | muniid==1280 | muniid==1480 // stockholm, malmö, göteborg
				*gen incmiss=(loginc3035b==.)
				gen inc = earn3655/1000
				*replace inc=0 if inc<0
				gen lninc=ln(inc)
				cap drop dif
replace firstcohort60=. if firstcohort60==0
gen dif=cohort-firstcohort60
replace dif=dif+100
replace dif=. if firstcohort60==.			/*Set those without reform information as not implemented yet*/
fvset base 98 dif
gen treat9D=(dif>98)


/*				
				* aged atleast 36 in 1968, if survived
				keep if cohort>=1932 
				* aged atleast 64 in 2016, if survived
				keep if cohort<1953
				* keep if swedish born
				keep if corigin==29
				* 2,136,250 obs
				
				keep if muniid!=. 
				* 157,590  missing, 1,978,660 obs
				
				keep if yearseduc_FOB!=. 
				* 90,971  observations deleted,  1,887,689
				
				drop if inc==.
				* 22,901 observations deleted, 1,704,165
				
				drop if firstcohort60==.
				* 3,397 observations deleted, 1,861,391
				
				keep if storstad9==0  
				* 290,101   observations deleted, 1,506,850
				

*/
			
			
* Analysis sample
keep if cohort>=1932 & cohort<1953 &  corigin==29 &  muniid!=. & yearseduc_FOB!=. & inc!=. & storstad9==0 
* restrict sample to those born within 10 years of first reform cohort to help ensure relevant controls are used
keep if dif>88 & dif<108
* 475,120 observations deleted, 1,096,170

  
 
save $anadata2\ana_earnPERM.dta, replace
 
 





