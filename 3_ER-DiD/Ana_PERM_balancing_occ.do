********************************
/*Balanincing tests TABLE  */
********************************
**Folder Data
global outfig 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\WP1_tables"
global outtab 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\WP1_tables"
global anadata 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\Data"

cd "$outtab"

use  "$anadata\ana_earnPERM.dta", clear

gen farmerp=0
gen nooccp=0
gen bluecp=0
gen whitecp=0
replace farmerp=1 if occ5f==1 | occ5m==1
replace nooccp=1 if occ10f==1 | occ10m==1
replace bluecp=1 if occ6f==1 | occ6m==1 
replace bluecp=1 if occ8f==1 | occ8m==1
replace bluecp=1 if occ7f==1 | occ7m==1
replace bluecp=1 if occ9f==1  | occ9m==1
replace whitecp=1 if occ1f==1 | occ1m==1
replace whitecp=1 if occ2f==1 | occ2m==1
replace whitecp=1 if occ3f==1 | occ3m==1
replace whitecp=1 if occ4f==1|  occ4m==1

lab var farmerp "Agricultural worker"
lab var nooccp "No occupation"
lab var bluecp "Blue collar worker"
lab var whitecp "White collar worker"


global dependent "   farmerp bluecp whitecp"
foreach i of global dependent {

reghdfe `i'  treat9D , absorb(i.cohort) vce(cluster muniid) 
sca a1`i'=r(table)[1,1]
sca a1`i'_se=r(table)[2,1]
  

did_multiplegt `i' muniid cohort treat9D, robust_dynamic placebo(0) dynamic(8)  average_effect breps(200) cluster(muniid) 
sca a2`i'=e(effect_average)
sca a2`i'_se=e(se_effect_average)
  

  }

  cd "$outtab\"
  
foreach i of global dependent {
  
local x1: display %9.3f a1`i'
dis "`x1'"
file open Balancing_a1`i' using Balancing_a1`i'.txt, write text replace
file write Balancing_a1`i' "`x1'"
file close Balancing_a1`i'

local x2: display %9.3f a1`i'_se
dis "`x2'"
file open Balancing_a1`i'_se using Balancing_a1`i'_se.txt, write text replace
file write Balancing_a1`i'_se "(`x2')"
file close Balancing_a1`i'_se
  
local x3: display %9.3f a2`i'
dis "`x3'"
file open Balancing_a2`i' using Balancing_a2`i'.txt, write text replace
file write Balancing_a2`i' "`x3'"
file close Balancing_a2`i'

local x4: display %9.3f a2`i'_se
dis "`x4'"
file open Balancing_a2`i'_se using Balancing_a2`i'_se.txt, write text replace
file write Balancing_a2`i'_se "(`x4')"
file close Balancing_a2`i'_se
    }
 
 
