**#
* Graph settings
graph set window fontface "Times New Roman"
set scheme cleanplots
grstyle init
grstyle set size 12pt: heading subheading body small_body text_option axis_title tick_label minortick_label 
grstyle set size 9pt:key_label

* PC
global datause "G:\Shared drives\Inequality Decomposition\Monte Carlo Sim\BS11"
global outtab "G:\Shared drives\Inequality Decomposition\Monte Carlo Sim\MCS_BS8Figures"
* mac
global datause "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/Monte Carlo Sim/BS11"
global outtab "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/Monte Carlo Sim/MCS_BS11Figures"


clear all
clear
gen sampsize=.
forvalues k=250(1)250 {
forvalues j=1001(1)11000 {
	display `j'
capture append using "$datause/r_MCS1_nSS`k'_`j'ln.dta"
cap drop if Var_cr1==.
}
replace sampsize=`k' if sampsize==.
}
forvalues k=1000(1)1000 {
forvalues j=501(1)3000 {
	display `j'
capture append using "$datause/r_MCS1_nSS`k'_`j'ln.dta"
cap drop if Var_cr1==.
}
replace sampsize=`k' if sampsize==.
}

forvalues j=1(1)1000 {
	display `j'
capture append using "$datause/r_MCS1_nSS10000_`j'ln.dta"
drop if Var_cr_L9==.
}
replace sampsize=10000 if sampsize==.
forvalues j=1(1)2000 {
	display `j'
capture append using "$datause/r_MCS1_nSS100000_`j'ln.dta"
drop if Var_cr_L9==.
}
replace sampsize=100000 if sampsize==.

* choose how many replications want from the total available
tab sampsize
bysort sampsize: gen dropp=(_n>20000)
drop if dropp==1
tab sampsize

gen sampsize_2=1 if sampsize==250
replace sampsize_2=2 if sampsize==375
replace sampsize_2=3 if sampsize==500
replace sampsize_2=4 if sampsize==625 //Not currently there
replace sampsize_2=5 if sampsize==750
replace sampsize_2=6 if sampsize==875 //Not currently there
replace sampsize_2=7 if sampsize==1000
replace sampsize_2=8 if sampsize==2000
replace sampsize_2=9 if sampsize==10000
replace sampsize_2=10 if sampsize==100000
replace sampsize_2=11 if sampsize==1000000 //Not currently there
bysort sampsize: gen FIRST=(_n==1)


*** ln(y) transformation
sca TE_Kurtosis_std = -.66133728
sca TE_Kurtosis =   .1098292
sca TE_Skewness_std =   1.427628
sca TE_Skewness =  .10502422
sca TE_Mean =   .8222533
sca TE_Variance =  .07924245
sca TE_CV =  2.1220568

sca      C_SK =  4.9549911
sca       C_K =  .09870331
sca      C_SS = -.84613859
sca       C_S = -.04486505
sca       C_V =  .14113815
sca       C_M = -.31302197
sca     OB_SK =  4.2936539
sca      OB_K =  .20853251
sca     OB_SS =  .58148944
sca      OB_S =  .06015918
sca      OB_V =   .2203806
sca      OB_M =  .50923133


*********************** COVERAGE ******************************
* variance coverage
* PERM PC bootstrap CI
gen Var_cr_L21_covPC=(Var_cr_L109<TE_Variance & TE_Variance<Var_cr_L110)
sum Var_cr_L21_covPC
* PERM linearisation s.e
gen Var_cr_L11_cov=(abs(Var_cr_L13-TE_Variance)<(1.6449*Var_cr_L21))
sum Var_cr_L11_cov
* PERM bootstrap s.e
gen Var_cr_L22_cov=(abs(Var_cr_L13-TE_Variance)<(1.6449*Var_cr_L29))
sum Var_cr_L22_cov
* IPW bootstrap s.e
gen Var_cr_L7_cov=(abs(Var_cr_L78-TE_Variance)<(1.6449*Var_cr_L83))
sum Var_cr_L7_cov
* IPW PC bootstrap 90% CI
gen Var_cr_L7_covPC=(Var_cr_L121<TE_Variance & TE_Variance<Var_cr_L122)
sum Var_cr_L7_covPC

bysort sampsize: egen coverage_linear=mean(Var_cr_L11_cov)
bysort sampsize: egen coverage_BS=mean(Var_cr_L22_cov)
bysort sampsize: egen coverage_PC=mean(Var_cr_L21_covPC)
bysort sampsize: egen coverage_W=mean(Var_cr_L7_cov)
bysort sampsize: egen coverage_WPC=mean(Var_cr_L7_covPC)


graph tw (line coverage_linear sampsize if FIRST==1) ///
		(line coverage_BS sampsize if FIRST==1)  ///
		(line coverage_PC sampsize if FIRST==1) /// 
		(line coverage_W sampsize if FIRST==1, lpattern(dash))  ///
		(line coverage_WPC sampsize if FIRST==1, lpattern(dash)), /// 
		ylab(0.0(0.2)1) xscale(log) xlabel(250 500 10000 100000 , format(%15.0gc)) ///
		legend(order(1 "PERM Linearisation s.e" 2 "PERM Bootstrap s.e" 3 "PERM Percentile Bootstrap 90% CI" 4 "IPW Bootstrap s.e" 5 "IPW Percentile Bootstrap 90% CI") ///
		position(5) ring(0)) xtitle("Sample Size (log scale)") yline(0.9, lpattern(dash)) ytitle("90% Coverage Rate") graphregion(margin(r+4)) xsize(4) ysize(4) 

graph export "$outtab/Var_Coverage_lnY.pdf", replace	


* Skewness coverage
* PERM bootstrap s.e
gen S_P_CovBS=(abs(Var_cr_L15-TE_Skewness)<(1.6449*Var_cr_L31))
sum S_P_CovBS
* PERM PC bootstrap CI
gen S_P_CovPC=(Var_cr_L113<TE_Skewness & TE_Skewness<Var_cr_L114)
sum S_P_CovPC
* IPW bootstrap s.e
gen S_W_covBS=(abs(Var_cr_L164-TE_Skewness)<(1.6449*Var_cr_L166))
sum S_W_covBS
* IPW PC bootstrap 90% CI
gen S_W_covPC=(Var_cr_L184<TE_Skewness & TE_Skewness<Var_cr_L185)
sum S_W_covPC

bysort sampsize: egen coverage_BSS=mean(S_P_CovBS)
bysort sampsize: egen coverage_PCS=mean(S_P_CovPC)
bysort sampsize: egen coverage_W_BSS=mean(S_W_covBS)
bysort sampsize: egen coverage_W_PCS=mean(S_W_covPC)
cap bysort sampsize: gen FIRST=(_n==1)

graph tw (line coverage_BSS sampsize if FIRST==1)  ///
		(line coverage_PCS sampsize if FIRST==1)  /// 
		(line coverage_W_BSS sampsize if FIRST==1, lpattern(dash))  ///
		(line coverage_W_PCS sampsize if FIRST==1, lpattern(dash)) , /// 
		ylab(0.0(0.2)1.0) xscale(log) yline(0.9, lpattern(dash)) xlabel(250 1000 10000 100000 , format(%15.0gc)) ///
		legend(order(1  "PERM Bootstrap s.e" 2 "PERM Percentile Bootstrap 90% CI"  3  "IPW Bootstrap s.e" 4 "IPW Percentile Bootstrap 90% CI" ) ///
		position(5) ring(0)) xtitle("Sample Size (log scale)") ytitle("90% Coverage Rate")  graphregion(margin(r+4)) xsize(4) ysize(4) 


graph export "$outtab/S_Coverage_lnY.pdf", replace		

* Standardised skewness coverage
* PERM bootstrap s.e
gen Var_cr_L16_cov=(abs(Var_cr_L16-TE_Skewness_std)<(1.6449*Var_cr_L32))
sum Var_cr_L16_cov
* PERM PC bootstrap CI
gen Var_cr_L16_covPC=(Var_cr_L115<TE_Skewness_std & TE_Skewness_std<Var_cr_L116)
sum Var_cr_L16_covPC
* IPW bootstrap s.e
gen Var_cr_L80_cov=(abs(Var_cr_L80-TE_Skewness_std)<(1.6449*Var_cr_L85))
sum Var_cr_L80_cov
* IPW PC bootstrap 90% CI
gen Var_cr_L80_covPC=(Var_cr_L125<TE_Skewness_std & TE_Skewness_std<Var_cr_L126)
sum Var_cr_L80_covPC

bysort sampsize: egen coverage_BSSS=mean(Var_cr_L16_cov)
bysort sampsize: egen coverage_PCSS=mean(Var_cr_L16_covPC)
bysort sampsize: egen coverage_WSS=mean(Var_cr_L80_cov)
bysort sampsize: egen coverage_WPCSS=mean(Var_cr_L80_covPC)
cap bysort sampsize: gen FIRST=(_n==1)

graph tw (line coverage_BSSS sampsize if FIRST==1)  ///
		(line coverage_PCSS sampsize if FIRST==1) /// 
		(line coverage_WSS sampsize if FIRST==1, lpattern(dash))  ///
		(line coverage_WPCSS sampsize if FIRST==1, lpattern(dash)), /// 
		ylab(0.0(0.2)1.0) xscale(log) yline(0.9, lpattern(dash)) xlabel(250 1000 10000 100000 , format(%15.0gc)) ///
		legend(order(1  "PERM Bootstrap s.e" 2 "PERM Percentile Bootstrap 90% CI" 3 "IPW Bootstrap s.e" 4 "IPW Percentile Bootstrap 90% CI") ///
		position(5) ring(0)) xtitle("Sample Size (log scale)") ytitle("90% Coverage Rate")  graphregion(margin(r+4)) xsize(4) ysize(4) 

graph export "$outtab/SS_Coverage_lnY.pdf", replace		


*******************************  BIAS ***************************************************
** BIAS FIGURES (avg result - truth)
** Mean
cap drop Avg_M_PERM Avg_M_IPW
bysort sampsize: egen Avg_M_PERM=mean(Var_cr_L11)
bysort sampsize: egen Avg_M_IPW =mean(Var_cr_L77)

local truth=TE_Mean
di `truth'
graph tw (line Avg_M_PERM sampsize if FIRST==1) ///
		 (line Avg_M_IPW sampsize if FIRST==1), ///
		ylab(#5) xscale(log) xlabel(250 1000 10000 100000 , format(%15.0gc)) ///
		yline(`truth') legend(order(1 "PERM " 2 "IPW " ) ///
		position(1) ring(0))  xtitle("Sample Size (log scale)") ytitle("PTT")  graphregion(margin(r+4)) xsize(4) ysize(4) 

graph export "$outtab/M_BIAS_lnY.pdf", replace	

** Variance
bysort sampsize: egen Avg_Var_PERM=mean(Var_cr_L12)
bysort sampsize: egen Avg_Var_PERM2=mean(Var_cr_L13)
bysort sampsize: egen Avg_Var_IPW =mean(Var_cr_L78)

local truth=TE_Variance
di `truth'
graph tw (line Avg_Var_PERM sampsize if FIRST==1) ///
		(line Avg_Var_PERM2 sampsize if FIRST==1) ///
		 (line Avg_Var_IPW sampsize if FIRST==1), ///
		ylab(0.03(0.02).12) xscale(log) xlabel(250 1000 10000 100000 , format(%15.0gc)) ///
		yline(`truth') legend(order(1 "PERM " 2 "PERM bias corrected" 3 "IPW" ) ///
		position(1) ring(0))  xtitle("Sample Size (log scale)") ytitle("PTT")  graphregion(margin(r+4)) xsize(4) ysize(4) 

graph export "$outtab/Var_BIAS_lnY.pdf", replace		

** Un-Standardised skewness
cap drop Avg_S_PERM
bysort sampsize: egen Avg_S_PERM=mean(Var_cr_L15)
bysort sampsize: egen Avg_S_PERM2=mean(Var_cr_L23)
bysort sampsize: egen Avg_S_IPW=mean(Var_cr_L164)
bysort sampsize: egen Avg_S_Unfeasible=mean(Var_cr_L160)



local truth=TE_Skewness
di `truth'
graph tw (line Avg_S_PERM sampsize if FIRST==1) ///
		(line Avg_S_PERM2 sampsize if FIRST==1) ///
				(line Avg_S_IPW sampsize if FIRST==1, lpattern(dash)), ///
		ylab(0.045(0.03).175) xscale(log) xlabel(250 1000 10000 100000 , format(%15.0gc)) ///
		yline(`truth') legend(order(1 "PERM " 2 "PERM bias corrected" 3 "IPW " ) ///
		position(1) ring(0))  xtitle("Sample Size (log scale)") ytitle("PTT")  graphregion(margin(r+4)) xsize(4) ysize(4) 

graph export "$outtab/S_BIAS_lnY.pdf", replace	


** Standardised skewness
bysort sampsize: egen Avg_SS_PERM=mean(Var_cr_L16)
bysort sampsize: egen Avg_SS_IPW=mean(Var_cr_L80)

local truth=TE_Skewness_std
di `truth'
graph tw (line Avg_SS_PERM sampsize if FIRST==1) ///
(line Avg_SS_IPW sampsize if FIRST==1), ///
		ylab(0.8(0.2)2) xscale(log) xlabel(250 1000 10000 100000 , format(%15.0gc)) ///
		yline(`truth') legend(order(1 "PERM "  2 "IPW "  ) ///
		position(1) ring(0))  xtitle("Sample Size (log scale)") ytitle("PTT")  graphregion(margin(r+4)) xsize(4) ysize(4) 

graph export "$outtab/SS_BIAS_lnY.pdf", replace	



******
** ROOT MEAN SQUARE ERROR FIGURES
** Variance
gen MSE_Var=(Var_cr_L13-TE_Variance)^2
bysort sampsize: egen average_MSE_Var=mean(MSE_Var)
gen RMSE_Var=average_MSE_Var^0.5

gen MSE_Var_P=(Var_cr_L12-TE_Variance)^2
bysort sampsize: egen average_MSE_Var_P=mean(MSE_Var_P)
gen RMSE_Var_P=average_MSE_Var_P^0.5

gen MSE_Var_IPW=(Var_cr_L78-TE_Variance)^2
bysort sampsize: egen average_MSE_Var_IPW=mean(MSE_Var_IPW)
gen RMSE_Var_IPW=average_MSE_Var_IPW^0.5


graph tw (line RMSE_Var_P sampsize if FIRST==1) ///
		(line RMSE_Var sampsize if FIRST==1) ///
		 (line RMSE_Var_IPW sampsize if FIRST==1, lpattern(dash)), ///
		ylab(#5) xscale(log) xlabel(250 1000 10000 100000 , format(%15.0gc)) ///
		legend(order(1 "PERM " 2 "PERM bias corrected " 3 "IPW") ///
		position(1) ring(0)) xtitle("Sample Size (log scale)") ytitle("RMSE")  graphregion(margin(r+4)) xsize(4) ysize(4) 


graph export "$outtab/Var_RMSE_lnY.pdf", replace		

** Un-Standardised skewness
gen MSE_S=(Var_cr_L15-TE_Skewness)^2
bysort sampsize: egen average_MSE_S=mean(MSE_S)
gen RMSE_S=average_MSE_S^0.5

gen MSE_S_P=(Var_cr_L23-TE_Skewness)^2
bysort sampsize: egen average_MSE_S_P=mean(MSE_S_P)
gen RMSE_S_P=average_MSE_S_P^0.5

gen MSE_S_W=(Var_cr_L164-TE_Skewness)^2
bysort sampsize: egen average_MSE_S_W=mean(MSE_S_W)
gen RMSE_S_W=average_MSE_S_W^0.5

graph tw (line RMSE_S sampsize if FIRST==1) ///
				(line RMSE_S_P sampsize if FIRST==1) ///
				(line RMSE_S_W sampsize if FIRST==1), ///
		ylab(#5) xscale(log) xlabel(250 1000 10000 100000 , format(%15.0gc)) ///
		legend(order(1 "PERM" 2 "PERM bias corrected" 3 "IPW") ///
		position(1) ring(0)) xtitle("Sample Size (log scale)") ytitle("RMSE")  graphregion(margin(r+4)) xsize(4) ysize(4) 

graph export "$outtab/S_RMSE_lnY.pdf", replace

** Standardised skewness
gen MSE_SS=(Var_cr_L16-TE_Skewness_std)^2
bysort sampsize: egen average_MSE_SS=mean(MSE_SS)
gen RMSE_SS=average_MSE_SS^0.5

gen MSE_SS_IPW=(Var_cr_L80-TE_Skewness_std)^2
bysort sampsize: egen average_MSE_SS_IPW=mean(MSE_SS_IPW)
gen RMSE_SS_IPW=average_MSE_SS_IPW^0.5


graph tw (line RMSE_SS sampsize if FIRST==1) ///
		 (line RMSE_SS_IPW sampsize if FIRST==1), ///
		ylab(#5) xscale(log) xlabel(250 1000 10000 100000 , format(%15.0gc)) ///
		legend(order(1 "PERM RMSE" 2 "IPW RMSE") ///
		position(1) ring(0)) xtitle("Sample Size (log scale)") ytitle("RMSE")  graphregion(margin(r+4)) xsize(4) ysize(4) 

graph export "$outtab/SS_RMSE_lnY.pdf", replace		

