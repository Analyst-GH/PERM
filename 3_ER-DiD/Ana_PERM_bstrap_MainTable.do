********************************
/*PERM DiD - uses "did_multiplegt_GHDP.ado" to estimate DiD of raw moments and correction terms for PERM DiD
 - Scalars are produced for the whole treatment period, as well as for every time point and saved to a matrix
 - The whole procedure is then bootstrapped
 - This file tablutes the main results
 */
********************************
set scheme cleanplots
graph set window fontface "Times New Roman"

local today: display %tdCYND date(c(current_date), "DMY")

**Folder Data

global outtab 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\WP1_figures"
global outtab2 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\WP1_tables"
global output 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\WP1_output"
global anadata 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\Data"
global myado "\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\do\Gawain\PERM\PERM_DiD"

clear all


******* Main table results (education and covariance) *********
clear all
use "$output\sim_PERM_EDUV2.dta", clear
gen id=_n

rename simu_PERM_EDU1 y1_TT
rename simu_PERM_EDU2 y1_11

rename simu_PERM_EDU151 V_TT
rename simu_PERM_EDU150 V_11

rename simu_PERM_EDU251 S_TT
rename simu_PERM_EDU252 S_11

rename simu_PERM_EDU254 SU_TT
rename simu_PERM_EDU253 SU_11

***** GAWAIN GOT TO HERE, NEED TO ADD COVARIANCE AND BETA, THEN IT'S DONE!
rename simu_PERM_EDU481 C_TT
rename simu_PERM_EDU480 C_11

rename simu_PERM_EDU484 B_TT
rename simu_PERM_EDU483 B_11

global estimator y1_11 y1_TT V_11 V_TT S_11 S_TT SU_11 SU_TT C_11 C_TT B_11 B_TT
global main yearseduc_FOB

cd "$outtab2"
foreach JJ of global main {
foreach var of global estimator {
	sum  `var' if _n==1
	local x1: display %9.3f r(mean)
	di "`x1'"
file open `JJ'_`var'_A using `JJ'_`var'_A.txt, write text replace
file write `JJ'_`var'_A "`x1'"
file close `JJ'_`var'_A
	sum `var' if _n!=1
	local sdx1: display %9.3f r(sd)
	di "`sdx1'"
file open `JJ'_`var'_se_A using `JJ'_`var'_se_A.txt, write text replace
file write `JJ'_`var'_se_A "(`sdx1')"
file close `JJ'_`var'_se_A
}
}

******* Main table results (income) *********
clear all
use "$output\sim_PERM_INCV2.dta", clear
gen id=_n

rename simu_PERM_EDU1 y1_TT
rename simu_PERM_EDU2 y1_11

rename simu_PERM_EDU151 V_TT
rename simu_PERM_EDU150 V_11

rename simu_PERM_EDU251 S_TT
rename simu_PERM_EDU252 S_11

rename simu_PERM_EDU254 SU_TT
rename simu_PERM_EDU253 SU_11

global estimator y1_11 y1_TT V_11 V_TT S_11 S_TT SU_11 SU_TT 
global main inc

cd "$outtab2"
foreach JJ of global main {
foreach var of global estimator {
	sum  `var' if _n==1
	local x1: display %9.3f r(mean)
	di "`x1'"
file open `JJ'_`var'_A using `JJ'_`var'_A.txt, write text replace
file write `JJ'_`var'_A "`x1'"
file close `JJ'_`var'_A
	sum `var' if _n!=1
	local sdx1: display %9.3f r(sd)
	di "`sdx1'"
file open `JJ'_`var'_se_A using `JJ'_`var'_se_A.txt, write text replace
file write `JJ'_`var'_se_A "(`sdx1')"
file close `JJ'_`var'_se_A
}
}
