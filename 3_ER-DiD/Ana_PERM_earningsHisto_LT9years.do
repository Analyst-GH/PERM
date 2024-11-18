********************************
/*Histogram M.1 */
********************************
* histogram of earnings for untreated with less than 9 years of schooling
* To show that there are high earners even amongst the lowest educated

cap log close
set scheme cleanplots
graph set window fontface "Times New Roman"
**Folder Data
global outtab2 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\WP1_figures"
global anadata 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\Data"

cap mkdir "$outtab2" 

use  "$anadata\ana_earnPERM.dta", clear


lab var inc "Earnings (ages 36-55, 100,000 SEK)"

************ Desciriptive Figures ************

#delimit ;
hist inc if treat9D==0 & yearseduc_FOB<9, xsize(3) ysize(3) 
		plotregion(color(white)) graphregion(color(white))
				bgcolor(white) 
				legend(order(1  "Less than 9 years of schooling"  ) col(1)  position(1) ring(0)  region(col(white)) $legs )
		;
# delimit cr;		
graph export "$outtab2/Histo_earnsLT9YEARS.pdf", replace
#delimit ;
 hist inc if treat9D==0 , 		xsize(3) ysize(3) 
		plotregion(color(white)) graphregion(color(white))
				bgcolor(white) 
				legend(order(1   "All years of schooling"   ) col(1)  position(1) ring(0)  region(col(white)) $legs )
		;
# delimit cr;		
graph export "$outtab2/Histo_earnsALL.pdf", replace
