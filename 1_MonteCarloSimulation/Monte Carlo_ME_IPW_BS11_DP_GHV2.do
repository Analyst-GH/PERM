/*
This STATA do file provides a Monte Carlo simulation of PERM and IPW from ``Taking an extra moment to consider treatment effects on distributions´´ by Gawain Heckley and Dennis Petrie.

It uses the same DGP as Firpo and Pinto (2016), also described in Appendix E of our paper.

Estimates are provided for observed, counterfactual and DPTE for mean, variance, coefficient of variation, skewness, standardised skewness, kurtosis and standardised kurtosis 
Two sub-programs are utilised
1) PERM_quad provides bootstrap standard errors for IPW and PERM based estimates
2) PERM_bias provides sample estimator bias correction terms, to provide bias corrected PERM estimator for variance, skewness and kurtosis

The Monte Carlo exercise consists of looping the whole DGP, PERM and IPW procedures and saving these to a matrix. Many simulations can run concurrently.
All simulations are then appended from each matrix datafile and then analysed usin a separate code
*/

* PC
*global save "G:\Shared drives\Inequality Decomposition\Monte Carlo Sim\BS7"
* mac
global save "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/Monte Carlo Sim/BS11"

clear all


*Create program used in MCS - sample with replacement generation of sampling error components used to correct the PERM sample estimator
capture program drop PERM_bias
program define PERM_bias, rclass 

reg y (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform 
margins , post at(reform=(0(1)1)) over(reform) nose
sca e11=y11-_b[2._at#1.reform]
return sca e11_2=e11^2
return sca e11_3=e11^3
return sca e11_4=e11^4
sca e01=y01-_b[1._at#1.reform]
return sca e01_2=e01^2
return sca e01_3=e01^3
return sca e01_4=e01^4

reg y2 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform 
margins , post at(reform=(0(1)1)) over(reform)  nose
sca e12=y211-_b[2._at#1.reform]
return sca e12_2=e12^2
sca e02=y201-_b[1._at#1.reform]
return sca e02_2=e02^2

reg y3 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform 
margins , post at(reform=(0(1)1)) over(reform)  nose
sca e13=y311-_b[2._at#1.reform]
return sca e13_2=e13^2
sca e03=y301-_b[1._at#1.reform]
return sca e03_2=e03^2

return sca e11_12=e11*e12
return sca e01_02=e01*e02
return sca e11_2_12=e11_2*e12
return sca e01_2_02=e01_2*e02
return sca e11_13=e11*e13
return sca e01_03=e01*e03

* add these as not sure if sample means or bootstrap sample means should be used
return sca bmu11_e11_2=e11^2*(y11+e11)
return sca bmu01_e01_2=e01^2*(y01+e01)

return sca bmu12_e11_2=e11^2*(y211+e12)
return sca bmu02_e01_2=e01^2*(y201+e02)
return sca bmu11_e11_12=(y11+e11)*e11*e12
return sca bmu01_e01_02=(y01+e01)*e01*e02
return sca bmu11_e11_3=e11^3*(y11+e11)
return sca bmu01_e01_3=e01^3*(y01+e01)
return sca bmu11_2_e11_2=e11^2*(y11+e11)^2
return sca bmu01_2_e01_2=e01^2*(y01+e01)^2

end


*Create program use in MCS - provides bootstrap standard errors 
capture program drop PERM_quad
program define PERM_quad, rclass 

reg y (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) vce(unconditional)
sca by11 =  _b[2._at#1.reform]
sca by01 =  _b[1._at#1.reform]
sca bV11 =  e(V)[4,4]
sca bV01 =  e(V)[2,2]

** GAWAIN ADDED error terms to this bootstrap, pulled out by the simulation, then used to correct PERM (but not provide standard errors)

sca e11=y11-_b[2._at#1.reform]
return sca e11_2=e11^2
return sca e11_3=e11^3
return sca e11_4=e11^4
sca e01=y01-_b[1._at#1.reform]
return sca e01_2=e01^2
return sca e01_3=e01^3
return sca e01_4=e01^4

reg y2 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca by211 =  _b[2._at#1.reform]
sca by201 =  _b[1._at#1.reform]

sca e12=y211-_b[2._at#1.reform]
return sca e12_2=e12^2
sca e02=y201-_b[1._at#1.reform]
return sca e02_2=e02^2

reg y3 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca by311 =  _b[2._at#1.reform]
sca by301 =  _b[1._at#1.reform]

sca e13=y311-_b[2._at#1.reform]
return sca e13_2=e13^2
sca e03=y301-_b[1._at#1.reform]
return sca e03_2=e03^2

reg y4 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca by411 =  _b[2._at#1.reform]
sca by401 =  _b[1._at#1.reform]

return sca e11_12=e11*e12
return sca e01_02=e01*e02
return sca e11_2_12=e11^2*e12
return sca e01_2_02=e01^2*e02
return sca e11_13=e11*e13
return sca e01_03=e01*e03

* add these as not sure if sample means or bootstrap sample means should be used
return sca bmu11_e11_2=e11^2*(y11+e11)
return sca bmu01_e01_2=e01^2*(y01+e01)

return sca bmu12_e11_2=e11^2*(y211+e12)
return sca bmu02_e01_2=e01^2*(y201+e02)
return sca bmu11_e11_12=(y11+e11)*e11*e12
return sca bmu01_e01_02=(y01+e01)*e01*e02
return sca bmu11_e11_3=e11^3*(y11+e11)
return sca bmu01_e01_3=e01^3*(y01+e01)
return sca bmu11_2_e11_2=e11^2*(y11+e11)^2
return sca bmu01_2_e01_2=e01^2*(y01+e01)^2


* PTT of mean
return sca M_ME_TE= by11 - by01
return sca M_ME_OB= by11
return sca M_ME_C = by01
di r(M_ME_TE)

* PTT of Variance
return sca V_ME_OB=((by211 - (by11)^2))
return sca V_ME_C =((by201 - (by01)^2 ))
return sca V_ME_TE=((by211 - (by11)^2) - (by201 - (by01)^2 ))
di r(V_ME_TE)

* PTT of Variance SSB corrected*/
return sca V_MESSB_TE=(((by211 - (by11)^2) - (by201 - (by01)^2 )) + bV11 - bV01)
di r(V_MESSB_TE)

* PTT of CoefVariation */
return sca CV_ME_OB=((sqrt(by211 - (by11)^2))/by11 )
return sca CV_ME_C=( (sqrt(by201 - (by01)^2))/by01)
return sca CV_ME_TE=((sqrt(by211 - (by11)^2))/by11 - (sqrt(by201 - (by01)^2))/by01)
di r(CV_ME_TE)

* PTT of Skewness
return sca S_ME_OB= ((by311)-3*(by211)*(by11) +2*(by11)^3)
return sca S_ME_C= ((by301)-3*(by201)*(by01) +2*(by01)^3)
return sca S_ME_TE= ((by311)-3*(by211)*(by11) +2*(by11)^3) - (((by301)-3*(by201)*(by01) +2*(by01)^3))
di r(S_ME_TE)

* PTT of standardised Skewness
return sca SS_ME_OB= ((by311)-3*(by211)*(by11) +2*(by11)^3)/(by211 - (by11)^2)^(3/2) 
return sca SS_ME_C= (((by301)-3*(by201)*(by01) +2*(by01)^3)/(by201 - (by01)^2)^(3/2))
return sca SS_ME_TE= ((by311)-3*(by211)*(by11) +2*(by11)^3)/(by211 - (by11)^2)^(3/2) - (((by301)-3*(by201)*(by01) +2*(by01)^3)/(by201 - (by01)^2)^(3/2))
di r(SS_ME_TE)

* PTT of Kurtosis
return sca K_ME_OB= (by411-(4*by311*by11)+6*by211*(by11^2)-3*(by11^4))
return sca K_ME_C= ((by401-(4*by301*by01)+6*by201*(by01^2)-3*(by01^4)))
return sca K_ME_TE= (by411-(4*by311*by11)+6*by211*(by11^2)-3*(by11^4)) - (by401-(4*by301*by01)+6*by201*(by01^2)-3*(by01^4))
di r(K_ME_TE)

* PTT of standardised Kurtosis
return sca SK_ME_OB= (by411-(4*by311*by11)+6*by211*(by11^2)-3*(by11^4))/((by211 - (by11)^2)^2) 
return sca SK_ME_C= ((by401-(4*by301*by01)+6*by201*(by01^2)-3*(by01^4))/((by201 - (by01)^2)^2))
return sca SK_ME_TE= (by411-(4*by311*y11)+6*by211*(by11^2)-3*(by11^4))/((by211 - (by11)^2)^2) - ((by401-(4*by301*by01)+6*by201*(by01^2)-3*(by01^4))/((by201 - (by01)^2)^2))
di r(SK_ME_TE)


* Calculate IP weights
* Quadratic prediction
logit reform X1 X2 X1_2 X2_2 X1_X2
capture drop p_reform
predict p_reform, pr
cap drop w
gen w=.
replace w=1/1 if reform==1
replace w=p_reform/(1-p_reform) if reform==0
sum w
* Weighted
tabstat y [aw=w], stat(mean var skewness kurtosis) by(reform) save

sca bM_W_OB= r(Stat2)[1,1]
sca bM_W_C=r(Stat1)[1,1]
return sca M_W_TE=bM_W_OB-bM_W_C
return sca M_W_OB= r(Stat2)[1,1]
return sca M_W_C=r(Stat1)[1,1]
di r(M_W_TE)

 sca bV_W_OB= r(Stat2)[2,1]
 sca bV_W_C=r(Stat1)[2,1]
return sca V_W_TE=bV_W_OB-bV_W_C
return sca V_W_OB= r(Stat2)[2,1]
return sca V_W_C=r(Stat1)[2,1]
di r(V_W_TE)

sca bS_W_OB= r(Stat2)[3,1]
sca bS_W_C=r(Stat1)[3,1]
return sca SS_W_TE=bS_W_OB-bS_W_C
return sca SS_W_OB= bS_W_OB
return sca SS_W_C=bS_W_C
di r(SS_W_TE)

return sca S_W_TE=bS_W_OB*(bV_W_OB)^(3/2)-bS_W_C*(bV_W_C)^(3/2)
return sca S_W_OB= bS_W_OB*(bV_W_OB)^(3/2)
return sca S_W_C=bS_W_C*(bV_W_C)^(3/2)
di r(S_W_TE)

 sca bK_W_OB = r(Stat2)[4,1]
 sca bK_W_C = r(Stat1)[4,1]
return sca SK_W_TE=bK_W_OB-bK_W_C
return sca SK_W_OB =bK_W_OB
return sca SK_W_C = bK_W_C
di r(SK_W_TE)

return sca K_W_TE=bK_W_OB*(bV_W_OB)^(2)-bK_W_C*(bV_W_C)^(2)
return sca K_W_OB =bK_W_OB*(bV_W_OB)^(2)
return sca K_W_C = bK_W_C*(bV_W_C)^(2)
di r(SK_W_TE)

return scalar CV_W_TE=((sqrt(bV_W_OB))/bM_W_OB - (sqrt(bV_W_C))/bM_W_C)
di r(CV_W_TE)



******* Do it all again for ln(y)
cap drop y_temp
gen y_temp=y
replace y=ln(y)
replace y2=y^2
replace y3=y^3
replace y4=y^4



* PERM regression (quadratic)
reg y (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) vce(unconditional)
sca by11 =  _b[2._at#1.reform]
sca by01 =  _b[1._at#1.reform]
sca bV11 =  e(V)[4,4]
sca bV01 =  e(V)[2,2]

sca e11=ly11-_b[2._at#1.reform]
return sca e11_2_L=e11^2
return sca e11_3_L=e11^3
return sca e11_4_L=e11^4
sca e01=ly01-_b[1._at#1.reform]
return sca e01_2_L=e01^2
return sca e01_3_L=e01^3
return sca e01_4_L=e01^4

reg y2 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca by211 =  _b[2._at#1.reform]
sca by201 =  _b[1._at#1.reform]

sca e12=ly211-_b[2._at#1.reform]
return sca e12_2_L=e12^2
sca e02=ly201-_b[1._at#1.reform]
return sca e02_2_L=e02^2

reg y3 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca by311 =  _b[2._at#1.reform]
sca by301 =  _b[1._at#1.reform]

sca e13=ly311-_b[2._at#1.reform]
return sca e13_2_L=e13^2
sca e03=ly301-_b[1._at#1.reform]
return sca e03_2_L=e03^2

reg y4 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca by411 =  _b[2._at#1.reform]
sca by401 =  _b[1._at#1.reform]

return sca e11_12_L=e11*e12
return sca e01_02_L=e01*e02
return sca e11_2_12_L=e11^2*e12
return sca e01_2_02_L=e01^2*e02
return sca e11_13_L=e11*e13
return sca e01_03_L=e01*e03

* add these as not sure if sample means or bootstrap sample means should be used
return sca bmu11_e11_2_L=e11^2*(ly11+e11)
return sca bmu01_e01_2_L=e01^2*(ly01+e01)

return sca bmu12_e11_2_L=e11^2*(ly211+e12)
return sca bmu02_e01_2_L=e01^2*(ly201+e02)
return sca bmu11_e11_12_L=(ly11+e11)*e11*e12
return sca bmu01_e01_02_L=(ly01+e01)*e01*e02
return sca bmu11_e11_3_L=e11^3*(ly11+e11)
return sca bmu01_e01_3_L=e01^3*(ly01+e01)
return sca bmu11_2_e11_2_L=e11^2*(ly11+e11)^2
return sca bmu01_2_e01_2_L=e01^2*(ly01+e01)^2

* PTT of mean
return sca M_ME_TE_L= by11 - by01
return sca M_ME_OB_L= by11
return sca M_ME_C_L = by01
di r(M_ME_TE_L)

* PTT of Variance
return sca V_ME_OB_L=((by211 - (by11)^2))
return sca V_ME_C_L =((by201 - (by01)^2 ))
return sca V_ME_TE_L=((by211 - (by11)^2) - (by201 - (by01)^2 ))
di r(V_ME_TE_L)

* PTT of Variance SSB corrected*/
return sca V_MESSB_TE_L=(((by211 - (by11)^2) - (by201 - (by01)^2 )) + bV11 - bV01)
di r(V_MESSB_TE_L)

* PTT of CoefVariation */
return sca CV_ME_OB_L=((sqrt(by211 - (by11)^2))/by11 )
return sca CV_ME_C_L=( (sqrt(by201 - (by01)^2))/by01)
return sca CV_ME_TE_L=((sqrt(by211 - (by11)^2))/by11 - (sqrt(by201 - (by01)^2))/by01)
di r(CV_ME_TE_L)

* PTT of Skewness
return sca S_ME_OB_L= ((by311)-3*(by211)*(by11) +2*(by11)^3)
return sca S_ME_C_L=  ((by301)-3*(by201)*(by01) +2*(by01)^3)
return sca S_ME_TE_L= ((by311)-3*(by211)*(by11) +2*(by11)^3) - (((by301)-3*(by201)*(by01) +2*(by01)^3))
di r(S_ME_TE_L)

* PTT of standardised Skewness
return sca SS_ME_OB_L= ((by311)-3*(by211)*(by11) +2*(by11)^3)/(by211 - (by11)^2)^(3/2) 
return sca SS_ME_C_L= (((by301)-3*(by201)*(by01) +2*(by01)^3)/(by201 - (by01)^2)^(3/2))
return sca SS_ME_TE_L= ((by311)-3*(by211)*(by11) +2*(by11)^3)/(by211 - (by11)^2)^(3/2) - (((by301)-3*(by201)*(by01) +2*(by01)^3)/(by201 - (by01)^2)^(3/2))
di r(SS_ME_TE_L)

* PTT of Kurtosis
return sca K_ME_OB_L= (by411-(4*by311*by11)+6*by211*(by11^2)-3*(by11^4))
return sca K_ME_C_L= ((by401-(4*by301*by01)+6*by201*(by01^2)-3*(by01^4)))
return sca K_ME_TE_L= (by411-(4*by311*by11)+6*by211*(by11^2)-3*(by11^4)) - (by401-(4*by301*by01)+6*by201*(by01^2)-3*(by01^4))
di r(K_ME_TE_L)

* PTT of standardised Kurtosis
return sca SK_ME_OB_L= (by411-(4*by311*by11)+6*by211*(by11^2)-3*(by11^4))/((by211 - (by11)^2)^2) 
return sca SK_ME_C_L= ((by401-(4*by301*by01)+6*by201*(by01^2)-3*(by01^4))/((by201 - (by01)^2)^2))
return sca SK_ME_TE_L= (by411-(4*by311*by11)+6*by211*(by11^2)-3*(by11^4))/((by211 - (by11)^2)^2) - ((by401-(4*by301*by01)+6*by201*(by01^2)-3*(by01^4))/((by201 - (by01)^2)^2))
di r(SK_ME_TE_L)


* Weighted
tabstat y [aw=w], stat(mean var skewness kurtosis) by(reform) save

return sca M_W_OB_L= r(Stat2)[1,1]
return sca M_W_C_L=r(Stat1)[1,1]
return sca M_W_TE_L=r(Stat2)[1,1]-r(Stat1)[1,1]

di r(M_W_TE_L)

 sca bV_W_OB_L= r(Stat2)[2,1]
 sca bV_W_C_L=r(Stat1)[2,1]
return sca V_W_TE_L=bV_W_OB_L-bV_W_C_L
return sca V_W_OB_L= r(Stat2)[2,1]
return sca V_W_C_L=r(Stat1)[2,1]
di r(V_W_TE_L)

sca bS_W_OB_L= r(Stat2)[3,1]
sca bS_W_C_L=r(Stat1)[3,1]
return sca SS_W_TE_L=bS_W_OB_L-bS_W_C_L
return sca SS_W_OB_L= bS_W_OB_L
return sca SS_W_C_L=bS_W_C_L
di r(SS_W_TE_L)

return sca S_W_TE_L=bS_W_OB_L*(bV_W_OB_L)^(3/2)-bS_W_C_L*(bV_W_C_L)^(3/2)
return sca S_W_OB_L= bS_W_OB_L*(bV_W_OB_L)^(3/2)
return sca S_W_C_L =bS_W_C_L*(bV_W_C_L)^(3/2)
di r(S_W_TE_L)

 sca bK_W_OB_L = r(Stat2)[4,1]
 sca bK_W_C_L = r(Stat1)[4,1]
return sca SK_W_TE_L=bK_W_OB_L-bK_W_C_L
return sca SK_W_OB_L =bK_W_OB_L
return sca SK_W_C_L = bK_W_C_L
di r(SK_W_TE_L)

return sca K_W_TE_L=bK_W_OB_L*(bV_W_OB_L)^(2)-bK_W_C_L*(bV_W_C_L)^(2)
return sca K_W_OB_L =bK_W_OB_L*(bV_W_OB_L)^(2)
return sca K_W_C_L = bK_W_C_L*(bV_W_C_L)^(2)
di r(SK_W_TE)


return scalar CV_W_TE_L=((sqrt(bV_W_OB_L))/r(Stat2)[1,1] - (sqrt(bV_W_C_L))/r(Stat1)[1,1])
di r(CV_W_TE_L)

replace y=y_temp
replace y2=y^2
replace y3=y^3
replace y4=y^4

drop y_temp


end


*********** MONTE CARLO SIMULATION ****************

* SS = sample size 
* j = Number of matrices to run (save every 50 replications in separate matrix)
* k = Number of replications per matrix
* two matrices are produced, Var_cr is for levels, Var_cr_L is for log transformation of observations

* Begin MCS loops
forvalues SS=250(125)250 {
matrix Var_cr=J(50,200,.)
matrix Var_cr_L=J(50,200,.)
forvalues j=1(10)200 {
set seed 123`j' 
forvalues k=1(1)50 {
timer clear
timer on 1
display `k'
quietly { 


clear
set obs `SS'

********** SET UP VARIABLES *************
* This is described in Appendix 

gen ID=_n

gen X1 = runiform((1-sqrt(12)/2),(1+sqrt(12)/2))
gen X2 = runiform((5-sqrt(12)/2),(5+sqrt(12)/2))

gen X1_2=X1^2
gen X2_2=X2^2
gen X1_X2=X1*X2

gen reform=((-0.5 + 1.35*X1 - .2*X2 + 0.15*X1_2 - .1*X2_2 + 0.5*X1_X2 + rnormal(0,10))>0)

gen e_0=(0.01 - 0.01*X1 + 0.01*X2 + 0.01*X1_2 - 0.01*X2_2 - 0.02*X1_X2)*rnormal(0,1)
gen e_1=(0.01 + 0.01*X1 + 0.01*X2 + 0.01*X1_2 + 0.01*X2_2 + 0.01*X1_X2)*rnormal(0,1)

gen y_0=exp(0.01 - 0.01*X1 + 0.01*X2 + 0.01*X1_2 - 0.01*X2_2 - 0.02*X1_X2 + e_0)
gen y_1=exp(0.1 + 0.01*X1 + 0.01*X2 + 0.01*X1_2 + 0.01*X2_2 + 0.01*X1_X2 + e_1) 
sum y_0 y_1 if reform==1

gen y=y_1 if reform==1
replace y=y_0 if reform==0

gen y2 = y^2
gen y3 = y^3
gen y4 = y^4


****** raw moment regressions ***************************************

reg y (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca y11 =  _b[2._at#1.reform]
sca y01 =  _b[1._at#1.reform]

reg y2 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca y211 =  _b[2._at#1.reform]
sca y201 =  _b[1._at#1.reform]

reg y3 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca y311 =  _b[2._at#1.reform]
sca y301 =  _b[1._at#1.reform]

reg y4 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca y411 =  _b[2._at#1.reform]
sca y401 =  _b[1._at#1.reform]

* generate log outcomes
capture drop y_temp
gen y_temp=y
replace y=ln(y)
replace y2 = y^2
replace y3 = y^3
replace y4 = y^4

reg y (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca ly11 =  _b[2._at#1.reform]
sca ly01 =  _b[1._at#1.reform]

reg y2 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca ly211 =  _b[2._at#1.reform]
sca ly201 =  _b[1._at#1.reform]

reg y3 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca ly311 =  _b[2._at#1.reform]
sca ly301 =  _b[1._at#1.reform]

reg y4 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca ly411 =  _b[2._at#1.reform]
sca ly401 =  _b[1._at#1.reform]

* the bootstrap needs to use ly11 etc to calculate the stuff for log(y)

replace y=y_temp
replace y2 = y^2
replace y3 = y^3
replace y4 = y^4
drop y_temp

*********************************************************************
* Run PERM_quad to generate bootstrap standard errors

# delimit ;
 bs "PERM_quad" 			fM_ME_TE=r(M_ME_TE)
						fV_ME_OB=r(V_ME_OB) 	fV_ME_C=r(V_ME_C) 		fV_ME_TE=r(V_ME_TE) 
						fCV_ME_OB=r(CV_ME_OB) 	fCV_ME_C=r(CV_ME_C)  	fCV_ME_TE=r(CV_ME_TE)  
						fV_MESSB_TE=r(V_MESSB_TE)  
						fS_ME_OB=r(S_ME_OB) 	fS_ME_C=r(S_ME_C) 		fS_ME_TE=r(S_ME_TE) 
						fSS_ME_OB=r(SS_ME_OB) 	fSS_ME_C=r(SS_ME_C) 	fSS_ME_TE=r(SS_ME_TE) 
						fK_ME_OB=r(K_ME_OB)		fK_ME_C=r(K_ME_C)		fK_ME_TE=r(K_ME_TE)
						fSK_ME_OB=r(SK_ME_OB)	fSK_ME_C=r(SK_ME_C) 	fSK_ME_TE=r(SK_ME_TE) 
						fM_W_TE=r(M_W_TE) 
						fV_W_OB=r(V_W_OB) 		fV_W_C=r(V_W_C) 		fV_W_TE=r(V_W_TE) 
						fCV_W_TE=r(CV_W_TE) 
						fSS_W_OB=r(SS_W_OB)		fSS_W_C=r(SS_W_C)		fSS_W_TE=r(SS_W_TE) 
						fSK_W_OB=r(SK_W_OB) 	fSK_W_C=r(SK_W_C)		fSK_W_TE=r(SK_W_TE)
						
						fM_ME_TE_L=r(M_ME_TE_L) 
						fV_ME_OB_L=r(V_ME_OB_L) 	fV_ME_C_L=r(V_ME_C_L) 		fV_ME_TE_L=r(V_ME_TE_L) 
						fCV_ME_OB_L=r(CV_ME_OB_L) 	fCV_ME_C_L=r(CV_ME_C_L)  	fCV_ME_TE_L=r(CV_ME_TE_L)  
						fV_MESSB_TE_L=r(V_MESSB_TE_L)  
						fS_ME_OB_L=r(S_ME_OB_L) 	fS_ME_C_L=r(S_ME_C_L) 		fS_ME_TE_L=r(S_ME_TE_L) 
						fSS_ME_OB_L=r(SS_ME_OB_L) 	fSS_ME_C_L=r(SS_ME_C_L) 	fSS_ME_TE_L=r(SS_ME_TE_L) 
						fK_ME_OB_L=r(K_ME_OB_L)		fK_ME_C_L=r(K_ME_C_L)		fK_ME_TE_L=r(K_ME_TE_L)
						fSK_ME_OB_L=r(SK_ME_OB_L)	fSK_ME_C_L=r(SK_ME_C_L) 	fSK_ME_TE_L=r(SK_ME_TE_L) 
						fM_W_TE_L=r(M_W_TE_L) 
						fV_W_OB_L=r(V_W_OB_L) 		fV_W_C_L=r(V_W_C_L) 		fV_W_TE_L=r(V_W_TE_L) 
						fCV_W_TE_L=r(CV_W_TE_L) 
						fSS_W_OB_L=r(SS_W_OB_L)		fSS_W_C_L=r(SS_W_C_L)		fSS_W_TE_L=r(SS_W_TE_L) 
						fSK_W_OB_L=r(SK_W_OB_L) 	fSK_W_C_L=r(SK_W_C_L)		fSK_W_TE_L=r(SK_W_TE_L)
						fM_ME_OB=r(M_ME_OB) 		fM_ME_C=r(M_ME_C)
						fM_ME_OB_L=r(M_ME_OB_L) 	fM_ME_C_L=r(M_ME_C_L) 
						
						fe11_2=r(e11_2) 					fe11_3=r(e11_3)		fe11_4=r(e11_4)
						fe01_2=r(e01_2) 					fe01_3=r(e01_3)		fe01_4=r(e01_4)
						fe11_12=r(e11_12)				fe01_02=r(e01_02)
						fe11_2_12=r(e11_2_12) 			fe01_2_02=r(e01_2_02)
						fe11_13=r(e11_13)				fe01_03=r(e01_03)
						fbmu11_e11_2=r(bmu11_e11_2)		fbmu01_e01_2=r(bmu01_e01_2)
						fbmu12_e11_2=r(bmu12_e11_2)		fbmu02_e01_2=r(bmu02_e01_2)
						fbmu11_e11_12=r(bmu11_e11_12)	fbmu01_e01_02=r(bmu01_e01_02)
						fbmu11_e11_3=r(bmu11_e11_3)		fbmu01_e01_3=r(bmu01_e01_3)
						fbmu11_2_e11_2=r(bmu11_2_e11_2)	fbmu01_2_e01_2=r(bmu01_2_e01_2)

						fe11_2_L=r(e11_2_L) 					fe11_3_L=r(e11_3_L)		fe11_4_L=r(e11_4_L)
						fe01_2_L=r(e01_2_L) 					fe01_3_L=r(e01_3_L)		fe01_4_L=r(e01_4_L)
						fe11_12_L=r(e11_12_L)				fe01_02_L=r(e01_02_L)
						fe11_2_12_L=r(e11_2_12_L) 			fe01_2_02_L=r(e01_2_02_L)
						fe11_13_L=r(e11_13_L)				fe01_03_L=r(e01_03_L)
						fbmu11_e11_2_L=r(bmu11_e11_2_L)		fbmu01_e01_2_L=r(bmu01_e01_2_L)
						fbmu12_e11_2_L=r(bmu12_e11_2_L)		fbmu02_e01_2_L=r(bmu02_e01_2_L)
						fbmu11_e11_12_L=r(bmu11_e11_12_L)	fbmu01_e01_02_L=r(bmu01_e01_02_L)
						fbmu11_e11_3_L=r(bmu11_e11_3_L)		fbmu01_e01_3_L=r(bmu01_e01_3_L)
						fbmu11_2_e11_2_L=r(bmu11_2_e11_2_L)	fbmu01_2_e01_2_L=r(bmu01_2_e01_2_L)
						
						fS_W_OB=r(S_W_OB)			fS_W_C=r(S_W_C)		fS_W_TE=r(S_W_TE)
						fK_W_OB=r(K_W_OB)			fK_W_C=r(K_W_C)		fK_W_TE=r(K_W_TE)
						fS_W_OB_L=r(S_W_OB_L)			fS_W_C_L=r(S_W_C_L)		fS_W_TE_L=r(S_W_TE_L)
						fK_W_OB_L=r(K_W_OB_L)			fK_W_C_L=r(K_W_C_L)		fK_W_TE_L=r(K_W_TE_L)			

						, level(90) reps(200) dots   /* saving(bootstrap.dta, replace) */
						;
# delimit cr;

* Place estimates in memory as scalars
* Point estimates						
 sca M_BME_OB=e(b)[1,63]
 sca M_BME_C=e(b)[1,64]
 sca M_BME_TE=e(b)[1,1]
 
 sca V_BME_OB=e(b)[1,2]
 sca V_BME_C=e(b)[1,3]
 sca V_BME_TE=e(b)[1,4]
 
 sca CV_BME_OB=e(b)[1,5] 
 sca CV_BME_C=e(b)[1,6] 
 sca CV_BME_TE=e(b)[1,7]
 
 sca V_BMESSB_TE=e(b)[1,8]
 
 sca S_BME_OB=e(b)[1,9]
 sca S_BME_C=e(b)[1,10]
 sca S_BME_TE=e(b)[1,11]
 
 sca SS_BME_OB=e(b)[1,12]
 sca SS_BME_C=e(b)[1,13]
 sca SS_BME_TE=e(b)[1,14]
 
 sca K_BME_OB=e(b)[1,15]
 sca K_BME_C=e(b)[1,16]
 sca K_BME_TE=e(b)[1,17]

 sca SK_BME_OB=e(b)[1,18]
 sca SK_BME_C=e(b)[1,19]
 sca SK_BME_TE=e(b)[1,20]
 
 sca M_BW_TE=e(b)[1,21]
 
 sca V_BW_OB=e(b)[1,22]
 sca V_BW_C=e(b)[1,23]
 sca V_BW_TE=e(b)[1,24]
 
 sca CV_BW_TE=e(b)[1,25]
 
 sca SS_BW_OB=e(b)[1,26]
 sca SS_BW_C=e(b)[1,27]
 sca SS_BW_TE=e(b)[1,28]
 
 sca SK_BW_OB=e(b)[1,29]
 sca SK_BW_C=e(b)[1,30]
 sca SK_BW_TE=e(b)[1,31]

* Bootstrap s.es
 sca M_BME_TE_se=e(V)[1,1]^.5
 
 sca V_BME_OB_se=e(V)[2,2]^.5
 sca V_BME_C_se=e(V)[3,3]^.5
 sca V_BME_TE_se=e(V)[4,4]^.5
 
 sca CV_BME_OB_se=e(V)[5,5]^.5 
 sca CV_BME_C_se=e(V)[6,6]^.5 
 sca CV_BME_TE_se=e(V)[7,7]^.5
 
 sca V_BMESSB_TE_se=e(V)[8,8]^.5
 
 sca S_BME_OB_se=e(V)[9,9]^.5
 sca S_BME_C_se=e(V)[10,10]^.5
 sca S_BME_TE_se=e(V)[11,11]^.5
 
 sca SS_BME_OB_se=e(V)[12,12]^.5
 sca SS_BME_C_se=e(V)[13,13]^.5
 sca SS_BME_TE_se=e(V)[14,14]^.5
 
 sca K_BME_OB_se=e(V)[15,15]^.5
 sca K_BME_C_se=e(V)[16,16]^.5
 sca K_BME_TE_se=e(V)[17,17]^.5

 sca SK_BME_OB_se=e(V)[18,18]^.5
 sca SK_BME_C_se=e(V)[19,19]^.5
 sca SK_BME_TE_se=e(V)[20,20]^.5
 
 sca M_BW_TE_se=e(V)[21,21]^.5
 
 sca V_BW_OB_se=e(V)[22,22]^.5
 sca V_BW_C_se=e(V)[23,23]^.5
 sca V_BW_TE_se=e(V)[24,24]^.5
 
 sca CV_BW_TE_se=e(V)[25,25]^.5
 
 sca SS_BW_OB_se=e(V)[26,26]^.5
 sca SS_BW_C_se=e(V)[27,27]^.5
 sca SS_BW_TE_se=e(V)[28,28]^.5
 
 sca SK_BW_OB_se=e(V)[29,29]^.5
 sca SK_BW_C_se=e(V)[30,30]^.5
 sca SK_BW_TE_se=e(V)[31,31]^.5

 * percentile bootstrap 
 sca V_BME_TE_PCLL=e(ci_percentile)[1,4]
 sca V_BME_TE_PCUL=e(ci_percentile)[2,4]
 sca V_BME_TE_PCLLSSB=e(ci_percentile)[1,8]
 sca V_BME_TE_PCULSSB=e(ci_percentile)[2,8]
 sca CV_BME_TE_PCLL=e(ci_percentile)[1,7]
 sca CV_BME_TE_PCUL=e(ci_percentile)[2,7]
 sca S_BME_TE_PCLL=e(ci_percentile)[1,11]
 sca S_BME_TE_PCUL=e(ci_percentile)[2,11]
 sca SS_BME_TE_PCLL=e(ci_percentile)[1,14]
 sca SS_BME_TE_PCUL=e(ci_percentile)[2,14]
 sca K_BME_TE_PCLL=e(ci_percentile)[1,17]
 sca K_BME_TE_PCUL=e(ci_percentile)[2,17]
 sca SK_BME_TE_PCLL=e(ci_percentile)[1,20]
 sca SK_BME_TE_PCUL=e(ci_percentile)[2,20]
 
 sca V_BW_TE_PCLL=e(ci_percentile)[1,24]
 sca V_BW_TE_PCUL=e(ci_percentile)[2,24]
 sca CV_BW_TE_PCLL=e(ci_percentile)[1,25]
 sca CV_BW_TE_PCUL=e(ci_percentile)[2,25]

 sca SS_BW_TE_PCLL=e(ci_percentile)[1,28]
 sca SS_BW_TE_PCUL=e(ci_percentile)[2,28]
 sca SK_BW_TE_PCLL=e(ci_percentile)[1,31]
 sca SK_BW_TE_PCUL=e(ci_percentile)[2,31]
 
 
 **************** now for ln(y)
 
 
* Point estimates						
 sca M_BME_OB_L=e(b)[1,65]
 sca M_BME_C_L=e(b)[1,66]
 sca M_BME_TE_L=e(b)[1,32]
 
 sca V_BME_OB_L=e(b)[1,33]
 sca V_BME_C_L=e(b)[1,34]
 sca V_BME_TE_L=e(b)[1,35]
 
 sca CV_BME_OB_L=e(b)[1,36] 
 sca CV_BME_C_L=e(b)[1,37] 
 sca CV_BME_TE_L=e(b)[1,38]
 
 sca V_BMESSB_TE_L=e(b)[1,39]
 
 sca S_BME_OB_L=e(b)[1,40]
 sca S_BME_C_L=e(b)[1,41]
 sca S_BME_TE_L=e(b)[1,42]
 
 sca SS_BME_OB_L=e(b)[1,43]
 sca SS_BME_C_L=e(b)[1,44]
 sca SS_BME_TE_L=e(b)[1,45]
 
 sca K_BME_OB_L=e(b)[1,46]
 sca K_BME_C_L=e(b)[1,47]
 sca K_BME_TE_L=e(b)[1,48]

 sca SK_BME_OB_L=e(b)[1,49]
 sca SK_BME_C_L=e(b)[1,50]
 sca SK_BME_TE_L=e(b)[1,51]
 
 sca M_BW_TE_L=e(b)[1,52]
 
 sca V_BW_OB_L=e(b)[1,53]
 sca V_BW_C_L=e(b)[1,54]
 sca V_BW_TE_L=e(b)[1,55]
 
 sca CV_BW_TE_L=e(b)[1,56]
 
 sca SS_BW_OB_L=e(b)[1,57]
 sca SS_BW_C_L=e(b)[1,58]
 sca SS_BW_TE_L=e(b)[1,59]
 
 sca SK_BW_OB_L=e(b)[1,60]
 sca SK_BW_C_L=e(b)[1,61]
 sca SK_BW_TE_L=e(b)[1,62]

* Bootstrap s.es
 sca M_BME_TE_se_L=e(V)[32,32]^.5
 
 sca V_BME_OB_se_L=e(V)[33,33]^.5
 sca V_BME_C_se_L=e(V)[34,34]^.5
 sca V_BME_TE_se_L=e(V)[35,35]^.5
 
 sca CV_BME_OB_se_L=e(V)[36,36]^.5 
 sca CV_BME_C_se_L=e(V)[37,37]^.5 
 sca CV_BME_TE_se_L=e(V)[38,38]^.5
 
 sca V_BMESSB_TE_se_L=e(V)[39,39]^.5
 
 sca S_BME_OB_se_L=e(V)[40,40]^.5
 sca S_BME_C_se_L=e(V)[41,41]^.5
 sca S_BME_TE_se_L=e(V)[42,42]^.5
 
 sca SS_BME_OB_se_L=e(V)[43,43]^.5
 sca SS_BME_C_se_L=e(V)[44,44]^.5
 sca SS_BME_TE_se_L=e(V)[45,45]^.5
 
 sca K_BME_OB_se_L=e(V)[46,46]^.5
 sca K_BME_C_se_L=e(V)[47,47]^.5
 sca K_BME_TE_se_L=e(V)[48,48]^.5

 sca SK_BME_OB_se_L=e(V)[49,49]^.5
 sca SK_BME_C_se_L=e(V)[50,50]^.5
 sca SK_BME_TE_se_L=e(V)[51,51]^.5
 
 sca M_BW_TE_se_L=e(V)[52,52]^.5
 
 sca V_BW_OB_se_L=e(V)[53,53]^.5
 sca V_BW_C_se_L=e(V)[54,54]^.5
 sca V_BW_TE_se_L=e(V)[55,55]^.5
 
 sca CV_BW_TE_se_L=e(V)[56,56]^.5
 
 sca SS_BW_OB_se_L=e(V)[57,57]^.5
 sca SS_BW_C_se_L=e(V)[58,58]^.5
 sca SS_BW_TE_se_L=e(V)[59,59]^.5
 
 sca SK_BW_OB_se_L=e(V)[60,60]^.5
 sca SK_BW_C_se_L=e(V)[61,61]^.5
 sca SK_BW_TE_se_L=e(V)[62,62]^.5

 * percentile bootstrap 
 sca V_BME_TE_PCLL_L=e(ci_percentile)[1,35]
 sca V_BME_TE_PCUL_L=e(ci_percentile)[2,35]
 sca V_BME_TE_PCLLSSB_L=e(ci_percentile)[1,39]
 sca V_BME_TE_PCULSSB_L=e(ci_percentile)[2,39]
 sca CV_BME_TE_PCLL_L=e(ci_percentile)[1,38]
 sca CV_BME_TE_PCUL_L=e(ci_percentile)[2,38]
 sca S_BME_TE_PCLL_L=e(ci_percentile)[1,42]
 sca S_BME_TE_PCUL_L=e(ci_percentile)[2,42]
 sca SS_BME_TE_PCLL_L=e(ci_percentile)[1,45]
 sca SS_BME_TE_PCUL_L=e(ci_percentile)[2,45]
 sca K_BME_TE_PCLL_L=e(ci_percentile)[1,48]
 sca K_BME_TE_PCUL_L=e(ci_percentile)[2,48]
 sca SK_BME_TE_PCLL_L=e(ci_percentile)[1,51]
 sca SK_BME_TE_PCUL_L=e(ci_percentile)[2,51]
 
 sca V_BW_TE_PCLL_L=e(ci_percentile)[1,55]
 sca V_BW_TE_PCUL_L=e(ci_percentile)[2,55]
 sca CV_BW_TE_PCLL_L=e(ci_percentile)[1,56]
 sca CV_BW_TE_PCUL_L=e(ci_percentile)[2,56]

 sca SS_BW_TE_PCLL_L=e(ci_percentile)[1,59]
 sca SS_BW_TE_PCUL_L=e(ci_percentile)[2,59]
 sca SK_BW_TE_PCLL_L=e(ci_percentile)[1,62]
 sca SK_BW_TE_PCUL_L=e(ci_percentile)[2,62]
 
 ** functions of the mean sampling errors
 
 sca e11_2=e(bs_b)[1,67]
 sca e11_3=e(bs_b)[1,68]
 sca e11_4=e(bs_b)[1,69]
 sca e01_2=e(bs_b)[1,70]
 sca e01_3=e(bs_b)[1,71]
 sca e01_4=e(bs_b)[1,72] 
 sca e11_12=e(bs_b)[1,73]  
 sca e01_02=e(bs_b)[1,74] 
 sca e11_2_12=e(bs_b)[1,75] 
 sca e01_2_02=e(bs_b)[1,76]
 sca e11_13=e(bs_b)[1,77] 
 sca e01_03=e(bs_b)[1,78] 
 
 sca m11_e11_2=e(bs_b)[1,79] 
 sca m01_e01_2=e(bs_b)[1,80] 
 sca m12_e11_2=e(bs_b)[1,81] 
 sca m02_e01_2=e(bs_b)[1,82] 
 sca m11_e11_12=e(bs_b)[1,83] 
 sca m01_e01_02=e(bs_b)[1,84] 
 sca m11_e11_3=e(bs_b)[1,85] 
 sca m01_e01_3=e(bs_b)[1,86]  
 sca m11_2_e11_2=e(bs_b)[1,87] 
 sca m01_2_e01_2=e(bs_b)[1,88] 
 
 sca e11_2_L=e(bs_b)[1,89]
 sca e11_3_L=e(bs_b)[1,90]
 sca e11_4_L=e(bs_b)[1,91]
 sca e01_2_L=e(bs_b)[1,92]
 sca e01_3_L=e(bs_b)[1,93]
 sca e01_4_L=e(bs_b)[1,94] 
 sca e11_12_L=e(bs_b)[1,95]  
 sca e01_02_L=e(bs_b)[1,96] 
 sca e11_2_12_L=e(bs_b)[1,97] 
 sca e01_2_02_L=e(bs_b)[1,98]
 sca e11_13_L=e(bs_b)[1,99] 
 sca e01_03_L=e(bs_b)[1,100] 
 
 sca m11_e11_2_L=e(bs_b)[1,101] 
 sca m01_e01_2_L=e(bs_b)[1,102] 
 sca m12_e11_2_L=e(bs_b)[1,103] 
 sca m02_e01_2_L=e(bs_b)[1,104] 
 sca m11_e11_12_L=e(bs_b)[1,105] 
 sca m01_e01_02_L=e(bs_b)[1,106] 
 sca m11_e11_3_L=e(bs_b)[1,107] 
 sca m01_e01_3_L=e(bs_b)[1,108]  
 sca m11_2_e11_2_L=e(bs_b)[1,109] 
 sca m01_2_e01_2_L=e(bs_b)[1,110] 
 
 ** backed out unstandardised skewness and kurtosis
  sca S_BW_OB=e(b)[1,111]
 sca S_BW_C=e(b)[1,112]
 sca S_BW_TE=e(b)[1,113]
 
 sca K_BW_OB=e(b)[1,114]
 sca K_BW_C=e(b)[1,115]
 sca K_BW_TE=e(b)[1,116]
 
  sca S_BW_OB_se=e(V)[111,111]^.5
 sca S_BW_C_se=e(V)[112,112]^.5
 sca S_BW_TE_se=e(V)[113,113]^.5
 
 sca K_BW_OB_se=e(V)[114,114]^.5
 sca K_BW_C_se=e(V)[115,115]^.5
 sca K_BW_TE_se=e(V)[116,116]^.5
 
 sca S_BW_TE_PCLL=e(ci_percentile)[1,113]
 sca S_BW_TE_PCUL=e(ci_percentile)[2,113]
 sca K_BW_TE_PCLL=e(ci_percentile)[1,116]
 sca K_BW_TE_PCUL=e(ci_percentile)[2,116]
 
  sca S_BW_OB_L=e(b)[1,117]
 sca S_BW_C_L=e(b)[1,118]
 sca S_BW_TE_L=e(b)[1,119]
 
 sca K_BW_OB_L=e(b)[1,120]
 sca K_BW_C_L=e(b)[1,121]
 sca K_BW_TE_L=e(b)[1,122]
 
  sca S_BW_OB_se_L=e(V)[117,117]^.5
 sca S_BW_C_se_L=e(V)[118,118]^.5
 sca S_BW_TE_se_L=e(V)[119,119]^.5
 
 sca K_BW_OB_se_L=e(V)[120,120]^.5
 sca K_BW_C_se_L=e(V)[121,121]^.5
 sca K_BW_TE_se_L=e(V)[122,122]^.5
 
  sca S_BW_TE_PCLL_L=e(ci_percentile)[1,119]
 sca S_BW_TE_PCUL_L=e(ci_percentile)[2,119]
 sca K_BW_TE_PCLL_L=e(ci_percentile)[1,122]
 sca K_BW_TE_PCUL_L=e(ci_percentile)[2,122]
 
 scalar list 
 
 * End of bootstrap standard errors estimation

 *********************************************************************
* Provide Unfeasible estimates: provided using potential outcomes distribution
 *********************************************************************
gen a=y_1-y_0
sum a if reform==1
sca M_unf = r(mean)
di M_unf

tabstat y_1 y_0 if reform==1, stat(mean) save
sca M_U_OB= r(StatTotal)[1,1]
sca M_U_C= r(StatTotal)[1,2]
sca M_U_TE=M_U_OB-M_U_C
di M_U_TE

tabstat y_1 y_0 if reform==1, stat(var) save
sca V_U_OB= r(StatTotal)[1,1]
sca V_U_C= r(StatTotal)[1,2]
sca V_U_TE=V_U_OB-V_U_C
di V_U_TE

tabstat y_1 y_0 if reform==1, stat(skewness) save
sca SS_U_OB= r(StatTotal)[1,1]
sca SS_U_C= r(StatTotal)[1,2]
sca SS_U_TE=SS_U_OB-SS_U_C
di SS_U_TE

tabstat y_1 y_0 if reform==1, stat(kurtosis) save
sca SK_U_OB= r(StatTotal)[1,1]
sca SK_U_C= r(StatTotal)[1,2]
sca SK_U_TE=SK_U_OB-SK_U_C
di SK_U_TE

sca S_U_OB= SS_U_OB*V_U_OB^(3/2)
sca S_U_C= SS_U_C*V_U_C^(3/2)
sca S_U_TE=SS_U_OB*V_U_OB^(3/2)-SS_U_C*V_U_C^(3/2)
di S_U_TE

sca K_U_OB= SK_U_OB*V_U_OB^(2)
sca K_U_C= SK_U_C*V_U_C^(2)
sca K_U_TE=SK_U_OB*V_U_OB^(2)-SK_U_C*V_U_C^(2)
di K_U_TE

sca CV_U_TE=((sqrt(V_U_OB))/M_U_OB - (sqrt(V_U_C))/M_U_C)
di CV_U_TE

 *********************************************************************
* Provide Naive estimates: not accounting for treatment selection
 *********************************************************************
tabstat y , stat(mean var skewness kurtosis) by(reform) save

sca M_N_OB= r(Stat2)[1,1]
sca M_N_C=r(Stat1)[1,1]
sca M_N_TE=M_N_OB-M_N_C
di M_N_TE

sca V_N_OB= r(Stat2)[2,1]
sca V_N_C=r(Stat1)[2,1]
sca V_N_TE=V_N_OB-V_N_C
di V_N_TE

sca SS_N_OB= r(Stat2)[3,1]
sca SS_N_C=r(Stat1)[3,1]
sca SS_N_TE=SS_N_OB-SS_N_C
di SS_N_TE

sca SK_N_OB = r(Stat2)[4,1]
sca SK_N_C = r(Stat1)[4,1]
 sca SK_N_TE=SK_N_OB-SK_N_C
di SK_N_TE

sca S_N_OB= SS_N_OB*V_N_OB^(3/2)
sca S_N_C= SS_N_C*V_N_C^(3/2)
sca S_N_TE=SS_N_OB*V_N_OB^(3/2)-SS_N_C*V_N_C^(3/2)
di S_N_TE

sca K_N_OB= SK_N_OB*V_N_OB^(2)
sca K_N_C= SK_N_C*V_N_C^(2)
sca K_N_TE=SK_N_OB*V_N_OB^(2)-SK_N_C*V_N_C^(2)
di K_N_TE

sca CV_N_TE=((sqrt(V_N_OB))/M_N_OB - (sqrt(V_N_C))/M_N_C)
di CV_N_TE

 *********************************************************************
* Provide Inverse Probability Weighting (IPW) estimates: 
 *********************************************************************
* Calculate weights
* Quadratic prediction
logit reform X1 X2 X1_2 X2_2 X1_X2
capture drop p_reform
predict p_reform, pr
cap drop w
gen w=.
replace w=1/1 if reform==1
replace w=p_reform/(1-p_reform) if reform==0
sum w
* Weighted
tabstat y [aw=w], stat(mean var skewness kurtosis) by(reform) save

sca M_W_OB= r(Stat2)[1,1]
sca M_W_C=r(Stat1)[1,1]
sca M_W_TE=M_W_OB-M_W_C
di M_W_TE

sca V_W_OB= r(Stat2)[2,1]
sca V_W_C=r(Stat1)[2,1]
sca V_W_TE=V_W_OB-V_W_C
di V_W_TE

sca SS_W_OB= r(Stat2)[3,1]
sca SS_W_C=r(Stat1)[3,1]
sca SS_W_TE=SS_W_OB-SS_W_C
di SS_W_TE

sca SK_W_OB = r(Stat2)[4,1]
sca SK_W_C = r(Stat1)[4,1]
sca SK_W_TE=SK_W_OB-SK_W_C
di SK_W_TE

sca S_W_OB= SS_W_OB*V_W_OB^(3/2)
sca S_W_C= SS_W_C*V_W_C^(3/2)
sca S_W_TE=SS_W_OB*V_W_OB^(3/2)-SS_W_C*V_W_C^(3/2)
di S_W_TE

sca K_W_OB= SK_W_OB*V_W_OB^(2)
sca K_W_C= SK_W_C*V_W_C^(2)
sca K_W_TE=SK_W_OB*V_W_OB^(2)-SK_W_C*V_W_C^(2)
di K_W_TE

scalar CV_W_TE=((sqrt(V_W_OB))/M_W_OB - (sqrt(V_W_C))/M_W_C)
di CV_W_TE


 

*********************************************************************
* Provide PERM estimates (MOMENT ESTIMATION=ME) regression (quadratic)
*********************************************************************
 
gsem (y <- (c.X1 c.X2 c.X1_2 c.X2_2  c.X1_X2)##reform) (y2 <-  (c.X1 c.X2 c.X1_2 c.X2_2  c.X1_X2)##reform) , covstr(e.y e.y2, un)  vce(r) nocapslatent
margins, post at(reform=(0(1)1)) over(reform)  vce(unconditional)

* Observed mean
nlcom  _b[1._predict#2._at#1.reform]
 sca M_ME_OB=r(b)[1,1]
 sca M_ME_OB_se=r(V)[1,1]^.5
di M_ME_OB
di M_ME_OB_se

* Counterfactual mean
nlcom  _b[1._predict#1._at#1.reform]
 sca M_ME_C=r(b)[1,1]
 sca M_ME_C_se=r(V)[1,1]^.5
di M_ME_C
di M_ME_C_se

* InTT of mean
nlcom  _b[1._predict#2._at#1.reform]- _b[1._predict#1._at#1.reform]
 sca M_ME_TE=r(b)[1,1]
 sca M_ME_TE_se=r(V)[1,1]^.5
di M_ME_TE
di M_ME_TE_se

* Observed Variance
nlcom  ((_b[2._predict#2._at#1.reform] - (_b[1._predict#2._at#1.reform])^2) )
 sca V_ME_OB=r(b)[1,1]
 sca V_ME_OB_se=r(V)[1,1]^.5
di V_ME_OB
di V_ME_OB_se
* Counterfactual Variance
nlcom  ((_b[2._predict#1._at#1.reform] - (_b[1._predict#1._at#1.reform])^2 ))
 sca V_ME_C=r(b)[1,1]
 sca V_ME_C_se=r(V)[1,1]^.5
di V_ME_C
di V_ME_C_se
* InTT of Variance
nlcom  ((_b[2._predict#2._at#1.reform] - (_b[1._predict#2._at#1.reform])^2) - (_b[2._predict#1._at#1.reform] - (_b[1._predict#1._at#1.reform])^2 ))
 sca V_ME_TE=r(b)[1,1]
 sca V_ME_TE_se=r(V)[1,1]^.5
di V_ME_TE
di V_ME_TE_se

* InTT of Variance SSB corrected
cap sca vary_R_mean=e(V)[4,4]
cap sca vary_C_mean=e(V)[2,2]

nlcom  ((_b[2._predict#2._at#1.reform] - (_b[1._predict#2._at#1.reform])^2) - (_b[2._predict#1._at#1.reform] - (_b[1._predict#1._at#1.reform])^2 )) + e(V)[4,4] - e(V)[2,2]
 sca V_ME_TE_SSBC=r(b)[1,1]
 sca V_ME_TE_SSBC_se=r(V)[1,1]^.5
di V_ME_TE_SSBC
di V_ME_TE_SSBC_se

* Observed Coeficient of variation
nlcom  ((sqrt(_b[2._predict#2._at#1.reform] - (_b[1._predict#2._at#1.reform])^2))/_b[1._predict#2._at#1.reform] )
 sca CV_ME_OB=r(b)[1,1]
 sca CV_ME_OB_se=r(V)[1,1]^.5
di CV_ME_OB
di CV_ME_OB_se
* Counterfactual Coeficient of variation
nlcom  ((sqrt(_b[2._predict#1._at#1.reform] - (_b[1._predict#1._at#1.reform])^2 ))/_b[1._predict#1._at#1.reform])
 sca CV_ME_C=r(b)[1,1]
 sca CV_ME_C_se=r(V)[1,1]^.5
di CV_ME_C
di CV_ME_C_se
* InTT of Coeficient of variation
nlcom  ((sqrt(_b[2._predict#2._at#1.reform] - (_b[1._predict#2._at#1.reform])^2))/_b[1._predict#2._at#1.reform] - (sqrt(_b[2._predict#1._at#1.reform] - (_b[1._predict#1._at#1.reform])^2 ))/_b[1._predict#1._at#1.reform])
 sca CV_ME_TE=r(b)[1,1]
 sca CV_ME_TE_se=r(V)[1,1]^.5
di CV_ME_TE
di CV_ME_TE_se


* Observed Skewness
 sca S_ME_OB= ((y311)-3*(y211)*(y11) +2*(y11)^3) 
 sca S_ME_OB_SSBC= ((y311) -3*(y211)*(y11) +2*(y11)^3) -(-3*e11_12 +6*M_ME_OB*e11_2 + 2*e11_3)

 * Counterfactual Skewness
 sca S_ME_C= (((y301)-3*(y201)*(y01) +2*(y01)^3))
 sca S_ME_C_SSBC= (((y301)-3*(y201)*(y01) +2*(y01)^3) -(-3*e01_02 +6*M_ME_C*e01_2 + 2*e01_3))
di S_ME_C

* PTT of Skewness
*treatment effect on skewness
 sca S_ME_TE= ((y311)-3*(y211)*(y11) +2*(y11)^3) - (((y301)-3*(y201)*(y01) +2*(y01)^3))
 sca S_ME_TE_SSBC= ((y311)-3*(y211)*(y11) +2*(y11)^3 -(-3*e11_12 +6*M_ME_OB*e11_2 + 2*e11_3)) - ((y301)-3*(y201)*(y01) +2*(y01)^3-(-3*e01_02 +6*M_ME_C*e01_2 + 2*e01_3))
 di S_ME_TE
 
* Observed Standardised Skewness
 sca SS_ME_OB= 		((y311)-3*(y211)*(y11) +2*(y11)^3 )/(y211 - (y11)^2)^(3/2) 
di SS_ME_OB
 sca SS_ME_OB_SSBC= ((y311)-3*(y211)*(y11) +2*(y11)^3 -(-3*e11_12 +6*M_ME_OB*e11_2 + 2*e11_3))/(y211 - (y11)^2+ e11_2)^(3/2) 

* Counterfactual Standardised Skewness
 sca SS_ME_C= (((y301)-3*(y201)*(y01) +2*(y01)^3)/(y201 - (y01)^2)^(3/2))
 sca SS_ME_C_SSBC= (((y301)-3*(y201)*(y01) +2*(y01)^3 -(-3*e01_02 +6*M_ME_C*e01_2  + 2*e01_3))/(y201 - (y01)^2+ e01_2)^(3/2))
 di SS_ME_C
 
*treatment effect on Standardised skewness
 sca SS_ME_TE= ((y311)-3*(y211)*(y11) +2*(y11)^3)/(y211 - (y11)^2)^(3/2) - (((y301)-3*(y201)*(y01) +2*(y01)^3)/(y201 - (y01)^2)^(3/2))
 sca SS_ME_TE_SSBC= ((y311)-3*(y211)*(y11) +2*(y11)^3 -(-3*e11_12 +6*M_ME_OB*e11_2 + 2*e11_3))/(y211 - (y11)^2+ e11_2)^(3/2) - (((y301)-3*(y201)*(y01) +2*(y01)^3 -(-3*e01_02 +6*M_ME_C*e01_2  + 2*e01_3))/(y201 - (y01)^2+ e01_2)^(3/2))
di SS_ME_TE


* GH NOTE: following error - 18*y211*e11_2 should be - 18*y11^2*e11_2, similar for counterfactual
* Observed Kurtosis
 sca K_ME_OB= 		(y411-(4*y311*y11)+6*y211*(y11^2)-3*(y11^4) )
 sca K_ME_OB_SSBC= 	(y411-(4*y311*y11)+6*y211*(y11^2)-3*(y11^4) -(-4*e11_13 + 6*y211*e11_2 +6*e11_2_12 + 12*M_ME_OB*e11_12 -3*e11_4 -12*M_ME_OB*e11_3 - 18*M_ME_OB^2*e11_2))
 di K_ME_OB
 
* Counterfactual Kurtosis
 sca K_ME_C=		((y401-(4*y301*y01)+6*y201*(y01^2)-3*(y01^4)))
 sca K_ME_C_SSBC=	((y401-(4*y301*y01)+6*y201*(y01^2)-3*(y01^4) -(-4*e01_03 + 6*y201*e01_2 +6*e01_2_02 + 12*M_ME_C*e01_02 -3*e01_4 -12*M_ME_C*e01_3 - 18*M_ME_C^2*e01_2)))
 di K_ME_C
 
 * PTT of Kurtosis
 sca K_ME_TE= 		(y411-(4*y311*y11)+6*y211*(y11^2)-3*(y11^4)) - ((y401-(4*y301*y01)+6*y201*(y01^2)-3*(y01^4)))
 sca K_ME_TE_SSBC= K_ME_OB_SSBC - K_ME_C_SSBC
 di K_ME_TE
 
* Observed Standardised Kurtosis
sca SK_ME_OB= 		(y411-(4*y311*y11)+6*y211*(y11^2)-3*(y11^4))/((y211 - (y11)^2)^2)
sca SK_ME_OB_SSBC= 	(y411-(4*y311*y11)+6*y211*(y11^2)-3*(y11^4) -(-4*e11_13 + 6*y211*e11_2 +6*e11_2_12 + 12*M_ME_OB*e11_12 -3*e11_4 -12*M_ME_OB*e11_3 - 18*M_ME_OB^2*e11_2))/((y211 - (y11)^2+ e11_2)^2)
 di SK_ME_OB
 
* Counterfactual Standardised Kurtosis
sca SK_ME_C= 		(y401-(4*y301*y01)+6*y201*(y01^2)-3*(y01^4))/((y201 - (y01)^2)^2)
sca SK_ME_C_SSBC= 	(y401-(4*y301*y01)+6*y201*(y01^2)-3*(y01^4) -(-4*e01_03 + 6*y201*e01_2 +6*e01_2_02 + 12*M_ME_C*e01_02 -3*e01_4 -12*M_ME_C*e01_3 - 18*M_ME_C^2*e01_2))/((y201 - (y01)^2+ e01_2)^2)
 di SK_ME_C
 
* PTT of Standardised Kurtosis
 sca SK_ME_TE= (y411-(4*y311*y11)+6*y211*(y11^2)-3*(y11^4))/((y211 - (y11)^2)^2) - ((y401-(4*y301*y01)+6*y201*(y01^2)-3*(y01^4))/((y201 - (y01)^2)^2))
 sca SK_ME_TE_SSBC= SK_ME_OB_SSBC - SK_ME_C_SSBC
 di SK_ME_TE

 scalar list


* FEED THE MATRIX

cap matrix Var_cr[`k',1]=M_unf 				/* Mean unfeasible*/
cap matrix Var_cr[`k',2]=V_U_TE 			/* Variance unfeasible*/
cap matrix Var_cr[`k',3]=CV_U_TE 			/* COEFV unfeasible*/
cap matrix Var_cr[`k',4]=SS_U_TE 			/* Std skewness unfeasible*/
cap matrix Var_cr[`k',5]=SK_U_TE 			/* Std kurtosis unfeasible*/

cap matrix Var_cr[`k',6]=M_N_TE 			/* Mean Naive*/
cap matrix Var_cr[`k',7]=V_N_TE 			/* Variance Naive*/
cap matrix Var_cr[`k',8]=CV_N_TE 			/* CoefV Naive*/
cap matrix Var_cr[`k',9]=SS_N_TE 			/* Std skewness Naive*/
cap matrix Var_cr[`k',10]=SK_N_TE 			/* Std kurtosis Naive*/

* PERM PTT point estimates and standard errors

cap matrix Var_cr[`k',11]=M_ME_TE			/* Mean ME quadratic */
cap matrix Var_cr[`k',12]=V_ME_TE			/* Variance ME quadratic */
cap matrix Var_cr[`k',13]=V_ME_TE_SSBC		/* Variance ME quadratic SSB corrected*/
cap matrix Var_cr[`k',14]=CV_ME_TE			/* CoefV ME quadratic */
cap matrix Var_cr[`k',15]=S_ME_TE			/* skewness ME quadratic */
cap matrix Var_cr[`k',16]=SS_ME_TE			/* Std. skewness ME quadratic */
cap matrix Var_cr[`k',17]=K_ME_TE			/* kurtosis ME quadratic */
cap matrix Var_cr[`k',18]=SK_ME_TE			/* Std. kurtosis ME quadratic */

cap matrix Var_cr[`k',19]=M_ME_TE_se			/* Mean ME quadratic linearisation s.e */
cap matrix Var_cr[`k',20]=V_ME_TE_se		/* Variance ME quadratic linearisation s.e  */
cap matrix Var_cr[`k',21]=V_ME_TE_SSBC_se	/* Variance ME quadratic SSB corrected linearisation se*/
cap matrix Var_cr[`k',22]=CV_ME_TE_se		/* CoefV ME quadratic linearisation s.e */

* bias corrected sample estimators 
cap matrix Var_cr[`k',23]=S_ME_TE_SSBC			/* skewness bias corrected */
cap matrix Var_cr[`k',24]=SS_ME_TE_SSBC			/* Std. skewness (skewness and variance bias corrected), but still biased */
cap matrix Var_cr[`k',25]=K_ME_TE_SSBC			/* kurtosis bias corrected */
cap matrix Var_cr[`k',26]=SK_ME_TE_SSBC			/* Std. kurtosis (skewness and variance bias corrected), but still biased  */


cap matrix Var_cr[`k',27]=M_BME_TE_se		/* Mean ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',28]=V_BME_TE_se		/* Variance ME quadratic Bootstrap s.e  */
cap matrix Var_cr[`k',29]=V_BMESSB_TE_se	/* Variance ME quadratic SSB corrected Bootstrap se*/
cap matrix Var_cr[`k',30]=CV_BME_TE_se		/* CoefV ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',31]=S_BME_TE_se		/* skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',32]=SS_BME_TE_se		/* Std. skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',33]=K_BME_TE_se		/* kurtosis ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',34]=SK_BME_TE_se		/* Std. kurtosis ME quadratic Bootstrap s.e */

* PERM observed point estimates and standard errors

cap matrix Var_cr[`k',35]=M_ME_OB			/* Mean ME quadratic */
cap matrix Var_cr[`k',36]=V_ME_OB			/* Variance ME quadratic */
cap matrix Var_cr[`k',37]=CV_ME_OB			/* CoefV ME quadratic */
cap matrix Var_cr[`k',38]=S_ME_OB			/* skewness ME quadratic */
cap matrix Var_cr[`k',39]=SS_ME_OB			/* Std. skewness ME quadratic */
cap matrix Var_cr[`k',40]=K_ME_OB			/* kurtosis ME quadratic */
cap matrix Var_cr[`k',41]=SK_ME_OB			/* Std. kurtosis ME quadratic */

cap matrix Var_cr[`k',42]=M_ME_OB_se			/* Mean ME quadratic linearisation s.e */
cap matrix Var_cr[`k',43]=V_ME_OB_se		/* Variance ME quadratic linearisation s.e  */
cap matrix Var_cr[`k',44]=CV_ME_OB_se		/* CoefV ME quadratic linearisation s.e */

* bias corrected sample estimators 
cap matrix Var_cr[`k',45]=S_ME_OB_SSBC			/* skewness bias corrected */
cap matrix Var_cr[`k',46]=SS_ME_OB_SSBC			/* Std. skewness (skewness and variance bias corrected), but still biased */
cap matrix Var_cr[`k',47]=K_ME_OB_SSBC			/* kurtosis bias corrected */
cap matrix Var_cr[`k',48]=SK_ME_OB_SSBC			/* Std. kurtosis (skewness and variance bias corrected), but still biased  */

cap matrix Var_cr[`k',49]=M_BME_OB_se		/* Mean ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',50]=V_BME_OB_se		/* Variance ME quadratic Bootstrap s.e  */
cap matrix Var_cr[`k',51]=CV_BME_OB_se		/* CoefV ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',52]=S_BME_OB_se		/* skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',53]=SS_BME_OB_se		/* Std. skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',54]=K_BME_OB_se		/* kurtosis ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',55]=SK_BME_OB_se		/* Std. kurtosis ME quadratic Bootstrap s.e */

* PERM counterfactual point estimates and standard errors

cap matrix Var_cr[`k',56]=M_ME_C				/* Mean ME quadratic */
cap matrix Var_cr[`k',57]=V_ME_C			/* Variance ME quadratic */
cap matrix Var_cr[`k',58]=CV_ME_C			/* CoefV ME quadratic */
cap matrix Var_cr[`k',59]=S_ME_C			/* skewness ME quadratic */
cap matrix Var_cr[`k',60]=SS_ME_C			/* Std. skewness ME quadratic */
cap matrix Var_cr[`k',61]=K_ME_C			/* kurtosis ME quadratic */
cap matrix Var_cr[`k',62]=SK_ME_C			/* Std. kurtosis ME quadratic */

cap matrix Var_cr[`k',63]=M_ME_C_se			/* Mean ME quadratic linearisation s.e */
cap matrix Var_cr[`k',64]=V_ME_C_se			/* Variance ME quadratic linearisation s.e  */
cap matrix Var_cr[`k',65]=CV_ME_C_se		/* CoefV ME quadratic linearisation s.e */

* bias corrected sample estimators 
cap matrix Var_cr[`k',66]=S_ME_C_SSBC			/* skewness bias corrected */
cap matrix Var_cr[`k',67]=SS_ME_C_SSBC			/* Std. skewness (skewness and variance bias corrected), but still biased */
cap matrix Var_cr[`k',68]=K_ME_C_SSBC			/* kurtosis bias corrected */
cap matrix Var_cr[`k',69]=SK_ME_C_SSBC			/* Std. kurtosis (skewness and variance bias corrected), but still biased  */

cap matrix Var_cr[`k',70]=M_BME_C_se			/* Mean ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',71]=V_BME_C_se		/* Variance ME quadratic Bootstrap s.e  */
cap matrix Var_cr[`k',72]=CV_BME_C_se		/* CoefV ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',73]=S_BME_C_se		/* skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',74]=SS_BME_C_se		/* Std. skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',75]=K_BME_C_se		/* kurtosis ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',76]=SK_BME_C_se		/* Std. kurtosis ME quadratic Bootstrap s.e */

* IPW PTT point estimates and standard errors

cap matrix Var_cr[`k',77]=M_W_TE				/* Mean ME quadratic */
cap matrix Var_cr[`k',78]=V_W_TE			/* Variance ME quadratic */
cap matrix Var_cr[`k',79]=CV_W_TE			/* CoefV ME quadratic */
cap matrix Var_cr[`k',80]=SS_W_TE			/* Std. skewness ME quadratic */
cap matrix Var_cr[`k',81]=SK_W_TE			/* Std. kurtosis ME quadratic */

cap matrix Var_cr[`k',82]=M_BW_TE_se			/* Mean ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',83]=V_BW_TE_se		/* Variance ME quadratic Bootstrap s.e  */
cap matrix Var_cr[`k',84]=CV_BW_TE_se		/* CoefV ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',85]=SS_BW_TE_se		/* Std. skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',86]=SK_BW_TE_se		/* Std. kurtosis ME quadratic Bootstrap s.e */

* IPW observed point estimates and standard errors

cap matrix Var_cr[`k',87]=M_W_OB				/* Mean ME quadratic */
cap matrix Var_cr[`k',88]=V_W_OB			/* Variance ME quadratic */
cap matrix Var_cr[`k',90]=SS_W_OB			/* Std. skewness ME quadratic */
cap matrix Var_cr[`k',91]=SK_W_OB			/* Std. kurtosis ME quadratic */

cap matrix Var_cr[`k',93]=V_BW_OB_se		/* Variance ME quadratic Bootstrap s.e  */
cap matrix Var_cr[`k',95]=SS_BW_OB_se		/* Std. skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',96]=SK_BW_OB_se		/* Std. kurtosis ME quadratic Bootstrap s.e */

* IPW counterfactual point estimates and standard errors

cap matrix Var_cr[`k',97]=M_W_C				/* Mean ME quadratic */
cap matrix Var_cr[`k',98]=V_W_C				/* Variance ME quadratic */
cap matrix Var_cr[`k',100]=SS_W_C			/* Std. skewness ME quadratic */
cap matrix Var_cr[`k',101]=SK_W_C			/* Std. kurtosis ME quadratic */

cap matrix Var_cr[`k',103]=V_BW_C_se			/* Variance ME quadratic Bootstrap s.e  */
cap matrix Var_cr[`k',105]=SS_BW_C_se		/* Std. skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr[`k',106]=SK_BW_C_se		/* Std. kurtosis ME quadratic Bootstrap s.e */

* Percentile bootstrap LL and UL

cap matrix Var_cr[`k',107]=V_BME_TE_PCLL		/* BS Variance ME quadratic PC LL*/
cap matrix Var_cr[`k',108]=V_BME_TE_PCUL	    /* BS Variance ME quadratic PC UL*/
cap matrix Var_cr[`k',109]=V_BME_TE_PCLLSSB	/* BS Variance SSB ME quadratic PC LL*/
cap matrix Var_cr[`k',110]=V_BME_TE_PCULSSB	/* BS Variance SSB ME quadratic PC UL*/
cap matrix Var_cr[`k',111]=CV_BME_TE_PCLL	/* BS CoefV ME quadratic PC LL*/
cap matrix Var_cr[`k',112]=CV_BME_TE_PCUL	/* BS CoefV ME quadratic PC UL*/
cap matrix Var_cr[`k',113] = S_BME_TE_PCLL	/* skewness ME quadratic PC LL*/
cap matrix Var_cr[`k',114] = S_BME_TE_PCUL  	/* skewness ME quadratic PC UL*/
cap matrix Var_cr[`k',115] = SS_BME_TE_PCLL	/* Std. skewness ME quadratic PC LL*/
cap matrix Var_cr[`k',116] = SS_BME_TE_PCUL  /* Std. skewness ME quadratic PC UL*/
cap matrix Var_cr[`k',117] = K_BME_TE_PCLL	/* kurtosis ME quadratic PC LL*/
cap matrix Var_cr[`k',118] = K_BME_TE_PCUL  	/* kurtosis ME quadratic PC UL*/
cap matrix Var_cr[`k',119] = SK_BME_TE_PCLL	/* Std. kurtosis ME quadratic PC LL*/
cap matrix Var_cr[`k',120] = SK_BME_TE_PCUL  /* Std. kurtosis ME quadratic PC UL*/

cap matrix Var_cr[`k',121]=V_BW_TE_PCLL		/* BS Variance ME quadratic PC LL*/
cap matrix Var_cr[`k',122]=V_BW_TE_PCUL	    /* BS Variance ME quadratic PC UL*/
cap matrix Var_cr[`k',123]=CV_BW_TE_PCLL		/* BS CoefV ME quadratic PC LL*/
cap matrix Var_cr[`k',124]=CV_BW_TE_PCUL	    /* BS CoefV ME quadratic PC UL*/
cap matrix Var_cr[`k',125] = SS_BW_TE_PCLL	/* Std. skewness IPW quadratic PC LL*/
cap matrix Var_cr[`k',126] = SS_BW_TE_PCUL  	/* Std. skewness IPW quadratic PC UL*/
cap matrix Var_cr[`k',127] = SK_BW_TE_PCLL	/* Std. kurtosis IPW quadratic PC LL*/
cap matrix Var_cr[`k',128] = SK_BW_TE_PCUL  	/* Std. kurtosis IPW quadratic PC UL*/

* bias terms
cap matrix Var_cr[`k',131]=e11_2
cap matrix Var_cr[`k',132]=e11_3
cap matrix Var_cr[`k',133]=e11_4
cap matrix Var_cr[`k',134]=e01_2
cap matrix Var_cr[`k',135]=e01_3
cap matrix Var_cr[`k',136]=e01_4
cap matrix Var_cr[`k',137]=e11_12
cap matrix Var_cr[`k',138]=e01_02
cap matrix Var_cr[`k',139]=e11_2_12
cap matrix Var_cr[`k',140]=e01_2_02
cap matrix Var_cr[`k',141]=e11_13
cap matrix Var_cr[`k',142]=e01_03
 
cap matrix Var_cr[`k',143]=m11_e11_2
cap matrix Var_cr[`k',144]=m01_e01_2
cap matrix Var_cr[`k',145]=m12_e11_2
cap matrix Var_cr[`k',146]=m02_e01_2
cap matrix Var_cr[`k',147]=m11_e11_12
cap matrix Var_cr[`k',148]=m01_e01_02
cap matrix Var_cr[`k',149]=m11_e11_3
cap matrix Var_cr[`k',150]=m01_e01_3
cap matrix Var_cr[`k',151]=m11_2_e11_2
cap matrix Var_cr[`k',152]=m01_2_e01_2

* unstandardised skewness and kurtosis

cap matrix Var_cr[`k',160]=S_U_TE			/* skewness Unfeasible */
cap matrix Var_cr[`k',161]=K_U_TE			/* kurtosis Unfeasible */
cap matrix Var_cr[`k',162]=S_N_TE			/* skewness Naive */
cap matrix Var_cr[`k',163]=K_N_TE			/* kurtosis Naive */
cap matrix Var_cr[`k',164]=S_W_TE			/* skewness IPW */
cap matrix Var_cr[`k',165]=K_W_TE			/* kurtosis IPW */

cap matrix Var_cr[`k',166]=S_BW_TE_se				/* skewness IPW BS s.e. */
cap matrix Var_cr[`k',167]=K_BW_TE_se				/* kurtosis IPW BS s.e. */


cap matrix Var_cr[`k',168]=S_U_OB			/* skewness Unfeasible */
cap matrix Var_cr[`k',169]=K_U_OB			/* kurtosis Unfeasible */
cap matrix Var_cr[`k',170]=S_N_OB			/* skewness Naive */
cap matrix Var_cr[`k',171]=K_N_OB			/* kurtosis Naive */
cap matrix Var_cr[`k',172]=S_W_OB			/* skewness IPW */
cap matrix Var_cr[`k',173]=K_W_OB			/* kurtosis IPW  */

cap matrix Var_cr[`k',174]=S_BW_OB_se				/* Std. skewness ME quadratic */
cap matrix Var_cr[`k',175]=K_BW_OB_se				/* Std. kurtosis ME quadratic */


cap matrix Var_cr[`k',176]=S_U_C			/* skewness Unfeasible */
cap matrix Var_cr[`k',177]=K_U_C			/* kurtosis Unfeasible */
cap matrix Var_cr[`k',178]=S_N_C			/* skewness Naive */
cap matrix Var_cr[`k',179]=K_N_C			/* kurtosis Naive */
cap matrix Var_cr[`k',180]=S_W_C			/* skewness IPW */
cap matrix Var_cr[`k',181]=K_W_C			/* kurtosis IPW  */

cap matrix Var_cr[`k',182]=S_BW_C_se				/* skewness IPW BS s.e. */
cap matrix Var_cr[`k',183]=K_BW_C_se				/* kurtosis IPW BS s.e. */

cap matrix Var_cr[`k',184] = S_BW_TE_PCLL	/* skewness IPW quadratic PC LL*/
cap matrix Var_cr[`k',185] = S_BW_TE_PCUL  	/* skewness IPW quadratic PC UL*/
cap matrix Var_cr[`k',186] = K_BW_TE_PCLL	/* kurtosis IPW quadratic PC LL*/
cap matrix Var_cr[`k',187] = K_BW_TE_PCUL  	/* kurtosis IPW quadratic PC UL*/


*********************************************************************
********************************************************************* 
****** Now do it all again, but for ln(y) (bootstrap s.e.s already estimated)
*********************************************************************
*********************************************************************


replace y_1=ln(y_1)
replace y_0=ln(y_0)
replace y=y_1 if reform==1
replace y=y_0 if reform==0
replace y2 = y^2
replace y3 = y^3
replace y4 = y^4

 *********************************************************************
* Provide Unfeasible estimates: provided using potential outcomes distribution
 *********************************************************************
cap drop a
gen a=y_1-y_0
sum a if reform==1
sca M_unf = r(mean)
di M_unf

tabstat y_1 y_0 if reform==1, stat(mean) save
sca M_U_OB= r(StatTotal)[1,1]
sca M_U_C= r(StatTotal)[1,2]
sca M_U_TE=M_U_OB-M_U_C
di M_U_TE

tabstat y_1 y_0 if reform==1, stat(var) save
sca V_U_OB= r(StatTotal)[1,1]
sca V_U_C= r(StatTotal)[1,2]
sca V_U_TE=V_U_OB-V_U_C
di V_U_TE

tabstat y_1 y_0 if reform==1, stat(skewness) save
sca SS_U_OB= r(StatTotal)[1,1]
sca SS_U_C= r(StatTotal)[1,2]
sca SS_U_TE=SS_U_OB-SS_U_C
di SS_U_TE

tabstat y_1 y_0 if reform==1, stat(kurtosis) save
sca SK_U_OB= r(StatTotal)[1,1]
sca SK_U_C= r(StatTotal)[1,2]
sca SK_U_TE=SK_U_OB-SK_U_C
di SK_U_TE

sca S_U_OB= SS_U_OB*V_U_OB^(3/2)
sca S_U_C= SS_U_C*V_U_C^(3/2)
sca S_U_TE=SS_U_OB*V_U_OB^(3/2)-SS_U_C*V_U_C^(3/2)
di S_U_TE

sca K_U_OB= SK_U_OB*V_U_OB^(2)
sca K_U_C= SK_U_C*V_U_C^(2)
sca K_U_TE=SK_U_OB*V_U_OB^(2)-SK_U_C*V_U_C^(2)
di K_U_TE

sca CV_U_TE=((sqrt(V_U_OB))/M_U_OB - (sqrt(V_U_C))/M_U_C)
di CV_U_TE

 *********************************************************************
* Provide Naive estimates: not accounting for selection
 *********************************************************************
tabstat y , stat(mean var skewness kurtosis) by(reform) save

sca M_N_OB= r(Stat2)[1,1]
sca M_N_C=r(Stat1)[1,1]
sca M_N_TE=M_N_OB-M_N_C
di M_N_TE

sca V_N_OB= r(Stat2)[2,1]
sca V_N_C=r(Stat1)[2,1]
sca V_N_TE=V_N_OB-V_N_C
di V_N_TE

sca SS_N_OB= r(Stat2)[3,1]
sca SS_N_C=r(Stat1)[3,1]
sca SS_N_TE=SS_N_OB-SS_N_C
di SS_N_TE

sca SK_N_OB = r(Stat2)[4,1]
sca SK_N_C = r(Stat1)[4,1]
 sca SK_N_TE=SK_N_OB-SK_N_C
di SK_N_TE

sca S_N_OB= SS_N_OB*V_N_OB^(3/2)
sca S_N_C= SS_N_C*V_N_C^(3/2)
sca S_N_TE=SS_N_OB*V_N_OB^(3/2)-SS_N_C*V_N_C^(3/2)
di S_N_TE

sca K_N_OB= SK_N_OB*V_N_OB^(2)
sca K_N_C= SK_N_C*V_N_C^(2)
sca K_N_TE=SK_N_OB*V_N_OB^(2)-SK_N_C*V_N_C^(2)
di K_N_TE

sca CV_N_TE=((sqrt(V_N_OB))/M_N_OB - (sqrt(V_N_C))/M_N_C)
di CV_N_TE

 *********************************************************************
* Provide Inverse Probability Weighting (IPW) estimates: 
 *********************************************************************
 
tabstat y [aw=w], stat(mean var skewness kurtosis) by(reform) save

sca M_W_OB= r(Stat2)[1,1]
sca M_W_C=r(Stat1)[1,1]
sca M_W_TE=M_W_OB-M_W_C
di M_W_TE

sca V_W_OB= r(Stat2)[2,1]
sca V_W_C=r(Stat1)[2,1]
sca V_W_TE=V_W_OB-V_W_C
di V_W_TE

sca SS_W_OB= r(Stat2)[3,1]
sca SS_W_C=r(Stat1)[3,1]
sca SS_W_TE=SS_W_OB-SS_W_C
di SS_W_TE

sca SK_W_OB = r(Stat2)[4,1]
sca SK_W_C = r(Stat1)[4,1]
sca SK_W_TE=SK_W_OB-SK_W_C
di SK_W_TE

sca S_W_OB= SS_W_OB*V_W_OB^(3/2)
sca S_W_C= SS_W_C*V_W_C^(3/2)
sca S_W_TE=SS_W_OB*V_W_OB^(3/2)-SS_W_C*V_W_C^(3/2)
di S_W_TE

sca K_W_OB= SK_W_OB*V_W_OB^(2)
sca K_W_C= SK_W_C*V_W_C^(2)
sca K_W_TE=SK_W_OB*V_W_OB^(2)-SK_W_C*V_W_C^(2)
di K_W_TE

scalar CV_W_TE=((sqrt(V_W_OB))/M_W_OB - (sqrt(V_W_C))/M_W_C)
di CV_W_TE


 

*********************************************************************
* Provide PERM estimates (MOMENT ESTIMATION=ME) regression (quadratic)
*********************************************************************
 
gsem (y <- (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform) (y2 <-  (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform) , covstr(e.y e.y2, un)  vce(r) nocapslatent
margins, post at(reform=(0(1)1)) over(reform)  vce(unconditional)

* Observed mean
nlcom  _b[1._predict#2._at#1.reform]
 sca M_ME_OB=r(b)[1,1]
 sca M_ME_OB_se=r(V)[1,1]^.5
di M_ME_OB
di M_ME_OB_se

* Counterfactual mean
nlcom  _b[1._predict#1._at#1.reform]
 sca M_ME_C=r(b)[1,1]
 sca M_ME_C_se=r(V)[1,1]^.5
di M_ME_C
di M_ME_C_se

* InTT of mean
nlcom  _b[1._predict#2._at#1.reform]- _b[1._predict#1._at#1.reform]
 sca M_ME_TE=r(b)[1,1]
 sca M_ME_TE_se=r(V)[1,1]^.5
di M_ME_TE
di M_ME_TE_se

* Observed Variance
nlcom  ((_b[2._predict#2._at#1.reform] - (_b[1._predict#2._at#1.reform])^2) )
 sca V_ME_OB=r(b)[1,1]
 sca V_ME_OB_se=r(V)[1,1]^.5
di V_ME_OB
di V_ME_OB_se
* Counterfactual Variance
nlcom  ((_b[2._predict#1._at#1.reform] - (_b[1._predict#1._at#1.reform])^2 ))
 sca V_ME_C=r(b)[1,1]
 sca V_ME_C_se=r(V)[1,1]^.5
di V_ME_C
di V_ME_C_se
* InTT of Variance
nlcom  ((_b[2._predict#2._at#1.reform] - (_b[1._predict#2._at#1.reform])^2) - (_b[2._predict#1._at#1.reform] - (_b[1._predict#1._at#1.reform])^2 ))
 sca V_ME_TE=r(b)[1,1]
 sca V_ME_TE_se=r(V)[1,1]^.5
di V_ME_TE
di V_ME_TE_se

* InTT of Variance SSB corrected
cap sca vary_R_mean=e(V)[4,4]
cap sca vary_C_mean=e(V)[2,2]

nlcom  ((_b[2._predict#2._at#1.reform] - (_b[1._predict#2._at#1.reform])^2) - (_b[2._predict#1._at#1.reform] - (_b[1._predict#1._at#1.reform])^2 )) + e(V)[4,4] - e(V)[2,2]
 sca V_ME_TE_SSBC=r(b)[1,1]
 sca V_ME_TE_SSBC_se=r(V)[1,1]^.5
di V_ME_TE_SSBC
di V_ME_TE_SSBC_se

* Observed Coeficient of variation
nlcom  ((sqrt(_b[2._predict#2._at#1.reform] - (_b[1._predict#2._at#1.reform])^2))/_b[1._predict#2._at#1.reform] )
 sca CV_ME_OB=r(b)[1,1]
 sca CV_ME_OB_se=r(V)[1,1]^.5
di CV_ME_OB
di CV_ME_OB_se
* Counterfactual Coeficient of variation
nlcom  ((sqrt(_b[2._predict#1._at#1.reform] - (_b[1._predict#1._at#1.reform])^2 ))/_b[1._predict#1._at#1.reform])
 sca CV_ME_C=r(b)[1,1]
 sca CV_ME_C_se=r(V)[1,1]^.5
di CV_ME_C
di CV_ME_C_se
* InTT of Coeficient of variation
nlcom  ((sqrt(_b[2._predict#2._at#1.reform] - (_b[1._predict#2._at#1.reform])^2))/_b[1._predict#2._at#1.reform] - (sqrt(_b[2._predict#1._at#1.reform] - (_b[1._predict#1._at#1.reform])^2 ))/_b[1._predict#1._at#1.reform])
 sca CV_ME_TE=r(b)[1,1]
 sca CV_ME_TE_se=r(V)[1,1]^.5
di CV_ME_TE
di CV_ME_TE_se

reg y (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca y11 =  _b[2._at#1.reform]
sca y01 =  _b[1._at#1.reform]

reg y2 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca y211 =  _b[2._at#1.reform]
sca y201 =  _b[1._at#1.reform]

reg y3 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca y311 =  _b[2._at#1.reform]
sca y301 =  _b[1._at#1.reform]

reg y4 (c.X1 c.X2 c.X1_2 c.X2_2 c.X1_X2)##reform, r
margins, post at(reform=(0(1)1)) over(reform) nose
sca y411 =  _b[2._at#1.reform]
sca y401 =  _b[1._at#1.reform]


*errors need _L to use the log(Y) errors

* Observed Skewness
 sca S_ME_OB= ((y311)-3*(y211)*(y11) +2*(y11)^3) 
 sca S_ME_OB_SSBC= ((y311) -3*(y211)*(y11) +2*(y11)^3) -(-3*e11_12_L +6*y11*e11_2_L + 2*e11_3_L)

 * Counterfactual Skewness
 sca S_ME_C= (((y301)-3*(y201)*(y01) +2*(y01)^3))
 sca S_ME_C_SSBC= (((y301)-3*(y201)*(y01) +2*(y01)^3) -(-3*e01_02_L +6*y01*e01_2_L + 2*e01_3_L))
di S_ME_C

* PTT of Skewness
*treatment effect on skewness
 sca S_ME_TE= ((y311)-3*(y211)*(y11) +2*(y11)^3) - (((y301)-3*(y201)*(y01) +2*(y01)^3))
 sca S_ME_TE_SSBC= ((y311)-3*(y211)*(y11) +2*(y11)^3 -(-3*e11_12_L +6*y11*e11_2_L + 2*e11_3_L)) - ((y301)-3*(y201)*(y01) +2*(y01)^3-(-3*e01_02_L +6*y01*e01_2_L + 2*e01_3_L))
 di S_ME_TE
 
* Observed Standardised Skewness
 sca SS_ME_OB= 		((y311)-3*(y211)*(y11) +2*(y11)^3 )/(y211 - (y11)^2)^(3/2) 
di SS_ME_OB
 sca SS_ME_OB_SSBC= ((y311)-3*(y211)*(y11) +2*(y11)^3 -(-3*e11_12_L +6*y11*e11_2_L + 2*e11_3_L))/(y211 - (y11)^2+ e11_2_L)^(3/2) 

* Counterfactual Standardised Skewness
 sca SS_ME_C= (((y301)-3*(y201)*(y01) +2*(y01)^3)/(y201 - (y01)^2)^(3/2))
 sca SS_ME_C_SSBC= (((y301)-3*(y201)*(y01) +2*(y01)^3 -(-3*e01_02_L +6*y01*e01_2_L  + 2*e01_3_L))/(y201 - (y01)^2+ e01_2_L)^(3/2))
 di SS_ME_C
 
*treatment effect on Standardised skewness
 sca SS_ME_TE= ((y311)-3*(y211)*(y11) +2*(y11)^3)/(y211 - (y11)^2)^(3/2) - (((y301)-3*(y201)*(y01) +2*(y01)^3)/(y201 - (y01)^2)^(3/2))
 sca SS_ME_TE_SSBC= ((y311)-3*(y211)*(y11) +2*(y11)^3 -(-3*e11_12_L +6*y11*e11_2_L + 2*e11_3_L))/(y211 - (y11)^2+ e11_2_L)^(3/2) - (((y301)-3*(y201)*(y01) +2*(y01)^3 -(-3*e01_02_L +6*y01*e01_2_L  + 2*e01_3_L))/(y201 - (y01)^2+ e01_2_L)^(3/2))
di SS_ME_TE



* Observed Kurtosis
 sca K_ME_OB= 		(y411-(4*y311*y11)+6*y211*(y11^2)-3*(y11^4) )
 sca K_ME_OB_SSBC= 	(y411-(4*y311*y11)+6*y211*(y11^2)-3*(y11^4) -(-4*e11_13_L + 6*y211*e11_2_L +6*e11_2_12_L + 12*y11*e11_12_L -3*e11_4_L -12*y11*e11_3_L - 18*y11^2*e11_2_L))
 di K_ME_OB
 
* Counterfactual Kurtosis
 sca K_ME_C=		((y401-(4*y301*y01)+6*y201*(y01^2)-3*(y01^4)))
 sca K_ME_C_SSBC=	((y401-(4*y301*y01)+6*y201*(y01^2)-3*(y01^4) -(-4*e01_03_L + 6*y201*e01_2_L +6*e01_2_02_L + 12*y01*e01_02_L -3*e01_4_L -12*y01*e01_3_L - 18*y01^2*e01_2_L)))
 di K_ME_C
 
 * PTT of Kurtosis
 sca K_ME_TE= 		(y411-(4*y311*y11)+6*y211*(y11^2)-3*(y11^4)) - ((y401-(4*y301*y01)+6*y201*(y01^2)-3*(y01^4)))
 sca K_ME_TE_SSBC= K_ME_OB_SSBC - K_ME_C_SSBC
 di K_ME_TE
 
* Observed Standardised Kurtosis
sca SK_ME_OB= 		(y411-(4*y311*y11)+6*y211*(y11^2)-3*(y11^4))/((y211 - (y11)^2)^2)
sca SK_ME_OB_SSBC= 	(y411-(4*y311*y11)+6*y211*(y11^2)-3*(y11^4) -(-4*e11_13_L + 6*y211*e11_2_L +6*e11_2_12_L + 12*y11*e11_12_L -3*e11_4_L -12*y11*e11_3_L - 18*y11^2*e11_2_L))/((y211 - (y11)^2+ e11_2_L)^2)
 di SK_ME_OB
 
* Counterfactual Standardised Kurtosis
sca SK_ME_C= 		((y401-(4*y301*y01)+6*y201*(y01^2)-3*(y01^4)))/((y201 - (y01)^2)^2)
sca SK_ME_C_SSBC= 	((y401-(4*y301*y01)+6*y201*(y01^2)-3*(y01^4) -(-4*e01_03_L + 6*y201*e01_2_L +6*e01_2_02_L + 12*y01*e01_02_L -3*e01_4_L -12*y01*e01_3_L - 18*y01^2*e01_2_L)))/((y201 - (y01)^2+ e01_2_L)^2)
 di SK_ME_C
 
* PTT of Standardised Kurtosis
 sca SK_ME_TE= (y411-(4*y311*y11)+6*y211*(y11^2)-3*(y11^4))/((y211 - (y11)^2)^2) - ((y401-(4*y301*y01)+6*y201*(y01^2)-3*(y01^4))/((y201 - (y01)^2)^2))
 sca SK_ME_TE_SSBC= SK_ME_OB_SSBC - SK_ME_C_SSBC
 di SK_ME_TE

 
 
scalar list


* FEED THE MATRIX

cap matrix Var_cr_L[`k',1]=M_unf 				/* Mean unfeasible*/
cap matrix Var_cr_L[`k',2]=V_U_TE 			/* Variance unfeasible*/
cap matrix Var_cr_L[`k',3]=CV_U_TE 			/* COEFV unfeasible*/
cap matrix Var_cr_L[`k',4]=SS_U_TE 			/* Std skewness unfeasible*/
cap matrix Var_cr_L[`k',5]=SK_U_TE 			/* Std kurtosis unfeasible*/

cap matrix Var_cr_L[`k',6]=M_N_TE 			/* Mean Naive*/
cap matrix Var_cr_L[`k',7]=V_N_TE 			/* Variance Naive*/
cap matrix Var_cr_L[`k',8]=CV_N_TE 			/* CoefV Naive*/
cap matrix Var_cr_L[`k',9]=SS_N_TE 			/* Std skewness Naive*/
cap matrix Var_cr_L[`k',10]=SK_N_TE 			/* Std kurtosis Naive*/

* PERM PTT point estimates and standard errors

cap matrix Var_cr_L[`k',11]=M_ME_TE			/* Mean ME quadratic */
cap matrix Var_cr_L[`k',12]=V_ME_TE			/* Variance ME quadratic */
cap matrix Var_cr_L[`k',13]=V_ME_TE_SSBC		/* Variance ME quadratic SSB corrected*/
cap matrix Var_cr_L[`k',14]=CV_ME_TE			/* CoefV ME quadratic */
cap matrix Var_cr_L[`k',15]=S_ME_TE			/* skewness ME quadratic */
cap matrix Var_cr_L[`k',16]=SS_ME_TE			/* Std. skewness ME quadratic */
cap matrix Var_cr_L[`k',17]=K_ME_TE			/* kurtosis ME quadratic */
cap matrix Var_cr_L[`k',18]=SK_ME_TE			/* Std. kurtosis ME quadratic */

cap matrix Var_cr_L[`k',19]=M_ME_TE_se			/* Mean ME quadratic linearisation s.e */
cap matrix Var_cr_L[`k',20]=V_ME_TE_se		/* Variance ME quadratic linearisation s.e  */
cap matrix Var_cr_L[`k',21]=V_ME_TE_SSBC_se	/* Variance ME quadratic SSB corrected linearisation se*/
cap matrix Var_cr_L[`k',22]=CV_ME_TE_se		/* CoefV ME quadratic linearisation s.e */

* bias corrected sample estimators 
cap matrix Var_cr_L[`k',23]=S_ME_TE_SSBC			/* skewness bias corrected */
cap matrix Var_cr_L[`k',24]=SS_ME_TE_SSBC			/* Std. skewness (skewness and variance bias corrected), but still biased */
cap matrix Var_cr_L[`k',25]=K_ME_TE_SSBC			/* kurtosis bias corrected */
cap matrix Var_cr_L[`k',26]=SK_ME_TE_SSBC			/* Std. kurtosis (skewness and variance bias corrected), but still biased  */

cap matrix Var_cr_L[`k',27]=M_BME_TE_se_L		/* Mean ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',28]=V_BME_TE_se_L		/* Variance ME quadratic Bootstrap s.e  */
cap matrix Var_cr_L[`k',29]=V_BMESSB_TE_se_L	/* Variance ME quadratic SSB corrected Bootstrap se*/
cap matrix Var_cr_L[`k',30]=CV_BME_TE_se_L		/* CoefV ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',31]=S_BME_TE_se_L		/* skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',32]=SS_BME_TE_se_L		/* Std. skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',33]=K_BME_TE_se_L		/* kurtosis ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',34]=SK_BME_TE_se_L		/* Std. kurtosis ME quadratic Bootstrap s.e */

* PERM observed point estimates and standard errors

cap matrix Var_cr_L[`k',35]=M_ME_OB			/* Mean ME quadratic */
cap matrix Var_cr_L[`k',36]=V_ME_OB			/* Variance ME quadratic */
cap matrix Var_cr_L[`k',37]=CV_ME_OB			/* CoefV ME quadratic */
cap matrix Var_cr_L[`k',38]=S_ME_OB			/* skewness ME quadratic */
cap matrix Var_cr_L[`k',39]=SS_ME_OB			/* Std. skewness ME quadratic */
cap matrix Var_cr_L[`k',40]=K_ME_OB			/* kurtosis ME quadratic */
cap matrix Var_cr_L[`k',41]=SK_ME_OB			/* Std. kurtosis ME quadratic */

cap matrix Var_cr_L[`k',42]=M_ME_OB_se			/* Mean ME quadratic linearisation s.e */
cap matrix Var_cr_L[`k',43]=V_ME_OB_se		/* Variance ME quadratic linearisation s.e  */
cap matrix Var_cr_L[`k',44]=CV_ME_OB_se		/* CoefV ME quadratic linearisation s.e */

* bias corrected sample estimators 
cap matrix Var_cr_L[`k',45]=S_ME_OB_SSBC			/* skewness bias corrected */
cap matrix Var_cr_L[`k',46]=SS_ME_OB_SSBC			/* Std. skewness (skewness and variance bias corrected), but still biased */
cap matrix Var_cr_L[`k',47]=K_ME_OB_SSBC			/* kurtosis bias corrected */
cap matrix Var_cr_L[`k',48]=SK_ME_OB_SSBC			/* Std. kurtosis (skewness and variance bias corrected), but still biased  */

cap matrix Var_cr_L[`k',49]=M_BME_OB_se_L		/* Mean ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',50]=V_BME_OB_se_L		/* Variance ME quadratic Bootstrap s.e  */
cap matrix Var_cr_L[`k',51]=CV_BME_OB_se_L		/* CoefV ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',52]=S_BME_OB_se_L		/* skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',53]=SS_BME_OB_se_L		/* Std. skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',54]=K_BME_OB_se_L		/* kurtosis ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',55]=SK_BME_OB_se_L		/* Std. kurtosis ME quadratic Bootstrap s.e */

* PERM counterfactual point estimates and standard errors

cap matrix Var_cr_L[`k',56]=M_ME_C				/* Mean ME quadratic */
cap matrix Var_cr_L[`k',57]=V_ME_C			/* Variance ME quadratic */
cap matrix Var_cr_L[`k',58]=CV_ME_C			/* CoefV ME quadratic */
cap matrix Var_cr_L[`k',59]=S_ME_C			/* skewness ME quadratic */
cap matrix Var_cr_L[`k',60]=SS_ME_C			/* Std. skewness ME quadratic */
cap matrix Var_cr_L[`k',61]=K_ME_C			/* kurtosis ME quadratic */
cap matrix Var_cr_L[`k',62]=SK_ME_C			/* Std. kurtosis ME quadratic */

cap matrix Var_cr_L[`k',63]=M_ME_C_se			/* Mean ME quadratic linearisation s.e */
cap matrix Var_cr_L[`k',64]=V_ME_C_se			/* Variance ME quadratic linearisation s.e  */
cap matrix Var_cr_L[`k',65]=CV_ME_C_se		/* CoefV ME quadratic linearisation s.e */

* bias corrected sample estimators 
cap matrix Var_cr_L[`k',66]=S_ME_C_SSBC			/* skewness bias corrected */
cap matrix Var_cr_L[`k',67]=SS_ME_C_SSBC			/* Std. skewness (skewness and variance bias corrected), but still biased */
cap matrix Var_cr_L[`k',68]=K_ME_C_SSBC			/* kurtosis bias corrected */
cap matrix Var_cr_L[`k',69]=SK_ME_C_SSBC			/* Std. kurtosis (skewness and variance bias corrected), but still biased  */

cap matrix Var_cr_L[`k',70]=M_BME_C_se_L			/* Mean ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',71]=V_BME_C_se_L		/* Variance ME quadratic Bootstrap s.e  */
cap matrix Var_cr_L[`k',72]=CV_BME_C_se_L		/* CoefV ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',73]=S_BME_C_se_L		/* skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',74]=SS_BME_C_se_L		/* Std. skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',75]=K_BME_C_se_L		/* kurtosis ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',76]=SK_BME_C_se_L		/* Std. kurtosis ME quadratic Bootstrap s.e */

* IPW PTT point estimates and standard errors

cap matrix Var_cr_L[`k',77]=M_W_TE				/* Mean ME quadratic */
cap matrix Var_cr_L[`k',78]=V_W_TE			/* Variance ME quadratic */
cap matrix Var_cr_L[`k',79]=CV_W_TE			/* CoefV ME quadratic */
cap matrix Var_cr_L[`k',80]=SS_W_TE			/* Std. skewness ME quadratic */
cap matrix Var_cr_L[`k',81]=SK_W_TE			/* Std. kurtosis ME quadratic */

cap matrix Var_cr_L[`k',82]=M_BW_TE_se_L			/* Mean ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',83]=V_BW_TE_se_L		/* Variance ME quadratic Bootstrap s.e  */
cap matrix Var_cr_L[`k',84]=CV_BW_TE_se_L		/* CoefV ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',85]=SS_BW_TE_se_L		/* Std. skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',86]=SK_BW_TE_se_L		/* Std. kurtosis ME quadratic Bootstrap s.e */

* IPW observed point estimates and standard errors

cap matrix Var_cr_L[`k',87]=M_W_OB				/* Mean ME quadratic */
cap matrix Var_cr_L[`k',88]=V_W_OB			/* Variance ME quadratic */
cap matrix Var_cr_L[`k',90]=SS_W_OB			/* Std. skewness ME quadratic */
cap matrix Var_cr_L[`k',91]=SK_W_OB			/* Std. kurtosis ME quadratic */

cap matrix Var_cr_L[`k',93]=V_BW_OB_se_L		/* Variance ME quadratic Bootstrap s.e  */
cap matrix Var_cr_L[`k',95]=SS_BW_OB_se_L		/* Std. skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',96]=SK_BW_OB_se_L		/* Std. kurtosis ME quadratic Bootstrap s.e */

* IPW counterfactual point estimates and standard errors

cap matrix Var_cr_L[`k',97]=M_W_C				/* Mean ME quadratic */
cap matrix Var_cr_L[`k',98]=V_W_C				/* Variance ME quadratic */
cap matrix Var_cr_L[`k',100]=SS_W_C			/* Std. skewness ME quadratic */
cap matrix Var_cr_L[`k',101]=SK_W_C			/* Std. kurtosis ME quadratic */

cap matrix Var_cr_L[`k',103]=V_BW_C_se_L			/* Variance ME quadratic Bootstrap s.e  */
cap matrix Var_cr_L[`k',105]=SS_BW_C_se_L		/* Std. skewness ME quadratic Bootstrap s.e */
cap matrix Var_cr_L[`k',106]=SK_BW_C_se_L		/* Std. kurtosis ME quadratic Bootstrap s.e */

* Percentile bootstrap LL and UL

cap matrix Var_cr_L[`k',107]=V_BME_TE_PCLL_L		/* BS Variance ME quadratic PC LL*/
cap matrix Var_cr_L[`k',108]=V_BME_TE_PCUL_L	    /* BS Variance ME quadratic PC UL*/
cap matrix Var_cr_L[`k',109]=V_BME_TE_PCLLSSB_L	/* BS Variance SSB ME quadratic PC LL*/
cap matrix Var_cr_L[`k',110]=V_BME_TE_PCULSSB_L	/* BS Variance SSB ME quadratic PC UL*/
cap matrix Var_cr_L[`k',111]=CV_BME_TE_PCLL_L	/* BS CoefV ME quadratic PC LL*/
cap matrix Var_cr_L[`k',112]=CV_BME_TE_PCUL_L	/* BS CoefV ME quadratic PC UL*/
cap matrix Var_cr_L[`k',113] = S_BME_TE_PCLL_L	/* skewness ME quadratic PC LL*/
cap matrix Var_cr_L[`k',114] = S_BME_TE_PCUL_L  	/* skewness ME quadratic PC UL*/
cap matrix Var_cr_L[`k',115] = SS_BME_TE_PCLL_L	/* Std. skewness ME quadratic PC LL*/
cap matrix Var_cr_L[`k',116] = SS_BME_TE_PCUL_L  /* Std. skewness ME quadratic PC UL*/
cap matrix Var_cr_L[`k',117] = K_BME_TE_PCLL_L	/* kurtosis ME quadratic PC LL*/
cap matrix Var_cr_L[`k',118] = K_BME_TE_PCUL_L  	/* kurtosis ME quadratic PC UL*/
cap matrix Var_cr_L[`k',119] = SK_BME_TE_PCLL_L	/* Std. kurtosis ME quadratic PC LL*/
cap matrix Var_cr_L[`k',120] = SK_BME_TE_PCUL_L  /* Std. kurtosis ME quadratic PC UL*/

cap matrix Var_cr_L[`k',121]=V_BW_TE_PCLL_L		/* BS Variance ME quadratic PC LL*/
cap matrix Var_cr_L[`k',122]=V_BW_TE_PCUL_L	    /* BS Variance ME quadratic PC UL*/
cap matrix Var_cr_L[`k',123]=CV_BW_TE_PCLL_L		/* BS CoefV ME quadratic PC LL*/
cap matrix Var_cr_L[`k',124]=CV_BW_TE_PCUL_L	    /* BS CoefV ME quadratic PC UL*/
cap matrix Var_cr_L[`k',125] = SS_BW_TE_PCLL_L	/* Std. skewness IPW quadratic PC LL*/
cap matrix Var_cr_L[`k',126] = SS_BW_TE_PCUL_L  	/* Std. skewness IPW quadratic PC UL*/
cap matrix Var_cr_L[`k',127] = SK_BW_TE_PCLL_L	/* Std. kurtosis IPW quadratic PC LL*/
cap matrix Var_cr_L[`k',128] = SK_BW_TE_PCUL_L  	/* Std. kurtosis IPW quadratic PC UL*/

* bias terms
cap matrix Var_cr_L[`k',131]=e11_2_L
cap matrix Var_cr_L[`k',132]=e11_3_L
cap matrix Var_cr_L[`k',133]=e11_4_L
cap matrix Var_cr_L[`k',134]=e01_2_L
cap matrix Var_cr_L[`k',135]=e01_3_L
cap matrix Var_cr_L[`k',136]=e01_4_L
cap matrix Var_cr_L[`k',137]=e11_12_L
cap matrix Var_cr_L[`k',138]=e01_02_L
cap matrix Var_cr_L[`k',139]=e11_2_12_L
cap matrix Var_cr_L[`k',140]=e01_2_02_L
cap matrix Var_cr_L[`k',141]=e11_13_L
cap matrix Var_cr_L[`k',142]=e01_03_L
 
cap matrix Var_cr_L[`k',143]=m11_e11_2_L
cap matrix Var_cr_L[`k',144]=m01_e01_2_L
cap matrix Var_cr_L[`k',145]=m12_e11_2_L
cap matrix Var_cr_L[`k',146]=m02_e01_2_L
cap matrix Var_cr_L[`k',147]=m11_e11_12_L
cap matrix Var_cr_L[`k',148]=m01_e01_02_L
cap matrix Var_cr_L[`k',149]=m11_e11_3_L
cap matrix Var_cr_L[`k',150]=m01_e01_3_L
cap matrix Var_cr_L[`k',151]=m11_2_e11_2_L
cap matrix Var_cr_L[`k',152]=m01_2_e01_2_L

* unstandardised skewness and kurtosis

cap matrix Var_cr_L[`k',160]=S_U_TE			/* skewness Unfeasible */
cap matrix Var_cr_L[`k',161]=K_U_TE			/* kurtosis Unfeasible */
cap matrix Var_cr_L[`k',162]=S_N_TE			/* skewness Naive */
cap matrix Var_cr_L[`k',163]=K_N_TE			/* kurtosis Naive */
cap matrix Var_cr_L[`k',164]=S_W_TE			/* skewness IPW */
cap matrix Var_cr_L[`k',165]=K_W_TE			/* kurtosis IPW */

cap matrix Var_cr_L[`k',166]=S_BW_TE_se_L				/* skewness IPW BS s.e. */
cap matrix Var_cr_L[`k',167]=K_BW_TE_se_L				/* kurtosis IPW BS s.e. */


cap matrix Var_cr_L[`k',168]=S_U_OB			/* skewness Unfeasible */
cap matrix Var_cr_L[`k',169]=K_U_OB			/* kurtosis Unfeasible */
cap matrix Var_cr_L[`k',170]=S_N_OB			/* skewness Naive */
cap matrix Var_cr_L[`k',171]=K_N_OB			/* kurtosis Naive */
cap matrix Var_cr_L[`k',172]=S_W_OB			/* skewness IPW */
cap matrix Var_cr_L[`k',173]=K_W_OB			/* kurtosis IPW  */

cap matrix Var_cr_L[`k',174]=S_BW_OB_se_L				/* Std. skewness ME quadratic */
cap matrix Var_cr_L[`k',175]=K_BW_OB_se_L				/* Std. kurtosis ME quadratic */


cap matrix Var_cr_L[`k',176]=S_U_C			/* skewness Unfeasible */
cap matrix Var_cr_L[`k',177]=K_U_C			/* kurtosis Unfeasible */
cap matrix Var_cr_L[`k',178]=S_N_C			/* skewness Naive */
cap matrix Var_cr_L[`k',179]=K_N_C			/* kurtosis Naive */
cap matrix Var_cr_L[`k',180]=S_W_C			/* skewness IPW */
cap matrix Var_cr_L[`k',181]=K_W_C			/* kurtosis IPW  */

cap matrix Var_cr_L[`k',182]=S_BW_C_se_L				/* skewness IPW BS s.e. */
cap matrix Var_cr_L[`k',183]=K_BW_C_se_L				/* kurtosis IPW BS s.e. */

cap matrix Var_cr_L[`k',184] = S_BW_TE_PCLL_L	/* skewness IPW quadratic PC LL*/
cap matrix Var_cr_L[`k',185] = S_BW_TE_PCUL_L  	/* skewness IPW quadratic PC UL*/
cap matrix Var_cr_L[`k',186] = K_BW_TE_PCLL_L	/* kurtosis IPW quadratic PC LL*/
cap matrix Var_cr_L[`k',187] = K_BW_TE_PCUL_L  	/* kurtosis IPW quadratic PC UL*/


}
timer off 1
timer list 1
}
 drop * 
  svmat double Var_cr
 * mac
  cap save "$save/r_MCS1_nSS`SS'_`j'.dta", replace
 * pc
 * cap save "$save\r_MCS1_nSS`SS'_`j'.dta", replace

   drop * 
  svmat double Var_cr_L
 * mac
  cap save "$save/r_MCS1_nSS`SS'_`j'ln.dta", replace
 * pc
 * cap save "$save\r_MCS1_nSS`SS'_`j'ln.dta", replace
  
}

}
