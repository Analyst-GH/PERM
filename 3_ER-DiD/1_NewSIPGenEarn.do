
****************************
/*GENERATE LABOUR EARNINGS */
/* This file generates earnings measures for all tax years, cohorts 1900-1985 */
****************************
/* list revisions here, who did them, and what they were */
* Version 2020-10-21: Gawain. First build
* Version 2021-01-19: Martin. Correction for missing CSFVI in 1996 (line 440-449)
* Version 2021-01-22: Gawain. Proper correction for missing CSFVI in 1996 and dodgy ARBINK in 1989 (line:406-444)
* Version 2021-02-16: Gawain. Swapped out INTJ for INKA in order to calculate CSFVI+INKA


**********************************************
** Global macros
set more off
global datasave  "\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\mydata\NewSIPBaseData"		/*Save own Data*/
global mydata  "\\micro.intra\projekt\P0524$\P0524_gem\TN_MK_MF_School_reform_health_SES\mydata"


/*Generates Labor Earnings as defined by SCB*/
*For years before 1978 no equivalent concept by SCB - approximate as in Fredriksson (2000)

* cohorts born before 1903 have all retired before 1968 (first year of income data) and cohorts born after 1985 have no income data
* The different earnings measures:
* inc_earn: CSFVI (sammanräknat förvarvsinkomst - total pre-tax income)
* inc_sempl: INRO (income from own firm)
* inc_empl: INTJ (income from employment)
* pens: PENS (from 1974)
* inc_labor: ARBINK (income from employment minus, sick leave and working age pension)
 
use id cohort  if inrange(cohort,1850,1985) using $datasave\BaseNewSIP.dta ,   clear
drop cohort
save  $datasave\EarningsNewSIP.dta, replace
clear
gen id=.

* IOT1968-IOT1973
forvalues i=68(1)73{
tempfile BASE
save `BASE', replace
odbc load, exec("select * from dbo.IOT`i'") dsn("P0524_LU_Arbetslivet") clear
bysort P0524_Lopnr_Personnr: gen counter=_N
drop if counter==2
drop counter
keep P0524_Lopnr_Personnr CSFVI INRO INKA
rename P0524_Lopnr_Personnr id
*rename CSFVI CSFVI_`i' 
*rename INRO INRO_`i' 
*rename INTJ INTJ_`i'
*gen ARBINK_`i'=CSFVI_`i' /*As in Edin Frediksson (2000)*/
gen ARBINK=CSFVI /*As in Edin Frediksson (2000)*/
tempfile INC
save `INC', replace

use id  using $datasave\EarningsNewSIP.dta, clear				/*Get Baseample ID */
merge 1:1 id  using `INC' 
keep if _merge==3												/* keep only if have income data*/
drop _merge
gen year=19`i'
save `INC', replace


use `BASE', clear
*merge 1:1  id  using `INC'
*drop if _m==2
*drop _m 
append using `INC'

}

* IOT 1974
tempfile BASE
save `BASE', replace
odbc load, exec("select * from dbo.IOT74") dsn("P0524_LU_Arbetslivet") clear
bysort P0524_Lopnr_Personnr: gen counter=_N
drop if counter>1
drop counter
keep P0524_Lopnr_Personnr CSFVI INRO INKA PENS DAGPE
rename P0524_Lopnr_Personnr id
*rename CSFVI CSFVI_74 
*rename INRO INRO_74 
*rename INTJ INTJ_74
gen ARBINK=CSFVI - PENS - DAGPE /*As in Edin Frediksson (2000)*/
drop PENS DAGPE
tempfile INC
save `INC', replace


use id  using $datasave\EarningsNewSIP.dta, clear				/*Get Baseample ID */
merge 1:1 id  using `INC' 
keep if _merge==3												/* keep only if have income data*/
drop _merge
gen year=1974
save `INC', replace

use `BASE', clear
*merge 1:1  id  using `INC'
*drop if _m==2
*drop _m 
append using `INC'


* IOT1975-IOT1977
forvalues i=75(1)77{
tempfile BASE
save `BASE', replace
odbc load, exec("select * from dbo.IOT`i'") dsn("P0524_LU_Arbetslivet") clear
bysort P0524_Lopnr_Personnr: gen counter=_N
drop if counter>1
drop counter
keep P0524_Lopnr_Personnr CSFVI INRO INKA PENS DAGPE
rename P0524_Lopnr_Personnr id
*rename CSFVI CSFVI_`i' 
*rename INRO INRO_`i' 
*rename INTJ INTJ_`i'
*gen ARBINK_`i'=CSFVI_`i' /*As in Edin Frediksson (2000)*/
gen ARBINK=CSFVI - PENS - DAGPE /*As in Edin Frediksson (2000)*/
drop PENS DAGPE
tempfile INC
save `INC', replace

use id  using $datasave\EarningsNewSIP.dta, clear				/*Get Baseample ID */
merge 1:1 id  using `INC' 
keep if _merge==3												/* keep only if have income data*/
drop _merge
gen year=19`i'
save `INC', replace


use `BASE', clear
*merge 1:1  id  using `INC'
*drop if _m==2
*drop _m 
append using `INC'

}
compress
*save $datasave\earn6877.dta, replace

*clear
*gen id=.
* IOT1978-IOT1979
forvalues i=78(1)79{
tempfile BASE
save `BASE', replace
odbc load, exec("select * from dbo.IOT`i'") dsn("P0524_LU_Arbetslivet") clear
bysort P0524_Lopnr_Personnr: gen counter=_N
drop if counter>1
drop counter
keep P0524_Lopnr_Personnr CSFVI INRO INKAP ARBINK
rename P0524_Lopnr_Personnr id
rename INKAP INKA
tempfile INC
save `INC', replace

use id  using $datasave\EarningsNewSIP.dta, clear				/*Get Baseample ID */
merge 1:1 id  using `INC' 
keep if _merge==3												/* keep only if have income data*/
drop _merge
gen year=19`i'
save `INC', replace


use `BASE', clear
*merge 1:1  id  using `INC'
*drop if _m==2
*drop _m 
append using `INC'

}



* IOT1980-IOT1981
forvalues i=80(1)81{
tempfile BASE
save `BASE', replace
odbc load, exec("select * from dbo.IOT`i'") dsn("P0524_LU_Arbetslivet") clear
bysort P0524_Lopnr_Personnr: gen counter=_N
drop if counter>1
drop counter
keep P0524_Lopnr_Personnr CSFVI INRO INKAP ARBINSJ
rename P0524_Lopnr_Personnr id
rename ARBINSJ ARBINK
rename INKAP INKA
tempfile INC
save `INC', replace

use id  using $datasave\EarningsNewSIP.dta, clear				/*Get Baseample ID */
merge 1:1 id  using `INC' 
keep if _merge==3												/* keep only if have income data*/
drop _merge
gen year=19`i'
save `INC', replace


use `BASE', clear
*merge 1:1  id  using `INC'
*drop if _m==2
*drop _m 
append using `INC'

}

* IOT1982-IOT1990
forvalues i=82(1)90{
tempfile BASE
save `BASE', replace
odbc load, exec("select * from dbo.IOT`i'") dsn("P0524_LU_Arbetslivet") clear
bysort P0524_Lopnr_Personnr: gen counter=_N
drop if counter>1
drop counter
keep P0524_Lopnr_Personnr CSFVI INRO INKAP ARBINK
rename P0524_Lopnr_Personnr id
rename INKAP INKA
tempfile INC
save `INC', replace

use id  using $datasave\EarningsNewSIP.dta, clear				/*Get Baseample ID */
merge 1:1 id  using `INC' 
keep if _merge==3												/* keep only if have income data*/
drop _merge
gen year=19`i'
save `INC', replace


use `BASE', clear
*merge 1:1  id  using `INC'
*drop if _m==2
*drop _m 
append using `INC'

}
compress
*save $datasave\earn7890.dta, replace




* IOT1991-IOT1992
forvalues i=91(1)92{
tempfile BASE
save `BASE', replace
odbc load, exec("select * from dbo.IOT`i'") dsn("P0524_LU_Arbetslivet") clear
bysort P0524_Lopnr_Personnr: gen counter=_N
drop if counter>1
drop counter
keep P0524_Lopnr_Personnr CSFVI INNRV INKAP ARBINK
rename P0524_Lopnr_Personnr id
rename INKAP INKA
rename INNRV INRO
tempfile INC
save `INC', replace

use id  using $datasave\EarningsNewSIP.dta, clear				/*Get Baseample ID */
merge 1:1 id  using `INC' 
keep if _merge==3												/* keep only if have income data*/
drop _merge
gen year=19`i'
save `INC', replace
compress

use `BASE', clear
*merge 1:1  id  using `INC'
*drop if _m==2
*drop _m 
append using `INC'

}
compress

* IOT1993-IOT1999
forvalues i=93(1)99{
tempfile BASE
save `BASE', replace
odbc load, exec("select * from dbo.IOT`i'") dsn("P0524_LU_Arbetslivet") clear
bysort P0524_Lopnr_Personnr: gen counter=_N
drop if counter>1
drop counter
keep P0524_Lopnr_Personnr CSFVI NRV KKAP CARB
rename P0524_Lopnr_Personnr id
rename NRV INRO
*rename TTJ INTJ
rename CARB ARBINK
rename KKAP INKA
tempfile INC
save `INC', replace

use id  using $datasave\EarningsNewSIP.dta, clear				/*Get Baseample ID */
merge 1:1 id  using `INC' 
keep if _merge==3												/* keep only if have income data*/
drop _merge
gen year=19`i'
save `INC', replace
compress

use `BASE', clear
*merge 1:1  id  using `INC'
*drop if _m==2
*drop _m 
append using `INC'

}

save $datasave\earn6899.dta, replace





clear
gen id=.

* IOT2000-IOT2009
forvalues i=0(1)9{
tempfile BASE
save `BASE', replace
odbc load, exec("select * from dbo.IOT0`i'") dsn("P0524_LU_Arbetslivet") clear
bysort P0524_Lopnr_Personnr: gen counter=_N
drop if counter>1
drop counter
keep P0524_Lopnr_Personnr CSFVI NRV KKAP CARB
rename P0524_Lopnr_Personnr id
rename NRV INRO
*rename TTJ INTJ
rename CARB ARBINK
rename KKAP INKA
tempfile INC
compress
save `INC', replace

use id  using $datasave\EarningsNewSIP.dta, clear				/*Get Baseample ID */
merge 1:1 id  using `INC' 
keep if _merge==3												/* keep only if have income data*/
drop _merge
gen year=200`i'
save `INC', replace
compress

use `BASE', clear
*merge 1:1  id  using `INC'
*drop if _m==2
*drop _m 
append using `INC'

}

compress
save $datasave\earn0009.dta, replace



clear
gen id=.

* IOT2010-IOT2016
forvalues i=10(1)16{
tempfile BASE
save `BASE', replace
odbc load, exec("select * from dbo.IOT`i'") dsn("P0524_LU_Arbetslivet") clear
bysort P0524_Lopnr_Personnr: gen counter=_N
drop if counter>1
drop counter
keep P0524_Lopnr_Personnr CSFVI NRV KKAP CARB
rename P0524_Lopnr_Personnr id
rename NRV INRO
*rename TTJ INTJ
rename CARB ARBINK
rename KKAP INKA
tempfile INC
compress
save `INC', replace

use id  using $datasave\EarningsNewSIP.dta, clear				/*Get Baseample ID */
merge 1:1 id  using `INC' 
keep if _merge==3												/* keep only if have income data*/
drop _merge
gen year=20`i'
save `INC', replace
compress

use `BASE', clear
*merge 1:1  id  using `INC'
*drop if _m==2
*drop _m 
append using `INC'

}

compress
save $datasave\earn1016.dta, replace
append using $datasave\earn0009.dta
append using $datasave\earn6899.dta
compress
tab year



* cohorts born before 1903 have all retired before 1968 (first year of income data) and cohorts born after 1985 have no income data
* The different earnings measures:
* inc_earn: CSFVI (sammanräknat förvarvsinkomst - total pre-tax income)
* inc_sempl: INRO (income from own firm)
* inc_empl: INTJ (income from employment)
* pens: PENS (from 1974)
* inc_labor: ARBINK (income from employment minus, sick leave and working age pension)

global inc ARBINK CSFVI INRO INKA
foreach i of global inc {
replace `i'=`i'/100 if  year<1978 
replace `i'=`i'/100 if  year>1993  
}

compress
save $datasave\earn6816.dta, replace

/* merge CSFVI 1996 fix */
odbc load, exec("select * from dbo.IOT96_kompl") dsn("P0524_LU_Arbetslivet") clear
bysort P0524_Lopnr_Personnr: gen counter=_N
drop if counter>1
drop counter
gen year=1996
rename P0524_Lopnr_Personnr id
compress
tempfile INC
save `INC', replace

use  $datasave\earn6816.dta, clear	
replace CSFVI=. if year==1996			
merge 1:1 id year using `INC' , update keepusing(CSFVI )
drop if _merge==2												/* keep only if have income data*/
drop _merge

replace CSFVI=CSFVI/100 if year==1996
compress
save $datasave\earn6816.dta, replace

/* merge ARBINK 1989 fix */
odbc load, exec("select * from dbo.IOT89_kompl") dsn("P0524_LU_Arbetslivet") clear
bysort P0524_Lopnr_Personnr: gen counter=_N
drop if counter>1
drop counter
gen year=1989
rename P0524_Lopnr_Personnr id
rename arbink ARBINK
tempfile INC
save `INC', replace

use  $datasave\earn6816.dta, clear	
replace ARBINK=. if year==1989			
merge 1:1 id year using `INC' , update keepusing(ARBINK)
drop if _merge==2												/* keep only if have income data*/
drop _merge
compress
save $datasave\earn6816.dta, replace

/*Check for outliers  /*(GH: looks good up to 2008, then they start being pensioners)*/

bysort year: gen first=1 if _n==1

use $datasave\earn6816.dta, clear
 preserve 
drop CSFVI INRO INTJ
bysort year: gen first=1 if _n==1
bysort year: egen meanARBINK=mean(ARBINK) 
scatter meanARBINK year if first==1  		/* ARBINK sees large jump in 1989 and small jump in 1990 */
restore

use $datasave\earn6816.dta, clear
 preserve 
drop ARBINK INRO INTJ
bysort year: gen first=1 if _n==1
bysort year: egen meanCSFVI=mean(CSFVI) 
scatter meanCSFVI year if first==1  		/* CSFVI sees small jump in 1990, missing in 1996 */
restore

use id INTJ year first using "$datasave\earn6816.dta", clear
bysort year: egen meanINTJ=mean(INTJ) 
scatter meanINTJ year if first==1  		/* INTJ sees small jump in 1990 */

use id INRO year first using "$datasave\earn6816.dta", clear
bysort year: egen meanINTJ=mean(INRO) 
scatter meanINTJ year if first==1  		/* INRO sees small jump in 1990 */
*/

/*Merge Consumer Price Index to deflate earnigns*/
capture drop cpi
merge m:1 year using $mydata\cpi.dta, gen(mcpi) keepusing(AnnualAver)
tab year if mcpi==2
drop if mcpi==2
drop mcpi
rename AnnualAver cpi

sum cpi if year==2011
sca cpi2011=r(mean)
replace cpi=cpi/cpi2011
*replace inc_labor=inc_labor*100
*replace inc_earn=inc_earn*100

/*Correction for missing CSFVI in 1996*/
/*

 replace  CSFVI=INTJ+INRO if year==1996
 preserve 
 keep CSFVI year
 binscatter CSFVI year, discrete linet(none)
 graph export  $datasave\CSFVI_year2.pdf, replace
 
 restore
*/
 
compress
sort id (year)
save $datasave\earn6816.dta, replace
*use $datasave\earn6816.dta, clear
