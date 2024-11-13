**Empirical application I**

Original programs in STATA and R accompanying
``Taking an extra moment to consider treatment effects on distributions´´by Gawain Heckley and Dennis Petrie


Data set is from the replication files of
``Unconditional Quantile Regressions'' by Sergio Firpo, Nicole M. Fortin, and Thomas
Lemieux. 
The original data are available on the web site: http://www.econ.ubc.ca/nfortin/

The data file and the original programs in STATA and R used to obtain the results in the
paper are described below. 

The data file is:
men8385.dta -- STATA10 data file containing an extract of the following variables 
from the Merged Outgoing Rotation Group of the Current Population Survey of 1983, 
1984 and 1985. The file contains 266956 observations on males with 17 variables 
whose definition is given by the variable labels. More detail about the data 
selection and recoding (e.g. top coding, wage deflator, etc.) is found in Lemieux 
(2006).


The STATA files are:
PERM_Unions.do -- the STATA file that performs PERM regression analysis of the mean, variance and standardised skewness comparing these to IPW, stores the PERM and IPW estimates, and their bootstrapped standard errors in an output file.
Results from this program are displayed in Table 2

PERM_RIF_Unions.do -- the STATA file that estimates PERM and RIF estimates of the partial policy effect, stores the estimates, and their bootstrapped standard errors in an output file.
Results from this program are displayed in Table J.1 in the appendix


PERM_Unions_subgroups.do -- the STATA file that estimates PERM providing variance treatment effect by subgroups, stores the estimates, and their bootstrapped standard errors in an output file.
Results from this program are displayed in Table K.1 in the appendix

Figure_PearsonIV.do - the STATA file graphs the counterfactual and observed distributions as estimated by Pearson distribution model in R.
Results from this program are displayed in Figure I.1 in the appendix

The R files are:
PearsonSIM.R - the R file simulates a Pearson distribution using the results from table 2.
Results from this program are utilised in the STATA do file: Figure_PearsonIV.do


