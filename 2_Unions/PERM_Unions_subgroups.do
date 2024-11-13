/*
This STATA do file estimates impact of union coverage as reported in:
 ``Taking an extra moment to consider treatment effects on distributions´´ by Gawain Heckley and Dennis Petrie.

 This do-file estimates the variance treatment effect on the treated, decomposing it by ethnic subgroup
 

*/
global save "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions"
global fig "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions/Results/Fig"
global tab "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions/Results/Tables"
global results "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/PERM WP1/2_Unions/Results/"

clear all

*rename covered union

use "$save/men8385.dta"
* may need to install the following user written packages:
* ssc install rif
global controls1 covered nonwhite marr ed0-ed5 ex1-ex9
global controls2 covered##nonwhite covered##marr covered##i.educ covered##i.exper

************************************************************
************************************************************
* UNIONISATION IMPACTS BY SUB-GROUPS OF ETHNICITY
************************************************************
************************************************************
	
************************************************************
* Impact on variance using PERM regression:
gen y = lwage
gen y2 = lwage^2
sum covered
sca Pr_covered=r(mean)
sum nonwhite
sca Pr_nonwhite=r(mean)

gsem (y <- $controls2, regress) (y2 <- $controls2, regress) y, covstr(e.y e.y2, un) vce(r) nocapslatent
margins, post at(covered=(0(1)1)) vce(unconditional) over(covered)
cd "$results/"
estimates save SUREGA

sureg (y $controls2) (y2 $controls2) 
margins, post at(covered=(0(1)1))  over(covered nonwhite)
cd "$results/"
estimates save SUREG2, replace

* InTT of Variance
estimates use SUREGA
nlcom  covered: ((_b[2._predict#2._at#1.covered] - (_b[1._predict#2._at#1.covered])^2) - (_b[2._predict#1._at#1.covered] - (_b[1._predict#1._at#1.covered])^2 )), post
estimates store HP1

estimates use SUREG2
nlcom  Within_white: ((_b[2._predict#2._at#1.covered#0.nonwhite] - (_b[1._predict#2._at#1.covered#0.nonwhite])^2) - (_b[2._predict#1._at#1.covered#0.nonwhite] - (_b[1._predict#1._at#1.covered#0.nonwhite])^2 )), post
estimates store HPwthn_white

estimates use SUREG2
nlcom  Within_nwhite: ((_b[2._predict#2._at#1.covered#1.nonwhite] - (_b[1._predict#2._at#1.covered#1.nonwhite])^2) - (_b[2._predict#1._at#1.covered#1.nonwhite] - (_b[1._predict#1._at#1.covered#1.nonwhite])^2 )), post
estimates store HPwthn_nwhite

estimates use SUREG2
nlcom  Within: (1-Pr_nonwhite)*((_b[2._predict#2._at#1.covered#0.nonwhite] - (_b[1._predict#2._at#1.covered#0.nonwhite])^2) - (_b[2._predict#1._at#1.covered#0.nonwhite] - (_b[1._predict#1._at#1.covered#0.nonwhite])^2 )) + Pr_nonwhite*((_b[2._predict#2._at#1.covered#1.nonwhite] - (_b[1._predict#2._at#1.covered#1.nonwhite])^2) - (_b[2._predict#1._at#1.covered#1.nonwhite] - (_b[1._predict#1._at#1.covered#1.nonwhite])^2 )), post
estimates store HPwthn

/*
estimates use SUREG2
nlcom  Between: ((_b[2._predict#2._at#1.covered] - (_b[1._predict#2._at#1.covered])^2) - (_b[2._predict#1._at#1.covered] - (_b[1._predict#1._at#1.covered])^2 )) - (1-Pr_nonwhite)*((_b[2._predict#2._at#1.covered#0.nonwhite] - (_b[1._predict#2._at#1.covered#0.nonwhite])^2) - (_b[2._predict#1._at#1.covered#0.nonwhite] - (_b[1._predict#1._at#1.covered#0.nonwhite])^2 )) + Pr_nonwhite*((_b[2._predict#2._at#1.covered#1.nonwhite] - (_b[1._predict#2._at#1.covered#1.nonwhite])^2) - (_b[2._predict#1._at#1.covered#1.nonwhite] - (_b[1._predict#1._at#1.covered#1.nonwhite])^2 )), post
estimates store HPbtwn
*/

capture erase "$tab/Main_union_G.tex"
 		#delimit ;
  estout           HP1
	using "$tab/Main_union_G.tex" , 
	style(tex)
	keep(covered)
	varlabel(covered "Total union effect" )
	/// stats(baseline, labels(Baseline) fmt( %12.4fc))
	cells(b(fmt(4)) se(par fmt(4)))
	mlabels(,none) collabels(,none) eqlabels(,none) 
	append
	/// posthead("\\ `vtext' \\")
	label unstack  prefoot("")
		///starlevels(* 0.10 ** 0.05 *** 0.01) 
;
#delimit cr	;
 		#delimit ;
 		#delimit ;
  estout           HPwthn
	using "$tab/Main_union_G.tex" , 
	style(tex)
	keep(Within)
	varlabel(Within "Within ethnic groups effect" )
	/// stats(baseline, labels(Baseline) fmt( %12.4fc))
	cells(b( fmt(4)) se(par fmt(4)))
	mlabels(,none) collabels(,none) eqlabels(,none) 
	append
	/// posthead("\\ `vtext' \\")
	label unstack  prefoot("")
		///starlevels(* 0.10 ** 0.05 *** 0.01) 
;
#delimit cr	;
 		#delimit ;
  estout           HPwthn_white
	using "$tab/Main_union_G.tex" , 
	style(tex)
	keep(Within_white)
	varlabel(Within_white "\hspace{6mm} Variance within white ethnic group" )
	/// stats(baseline, labels(Baseline) fmt( %12.4fc))
	cells(b( fmt(4)) se(par fmt(4)))
	mlabels(,none) collabels(,none) eqlabels(,none) 
	append
	/// posthead("\\ `vtext' \\")
	label unstack  prefoot("")
		///starlevels(* 0.10 ** 0.05 *** 0.01) 
;
#delimit cr	;
#delimit cr	;
 		#delimit ;
  estout           HPwthn_nwhite
	using "$tab/Main_union_G.tex" , 
	style(tex)
	keep(Within_nwhite)
	varlabel(Within_nwhite "\hspace{6mm} Variance within non-white ethnic group" )
	/// stats(baseline, labels(Baseline) fmt( %12.4fc))
	cells(b( fmt(4)) se(par fmt(4)))
	mlabels(,none) collabels(,none) eqlabels(,none) 
	append
	/// posthead("\\ `vtext' \\")
	label unstack  prefoot("")
		///starlevels(* 0.10 ** 0.05 *** 0.01) 
;
#delimit cr	;
/*
#delimit cr	;
 		#delimit ;
  estout           HPbtwn
	using "$tab/Main_union_G.tex" , 
	style(tex)
	keep(HPbtwn)
	varlabel(HPbtwn "\hspace{6mm} Variance between non-white and white ethnic group means" )
	/// stats(baseline, labels(Baseline) fmt( %12.4fc))
	cells(b(star fmt(4)) se(par fmt(4)))
	mlabels(,none) collabels(,none) eqlabels(,none) 
	append
	/// posthead("\\ `vtext' \\")
	label unstack  prefoot("")
		starlevels(* 0.10 ** 0.05 *** 0.01) 
;
#delimit cr	;
