graph set window fontface "Times New Roman"
set scheme cleanplots
global ls labsize(medlarge)
global size size(large)
global legs size(medium)

* Gawain's computer
global simdata "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/3_ER-DiD/Distribution_figures"
global admindata "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/Admin data/Distributions"
global outfig "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/3_ER-DiD/Distribution_figures"

/*
* Dennis' Computer
global simdata "G:\Shared drives\Inequality Decomposition\FFL2009UQR-data\Simulated gld"
global admindata "G:\Shared drives\Inequality Decomposition\Admin data\graphing do files\"
global outfig "G:\Shared drives\Inequality Decomposition\Admin data\Distribution_figures"
global overleaf "C:\Users\dpet0001\Dropbox (Monash Uni Enterprise)\Apps\Overleaf\Swedish Health Inequalities\"
*/
*******************************************
*Education results
use "$simdata/simdata_observed_yrsedu_pear_nokur.dta", clear 
gen ob=1
append using "$simdata/simdata_cf_yrsedu_pear_nokur.dta"
gen trend=1



capture drop dp1 dp2 X1_ob X1_cf 
kdensity data if data!=. & ob==1 & trend==1, gen(X1_ob dp1) nograph bwidth(1.5) n(1000)
kdensity data if data!=. & ob==. & trend==1, gen(X1_cf dp2) nograph bwidth(1.5) n(1000)
*kdensity X1 if X1!=. & ob==. & trend==., gen(X1_cf_nt dp3) nograph bwidth(1.5)  n(1000)

label variable dp2 "Counterfactual (Pearson IV)"
label variable dp1 "Observed (Pearson I)"

twoway (line dp1 X1_ob if X1_ob>4 & X1_ob<=21, lwidth(medthick) lpattern(dash)) (line dp2 X1_cf if X1_cf>4 & X1_cf<21, lwidth(medthick) lpattern(dash))  ///
, legend(position(2) ring(0) order( 1  2 ) region(fcolor(none))) ytitle("Density") xtitle("Years of Education") xsize(5) ysize(5) 
graph export "$outfig/PDFedu2.pdf", replace


* Generate CDF variables for twoway graphing

sort X1_ob ob
gen CF1=sum(dp1) 
sum CF1
replace CF1=CF1/r(max) 
sort X1_cf ob
gen CF2=sum(dp2)  
sum CF2
replace CF2=CF2/r(max) 

label variable CF1 "Observed (Pearson I)"
label variable CF2 "Counterfactual (Pearson IV)"



* sort orderings by subgroup so graphs nicely
sort ob  (X1_ob) (X1_cf)
* CDF of income, observed, modelled and counterfactual

twoway (line CF1 X1_ob if X1_ob>=4 & X1_ob<=21, lwidth(medthick) lpattern(dash)) (line CF2 X1_cf if X1_cf>=4 & X1_cf<21, lwidth(medthick) lpattern(dash))   ///
, legend(position(5) ring(0) order(1  2   ) region(fcolor(none)) ) ytitle("Cumulative Density") xtitle("Years of Education") xsize(4) ysize(4) 
graph export "$outfig/CDFedu2.pdf", replace



*******************************************
*Earnings results
use "$simdata/simdata_observed_inc_pear_nokur.dta", clear 
gen ob=1
append using "$simdata/simdata_cf_inc_pear_nokur.dta"
gen trend=1

capture drop dp1 dp2 X1_ob X1_cf 
kdensity data if data!=. & ob==1 & trend==1, gen(X1_ob dp1) nograph bwidth(0.05) n(2000)
kdensity data if data!=. & ob==. & trend==1, gen(X1_cf dp2) nograph bwidth(0.05) n(2000)
*kdensity X1 if X1!=. & ob==. & trend==., gen(X1_cf_nt dp3) nograph bwidth(1.5)  n(1000)

*save data

sum data if data!=. & ob==1 & trend==1
scalar min_ob=r(min)-0.025
scalar max_ob=r(max)+0.025 
sum data if data!=. & ob==. & trend==1
scalar min_cf=r(min)-0.025
scalar max_cf=r(max)+0.025 
/*
sort X1_ob ob
replace dp1=0 if _n==_N | _n==_N-1
replace X1_ob=min_ob if _n==_N
replace X1_ob=max_ob if _n==_N-1
sort X1_cf ob
replace dp2=0 if _n==_N| _n==_N-1
replace X1_cf=min_cf if _n==_N
replace X1_cf=max_cf if _n==_N-1
*/

label variable dp1 "Observed (Pearson VI)"
label variable dp2 "Counterfactual (Pearson IV)"


twoway (line dp1 X1_ob if X1_ob>0 & X1_ob<=10, sort lwidth(medthick) lpattern(dash)) (line dp2 X1_cf if X1_cf>0 & X1_cf<10, sort lwidth(medthick) lpattern(dash))  ///
, legend(position(2) ring(0) order( 1  2 ) region(fcolor(none))) ytitle("Density") xtitle("Earnings (100,000SEK, 2016 prices)") xsize(4) ysize(4) 
graph export "$outfig/PDFlninc2.pdf", replace


* Generate CDF variables for twoway graphing
sort X1_ob ob
cap drop CF1
gen CF1=sum(dp1) 
sum CF1
replace CF1=CF1/r(max) 
sort X1_cf ob
cap drop CF2
gen CF2=sum(dp2)  
sum CF2
replace CF2=CF2/r(max) 

label variable CF1 "Observed (Pearson VI)"
label variable CF2 "Counterfactual (Pearson IV)"



* sort orderings by subgroup so graphs nicely
sort ob  (X1_ob) (X1_cf)

twoway (line CF1 X1_ob if X1_ob>=-2 & X1_ob<=10, lwidth(medthick) lpattern(dash)) (line CF2 X1_cf if X1_cf>=-2 & X1_cf<10, lwidth(medthick) lpattern(dash))   ///
, legend(position(5) ring(0) order(1  2   ) region(fcolor(none))) ytitle("Cumulative Density") xtitle("Earnings (100,000SEK, 2016 prices)") xsize(4) ysize(4) 
graph export "$outfig/CDFlninc2.pdf", replace
