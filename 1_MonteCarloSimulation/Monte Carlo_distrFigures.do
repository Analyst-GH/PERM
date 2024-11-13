* Graph settings
graph set window fontface "Times New Roman"
set scheme cleanplots
grstyle init
grstyle set size 16pt: heading subheading body small_body text_option axis_title tick_label minortick_label key_label

global outtab "/Users/med-gwh/Library/CloudStorage/GoogleDrive-gawainheckley@gmail.com/Shared drives/Inequality Decomposition/Monte Carlo Sim/MCS_table250"




clear all


clear
set obs 100000

********** SET UP VARIABLES *************
* Following Firpo and Pinto 2015:

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

hist y, xtitle("Y")
graph export "$outtab/Distr_Y.pdf", replace		

replace y=ln(y)
hist y, xtitle("ln(Y)")
graph export "$outtab/Distr_lnY.pdf", replace		
