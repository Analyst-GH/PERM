cap log close
local today: display %tdCYND date(c(current_date), "DMY")
set scheme cleanplots
graph set window fontface "Times New Roman"
**Folder Data
global outtab2 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\WP1_figures"
global outtab3 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\WP1_output"

global anadata 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\Data"

cap mkdir "$outtab2" 

use  "$anadata\ana_earnPERM.dta", clear

lab var yearseduc_FOB "Years of education"
lab var inc "Earnings (ages 36-55, 100,000 SEK)"

reg inc yearseduc_FOB if treat9D==1
sca alpha1=e(b)[1,2]
sca beta1=e(b)[1,1]

global x1 "sex i.cohort"
global samp "cohort<1951 & treat9D==1"
global regopt2 "absorb(i.cohort i.muniid male) vce(cluster muniid)"
global regopt3 "absorb(muniid##c.cohort) endog(yrseduc_impute)  cl(muniid)  partial(sex i.cohort)"
 

dir
  parmby "regress  inc i.yearseduc_FOB   if $samp     ", saving("$outtab3\linearity_NOFE.dta", replace)
  parmby "reghdfe  inc i.yearseduc_FOB   if $samp    , $regopt2 ", saving("$outtab3\linearity_FE.dta", replace)

  use "$outtab3\linearity_NOFE.dta", clear


*drop if parmseq==1
sum estimate if parmseq==16 
sca C =r(mean)
replace estimate=estimate+C 			/*Set Constant as Baseline*/
replace min95=min95+C 			/*Set Constant as Baseline*/
replace max95=max95+C 			/*Set Constant as Baseline*/


rename parmseq  yearseduc_FOB
replace  yearseduc_FOB= yearseduc_FOB+6

 global start "5"
global end "21"
global start1 "5"
global end1 "21"
global length "2"

* mean education and income observed
gen Medu1=11.05
gen Minc1=2.372
* mean education and income counterfactual (=observed - ATT)
gen Medu2=Medu1-0.47 /* 11.078-0.47 */
gen Minc2=Minc1-0.017 /* 2.372-0.017 */

gen Y1=alpha1+(beta1)*yearseduc_FOB
sca alpha2=2.372-((beta1)+0.015)*Medu2
sca beta2=beta1+0.015
gen Y2=alpha2+(beta2)*yearseduc_FOB

reg estimate yearseduc_FOB

#delimit ;
graph twoway 	 		
		(scatter estimate yearseduc_FOB if    inrange(yearseduc_FOB,$start,$end), color(gs9)    msymbol(Oh))		 
		(rcap min95 max95 yearseduc_FOB if   inrange(yearseduc_FOB,$start,$end),   color(gs9) ytitle("lninc" ,  axis(1))) 
		(lfit Y1 yearseduc_FOB, color(gs4))
		(lfit Y2 yearseduc_FOB, color(gs4) lpattern(dash))
		(scatter Minc1 Medu1 if    inrange(yearseduc_FOB,$start,$end),   msymbol(T) msize(vlarge)  yaxis(1) )
		(scatter Minc2 Medu2 if    inrange(yearseduc_FOB,$start,$end),   msymbol(Th) msize(vlarge)  yaxis(1) color("200 0 0"))

		,  
		ylab(    ,  )
		xlab(    ,  )
		xscale( range($start,$end) )
		xlab($start1 ($length) $end1, )
		xtitle("Years of Education", )
		ytitle("Earnings (100,000 SEK)", )
		xsize(3) ysize(3)
		plotregion(color(white)) graphregion(color(white))
				bgcolor(white) 
				legend(order(5  "Observed joint mean" 6  "Counterfactual joint mean" 3 "Observed Beta" 4 "Counterfactual Beta" 1 "Conditional expectation"   ) col(1)  position(11) ring(0)  region(col(white)) )
		;
		#delimit cr 
		
* Output files are saved here
cd "$outtab2"

graph export linearity.pdf, replace
 

