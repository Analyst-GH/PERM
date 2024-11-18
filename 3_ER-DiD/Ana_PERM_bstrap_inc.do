********************************
/*PERM DiD - uses "did_multiplegt_GHDP.ado" to estimate DiD of raw moments and correction terms for PERM DiD
 - Scalars are produced for the whole treatment period, as well as for every time point and saved to a matrix
 - The whole procedure is then bootstrapped
 - Event study figures for mean, variance, skewness and kurtosis
 - Event study figures comparing DiD and PERM DiD for second, third and fourth raw moments 
 - Event study figures comparing PERM DiD raw moments with no variance/no Skewness/No Kurtosis*/
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

* load into memory dechaisemartin adaptation "did_multiplegt_GHDP"
do "$myado\did_multiplegt_GHDPV12_07"

use  "$anadata\ana_earnPERM.dta", clear

* Transform education and income variables
gen yearseduc_FOB_2 = yearseduc_FOB^2
gen yearseduc_FOB_3 = yearseduc_FOB^3
gen yearseduc_FOB_4 = yearseduc_FOB^4
lab var yearseduc_FOB "Years of education"
lab var yearseduc_FOB_2 "Years of education squared"
lab var yearseduc_FOB_3 "Years of education cubed"
lab var yearseduc_FOB_4 "Years of education quartic"
gen inc_2 = inc^2
gen inc_3 = inc^3
gen inc_4 = inc^4
lab var inc "Earnings (ages 36-55, 100,000 SEK)"
lab var inc_2 "Earnings squared"
lab var inc_3 "Earnings cubed"
lab var inc_4 "Earnings quartic"

* set up polynomials for Y and I, if only interested in Y fill in I with same outcome
global y1 inc
global y2 inc_2
global y3 inc_3
global y4 inc_4

global I1 yearseduc_FOB
gen edu_inc=yearseduc_FOB*inc


*Define matrix to fill, and number of bootstrap repititions 
matrix simu_PERM_EDU=J(201,520,.)


forvalues k=1(1)1 {
di `k'
 {	

* estimate for education first 2 raw moment treatment effects, program only allows for 4 placebos for this sample
did_multiplegt_GHDP $y1 muniid cohort treat9D, robust_dynamic placebo(4) dynamic(8) bivariate(inc) average_effect breps(0) cluster(muniid) 

sca Y1_DD=e(effect_average)
sum $y1 if dif>98 & dif<108
* send to R matrix
sca y1_11=r(mean)
* send to R matrix
sca y1_01=y1_11-Y1_DD

sca delta_rho_avg=e(delta_rho_average)

* save delta_rhos, treatment effects by t in order to calculate Event Study figures
forvalues i = 0/11 {
sca y1_effect_t`i'=e(effect_`i')
}
forvalues i = 1/7 {
sca y1_peffect_t`i'=e(placebo_`i')
}

* for -7, to 11 estimate E[Y_1], then subtract effect_`i to get, E[Y_0], then calculate E[Y^2_1]-E[Y^2_0]
* loop this
forvalues i = 0(1)11 {
sum $y1 if dif==(99+`i')  
sca y1_01_t`i'=r(mean)-y1_effect_t`i'
sca y1_11_t`i'=r(mean)
sca y1_2_01_t`i'=(y1_01_t`i')^2
sca y1_2_11_t`i'=(y1_11_t`i')^2
sca y1_2_DD_t`i'=y1_2_11_t`i'-y1_2_01_t`i'
}
forvalues i = 1(1)7 {
sum $y1 if dif==(99-`i')  
sca y1_01_tL`i'=r(mean)-y1_peffect_t`i'
sca y1_11_tL`i'=r(mean)
sca y1_2_01_tL`i'=(y1_01_tL`i')^2
sca y1_2_11_tL`i'=(y1_11_tL`i')^2
sca y1_2_DD_tL`i'=y1_2_11_tL`i'-y1_2_01_tL`i'
}


* Second moment, TE and ES estimates
sca Y2_TE=e(Teffect2_average)
di Y2_TE
sum $y2 if dif>98  & dif<108 
sca y2_11=r(mean)
sca y2_01=y2_11-Y2_TE
sca Y2_DD=e(effect2_average)

* save treatment effects and DD estimates by t
forvalues i = 0/11 {
sca y2_effect_t`i'=e(effect2_`i')
}
forvalues i = 1/7 {
sca y2_peffect_t`i'=e(placebo2_`i')
}
forvalues i = 0/11 {
sca y2_adj_effect_t`i'=e(Teffect2_`i')
}
forvalues i = 1/7 {
sca y2_adj_peffect_t`i'=e(Tplacebo2_`i')
}

** Variance
* variance = E(Y²) - E(Y)²
* observed variance
sca V_11=(y2_11 - (y1_11)^2) 
* counterfactual variance
sca V_01=(y2_01 - (y1_01)^2)
sca V_TT=((y2_11 - (y1_11)^2) - (y2_01 - (y1_01)^2 ))


* Third moment, TE and ES estimates
sca Y3_TE=e(Teffect3_average)
di Y3_TE
sum $y3 if dif>98  & dif<108 
sca y3_11=r(mean)
sca y3_01=y3_11-Y3_TE
sca Y3_DD=e(effect3_average)

* save treatment effects by t, adjust by delta_rho in order to calculate Event Study figures
forvalues i = 0/11 {
sca y3_effect_t`i'=e(effect3_`i')
}
forvalues i = 1/7 {
sca y3_peffect_t`i'=e(placebo3_`i')
}
forvalues i = 0/11 {
sca y3_adj_effect_t`i'=e(Teffect3_`i')
}
forvalues i = 1/7 {
sca y3_adj_peffect_t`i'=e(Tplacebo3_`i')
}

* for -7, to 11 estimate E[Y^2_1], then subtract effect2_`i' to get, E[Y^2_0], then calculate -3E[Y^2_1]E[Y_1]+2E[Y_1]^3 - (-3E[Y^2_0]E[Y_0]+2E[Y_0]^3)

* loop this
forvalues i = 0(1)11 {
sum $y2 if dif==(99+`i') 
sca y2_01_t`i'=r(mean)-y2_adj_effect_t`i'
sca y2_11_t`i'=r(mean)
sca y12_3_01_t`i'=-3*(y2_01_t`i')*(y1_01_t`i')+2*(y1_01_t`i')^3
sca y12_3_11_t`i'=-3*(y2_11_t`i')*(y1_11_t`i')+2*(y1_11_t`i')^3
sca y12_3_DD_t`i'=y12_3_11_t`i'-y12_3_01_t`i'
}
forvalues i = 1(1)7 {
sum $y2 if dif==(99-`i') 
sca y2_01_tL`i'=r(mean)-y2_adj_peffect_t`i'
sca y2_11_tL`i'=r(mean)
sca y12_3_01_tL`i'=-3*(y2_01_tL`i')*(y1_01_tL`i')+2*(y1_01_tL`i')^3
sca y12_3_11_tL`i'=-3*(y2_11_tL`i')*(y1_11_tL`i')+2*(y1_11_tL`i')^3
sca y12_3_DD_tL`i'=y12_3_11_tL`i'-y12_3_01_tL`i'
}


** Skewness
*Standardised Skewness = (E(Y³) - 3 * E(Y) * E(Y²) + 2 * E(Y)³) / (E(Y²) - E(Y)²)^(3/2)
*observed skewness
sca S_11=((y3_11)-3*(y2_11)*(y1_11) +2*(y1_11)^3)/((y2_11 - (y1_11)^2)^(3/2))
*counterfactual skewness
sca S_01=((y3_01)-3*(y2_01)*(y1_01) +2*(y1_01)^3)/((y2_01 - (y1_01)^2)^(3/2))
sca S_TT=S_11-S_01

* Skewness = (E(Y³) - 3 * E(Y) * E(Y²) + 2 * E(Y)³) / (E(Y²) - E(Y)²)^(3/2)
*observed skewness
sca US_11=((y3_11)-3*(y2_11)*(y1_11) +2*(y1_11)^3)
*counterfactual skewness
sca US_01=((y3_01)-3*(y2_01)*(y1_01) +2*(y1_01)^3)
sca US_TT=US_11-US_01


* Fourth moment, TE and ES estimates
sca Y4_TE=e(Teffect4_average)
di Y4_TE
sum $y4 if dif>98  & dif<108 
sca y4_11=r(mean)
sca y4_01=y4_11-Y4_TE
sca Y4_DD=e(effect4_average)

* save treatment effects by t, adjust by delta_rho in order to calculate Event Study figures
forvalues i = 0/11 {
sca y4_effect_t`i'=e(effect4_`i')
}
forvalues i = 1/7 {
sca y4_peffect_t`i'=e(placebo4_`i')
}
forvalues i = 0/11 {
sca y4_adj_effect_t`i'=e(Teffect4_`i')
}
forvalues i = 1/7 {
sca y4_adj_peffect_t`i'=e(Tplacebo4_`i')
}

* for -7, to 11 estimate E[Y^3_1], then subtract effect3_`i' to get, E[Y^3_0], then calculate -4E[Y^3_1]E[Y_1]+6E[Y^2_1]E[Y_1]^2-3E[Y_1]^4 - (-4E[Y^3_0]E[Y_0]+6E[Y^2_0]E[Y_0]^2-3E[Y_0]^4)

* loop this
forvalues i = 0(1)11 {
sum $y3 if dif==(99+`i') 
sca y3_01_t`i'=r(mean)-y3_adj_effect_t`i'
sca y3_11_t`i'=r(mean)
sca y123_4_01_t`i'=-4*(y3_01_t`i')*(y1_01_t`i')+6*(y2_01_t`i')*(y1_01_t`i')^2-3*(y1_01_t`i')^4
sca y123_4_11_t`i'=-4*(y3_11_t`i')*(y1_11_t`i')+6*(y2_11_t`i')*(y1_11_t`i')^2-3*(y1_11_t`i')^4
sca y123_4_DD_t`i'=y123_4_11_t`i'-y123_4_01_t`i'
}
forvalues i = 1(1)7 {
sum $y3 if dif==(99-`i') 
sca y3_01_tL`i'=r(mean)-y3_adj_peffect_t`i'
sca y3_11_tL`i'=r(mean)
sca y123_4_01_tL`i'=-4*(y3_01_tL`i')*(y1_01_tL`i')+6*(y2_01_tL`i')*(y1_01_tL`i')^2-3*(y1_01_tL`i')^4
sca y123_4_11_tL`i'=-4*(y3_11_tL`i')*(y1_11_tL`i')+6*(y2_11_tL`i')*(y1_11_tL`i')^2-3*(y1_11_tL`i')^4
sca y123_4_DD_tL`i'=y123_4_11_tL`i'-y123_4_01_tL`i'
}



** Kurtosis
*Standardised kurtosis = (E(Y^4) - 4 * E(Y^3) * E(Y) + 6 * E(Y^2) * E(Y)^2 - 3 * E(Y)^4) / (E(Y^2) - E[Y]^2)^2. 
sca K_11=(y4_11-4*y3_11*y1_11+6*y2_11*(y1_11^2)-3*(y1_11)^4)/((y2_11 - (y1_11)^2)^2)
sca K_01=(y4_01-4*y3_01*y1_01+6*y2_01*(y1_01^2)-3*(y1_01)^4)/((y2_01 - (y1_01)^2)^2)
sca K_TT=K_11-K_01

*kurtosis = (E(Y^4) - 4 * E(Y^3) * E(Y) + 6 * E(Y^2) * E(Y)^2 - 3 * E(Y)^4) / (E(Y^2) - E[Y]^2)^2. 
sca UK_11=(y4_11-4*y3_11*y1_11+6*y2_11*(y1_11^2)-3*(y1_11)^4)
sca UK_01=(y4_01-4*y3_01*y1_01+6*y2_01*(y1_01^2)-3*(y1_01)^4)
sca UK_TT=UK_11-UK_01


*** income (Z)
sca Z1_DD=e(effectZ_average)
sum $I1 if dif>98  & dif<108
* send to R matrix
sca z1_11=r(mean)
* send to R matrix
sca z1_01=z1_11-Z1_DD


* save delta_rhos, treatment effects by t in order to calculate Event Study figures
forvalues i = 0/11 {
sca z1_effect_t`i'=e(effectZ_`i')
}
forvalues i = 1/7 {
sca z1_peffect_t`i'=e(placeboZ_`i')
}

* for -7, to 11 estimate E[Y_1], then subtract effect_`i to get, E[Y_0], then calculate E[Y^2_1]-E[Y^2_0]
* loop this
forvalues i = 0(1)11 {
sum $I1 if dif==(99+`i') 
sca z1_01_t`i'=r(mean)-z1_effect_t`i'
sca z1_11_t`i'=r(mean)
sca z1_y1_01_t`i'=(z1_01_t`i')*(y1_01_t`i')
sca z1_y1_11_t`i'=(z1_11_t`i')*(y1_11_t`i')
sca z1_y1_DD_t`i'=z1_y1_11_t`i'-z1_y1_01_t`i'
}
forvalues i = 1(1)7 {
sum $I1 if dif==(99-`i')
sca z1_01_tL`i'=r(mean)-z1_peffect_t`i'
sca z1_11_tL`i'=r(mean)
sca z1_y1_01_tL`i'=(z1_01_tL`i')*(y1_01_tL`i')
sca z1_y1_11_tL`i'=(z1_11_tL`i')*(y1_11_tL`i')
sca z1_y1_DD_tL`i'=z1_y1_11_tL`i'-z1_y1_01_tL`i'
}


* joint moment Z, Y, TE and ES estimates
sca ZY_TE=e(TeffectZY_average)
di ZY_TE
sum edu_inc if dif>98  & dif<108
sca zy_11=r(mean)
sca zy_01=zy_11-ZY_TE
sca ZY_DD=e(effectZY_average)

* save treatment effects and DD estimates by t
forvalues i = 0/11 {
sca zy_effect_t`i'=e(effectZY_`i')
}
forvalues i = 1/7 {
sca zy_peffect_t`i'=e(placeboZY_`i')
}
forvalues i = 0/11 {
sca zy_adj_effect_t`i'=e(TeffectZY_`i')
}
forvalues i = 1/7 {
sca zy_adj_peffect_t`i'=e(TplaceboZY_`i')
}

** Covariance
* covariance = E(ZY) - E(Y)E(Z)
* observed variance
sca C_11=(zy_11 - (z1_11)*(y1_11)) 
* counterfactual variance
sca C_01=(zy_01 - (z1_01)*(y1_01)) 
sca C_TT=(zy_11 - (z1_11)*(y1_11)) - (zy_01 - (z1_01)*(y1_01))

** Slope
* slope = (E(ZY) - E(Y)E(Z))/(Var(Y))
* observed variance
sca B_11=(zy_11 - (z1_11)*(y1_11))/(y2_11 - (y1_11)^2) 
* counterfactual variance
sca B_01=(zy_01 - (z1_01)*(y1_01))/(y2_01 - (y1_01)^2) 
sca B_TT=(zy_11 - (z1_11)*(y1_11))/(y2_11 - (y1_11)^2) - (zy_01 - (z1_01)*(y1_01))/(y2_11 - (y1_11)^2)



******************* Fill the matrix***************************
* y1, average, and time specific estimates
cap matrix simu_PERM_EDU[`k',1]=Y1_DD 
cap matrix simu_PERM_EDU[`k',2]=y1_11
forvalues i = 7(-1)1 {
local j=(2+8-`i')
di `j'
 matrix simu_PERM_EDU[`k',`j']=y1_peffect_t`i' 
}
forvalues i = 0/11 {
local j=10+`i'
cap matrix simu_PERM_EDU[`k',`j']=y1_effect_t`i' 
}



* y2, average, adjusted and time specific estimates
cap matrix simu_PERM_EDU[`k',101]=Y2_DD 
cap matrix simu_PERM_EDU[`k',102]=y2_11
forvalues i = 7(-1)1 {
local j=(102+8-`i')
di `j'
cap matrix simu_PERM_EDU[`k',`j']=y2_peffect_t`i' 
}
forvalues i = 0/11 {
local j=111+`i'
cap matrix simu_PERM_EDU[`k',`j']=y2_effect_t`i' 
}
forvalues i = 7(-1)1 {
local j=(122+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=y2_adj_peffect_t`i' 
}
forvalues i = 0/11 {
local j=130+`i'
cap matrix simu_PERM_EDU[`k',`j']=y2_adj_effect_t`i' 
}
cap matrix simu_PERM_EDU[`k',150]=V_11 
cap matrix simu_PERM_EDU[`k',151]=V_TT
cap matrix simu_PERM_EDU[`k',152]=Y2_TE 

* E[Y1]^2-E[Y0]^2
forvalues i = 7(-1)1 {
local j=(160+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=y1_2_DD_tL`i' 
}
forvalues i = 0/11 {
local j=168+`i'
cap matrix simu_PERM_EDU[`k',`j']=y1_2_DD_t`i' 
}


* y3, average, AND time specific estimates
cap matrix simu_PERM_EDU[`k',201]=Y3_DD 
cap matrix simu_PERM_EDU[`k',202]=y3_11
forvalues i = 7(-1)1 {
local j=(202+8-`i')
di `j'
 matrix simu_PERM_EDU[`k',`j']=y3_peffect_t`i' 
}
forvalues i = 0/11 {
local j=210+`i'
cap matrix simu_PERM_EDU[`k',`j']=y3_effect_t`i' 
}
forvalues i = 7(-1)1 {
local j=(222+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=y3_adj_peffect_t`i'
}
forvalues i = 0/11 {
local j=230+`i'
cap matrix simu_PERM_EDU[`k',`j']=y3_adj_effect_t`i'
}
cap matrix simu_PERM_EDU[`k',250]=Y3_TE
cap matrix simu_PERM_EDU[`k',251]=S_TT
cap matrix simu_PERM_EDU[`k',252]=S_11
cap matrix simu_PERM_EDU[`k',253]=US_11
cap matrix simu_PERM_EDU[`k',254]=US_TT

* -3E[Y^2_1]E[Y_1]+2E[Y_1]^3 - (-3E[Y^2_0]E[Y_0]+2E[Y_0]^3)
forvalues i = 7(-1)1 {
local j=(260+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=y12_3_DD_tL`i' 
}
forvalues i = 0/11 {
local j=268+`i'
cap matrix simu_PERM_EDU[`k',`j']=y12_3_DD_t`i' 
}

* y4, average, adjusted and time specific estimates
cap matrix simu_PERM_EDU[`k',301]=Y4_DD 
cap matrix simu_PERM_EDU[`k',302]=y4_11
forvalues i = 7(-1)1 {
local j=(302+8-`i')
di `j'
cap matrix simu_PERM_EDU[`k',`j']=y4_peffect_t`i' 
}
forvalues i = 0/11 {
local j=310+`i'
cap matrix simu_PERM_EDU[`k',`j']=y4_effect_t`i' 
}
forvalues i = 7(-1)1 {
local j=(322+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=y4_adj_peffect_t`i' 
}
forvalues i = 0/11 {
local j=330+`i'
cap matrix simu_PERM_EDU[`k',`j']=y4_adj_effect_t`i' 
}
cap matrix simu_PERM_EDU[`k',350]=Y4_TE
cap matrix simu_PERM_EDU[`k',351]=K_TT
cap matrix simu_PERM_EDU[`k',352]=K_11
cap matrix simu_PERM_EDU[`k',353]=UK_11
cap matrix simu_PERM_EDU[`k',354]=UK_TT

* -4E[Y^3_1]E[Y_1]+6E[Y^2_1]E[Y_1]^2-3E[Y_1]^4 - (-4E[Y^3_0]E[Y_0]+6E[Y^2_0]E[Y_0]^2-3E[Y_0]^4)
forvalues i = 7(-1)1 {
local j=(360+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=y123_4_DD_tL`i' 
}
forvalues i = 0/11 {
local j=368+`i'
cap matrix simu_PERM_EDU[`k',`j']=y123_4_DD_t`i' 
}

* z1, average, and time specific estimates
cap matrix simu_PERM_EDU[`k',401]=Z1_DD 
cap matrix simu_PERM_EDU[`k',402]=z1_11
forvalues i = 7(-1)1 {
local j=(402+8-`i')
di `j'
 matrix simu_PERM_EDU[`k',`j']=z1_peffect_t`i' 
}
forvalues i = 0/11 {
local j=410+`i'
cap matrix simu_PERM_EDU[`k',`j']=z1_effect_t`i' 
}



* zy, average, adjusted and time specific estimates
cap matrix simu_PERM_EDU[`k',441]=ZY_DD 
cap matrix simu_PERM_EDU[`k',442]=zy_11
forvalues i = 7(-1)1 {
local j=(442+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=zy_peffect_t`i' 
}
forvalues i = 0/11 {
local j=450+`i'
cap matrix simu_PERM_EDU[`k',`j']=zy_effect_t`i' 
}
forvalues i = 7(-1)1 {
local j=(461+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=zy_adj_peffect_t`i' 
}
forvalues i = 0/11 {
local j=469+`i'
cap matrix simu_PERM_EDU[`k',`j']=zy_adj_effect_t`i' 
}
cap matrix simu_PERM_EDU[`k',481]=C_11 
cap matrix simu_PERM_EDU[`k',482]=C_TT
cap matrix simu_PERM_EDU[`k',482]=ZY_TE
cap matrix simu_PERM_EDU[`k',483]=B_11 
cap matrix simu_PERM_EDU[`k',484]=B_TT


* E[ZY]-E[Y]E[Z]
forvalues i = 7(-1)1 {
local j=(492+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=z1_y1_DD_tL`i' 
}
forvalues i = 0/11 {
local j=500+`i'
cap matrix simu_PERM_EDU[`k',`j']=z1_y1_DD_t`i' 
}


}
}



forvalues k=2(1)201 {
di `k'
quietly {	

preserve 
bsample, strata(firstcohort60) cluster(muniid)

* estimate for education first 2 raw moment treatment effects
did_multiplegt_GHDP $y1 muniid cohort treat9D, robust_dynamic placebo(4) dynamic(8) bivariate(inc) average_effect breps(0) cluster(muniid) 

sca Y1_DD=e(effect_average)
sum $y1 if dif>98 & dif<108
* send to R matrix
sca y1_11=r(mean)
* send to R matrix
sca y1_01=y1_11-Y1_DD

sca delta_rho_avg=e(delta_rho_average)

* save delta_rhos, treatment effects by t in order to calculate Event Study figures
forvalues i = 0/11 {
sca y1_effect_t`i'=e(effect_`i')
}
forvalues i = 1/7 {
sca y1_peffect_t`i'=e(placebo_`i')
}

* for -7, to 11 estimate E[Y_1], then subtract effect_`i to get, E[Y_0], then calculate E[Y^2_1]-E[Y^2_0]
* loop this
forvalues i = 0(1)11 {
sum $y1 if dif==(99+`i') 
sca y1_01_t`i'=r(mean)-y1_effect_t`i'
sca y1_11_t`i'=r(mean)
sca y1_2_01_t`i'=(y1_01_t`i')^2
sca y1_2_11_t`i'=(y1_11_t`i')^2
sca y1_2_DD_t`i'=y1_2_11_t`i'-y1_2_01_t`i'
}
forvalues i = 1(1)7 {
sum $y1 if dif==(99-`i') 
sca y1_01_tL`i'=r(mean)-y1_peffect_t`i'
sca y1_11_tL`i'=r(mean)
sca y1_2_01_tL`i'=(y1_01_tL`i')^2
sca y1_2_11_tL`i'=(y1_11_tL`i')^2
sca y1_2_DD_tL`i'=y1_2_11_tL`i'-y1_2_01_tL`i'
}


* Second moment, TE and ES estimates
sca Y2_TE=e(Teffect2_average)
di Y2_TE
sum $y2 if dif>98 & dif<108
sca y2_11=r(mean)
sca y2_01=y2_11-Y2_TE
sca Y2_DD=e(effect2_average)

* save treatment effects and DD estimates by t
forvalues i = 0/11 {
sca y2_effect_t`i'=e(effect2_`i')
}
forvalues i = 1/7 {
sca y2_peffect_t`i'=e(placebo2_`i')
}
forvalues i = 0/11 {
sca y2_adj_effect_t`i'=e(Teffect2_`i')
}
forvalues i = 1/7 {
sca y2_adj_peffect_t`i'=e(Tplacebo2_`i')
}

** Variance
* variance = E(Y²) - E(Y)²
* observed variance
sca V_11=(y2_11 - (y1_11)^2) 
* counterfactual variance
sca V_01=(y2_01 - (y1_01)^2)
sca V_TT=((y2_11 - (y1_11)^2) - (y2_01 - (y1_01)^2 ))


* Third moment, TE and ES estimates
sca Y3_TE=e(Teffect3_average)
di Y3_TE
sum $y3 if dif>98  & dif<108
sca y3_11=r(mean)
sca y3_01=y3_11-Y3_TE
sca Y3_DD=e(effect3_average)

* save treatment effects by t, adjust by delta_rho in order to calculate Event Study figures
forvalues i = 0/11 {
sca y3_effect_t`i'=e(effect3_`i')
}
forvalues i = 1/7 {
sca y3_peffect_t`i'=e(placebo3_`i')
}
forvalues i = 0/11 {
sca y3_adj_effect_t`i'=e(Teffect3_`i')
}
forvalues i = 1/7 {
sca y3_adj_peffect_t`i'=e(Tplacebo3_`i')
}

* for -7, to 11 estimate E[Y^2_1], then subtract effect2_`i' to get, E[Y^2_0], then calculate -3E[Y^2_1]E[Y_1]+2E[Y_1]^3 - (-3E[Y^2_0]E[Y_0]+2E[Y_0]^3)

* loop this
forvalues i = 0(1)11 {
sum $y2 if dif==(99+`i') 
sca y2_01_t`i'=r(mean)-y2_adj_effect_t`i'
sca y2_11_t`i'=r(mean)
sca y12_3_01_t`i'=-3*(y2_01_t`i')*(y1_01_t`i')+2*(y1_01_t`i')^3
sca y12_3_11_t`i'=-3*(y2_11_t`i')*(y1_11_t`i')+2*(y1_11_t`i')^3
sca y12_3_DD_t`i'=y12_3_11_t`i'-y12_3_01_t`i'
}
forvalues i = 1(1)7 {
sum $y2 if dif==(99-`i')
sca y2_01_tL`i'=r(mean)-y2_adj_peffect_t`i'
sca y2_11_tL`i'=r(mean)
sca y12_3_01_tL`i'=-3*(y2_01_tL`i')*(y1_01_tL`i')+2*(y1_01_tL`i')^3
sca y12_3_11_tL`i'=-3*(y2_11_tL`i')*(y1_11_tL`i')+2*(y1_11_tL`i')^3
sca y12_3_DD_tL`i'=y12_3_11_tL`i'-y12_3_01_tL`i'
}


** Skewness
*Standardised Skewness = (E(Y³) - 3 * E(Y) * E(Y²) + 2 * E(Y)³) / (E(Y²) - E(Y)²)^(3/2)
*observed skewness
sca S_11=((y3_11)-3*(y2_11)*(y1_11) +2*(y1_11)^3)/((y2_11 - (y1_11)^2)^(3/2))
*counterfactual skewness
sca S_01=((y3_01)-3*(y2_01)*(y1_01) +2*(y1_01)^3)/((y2_01 - (y1_01)^2)^(3/2))
sca S_TT=S_11-S_01

* Skewness = (E(Y³) - 3 * E(Y) * E(Y²) + 2 * E(Y)³) / (E(Y²) - E(Y)²)^(3/2)
*observed skewness
sca US_11=((y3_11)-3*(y2_11)*(y1_11) +2*(y1_11)^3)
*counterfactual skewness
sca US_01=((y3_01)-3*(y2_01)*(y1_01) +2*(y1_01)^3)
sca US_TT=US_11-US_01


* Fourth moment, TE and ES estimates
sca Y4_TE=e(Teffect4_average)
di Y4_TE
sum $y4 if dif>98  & dif<108 
sca y4_11=r(mean)
sca y4_01=y4_11-Y4_TE
sca Y4_DD=e(effect4_average)

* save treatment effects by t, adjust by delta_rho in order to calculate Event Study figures
forvalues i = 0/11 {
sca y4_effect_t`i'=e(effect4_`i')
}
forvalues i = 1/7 {
sca y4_peffect_t`i'=e(placebo4_`i')
}
forvalues i = 0/11 {
sca y4_adj_effect_t`i'=e(Teffect4_`i')
}
forvalues i = 1/7 {
sca y4_adj_peffect_t`i'=e(Tplacebo4_`i')
}

* for -7, to 11 estimate E[Y^3_1], then subtract effect3_`i' to get, E[Y^3_0], then calculate -4E[Y^3_1]E[Y_1]+6E[Y^2_1]E[Y_1]^2-3E[Y_1]^4 - (-4E[Y^3_0]E[Y_0]+6E[Y^2_0]E[Y_0]^2-3E[Y_0]^4)

* loop this
forvalues i = 0(1)11 {
sum $y3 if dif==(99+`i') 
sca y3_01_t`i'=r(mean)-y3_adj_effect_t`i'
sca y3_11_t`i'=r(mean)
sca y123_4_01_t`i'=-4*(y3_01_t`i')*(y1_01_t`i')+6*(y2_01_t`i')*(y1_01_t`i')^2-3*(y1_01_t`i')^4
sca y123_4_11_t`i'=-4*(y3_11_t`i')*(y1_11_t`i')+6*(y2_11_t`i')*(y1_11_t`i')^2-3*(y1_11_t`i')^4
sca y123_4_DD_t`i'=y123_4_11_t`i'-y123_4_01_t`i'
}
forvalues i = 1(1)7 {
sum $y3 if dif==(99-`i') 
sca y3_01_tL`i'=r(mean)-y3_adj_peffect_t`i'
sca y3_11_tL`i'=r(mean)
sca y123_4_01_tL`i'=-4*(y3_01_tL`i')*(y1_01_tL`i')+6*(y2_01_tL`i')*(y1_01_tL`i')^2-3*(y1_01_tL`i')^4
sca y123_4_11_tL`i'=-4*(y3_11_tL`i')*(y1_11_tL`i')+6*(y2_11_tL`i')*(y1_11_tL`i')^2-3*(y1_11_tL`i')^4
sca y123_4_DD_tL`i'=y123_4_11_tL`i'-y123_4_01_tL`i'
}



** Kurtosis
*Standardised kurtosis = (E(Y^4) - 4 * E(Y^3) * E(Y) + 6 * E(Y^2) * E(Y)^2 - 3 * E(Y)^4) / (E(Y^2) - E[Y]^2)^2. 
sca K_11=(y4_11-4*y3_11*y1_11+6*y2_11*(y1_11^2)-3*(y1_11)^4)/((y2_11 - (y1_11)^2)^2)
sca K_01=(y4_01-4*y3_01*y1_01+6*y2_01*(y1_01^2)-3*(y1_01)^4)/((y2_01 - (y1_01)^2)^2)
sca K_TT=K_11-K_01

*kurtosis = (E(Y^4) - 4 * E(Y^3) * E(Y) + 6 * E(Y^2) * E(Y)^2 - 3 * E(Y)^4) / (E(Y^2) - E[Y]^2)^2. 
sca UK_11=(y4_11-4*y3_11*y1_11+6*y2_11*(y1_11^2)-3*(y1_11)^4)
sca UK_01=(y4_01-4*y3_01*y1_01+6*y2_01*(y1_01^2)-3*(y1_01)^4)
sca UK_TT=UK_11-UK_01


*** income (Z)
sca Z1_DD=e(effectZ_average)
sum $I1 if dif>98  & dif<108
* send to R matrix
sca z1_11=r(mean)
* send to R matrix
sca z1_01=z1_11-Z1_DD


* save delta_rhos, treatment effects by t in order to calculate Event Study figures
forvalues i = 0/11 {
sca z1_effect_t`i'=e(effectZ_`i')
}
forvalues i = 1/7 {
sca z1_peffect_t`i'=e(placeboZ_`i')
}

* for -7, to 11 estimate E[Y_1], then subtract effect_`i to get, E[Y_0], then calculate E[Y^2_1]-E[Y^2_0]
* loop this
forvalues i = 0(1)11 {
sum $I1 if dif==(99+`i') 
sca z1_01_t`i'=r(mean)-z1_effect_t`i'
sca z1_11_t`i'=r(mean)
sca z1_y1_01_t`i'=(z1_01_t`i')*(y1_01_t`i')
sca z1_y1_11_t`i'=(z1_11_t`i')*(y1_11_t`i')
sca z1_y1_DD_t`i'=z1_y1_11_t`i'-z1_y1_01_t`i'
}
forvalues i = 1(1)7 {
sum $I1 if dif==(99-`i') 
sca z1_01_tL`i'=r(mean)-z1_peffect_t`i'
sca z1_11_tL`i'=r(mean)
sca z1_y1_01_tL`i'=(z1_01_tL`i')*(y1_01_tL`i')
sca z1_y1_11_tL`i'=(z1_11_tL`i')*(y1_11_tL`i')
sca z1_y1_DD_tL`i'=z1_y1_11_tL`i'-z1_y1_01_tL`i'
}


* joint moment Z, Y, TE and ES estimates
sca ZY_TE=e(TeffectZY_average)
di ZY_TE
sum edu_inc if dif>98  & dif<108 
sca zy_11=r(mean)
sca zy_01=zy_11-ZY_TE
sca ZY_DD=e(effectZY_average)

* save treatment effects and DD estimates by t
forvalues i = 0/11 {
sca zy_effect_t`i'=e(effectZY_`i')
}
forvalues i = 1/7 {
sca zy_peffect_t`i'=e(placeboZY_`i')
}
forvalues i = 0/11 {
sca zy_adj_effect_t`i'=e(TeffectZY_`i')
}
forvalues i = 1/7 {
sca zy_adj_peffect_t`i'=e(TplaceboZY_`i')
}

** Covariance
* covariance = E(ZY) - E(Y)E(Z)
* observed variance
sca C_11=(zy_11 - (z1_11)*(y1_11)) 
* counterfactual variance
sca C_01=(zy_01 - (z1_01)*(y1_01)) 
sca C_TT=(zy_11 - (z1_11)*(y1_11)) - (zy_01 - (z1_01)*(y1_01))

** Slope
* slope = (E(ZY) - E(Y)E(Z))/(Var(Y))
* observed variance
sca B_11=(zy_11 - (z1_11)*(y1_11))/(y2_11 - (y1_11)^2) 
* counterfactual variance
sca B_01=(zy_01 - (z1_01)*(y1_01))/(y2_01 - (y1_01)^2) 
sca B_TT=(zy_11 - (z1_11)*(y1_11))/(y2_11 - (y1_11)^2) - (zy_01 - (z1_01)*(y1_01))/(y2_11 - (y1_11)^2)



******************* Fill the matrix***************************
* y1, average, and time specific estimates
cap matrix simu_PERM_EDU[`k',1]=Y1_DD 
cap matrix simu_PERM_EDU[`k',2]=y1_11
forvalues i = 7(-1)1 {
local j=(2+8-`i')
di `j'
 matrix simu_PERM_EDU[`k',`j']=y1_peffect_t`i' 
}
forvalues i = 0/11 {
local j=10+`i'
cap matrix simu_PERM_EDU[`k',`j']=y1_effect_t`i' 
}



* y2, average, adjusted and time specific estimates
cap matrix simu_PERM_EDU[`k',101]=Y2_DD 
cap matrix simu_PERM_EDU[`k',102]=y2_11
forvalues i = 7(-1)1 {
local j=(102+8-`i')
di `j'
cap matrix simu_PERM_EDU[`k',`j']=y2_peffect_t`i' 
}
forvalues i = 0/11 {
local j=111+`i'
cap matrix simu_PERM_EDU[`k',`j']=y2_effect_t`i' 
}
forvalues i = 7(-1)1 {
local j=(122+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=y2_adj_peffect_t`i' 
}
forvalues i = 0/11 {
local j=130+`i'
cap matrix simu_PERM_EDU[`k',`j']=y2_adj_effect_t`i' 
}
cap matrix simu_PERM_EDU[`k',150]=V_11 
cap matrix simu_PERM_EDU[`k',151]=V_TT
cap matrix simu_PERM_EDU[`k',152]=Y2_TE 

* E[Y1]^2-E[Y0]^2
forvalues i = 7(-1)1 {
local j=(160+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=y1_2_DD_tL`i' 
}
forvalues i = 0/11 {
local j=168+`i'
cap matrix simu_PERM_EDU[`k',`j']=y1_2_DD_t`i' 
}


* y3, average, AND time specific estimates
cap matrix simu_PERM_EDU[`k',201]=Y3_DD 
cap matrix simu_PERM_EDU[`k',202]=y3_11
forvalues i = 7(-1)1 {
local j=(202+8-`i')
di `j'
 matrix simu_PERM_EDU[`k',`j']=y3_peffect_t`i' 
}
forvalues i = 0/11 {
local j=210+`i'
cap matrix simu_PERM_EDU[`k',`j']=y3_effect_t`i' 
}
forvalues i = 7(-1)1 {
local j=(222+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=y3_adj_peffect_t`i'
}
forvalues i = 0/11 {
local j=230+`i'
cap matrix simu_PERM_EDU[`k',`j']=y3_adj_effect_t`i'
}
cap matrix simu_PERM_EDU[`k',250]=Y3_TE
cap matrix simu_PERM_EDU[`k',251]=S_TT
cap matrix simu_PERM_EDU[`k',252]=S_11
cap matrix simu_PERM_EDU[`k',253]=US_11
cap matrix simu_PERM_EDU[`k',254]=US_TT

* -3E[Y^2_1]E[Y_1]+2E[Y_1]^3 - (-3E[Y^2_0]E[Y_0]+2E[Y_0]^3)
forvalues i = 7(-1)1 {
local j=(260+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=y12_3_DD_tL`i' 
}
forvalues i = 0/11 {
local j=268+`i'
cap matrix simu_PERM_EDU[`k',`j']=y12_3_DD_t`i' 
}

* y4, average, adjusted and time specific estimates
cap matrix simu_PERM_EDU[`k',301]=Y4_DD 
cap matrix simu_PERM_EDU[`k',302]=y4_11
forvalues i = 7(-1)1 {
local j=(302+8-`i')
di `j'
cap matrix simu_PERM_EDU[`k',`j']=y4_peffect_t`i' 
}
forvalues i = 0/11 {
local j=310+`i'
cap matrix simu_PERM_EDU[`k',`j']=y4_effect_t`i' 
}
forvalues i = 7(-1)1 {
local j=(322+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=y4_adj_peffect_t`i' 
}
forvalues i = 0/11 {
local j=330+`i'
cap matrix simu_PERM_EDU[`k',`j']=y4_adj_effect_t`i' 
}
cap matrix simu_PERM_EDU[`k',350]=Y4_TE
cap matrix simu_PERM_EDU[`k',351]=K_TT
cap matrix simu_PERM_EDU[`k',352]=K_11
cap matrix simu_PERM_EDU[`k',353]=UK_11
cap matrix simu_PERM_EDU[`k',354]=UK_TT

* -4E[Y^3_1]E[Y_1]+6E[Y^2_1]E[Y_1]^2-3E[Y_1]^4 - (-4E[Y^3_0]E[Y_0]+6E[Y^2_0]E[Y_0]^2-3E[Y_0]^4)
forvalues i = 7(-1)1 {
local j=(360+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=y123_4_DD_tL`i' 
}
forvalues i = 0/11 {
local j=368+`i'
cap matrix simu_PERM_EDU[`k',`j']=y123_4_DD_t`i' 
}

* z1, average, and time specific estimates
cap matrix simu_PERM_EDU[`k',401]=Z1_DD 
cap matrix simu_PERM_EDU[`k',402]=z1_11
forvalues i = 7(-1)1 {
local j=(402+8-`i')
di `j'
 matrix simu_PERM_EDU[`k',`j']=z1_peffect_t`i' 
}
forvalues i = 0/11 {
local j=410+`i'
cap matrix simu_PERM_EDU[`k',`j']=z1_effect_t`i' 
}



* zy, average, adjusted and time specific estimates
cap matrix simu_PERM_EDU[`k',441]=ZY_DD 
cap matrix simu_PERM_EDU[`k',442]=zy_11
forvalues i = 7(-1)1 {
local j=(442+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=zy_peffect_t`i' 
}
forvalues i = 0/11 {
local j=450+`i'
cap matrix simu_PERM_EDU[`k',`j']=zy_effect_t`i' 
}
forvalues i = 7(-1)1 {
local j=(461+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=zy_adj_peffect_t`i' 
}
forvalues i = 0/11 {
local j=469+`i'
cap matrix simu_PERM_EDU[`k',`j']=zy_adj_effect_t`i' 
}
cap matrix simu_PERM_EDU[`k',481]=C_11 
cap matrix simu_PERM_EDU[`k',482]=C_TT
cap matrix simu_PERM_EDU[`k',482]=ZY_TE
cap matrix simu_PERM_EDU[`k',483]=B_11 
cap matrix simu_PERM_EDU[`k',484]=B_TT


* E[ZY]-E[Y]E[Z]
forvalues i = 7(-1)1 {
local j=(492+8-`i')
cap matrix simu_PERM_EDU[`k',`j']=z1_y1_DD_tL`i' 
}
forvalues i = 0/11 {
local j=500+`i'
cap matrix simu_PERM_EDU[`k',`j']=z1_y1_DD_t`i' 
}



restore

}
}



matrix list simu_PERM_EDU


drop* 
svmat double simu_PERM_EDU
cap save "$output\sim_PERM_INCV2.dta", replace
clear all
use "$output\sim_PERM_INCV2.dta", clear
gen id=_n


* Event study figures, calculate 95% CIs and point estimates
forvalues i = 3(1)21 {
rename simu_PERM_EDU`i' y1_TT_`i'
sum y1_TT_`i' if _n!=1
gen y1_TT_se_`i'=r(sd)
sum y1_TT_`i' if _n==1
replace y1_TT_`i'=r(mean)
gen y1_TT_95LB_`i'=r(mean)-1.96*y1_TT_se_`i'
gen y1_TT_95UB_`i'=r(mean)+1.96*y1_TT_se_`i'
}

forvalues i = 103(1)122 {
rename simu_PERM_EDU`i' y2_TT_`i'
sum y2_TT_`i' if _n!=1
gen y2_TT_se_`i'=r(sd)
sum y2_TT_`i' if _n==1
replace y2_TT_`i'=r(mean)
gen y2_TT_95LB_`i'=r(mean)-1.96*y2_TT_se_`i'
gen y2_TT_95UB_`i'=r(mean)+1.96*y2_TT_se_`i'
}

forvalues i = 123(1)141 {
	local j=`i'+38
gen y2_VAR_TT_`i' = simu_PERM_EDU`i' - simu_PERM_EDU`j' 
sum y2_VAR_TT_`i' if _n!=1
gen y2_VAR_TT_se_`i'=r(sd)
sum y2_VAR_TT_`i' if _n==1
replace y2_VAR_TT_`i'=r(mean)
gen y2_VAR_TT_95LB_`i'=r(mean)-1.96*y2_VAR_TT_se_`i'
gen y2_VAR_TT_95UB_`i'=r(mean)+1.96*y2_VAR_TT_se_`i'
}


forvalues i = 123(1)141 {
rename simu_PERM_EDU`i' y2_adj_TT_`i'
sum y2_adj_TT_`i' if _n!=1
gen y2_adj_TT_se_`i'=r(sd)
sum y2_adj_TT_`i' if _n==1
replace y2_adj_TT_`i'=r(mean)
gen y2_adj_TT_95LB_`i'=r(mean)-1.96*y2_adj_TT_se_`i'
gen y2_adj_TT_95UB_`i'=r(mean)+1.96*y2_adj_TT_se_`i'
}
forvalues i = 161(1)179 {
rename simu_PERM_EDU`i' y1_2_DD_`i'
sum y1_2_DD_`i' if _n!=1
gen y1_2_DD_se_`i'=r(sd)
sum y1_2_DD_`i' if _n==1
replace y1_2_DD_`i'=r(mean)
gen y1_2_DD_95LB_`i'=r(mean)-1.96*y1_2_DD_se_`i'
gen y1_2_DD_95UB_`i'=r(mean)+1.96*y1_2_DD_se_`i'
}




* Y3

forvalues i = 203(1)222 {
rename simu_PERM_EDU`i' y3_TT_`i'
sum y3_TT_`i' if _n!=1
gen y3_TT_se_`i'=r(sd)
sum y3_TT_`i' if _n==1
replace y3_TT_`i'=r(mean)
gen y3_TT_95LB_`i'=r(mean)-1.96*y3_TT_se_`i'
gen y3_TT_95UB_`i'=r(mean)+1.96*y3_TT_se_`i'
}

forvalues i = 223(1)241 {
	local j=`i'+38
gen y3_VAR_TT_`i' = simu_PERM_EDU`i' + simu_PERM_EDU`j' 
sum y3_VAR_TT_`i' if _n!=1
gen y3_VAR_TT_se_`i'=r(sd)
sum y3_VAR_TT_`i' if _n==1
replace y3_VAR_TT_`i'=r(mean)
gen y3_VAR_TT_95LB_`i'=r(mean)-1.96*y3_VAR_TT_se_`i'
gen y3_VAR_TT_95UB_`i'=r(mean)+1.96*y3_VAR_TT_se_`i'
}

forvalues i = 223(1)241 {
rename simu_PERM_EDU`i' y3_adj_TT_`i'
sum y3_adj_TT_`i' if _n!=1
gen y3_adj_TT_se_`i'=r(sd)
sum y3_adj_TT_`i' if _n==1
replace y3_adj_TT_`i'=r(mean)
gen y3_adj_TT_95LB_`i'=r(mean)-1.96*y3_adj_TT_se_`i'
gen y3_adj_TT_95UB_`i'=r(mean)+1.96*y3_adj_TT_se_`i'
}
forvalues i = 261(1)279 {
rename simu_PERM_EDU`i' y2_2_DD_`i'
sum y2_2_DD_`i' if _n!=1
gen y2_2_DD_se_`i'=r(sd)
sum y2_2_DD_`i' if _n==1
replace y2_2_DD_`i'=-r(mean)
gen y2_2_DD_95LB_`i'=-r(mean)-1.96*y2_2_DD_se_`i'
gen y2_2_DD_95UB_`i'=-r(mean)+1.96*y2_2_DD_se_`i'
}



* Y4

forvalues i = 303(1)322 {
rename simu_PERM_EDU`i' y4_TT_`i'
sum y4_TT_`i' if _n!=1
gen y4_TT_se_`i'=r(sd)
sum y4_TT_`i' if _n==1
replace y4_TT_`i'=r(mean)
gen y4_TT_95LB_`i'=r(mean)-1.96*y4_TT_se_`i'
gen y4_TT_95UB_`i'=r(mean)+1.96*y4_TT_se_`i'
}

forvalues i = 323(1)341 {
	local j=`i'+38
gen y4_VAR_TT_`i' = simu_PERM_EDU`i' + simu_PERM_EDU`j'  
sum y4_VAR_TT_`i' if _n!=1
gen y4_VAR_TT_se_`i'=r(sd)
sum y4_VAR_TT_`i' if _n==1
replace y4_VAR_TT_`i'=r(mean)
gen y4_VAR_TT_95LB_`i'=r(mean)-1.96*y4_VAR_TT_se_`i'
gen y4_VAR_TT_95UB_`i'=r(mean)+1.96*y4_VAR_TT_se_`i'
}


forvalues i = 323(1)341 {
rename simu_PERM_EDU`i' y4_adj_TT_`i'
sum y4_adj_TT_`i' if _n!=1
gen y4_adj_TT_se_`i'=r(sd)
sum y4_adj_TT_`i' if _n==1
replace y4_adj_TT_`i'=r(mean)
gen y4_adj_TT_95LB_`i'=r(mean)-1.96*y4_adj_TT_se_`i'
gen y4_adj_TT_95UB_`i'=r(mean)+1.96*y4_adj_TT_se_`i'
}
forvalues i = 361(1)379 {
rename simu_PERM_EDU`i' y3_2_DD_`i'
sum y3_2_DD_`i' if _n!=1
gen y3_2_DD_se_`i'=r(sd)
sum y3_2_DD_`i' if _n==1
replace y3_2_DD_`i'=-r(mean)
gen y3_2_DD_95LB_`i'=-r(mean)-1.96*y3_2_DD_se_`i'
gen y3_2_DD_95UB_`i'=-r(mean)+1.96*y3_2_DD_se_`i'
}



# delimit ;
reshape long 	y1_TT_ y1_TT_se_ y1_TT_95LB_ y1_TT_95UB_ 
				y2_TT_ y2_TT_se_ y2_TT_95LB_ y2_TT_95UB_
				y2_adj_TT_ y2_adj_TT_se_ y2_adj_TT_95LB_ y2_adj_TT_95UB_
				y2_VAR_TT_ y2_VAR_TT_se_ y2_VAR_TT_95LB_ y2_VAR_TT_95UB_
				y1_2_DD_ y1_2_DD_se_ y1_2_DD_95LB_ y1_2_DD_95UB_
				y3_TT_ y3_TT_se_ y3_TT_95LB_ y3_TT_95UB_
				y3_adj_TT_ y3_adj_TT_se_ y3_adj_TT_95LB_ y3_adj_TT_95UB_
				y3_VAR_TT_ y3_VAR_TT_se_ y3_VAR_TT_95LB_ y3_VAR_TT_95UB_
				y2_2_DD_ y2_2_DD_se_ y2_2_DD_95LB_ y2_2_DD_95UB_
				y4_TT_ y4_TT_se_ y4_TT_95LB_ y4_TT_95UB_
				y4_adj_TT_ y4_adj_TT_se_ y4_adj_TT_95LB_ y4_adj_TT_95UB_
				y4_VAR_TT_ y4_VAR_TT_se_ y4_VAR_TT_95LB_ y4_VAR_TT_95UB_
				y3_2_DD_ y3_2_DD_se_ y3_2_DD_95LB_ y3_2_DD_95UB_
				, i(id) j(time)
;
# delimit cr;
* Y1
replace time=time-10 if time<22
* Y2
replace time=time-110 if time>102 & time<111
replace time=time-111 if time>110 & time<123
replace time=time-130 if time>122 & time<142
replace time=time-168 if time>160 & time<180
* Y3
replace time=time-210 if time>202 & time<211
replace time=time-210 if time>210 & time<223
replace time=time-230 if time>222 & time<242
replace time=time-268 if time>260 & time<280
* Y4
replace time=time-310 if time>302 & time<311
replace time=time-310 if time>310 & time<323
replace time=time-330 if time>322 & time<342
replace time=time-368 if time>360 & time<380

replace time=time-1 if time<0

keep if id==1
insobs 8
recode id (.=1)
recode time (.=-1)
recode y1*  (.=0) if time==-1
recode y2*  (.=0) if time==-1
recode y3*  (.=0) if time==-1
recode y4*  (.=0) if time==-1


sort time

cap drop timepl
cap drop timemi
gen timepl=time+0.15
gen timemi=time-0.15

drop if time<-6

grstyle init
grstyle set size 12pt: heading subheading small_body text_option axis_title tick_label minortick_label 
grstyle set size 10pt: key_label

tw  (rcap y1_TT_95LB_ y1_TT_95UB_ time if id==1 & time<9, color(gs9)) (scatter y1_TT_ time if id==1 & time<9, color(ebblue) connect(l) msymbol(Th)), legend(order(2 "E[Y]" 1 "E[Y] 95% CI") col(1) pos(11) ring(0) ) xtitle("Birth Years till First Treated Birth Cohort (t=0)") ytitle("Earnings") xsize(4) ysize(3.5) xlabel(-6(2)8)
graph export "$outtab\Y1_INC_A.pdf", replace

* Y squared vs y_adj squared event study figure
tw  (rcap y2_TT_95LB_ y2_TT_95UB_ time if id==1 & time<9, color(gs9)) (scatter y2_TT_ time if id==1 & time<9, connect(l) msymbol(Oh)) (rcap y2_adj_TT_95LB_ y2_adj_TT_95UB_ time if id==1 & time<9, color(gs4)) (scatter y2_adj_TT_ time if id==1 & time<9, color(ebblue) connect(l) msymbol(Th)), legend(order(4 "E[Y{superscript:2}] Treatment Effect" 3 "E[Y{superscript:2}] TE 95% CI" 2 "E[Y{superscript:2}] DiD" 1 "E[Y{superscript:2}] DiD 95% CI" ) col(1) pos(11) ring(0) ) xtitle("Birth Years till First Treated Birth Cohort (t=0)") ytitle("Earnings{superscript:2}") xsize(4) ysize(3.5) xlabel(-6(2)8)
graph export "$outtab\Y2_INC_TT_A.pdf", replace

* y_adj squared vs E[Y]^2 event study figure
tw  (rcap y2_adj_TT_95LB_ y2_adj_TT_95UB_ timemi if id==1 & time<9, color(gs9)) (scatter y2_adj_TT_ timemi if id==1 & time<9, color(ebblue)  connect(l) msymbol(Oh))  (scatter y1_2_DD_ timepl if id==1 & time<9, color(red) connect(l) msymbol(Th)), legend(order(2 "E[Y{superscript:2}] " 1 "E[Y{superscript:2}]  95% CI" 3 "No Variance Effect" ) col(1) pos(11) ring(0) ) xtitle("Birth Years till First Treated Birth Cohort (t=0)") ytitle("Parameter Treatment Effect on the Treated") xsize(4) ysize(3.5) xlabel(-6(2)8)
graph export "$outtab\Y2_INC_TT_vsEYTT_A.pdf", replace


* Variance event study figure
tw  (rcap y2_VAR_TT_95LB_ y2_VAR_TT_95UB_ timemi if id==1 & time<9, color(gs9)) (scatter y2_VAR_TT_ timemi if id==1 & time<9, color(ebblue) connect(l) msymbol(Oh))  , legend(order(2 "Variance Treatment Effect " 1 "Variance TE 95% CI"  ) col(1) pos(11) ring(0) ) xtitle("Birth Years till First Treated Birth Cohort (t=0)") ytitle("Parameter Treatment Effect on the Treated") xsize(4) ysize(3.5)  xlabel(-6(2)8)
graph export "$outtab\Var_INC_TT_A.pdf", replace



* Y cubed vs y3_adj cubed event study figure
	tw   (rcap y3_TT_95LB_ y3_TT_95UB_ time if id==1 & time<9, color(gs4)) (scatter y3_TT_ time if id==1 & time<12,  connect(l) msymbol(Th)) (rcap y3_adj_TT_95LB_ y3_adj_TT_95UB_ time if id==1 & time<9, color(gs9)) (scatter y3_adj_TT_ time if id==1 & time<9, color(ebblue) connect(l) msymbol(Oh)), legend(order(4 "E[Y{superscript:3}] Treatment Effect" 3 "E[Y{superscript:3}] TE 95% CI" 2 "E[Y{superscript:3}] DiD" 1 "E[Y{superscript:3}] DiD 95% CI" ) col(1) pos(11) ring(0) ) xtitle("Birth Years till First Treated Birth Cohort (t=0)") ytitle("Earnings{superscript:3}") xsize(4) ysize(3.5)  xlabel(-6(2)8)
graph export "$outtab\Y3_INC_adjusted_A.pdf", replace

* y_adj cubed vs skewness remainder event study figure
tw  (rcap y3_adj_TT_95LB_ y3_adj_TT_95UB_ timemi if id==1 & time<9, color(gs9)) (scatter y3_adj_TT_ timemi if id==1 & time<9, color(ebblue) connect(l) msymbol(Oh))  (scatter y2_2_DD_ timepl if id==1 & time<9, color(red) connect(l) msymbol(Th)), legend(order(2 "E[Y{superscript:3}] " 1 "E[Y{superscript:3}] 95% CI" 3 "No Skewness Effect"  ) col(1) pos(11) ring(0) ) xtitle("Birth Years till First Treated Birth Cohort (t=0)") ytitle("Parameter Treatment Effect on the Treated") xsize(4) ysize(3.5)  xlabel(-6(2)8)
graph export "$outtab\Y3_INC_versusY12_A.pdf", replace

* Skewness event study figure
tw  (rcap y3_VAR_TT_95LB_ y3_VAR_TT_95UB_ time if id==1 & time<9, color(gs9)) (scatter y3_VAR_TT_ time if id==1 & time<9, color(ebblue) connect(l) msymbol(Oh))  , legend(order(2 "Skewness Treatment Effect " 1 "Skewness TE 95% CI"  ) col(1) pos(11) ring(0) ) xtitle("Birth Years till First Treated Birth Cohort (t=0)") ytitle("Parameter Treatment Effect on the Treated") xsize(4) ysize(3.5)  xlabel(-6(2)8)
graph export "$outtab\Skew_INC_TT_A.pdf", replace


* Y quadruple vs y4_adj  event study figure
tw   (rcap y4_TT_95LB_ y4_TT_95UB_ time if id==1 & time<9, color(gs4)) (scatter y4_TT_ time if id==1 & time<9,  connect(l) msymbol(Th)) (rcap y4_adj_TT_95LB_ y4_adj_TT_95UB_ time if id==1 & time<9, color(gs9)) (scatter y4_adj_TT_ time if id==1 & time<9, color(ebblue) connect(l) msymbol(Oh)), legend(order(4 "E[Y{superscript:4}] Treatment Effect" 3 "E[Y{superscript:4}] TE 95% CI" 2 "E[Y{superscript:4}] DiD" 1 "E[Y{superscript:4}] DiD 95% CI" ) col(1) pos(11) ring(0) ) xtitle("Birth Years till First Treated Birth Cohort (t=0)") ytitle("Earnings{superscript:4}") xsize(4) ysize(3.5)  xlabel(-6(2)8)
graph export "$outtab\Y4_INC_adjusted_A.pdf", replace

* y_adj ^4 vs kurtosis remainder event study figure
tw  (rcap y4_adj_TT_95LB_ y4_adj_TT_95UB_ timemi if id==1 & time<9, color(gs9)) (scatter y4_adj_TT_ timemi if id==1 & time<9, color(ebblue) connect(l) msymbol(Oh))  (scatter y3_2_DD_ timepl if id==1 & time<9, color(red) connect(l) msymbol(Th)), legend(order(2 "E[Y{superscript:4}] " 1 "E[Y{superscript:4}] 95% CI" 3 "No Kurtosis Effect"  ) col(1) pos(11) ring(0) ) xtitle("Birth Years till First Treated Birth Cohort (t=0)") ytitle("Parameter Treatment Effect on the Treated") xsize(4) ysize(3.5)  xlabel(-6(2)8)
graph export "$outtab\Y4_INC_versusY123_A.pdf", replace

* kurtosis event study figure
tw  (rcap y4_VAR_TT_95LB_ y4_VAR_TT_95UB_ timemi if id==1 & time<9, color(gs9)) (scatter y4_VAR_TT_ timemi if id==1 & time<9, color(ebblue)  connect(l) msymbol(Oh))  , legend(order(2 "Kurtosis Treatment Effect " 1 "Kurtosis TE 95% CI"  ) col(1) pos(11) ring(0) ) xtitle("Birth Years till First Treated Birth Cohort (t=0)") ytitle("Parameter Treatment Effect on the Treated") xsize(4) ysize(3.5) xlabel(-6(2)8)
graph export "$outtab\Kurt_INC_TT_A.pdf", replace


