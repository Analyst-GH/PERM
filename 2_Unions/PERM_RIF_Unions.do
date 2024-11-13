/*
This STATA do file estimates impact of union coverage as reported in:
 ``Taking an extra moment to consider treatment effects on distributions´´ by Gawain Heckley and Dennis Petrie.

 This do-file estimates the Partial Policy Effect using PERM regression and compares it to RIF regression
 

*/

* General macros
* PC
* General macros
global save "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions"
global fig "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions/Results/Fig"
global tab "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions/Results/Tables"
global results "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions/Results/"


clear all

use "$save/men8385.dta"
* may need to install the following user written packages:
* ssc install rif
global controls1 covered nonwhite marr ed0-ed5 ex1-ex9
global controls2 covered##nonwhite covered##marr covered##i.educ covered##i.exper



*************** RIF estimation of PPE: IMPACT OF UNIONS ON VARIANCE *******************
* Impact on variance using RIF regression:
egen RIFvar_lwage=rifvar(lwage), var 
reg RIFvar_lwage $controls2, r
margins , post dydx(covered) 
 cd "$results/"
estimates save RIF1, replace

*************** PERM estimation of PPE: IMPACT OF UNIONS ON VARIANCE  *******************
gen y = lwage
gen y2 = lwage^2
gen y3 = lwage^3
gen y4 = lwage^4
sum covered
sca Pr_covered=r(mean)

sum lwage
sca meanwage=r(mean)
gsem (y <- $controls2, regress) (y2 <- $controls2, regress) y, covstr(e.y e.y2, un) vce(r) nocapslatent

margins, dydx(covered) vce(unconditional) post
nlcom covered: (_b[1.covered:2._predict]-2*meanwage*_b[1.covered:1._predict]), post
estimates save HP3, replace

estimates clear
cd "$results/"
global stored HP3 RIF1
foreach XX of global stored {
estimates use `XX'
estimates store `XX'
	}


capture erase "$tab/Main_unionAPE.tex"
 		#delimit ;
  estout           HP3  RIF1
	using "$tab/Main_unionAPE.tex" , 
	style(tex)
	 rename(1.covered covered) 
	keep(covered)
	varlabel(covered "Union" )
	/// stats(baseline, labels(Baseline) fmt( %12.4fc))
	cells(b(fmt(4)) se(par fmt(4)))
	mlabels(,none) collabels(,none) eqlabels(,none) 
	append
	/// posthead("\\ `vtext' \\")
	label unstack  prefoot("")
		///starlevels(* 0.10 ** 0.05 *** 0.01) 
;
#delimit cr	;
