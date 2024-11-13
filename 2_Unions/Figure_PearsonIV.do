* PC
global save "G:\Shared drives\Inequality Decomposition\"
global tab "G:\Shared drives\Inequality Decomposition\Unions_Var\Tables"

* mac
global fig "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions"
global predict "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions"

clear all
* Graph settings
graph set window fontface "Times New Roman"
set scheme cleanplots
global ls labsize(medlarge)
global size size(large)
global legs size(medium)
*graph set fontsize 12

clear all

use "$predict/simdata_observed_pear_nokur.dta", clear
gen ob=1
append using "$predict/simdata_counterfactual_pear_nokur.dta"

capture drop dp4 lnwage_ob_d dp5 lnwage_cf_d lnwage_d dp6
kdensity data if data!=. & ob==1, gen(lnwage_ob_d dp4) nograph bwidth(0.05) n(20000)
kdensity data if data!=. & ob==., gen(lnwage_cf_d dp5) nograph   bwidth(0.05) n(20000)

*add in the zero density point to make the density plot clearer
sum data if data!=. & ob==1
scalar min_ob=r(min)
scalar max_ob=r(max) 
sum data if data!=. & ob==.
scalar min_cf=r(min)
scalar max_cf=r(max) 

replace dp4=0 if _n==_N| _n==_N-1
replace lnwage_ob_d=min_ob if _n==_N
replace lnwage_ob_d=max_ob if _n==_N-1

replace dp5=0 if _n==_N| _n==_N-1
replace lnwage_cf_d=min_cf if _n==_N
replace lnwage_cf_d=max_cf if _n==_N-1

label variable dp4 "Observed (Fitted Pearson IV)"
label variable dp5 "Counterfactual (Fitted Pearson IV)"

twoway (line dp4 lnwage_ob_d if lnwage_ob_d>0 & lnwage_ob_d<4, sort lwidth(medthick)) (line dp5 lnwage_cf_d if lnwage_cf_d>0 & lnwage_cf_d<4, sort lwidth(medthick) lpattern(dash)) , ylabel(0(0.2)1.3) xlabel(0(1)4) legend(position(11) ring(0)) ytitle("Density") xtitle("ln(Hourly Wage US$ 1979)") xsize(5) ysize(5) saving(logw, replace) 

graph export "$fig/Union_results_log.pdf", replace

