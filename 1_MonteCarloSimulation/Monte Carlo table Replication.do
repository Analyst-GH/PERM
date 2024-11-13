* PC
global datause "G:\Shared drives\Inequality Decomposition\Monte Carlo Sim"
* mac
global datause "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/Monte Carlo Sim/BS11"
global outtab "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/Monte Carlo Sim/MCS_BS11_tables"


* loop over: (PTT; OB, C) (sampsize) (y ln(y))

clear all
forvalues j=1001(1)11000 {
	display `j'
capture append using "$datause/r_MCS1_nSS250_`j'"
}
gen sampsize=250
forvalues j=501(1)4000 {
	display `j'
capture append using "$datause/r_MCS1_nSS1000_`j'"
}
replace sampsize=1000 if sampsize==.
tab sampsize
bysort sampsize: gen dropp=(_n>100000)
drop if dropp==1
tab sampsize
* just need the point estimates (no standard errors)
* mean TT
label variable Var_cr1 "Unfeasible "
label variable Var_cr6 "Naive "
label variable Var_cr11 "PERM "
label variable Var_cr77 "IPW "
rename Var_cr1 M_U_T
rename Var_cr6 M_N_T
rename Var_cr11 M_P_T
rename Var_cr77 M_W_T
* mean OB
label variable Var_cr35 "PERM "
label variable Var_cr87 "IPW "
rename Var_cr35 M_P_OB
rename Var_cr87 M_W_OB
* mean C
label variable Var_cr56 "PERM "
label variable Var_cr97 "IPW "
rename Var_cr56 M_P_C
rename Var_cr97 M_W_C

***************
* VTT
label variable Var_cr2 "Unfeasible "
label variable Var_cr7 "Naive "
label variable Var_cr12 "PERM "
label variable Var_cr13 "PERM bias corrected"
label variable Var_cr78 "IPW "
rename Var_cr2 V_U_T
rename Var_cr7 V_N_T
rename Var_cr12 V_P_T
rename Var_cr13 V_PBC_T
rename Var_cr78 V_W_T

* V OB
label variable Var_cr36 "PERM "
label variable Var_cr88 "IPW "
rename Var_cr36 V_P_OB
rename Var_cr88 V_W_OB
* V C
label variable Var_cr57 "PERM "
label variable Var_cr98 "IPW "
rename Var_cr57 V_P_C
rename Var_cr98 V_W_C

**************
* CV TT
label variable Var_cr3 "Unfeasible "
label variable Var_cr8 "Naive "
label variable Var_cr14 "PERM "
label variable Var_cr79 "IPW "
rename Var_cr3 CV_U_T
rename Var_cr8 CV_N_T
rename Var_cr14 CV_P_T
rename Var_cr79 CV_W_T
* CV OB
label variable Var_cr37 "PERM "
rename Var_cr37 CV_P_OB
gen CV_W_OB=V_W_OB/M_W_OB
label variable CV_W_OB "IPW "
* CV C
label variable Var_cr58 "PERM "
rename Var_cr58 CV_P_C
gen CV_W_C=V_W_C/M_W_C
label variable CV_W_C "IPW "

****************
* STT
label variable Var_cr160 "Unfeasible "
label variable Var_cr162 "Naive "
label variable Var_cr15 "PERM "
label variable Var_cr23 "PERM bias corrected"
label variable Var_cr164 "IPW "
rename Var_cr160 S_U_T
rename Var_cr162 S_N_T
rename Var_cr15 S_P_T
rename Var_cr23 S_PBC_T
rename Var_cr164 S_W_T
* S OB
label variable Var_cr168 "Unfeasible "
label variable Var_cr170 "Naive "
label variable Var_cr38 "PERM "
label variable Var_cr45 "PERM bias corrected "
label variable Var_cr172 "IPW "
rename Var_cr168 S_U_OB
rename Var_cr170 S_N_OB
rename Var_cr38 S_P_OB
rename Var_cr45 S_PBC_OB
rename Var_cr172 S_W_OB
* S C 
label variable Var_cr176 "Unfeasible "
label variable Var_cr178 "Naive "
label variable Var_cr59 "PERM "
label variable Var_cr66 "PERM bias corrected "
label variable Var_cr180 "IPW "
rename Var_cr176 S_U_C
rename Var_cr178 S_N_C
rename Var_cr59 S_P_C
rename Var_cr66 S_PBC_C
rename Var_cr180 S_W_C

****************
* KTT
label variable Var_cr161 "Unfeasible "
label variable Var_cr163 "Naive "
label variable Var_cr17 "PERM "
label variable Var_cr25 "PERM bias corrected "
label variable Var_cr165 "IPW "
rename Var_cr161 K_U_T
rename Var_cr163 K_N_T
rename Var_cr17 K_P_T
rename Var_cr25 K_PBC_T
rename Var_cr165 K_W_T
* S OB
label variable Var_cr169 "Unfeasible "
label variable Var_cr171 "Naive "
label variable Var_cr40 "PERM "
label variable Var_cr47 "PERM bias corrected "
label variable Var_cr173 "IPW "
rename Var_cr169 K_U_OB
rename Var_cr171 K_N_OB
rename Var_cr40 K_P_OB
rename Var_cr47 K_PBC_OB
rename Var_cr173 K_W_OB
* S C 
label variable Var_cr177 "Unfeasible "
label variable Var_cr179 "Naive "
label variable Var_cr61 "PERM "
label variable Var_cr68 "PERM bias corrected "
label variable Var_cr181 "IPW "
rename Var_cr177 K_U_C
rename Var_cr179 K_N_C
rename Var_cr61 K_P_C
rename Var_cr68 K_PBC_C
rename Var_cr181 K_W_C

* truth scalars
sca 	T_SK =  41.727796
sca 	T_K  =  97.726706
sca 	T_SS =  3.1681685
sca 	T_S =  6.8928078
sca 	T_M =  1.1019412
sca 	T_V =  1.2852445
sca 	T_CV =  0.26914769



********* MEAN ***********
* Table: Mean, s.d., Bias, RMSE
* mean and s.d
global functional M
global estimator U N P W
foreach JJ of global functional {
foreach XX of global estimator {
estpost sum `JJ'_`XX'_T   if sampsize==250
estimates store E`JJ'_`XX'_T_250
estpost sum `JJ'_`XX'_T   if sampsize==1000  
estimates store E`JJ'_`XX'_T_1000
}
}
* bias (true=1.101428)
global functional M
global estimator U N P W
foreach JJ of global functional {
foreach XX of global estimator {
	cap drop `JJ'_`XX'_T_B
	qui gen `JJ'_`XX'_T_B = `JJ'_`XX'_T-T_`JJ'  if sampsize==250 
	estimates restore E`JJ'_`XX'_T_250
	sum `JJ'_`XX'_T_B    if sampsize==250 
estadd scalar bias = r(mean)
estimates store E`JJ'_`XX'_T_250
	cap drop `JJ'_`XX'_T_B
	qui gen `JJ'_`XX'_T_B = `JJ'_`XX'_T-T_`JJ'  if sampsize==1000 
	estimates restore E`JJ'_`XX'_T_1000
	sum `JJ'_`XX'_T_B    if sampsize==1000
estadd scalar bias = r(mean)
estimates store E`JJ'_`XX'_T_1000
}
}
* RMSE (Mean((X-true)^2)^1/2
global functional M
global estimator U N P W
foreach JJ of global functional {
foreach XX of global estimator {
	cap drop `JJ'_`XX'_T_SE
	cap drop `JJ'_`XX'_T_MSE
	cap drop `JJ'_`XX'_T_RMSE
	qui gen `JJ'_`XX'_T_SE = (`JJ'_`XX'_T-T_`JJ')^2  if sampsize==250 
	qui egen `JJ'_`XX'_T_MSE = mean(`JJ'_`XX'_T_SE)  if sampsize==250 
	qui gen `JJ'_`XX'_T_RMSE = `JJ'_`XX'_T_MSE^(1/2)  if sampsize==250 
	estimates restore E`JJ'_`XX'_T_250
	sum `JJ'_`XX'_T_RMSE    if sampsize==250 
estadd scalar RMSE = r(mean)
estimates store E`JJ'_`XX'_T_250
	cap drop `JJ'_`XX'_T_SE
	cap drop `JJ'_`XX'_T_MSE
	cap drop `JJ'_`XX'_T_RMSE
	qui gen `JJ'_`XX'_T_SE = (`JJ'_`XX'_T-T_`JJ')^2  if sampsize==1000 
	qui egen `JJ'_`XX'_T_MSE = mean(`JJ'_`XX'_T_SE)  if sampsize==1000 
	qui gen `JJ'_`XX'_T_RMSE = `JJ'_`XX'_T_MSE^(1/2)  if sampsize==1000 
	estimates restore E`JJ'_`XX'_T_1000
	sum `JJ'_`XX'_T_RMSE    if sampsize==1000 
estadd scalar RMSE = r(mean)
estimates store E`JJ'_`XX'_T_1000
}
}
*Store the mean, sd, and scalars in a matrix:
global functional M
global estimator U N P W
foreach JJ of global functional {
foreach XX of global estimator {
matrix results`XX' = J(1, 8, .) // Create a 1x4 matrix
    estimates restore E`JJ'_`XX'_T_250
    matrix b = e(mean) // Get the coefficient vector
    matrix V = e(sd) // Get the variance-covariance matrix
    scalar mean = b[1,1]
    scalar sd = V[1,1]
    scalar bias = e(bias)
    scalar RMSE = e(RMSE)

    matrix results`XX'[1,1] = mean
    matrix results`XX'[1,2] = sd
    matrix results`XX'[1,3] = bias
    matrix results`XX'[1,4] = RMSE
    
	estimates restore E`JJ'_`XX'_T_1000
    matrix b = e(mean) // Get the coefficient vector
    matrix V = e(sd) // Get the variance-covariance matrix
    scalar mean = b[1,1]
    scalar sd = V[1,1]
    scalar bias = e(bias)
    scalar RMSE = e(RMSE)

    matrix results`XX'[1,5] = mean
    matrix results`XX'[1,6] = sd
    matrix results`XX'[1,7] = bias
    matrix results`XX'[1,8] = RMSE
}
}
global functional M
global estimator U N P W
foreach JJ of global functional {
foreach XX of global estimator {
*matrix colnames results`XX' = mean sd bias RMSE
// Label the row
local v : variable label `JJ'_`XX'_T
matrix rownames results`XX' = "`v'"
esttab matrix(results`XX', fmt(%9.3f)) using "$outtab/`JJ'_`XX'_T.tex", tex  collabels(none) varwidth(30) noobs plain  nomtitles replace fragment
}
}

********* MEAN ***********
* Table: Mean, s.d., Bias, RMSE
* mean and s.d
global functional CV
global estimator U N P W
foreach JJ of global functional {
foreach XX of global estimator {
estpost sum `JJ'_`XX'_T   if sampsize==250
estimates store E`JJ'_`XX'_T_250
estpost sum `JJ'_`XX'_T   if sampsize==1000  
estimates store E`JJ'_`XX'_T_1000
}
}
* bias (true=1.101428)
global functional CV
global estimator U N P W
foreach JJ of global functional {
foreach XX of global estimator {
	cap drop `JJ'_`XX'_T_B
	qui gen `JJ'_`XX'_T_B = `JJ'_`XX'_T-T_`JJ'  if sampsize==250 
	estimates restore E`JJ'_`XX'_T_250
	sum `JJ'_`XX'_T_B    if sampsize==250 
estadd scalar bias = r(mean)
estimates store E`JJ'_`XX'_T_250
	cap drop `JJ'_`XX'_T_B
	qui gen `JJ'_`XX'_T_B = `JJ'_`XX'_T-T_`JJ'  if sampsize==1000 
	estimates restore E`JJ'_`XX'_T_1000
	sum `JJ'_`XX'_T_B    if sampsize==1000
estadd scalar bias = r(mean)
estimates store E`JJ'_`XX'_T_1000
}
}
* RMSE (Mean((X-true)^2)^1/2
global functional CV
global estimator U N P W
foreach JJ of global functional {
foreach XX of global estimator {
	cap drop `JJ'_`XX'_T_SE
	cap drop `JJ'_`XX'_T_MSE
	cap drop `JJ'_`XX'_T_RMSE
	qui gen `JJ'_`XX'_T_SE = (`JJ'_`XX'_T-T_`JJ')^2  if sampsize==250 
	qui egen `JJ'_`XX'_T_MSE = mean(`JJ'_`XX'_T_SE)  if sampsize==250 
	qui gen `JJ'_`XX'_T_RMSE = `JJ'_`XX'_T_MSE^(1/2)  if sampsize==250 
	estimates restore E`JJ'_`XX'_T_250
	sum `JJ'_`XX'_T_RMSE    if sampsize==250 
estadd scalar RMSE = r(mean)
estimates store E`JJ'_`XX'_T_250
	cap drop `JJ'_`XX'_T_SE
	cap drop `JJ'_`XX'_T_MSE
	cap drop `JJ'_`XX'_T_RMSE
	qui gen `JJ'_`XX'_T_SE = (`JJ'_`XX'_T-T_`JJ')^2  if sampsize==1000 
	qui egen `JJ'_`XX'_T_MSE = mean(`JJ'_`XX'_T_SE)  if sampsize==1000 
	qui gen `JJ'_`XX'_T_RMSE = `JJ'_`XX'_T_MSE^(1/2)  if sampsize==1000 
	estimates restore E`JJ'_`XX'_T_1000
	sum `JJ'_`XX'_T_RMSE    if sampsize==1000 
estadd scalar RMSE = r(mean)
estimates store E`JJ'_`XX'_T_1000
}
}
*Store the mean, sd, and scalars in a matrix:
global functional CV
global estimator U N P W
foreach JJ of global functional {
foreach XX of global estimator {
matrix results`XX' = J(1, 8, .) // Create a 1x4 matrix
    estimates restore E`JJ'_`XX'_T_250
    matrix b = e(mean) // Get the coefficient vector
    matrix V = e(sd) // Get the variance-covariance matrix
    scalar mean = b[1,1]
    scalar sd = V[1,1]
    scalar bias = e(bias)
    scalar RMSE = e(RMSE)

    matrix results`XX'[1,1] = mean
    matrix results`XX'[1,2] = sd
    matrix results`XX'[1,3] = bias
    matrix results`XX'[1,4] = RMSE
    
	estimates restore E`JJ'_`XX'_T_1000
    matrix b = e(mean) // Get the coefficient vector
    matrix V = e(sd) // Get the variance-covariance matrix
    scalar mean = b[1,1]
    scalar sd = V[1,1]
    scalar bias = e(bias)
    scalar RMSE = e(RMSE)

    matrix results`XX'[1,5] = mean
    matrix results`XX'[1,6] = sd
    matrix results`XX'[1,7] = bias
    matrix results`XX'[1,8] = RMSE
}
}
global functional CV
global estimator U N P W
foreach JJ of global functional {
foreach XX of global estimator {
*matrix colnames results`XX' = mean sd bias RMSE
// Label the row
local v : variable label `JJ'_`XX'_T
matrix rownames results`XX' = "`v'"
esttab matrix(results`XX', fmt(%9.3f)) using "$outtab/`JJ'_`XX'_T.tex", tex  collabels(none) varwidth(30) noobs plain  nomtitles replace fragment
}
}

********* Variance, skewness and kurtosis ***********
* Table: Mean, s.d., Bias, RMSE
* mean and s.d
global functional V 
global estimator U N P PBC W
foreach JJ of global functional {
foreach XX of global estimator {
estpost sum `JJ'_`XX'_T   if sampsize==250
estimates store E`JJ'_`XX'_T_250
estpost sum `JJ'_`XX'_T   if sampsize==1000  
estimates store E`JJ'_`XX'_T_1000
}
}
* bias (true=1.101428)
global functional V 
global estimator U N P PBC W
foreach JJ of global functional {
foreach XX of global estimator {
	cap drop `JJ'_`XX'_T_B
	qui gen `JJ'_`XX'_T_B = `JJ'_`XX'_T-T_`JJ'  if sampsize==250 
	estimates restore E`JJ'_`XX'_T_250
	sum `JJ'_`XX'_T_B    if sampsize==250 
estadd scalar bias = r(mean)
estimates store E`JJ'_`XX'_T_250
	cap drop `JJ'_`XX'_T_B
	qui gen `JJ'_`XX'_T_B = `JJ'_`XX'_T-T_`JJ'  if sampsize==1000 
	estimates restore E`JJ'_`XX'_T_1000
	sum `JJ'_`XX'_T_B    if sampsize==1000
estadd scalar bias = r(mean)
estimates store E`JJ'_`XX'_T_1000
}
}
* RMSE (Mean((X-true)^2)^1/2
global functional V 
global estimator U N P PBC W
foreach JJ of global functional {
foreach XX of global estimator {
	cap drop `JJ'_`XX'_T_SE
	cap drop `JJ'_`XX'_T_MSE
	cap drop `JJ'_`XX'_T_RMSE
	qui gen `JJ'_`XX'_T_SE = (`JJ'_`XX'_T-T_`JJ')^2  if sampsize==250 
	qui egen `JJ'_`XX'_T_MSE = mean(`JJ'_`XX'_T_SE)  if sampsize==250 
	qui gen `JJ'_`XX'_T_RMSE = `JJ'_`XX'_T_MSE^(1/2)  if sampsize==250 
	estimates restore E`JJ'_`XX'_T_250
	sum `JJ'_`XX'_T_RMSE    if sampsize==250 
estadd scalar RMSE = r(mean)
estimates store E`JJ'_`XX'_T_250
	cap drop `JJ'_`XX'_T_SE
	cap drop `JJ'_`XX'_T_MSE
	cap drop `JJ'_`XX'_T_RMSE
	qui gen `JJ'_`XX'_T_SE = (`JJ'_`XX'_T-T_`JJ')^2  if sampsize==1000 
	qui egen `JJ'_`XX'_T_MSE = mean(`JJ'_`XX'_T_SE)  if sampsize==1000 
	qui gen `JJ'_`XX'_T_RMSE = `JJ'_`XX'_T_MSE^(1/2)  if sampsize==1000 
	estimates restore E`JJ'_`XX'_T_1000
	sum `JJ'_`XX'_T_RMSE    if sampsize==1000 
estadd scalar RMSE = r(mean)
estimates store E`JJ'_`XX'_T_1000
}
}
*Store the mean, sd, and scalars in a matrix:
global functional V 
global estimator U N P PBC W
foreach JJ of global functional {
foreach XX of global estimator {
matrix results`JJ'_`XX' = J(1, 8, .) // Create a 1x4 matrix
    estimates restore E`JJ'_`XX'_T_250
    matrix b = e(mean) // Get the coefficient vector
    matrix V = e(sd) // Get the variance-covariance matrix
    scalar mean = b[1,1]
    scalar sd = V[1,1]
    scalar bias = e(bias)
    scalar RMSE = e(RMSE)

    matrix results`JJ'_`XX'[1,1] = mean
    matrix results`JJ'_`XX'[1,2] = sd
    matrix results`JJ'_`XX'[1,3] = bias
    matrix results`JJ'_`XX'[1,4] = RMSE
    
	estimates restore E`JJ'_`XX'_T_1000
    matrix b = e(mean) // Get the coefficient vector
    matrix V = e(sd) // Get the variance-covariance matrix
    scalar mean = b[1,1]
    scalar sd = V[1,1]
    scalar bias = e(bias)
    scalar RMSE = e(RMSE)

    matrix results`JJ'_`XX'[1,5] = mean
    matrix results`JJ'_`XX'[1,6] = sd
    matrix results`JJ'_`XX'[1,7] = bias
    matrix results`JJ'_`XX'[1,8] = RMSE
}
}
global functional V 
global estimator U N P PBC W
foreach JJ of global functional {
foreach XX of global estimator {
*matrix colnames results`XX' = mean sd bias RMSE
// Label the row
local v : variable label `JJ'_`XX'_T
matrix rownames results`JJ'_`XX' = "`v'"
esttab matrix(results`JJ'_`XX', fmt(%9.3f)) using "$outtab/`JJ'_`XX'_T.tex", tex  collabels(none) varwidth(30) noobs plain  nomtitles replace fragment
}
}

