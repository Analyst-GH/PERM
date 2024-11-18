********************************
/*DESCRIPTIVES TABLE  */
********************************
**Folder Data
global outtab2 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\WP1_tables"
global anadata 	"\\micro.intra\projekt\P0524$\P0524_Gem\TN_MK_MF_School_reform_health_SES\output\gawain\PERM\Data"


use  "$anadata\ana_earnPERM.dta", clear

		
* Variables to describe:
lab var treat9D "9 Year Reform Exposure"
lab var FAR_yrseducFOB "Father's Years of Education"
lab var MOR_yrseducFOB "Mother's Years of Education"

global child treat9D male 
global parent FAR_yrseducFOB MOR_yrseducFOB   

sum $child $parent

cd "$outtab2\"
 
global educsamp " treat9D<=1 "
estpost tabstat  cohort   if $educsamp , stat(mean sd )  columns(statistics) 
est store D1
global educsamp " treat9D!=1 "
estpost tabstat  cohort   if $educsamp , stat(mean sd )  columns(statistics) 
est store E1
global educsamp " treat9D==1 "
estpost tabstat  cohort   if $educsamp , stat(mean sd )  columns(statistics) 
est store G1


global educsamp " treat9D<=1 "
estpost tabstat  yearseduc_FOB   if $educsamp , stat(mean variance skewness  )  columns(statistics) 
est store D3
global educsamp " treat9D!=1"
estpost tabstat  yearseduc_FOB    if $educsamp , stat(mean variance skewness  )  columns(statistics) 
est store E3
global educsamp " treat9D==1 "
estpost tabstat  yearseduc_FOB    if $educsamp , stat(mean variance skewness  )  columns(statistics) 
est store G3

global educsamp " treat9D<=1 "
estpost tabstat  inc   if $educsamp , stat(mean variance skewness  )  columns(statistics) 
est store D4
global educsamp " treat9D!=1"
estpost tabstat  inc    if $educsamp , stat(mean variance skewness  )  columns(statistics) 
est store E4
global educsamp " treat9D==1 "
estpost tabstat  inc    if $educsamp , stat(mean variance skewness  )  columns(statistics) 
est store G4

global educsamp " treat9D<=1 "
estpost tabstat   $child   if $educsamp , stat(mean sd )  columns(statistics) 
est store D5
global educsamp " treat9D!=1"
estpost tabstat   $child   if $educsamp , stat(mean sd )  columns(statistics) 
est store E5
global educsamp " treat9D==1 "
estpost tabstat   $child   if $educsamp , stat(mean sd )  columns(statistics) 
est store G5

capture erase descriptivesA.tex
esttab D3 E3  G3  using descriptivesA.tex , append  cells(mean(fmt(%9.2f))) 	mlabels(,none) collabels(,none) eqlabels(,none) nomtitles nonumbers nolines noobs f varlabel(yearseduc_FOB "Mean") wide tex
esttab D3 E3  G3  using descriptivesA.tex , append  cells(variance(fmt(%9.2f))) 	mlabels(,none) collabels(,none) eqlabels(,none) nomtitles nonumbers nolines noobs f varlabel(yearseduc_FOB "Variance") wide tex
esttab D3 E3  G3  using descriptivesA.tex , append  cells(skewness(fmt(%9.2f))) 	mlabels(,none) collabels(,none) eqlabels(,none) nomtitles nonumbers nolines noobs f varlabel(yearseduc_FOB "Skewness") wide tex


capture erase descriptivesB.tex
esttab D4 E4  G4  using descriptivesB.tex , append  cells(mean(fmt(%9.2f))) 	mlabels(,none) collabels(,none) eqlabels(,none) nomtitles nonumbers nolines noobs f varlabel(inc "Mean") wide tex
esttab D4 E4  G4  using descriptivesB.tex , append  cells(variance(fmt(%9.2f))) 	mlabels(,none) collabels(,none) eqlabels(,none) nomtitles nonumbers nolines noobs f varlabel(inc "Variance") wide tex
esttab D4 E4  G4  using descriptivesB.tex , append  cells(skewness(fmt(%9.2f))) 	mlabels(,none) collabels(,none) eqlabels(,none) nomtitles nonumbers nolines noobs f varlabel(inc "Skewness") wide tex


capture erase descriptivesC.tex
esttab D1 E1  G1  using descriptivesC.tex , append  cells(mean(fmt(%9.0f)) sd(par("[" "]") fmt(%9.2f))) 	mlabels(,none) collabels(,none) eqlabels(,none) nomtitles nonumbers nolines noobs f label wide tex
esttab D5 E5  G5  using descriptivesC.tex , append  cells(mean(fmt(%9.2f)) sd(par("[" "]") fmt(%9.2f))) 	mlabels(,none) collabels(,none) eqlabels(,none) stats(N, fmt(%9.0fc)) nomtitles nonumbers nolines f label wide tex

capture erase descriptivesE.tex
esttab D1 E1  G1  using descriptivesE.tex , append  stats(N, fmt(%9.0fc)) 	mlabels(,none) collabels(,none) eqlabels(,none) nomtitles nonumbers nolines noobs f label wide tex

corr inc yearseduc_FOB, cov
local x1: display %9.2f r(C)[2,1]
dis "`x1'"
file open descriptives_COVA using descriptives_COVA.txt, write text replace
file write descriptives_COVA "`x1'"
file close descriptives_COVA

corr inc yearseduc_FOB if  treat9D!=1, cov
local x1: display %9.2f r(C)[2,1]
dis "`x1'"
file open descriptives_COVNT using descriptives_COVNT.txt, write text replace
file write descriptives_COVNT "`x1'"
file close descriptives_COVNT

corr inc yearseduc_FOB if  treat9D==1, cov
local x1: display %9.2f r(C)[2,1]
dis "`x1'"
file open descriptives_COVT using descriptives_COVT.txt, write text replace
file write descriptives_COVT "`x1'"
file close descriptives_COVT

reg inc yearseduc_FOB
local x1: display %9.2f e(b)[1,1]
dis "`x1'"
file open descriptives_CORRA using descriptives_CORRA.txt, write text replace
file write descriptives_CORRA "`x1'"
file close descriptives_CORRA

reg inc yearseduc_FOB if  treat9D!=1
local x1: display %9.2f e(b)[1,1]
dis "`x1'"
file open descriptives_CORRNT using descriptives_CORRNT.txt, write text replace
file write descriptives_CORRNT "`x1'"
file close descriptives_CORRNT

reg inc yearseduc_FOB if  treat9D==1
local x1: display %9.2f e(b)[1,1]
dis "`x1'"
file open descriptives_CORRT using descriptives_CORRT.txt, write text replace
file write descriptives_CORRT "`x1'"
file close descriptives_CORRT

log close