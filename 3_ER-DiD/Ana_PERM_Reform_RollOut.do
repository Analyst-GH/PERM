********************************
/*Histogram M.1 */
********************************
* histogram of earnings for untreated with less than 9 years of schooling
* To show that there are high earners even amongst the lowest educated

cap log close
set scheme cleanplots
graph set window fontface "Times New Roman"
**Folder Data
global outfig 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\WP1_figures"
global anadata 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\Data"

cap mkdir "$outtab2" 

use  "$anadata\ana_earnPERM.dta", clear

bysort cohort: egen coverage=mean(treat9D)
bysort cohort: gen keep=(_n==1)
graph tw (line coverage cohort if keep==1)

bysort cohort muniid: gen keep_mc=(_n==1)
bysort cohort: egen coverage_m=mean(treat9D) if keep_mc==1
*bysort cohort: gen keep=(_n==1)
graph tw (line coverage cohort if keep==1, color(ebblue)) (line coverage_m cohort, lpattern(dash) color(ebblue)), ytitle("Reform Roll-Out Coverage", axis(1) ) /// 
legend(label(1 "Individuals") label(2 "Municipalities") pos(11) ring(0)  )  ylabel() xlabel( 1930(5)1955) xtitle("Birth Cohort") xsize(4) ysize(3.5)
graph export "$outfig\ReformRollOut.pdf", replace
