/*
This STATA do file estimates impact of union coverage as reported in:
 ``Taking an extra moment to consider treatment effects on distributions´´ by Gawain Heckley and Dennis Petrie.

 This do-file performs PERM regression analysis of the mean, variance and standardised skewness comparing these to IPW, stores the PERM and IPW estimates, and their bootstrapped standard errors in an output file.
 
 
*/
* General macros
global save "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions"
global fig "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions/Results/Fig"
global tab "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions/Results/Tables"
global results "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions/Results/"

clear all

*rename covered union
global controls1 covered nonwhite marr ed0-ed5 ex1-ex9
global controls2 covered##nonwhite covered##marr covered##i.educ covered##i.exper

************************************************************
* Mean ITT using re-weighting
clear all

use "$save/men8385.dta"
probit $controls1
capture drop p_covered
predict p_covered, pr

/*Generate nonstabilized weights as P(A=1|covariates) if A = 1 and 1-P(A=1|covariates) if A = 0*/
cap drop w
gen w=.
replace w=1/1 if covered==1
replace w=p_covered/(1-p_covered) if covered==0
/*Check the mean of the weights; we expect it to be close to 2.0*/
sum w

tabstat lwage [aw=w], stat(mean) by(covered) save

sca var_T= r(Stat2)[1,1]
sca var_U=r(Stat1)[1,1]
sca covered_2=var_T-var_U
di covered_2

#delimit;
 	matrix RW = 	(covered_2)
	;
	#delimit cr:
	matrix list RW
	
	
	global bootrep "199"		/*Bootstrap Replications*/
	local n=e(N)	

*Programme:  Draw with replacement, reestimate statistic for each subdraw
capture program drop bootVarRW
program define bootVarRW, rclass
 preserve 
  bsample

probit $controls1
tempvar p_covered
predict `p_covered', pr

*Intt weights
tempvar w
gen `w'=.
replace `w'=1/1 if covered==1
replace `w'=`p_covered'/(1-`p_covered') if covered==0
/*Check the mean of the weights; we expect it to be close to 0.5*/
sum `w'

tabstat lwage [aw=`w'], stat(mean) by(covered) save

sca var_T= r(Stat2)[1,1]
sca var_U=r(Stat1)[1,1]
return sca union=var_T-var_U  



	restore
end

preserve
*Run Bootstrap
#delimit;
simulate 	covered_2=r(union)
			, reps($bootrep) seed(23): bootVarRW
  ;
  #delimit cr;
*Calculate Bootstrap Statistic

bstat, stat(covered_2) n(`n')
bstat covered_2, stat(RW) n(`n')

 estat bootstrap
 cd "$results/"
 est save boottabM, replace 

restore



************************************************************
* variance ITT using re-weighting
clear all
use "$save/men8385.dta"
probit $controls1
capture drop p_covered
predict p_covered, pr

/*Generate nonstabilized weights as P(A=1|covariates) if A = 1 and 1-P(A=1|covariates) if A = 0*/
cap drop w
gen w=.
replace w=1/1 if covered==1
replace w=p_covered/(1-p_covered) if covered==0
/*Check the mean of the weights; we expect it to be close to 2.0*/
sum w

tabstat lwage [aw=w], stat(var) by(covered) save

sca var_T= r(Stat2)[1,1]
sca var_U=r(Stat1)[1,1]
sca covered_2=var_T-var_U
di covered_2

#delimit;
 	matrix RW = 	(covered_2)
	;
	#delimit cr:
	matrix list RW
	
	
	global bootrep "199"		/*Bootstrap Replications*/
	local n=e(N)	

*Programme: Cluster Draw with replacement, reestimate delta statistic for each subdraw
capture program drop bootVarRW
program define bootVarRW, rclass
 preserve 
  bsample

probit $controls1
tempvar p_covered
predict `p_covered', pr

*Intt weights
tempvar w
gen `w'=.
replace `w'=1/1 if covered==1
replace `w'=`p_covered'/(1-`p_covered') if covered==0
/*Check the mean of the weights; we expect it to be close to 0.5*/
sum `w'

tabstat lwage [aw=`w'], stat(var) by(covered) save

sca var_T= r(Stat2)[1,1]
sca var_U=r(Stat1)[1,1]
return sca union=var_T-var_U  
	restore
end

preserve
*Run Bootstrap
#delimit;
simulate 	covered_2=r(union)
			, reps($bootrep) seed(23): bootVarRW
  ;
  #delimit cr;
*Calculate Bootstrap Statistic

bstat, stat(covered_2) n(`n')
bstat covered_2, stat(RW) n(`n')

 estat bootstrap
  cd "$results/"
 est save boottab, replace  

restore




************************************************************
* skewness ITT using re-weighting
clear all
use "$save/men8385.dta"
probit $controls1
capture drop p_covered
predict p_covered, pr

/*Generate nonstabilized weights as P(A=1|covariates) if A = 1 and 1-P(A=1|covariates) if A = 0*/
cap drop w
gen w=.
replace w=1/1 if covered==1
replace w=p_covered/(1-p_covered) if covered==0
/*Check the mean of the weights; we expect it to be close to 2.0*/
sum w

tabstat lwage [aw=w], stat(skewness) by(covered) save

sca var_T= r(Stat2)[1,1]
sca var_U=r(Stat1)[1,1]
sca covered_2=var_T-var_U
di covered_2

#delimit;
 	matrix RW = 	(covered_2)
	;
	#delimit cr:
	matrix list RW
	
	
	global bootrep "199"		/*Bootstrap Replications*/
	local n=e(N)	

*Programme: Cluster Draw with replacement, reestimate delta statistic for each subdraw
capture program drop bootVarRW
program define bootVarRW, rclass
 preserve 
  bsample

probit $controls1
tempvar p_covered
predict `p_covered', pr

*Intt weights
tempvar w
gen `w'=.
replace `w'=1/1 if covered==1
replace `w'=`p_covered'/(1-`p_covered') if covered==0
/*Check the mean of the weights; we expect it to be close to 0.5*/
sum `w'

tabstat lwage [aw=`w'], stat(skewness) by(covered) save

sca var_T= r(Stat2)[1,1]
sca var_U=r(Stat1)[1,1]
return sca union=var_T-var_U  
	restore
end

preserve
*Run Bootstrap
#delimit;
simulate 	covered_2=r(union)
			, reps($bootrep) seed(23): bootVarRW
  ;
  #delimit cr;
*Calculate Bootstrap Statistic

bstat, stat(covered_2) n(`n')
bstat covered_2, stat(RW) n(`n')

 estat bootstrap
  cd "$results/"
 est save boottabS, replace  

restore



************************************************************
* DPTT using PERM regression:
clear all
use "$save/men8385.dta"
gen y = lwage
gen y2 = lwage^2
gen y3 = lwage^3

sum covered
sca Pr_covered=r(mean)

gsem (y <- $controls2, regress) (y2 <- $controls2, regress) (y3 <- $controls2, regress) , vce(r) nocapslatent
margins, post at(covered=(0(1)1)) vce(unconditional) over(covered)

cd "$results/"
estimates save SUREG, replace


* InTT mean
cd "$results/"
estimates use SUREG
nlcom covered: _b[1._predict#2._at#1.covered] - _b[1._predict#1._at#1.covered], post
sca InTT_EST=r(b)[1,1]
sca InTT_EST_se=r(V)[1,1]^.5
di InTT_EST
di InTT_EST_se
estimates save HPM1, replace

*observed mean
estimates use SUREG
nlcom covered:  _b[1._predict#2._at#1.covered], post
estimates save OBM1, replace

* InTT of Variance
cd "$results/"
estimates use SUREG
nlcom  covered: ((_b[2._predict#2._at#1.covered] - (_b[1._predict#2._at#1.covered])^2) - (_b[2._predict#1._at#1.covered] - (_b[1._predict#1._at#1.covered])^2 )), post
sca InTT_EST_V=r(b)[1,1]
sca InTT_EST_V_se=r(V)[1,1]^.5
di InTT_EST_V
di InTT_EST_V_se
estimates save HPV1, replace

*observed variance
estimates use SUREG
nlcom  covered: (_b[2._predict#2._at#1.covered] - (_b[1._predict#2._at#1.covered])^2), post
estimates save OBV1, replace




*Skewness = (E(Y³) - 3 * E(Y) * E(Y²) + 2 * E(Y)³) / (E(Y²) - E(Y)²)^(3/2)

*observed skewness
cd "$results/"
estimates use SUREG
nlcom  covered: ((_b[3._predict#2._at#1.covered])-3*(_b[2._predict#2._at#1.covered])*(_b[1._predict#2._at#1.covered]) +2*(_b[1._predict#2._at#1.covered])^3)/(_b[2._predict#2._at#1.covered] - (_b[1._predict#2._at#1.covered])^2)^(3/2), post
estimates save OBS1, replace

*counterfactual skewness
cd "$results/"
estimates use SUREG
sca ske_C_EST=((_b[3._predict#1._at#1.covered])-3*(_b[2._predict#1._at#1.covered])*(_b[1._predict#1._at#1.covered]) +2*(_b[1._predict#1._at#1.covered])^3)/(_b[2._predict#1._at#1.covered] - (_b[1._predict#1._at#1.covered])^2)^(3/2)
di ske_C_EST

*treatment effect on skewness
cd "$results/"
estimates use SUREG
nlcom  covered: ((_b[3._predict#2._at#1.covered])-3*(_b[2._predict#2._at#1.covered])*(_b[1._predict#2._at#1.covered]) +2*(_b[1._predict#2._at#1.covered])^3)/(_b[2._predict#2._at#1.covered] - (_b[1._predict#2._at#1.covered])^2)^(3/2) - ((_b[3._predict#1._at#1.covered])-3*(_b[2._predict#1._at#1.covered])*(_b[1._predict#1._at#1.covered]) +2*(_b[1._predict#1._at#1.covered])^3)/(_b[2._predict#1._at#1.covered] - (_b[1._predict#1._at#1.covered])^2)^(3/2), post
estimates save HPS1, replace



estimates clear
cd "$results/"
global stored  OBM1 OBV1 OBS1   HPM1 HPV1 HPS1  boottab boottabM boottabS  
foreach XX of global stored {
estimates use `XX'
estimates store `XX'
	}

cd "$tab/"
	
capture erase "$tab/Main_unionInTTM.tex"
 		#delimit ;
  estout          OBM1 HPM1  boottabM
	using "$tab/Main_unionInTTM.tex" , 
	style(tex)
	 rename(covered covered_2) 
	keep(covered_2)
	varlabel( covered_2 "Union" )
	/// stats(baseline, labels(Baseline) fmt( %12.4fc))
	cells(b(fmt(4)) se(par fmt(4)))
	mlabels(,none) collabels(,none) eqlabels(,none) 
	append
	/// posthead("\\ `vtext' \\")
	label unstack  prefoot("")
		/// starlevels(* 0.10 ** 0.05 *** 0.01) 
		
;
#delimit cr	;

capture erase "$tab/Main_unionInTTV.tex"
 		#delimit ;
  estout         OBV1  HPV1  boottab
	using "$tab/Main_unionInTTV.tex" , 
	style(tex)
	 rename(covered covered_2) 
	keep(covered_2)
	varlabel(covered_2 "Union" )
	/// stats(baseline, labels(Baseline) fmt( %12.4fc))
	cells(b(fmt(4)) se(par fmt(4)))
	mlabels(,none) collabels(,none) eqlabels(,none) 
	append
	/// posthead("\\ `vtext' \\")
	label unstack  prefoot("")
		/// starlevels(* 0.10 ** 0.05 *** 0.01) 
;
#delimit cr	;

capture erase "$tab/Main_unionInTTS.tex"
 		#delimit ;
  estout         OBS1  HPS1  boottabS
	using "$tab/Main_unionInTTS.tex" , 
	style(tex)
	 rename(covered covered_2) 
	keep(covered_2)
	varlabel(covered_2 "Union" )
	/// stats(baseline, labels(Baseline) fmt( %12.4fc))
	cells(b(fmt(4)) se(par fmt(4)))
	mlabels(,none) collabels(,none) eqlabels(,none) 
	append
	/// posthead("\\ `vtext' \\")
	label unstack  prefoot("")
		/// starlevels(* 0.10 ** 0.05 *** 0.01) 
;
#delimit cr	;


end

