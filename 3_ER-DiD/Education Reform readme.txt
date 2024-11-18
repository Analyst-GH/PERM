**Empirical application II**
** PERM staggered DiD of Swedish Comprehensive school reform **

Original programs in STATA and R accompanying
``Taking an extra moment to consider treatment effects on distributions´´by Gawain Heckley and Dennis Petrie


Data Availability Statement
Data cannot be shared for ethical/privacy reasons. Our data contains sensitive information on individual outcomes and, hence, Swedish law requires users of the data to hold a permission from the Swedish Ethical Review Authority (“Etikprövningsmyndigheten”). This means that we are unable to make our data available online. Researchers interested in obtaining the data are able to apply for a permission from the Swedish Ethical Review Authority at https://etikprovningsmyndigheten.se/. Conditional on approval, researchers can apply for and buy the data from Statistics Sweden (www.scb.se). Statistics Sweden removes personal identifiers and replaces these with a personal ID used to merge the data sets. The data on the introduction of the comprehensive school reform is provided as part of the replication package for XXXXXXXXXX. The data obtained from Statistics Sweden does not contain any personal information such as names and addresses.

The replication package for the article can be found at: XXXXXXXXX

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
Data generating package
Descriptives
Event study figures
Main results

Appendix:
Histogram
Additional event study figures
Robustness event study figures
Robustness balancing tests
PDFs and CDFs
Joint distribution of education and earnings


PERM_Unions.do -- the STATA file that performs PERM regression analysis of the mean, variance and standardised skewness comparing these to IPW, stores the PERM and IPW estimates, and their bootstrapped standard errors in an output file.
Results from this program are displayed in Table 2




Figure_Pearson distribution.do - the STATA file graphs the counterfactual and observed distributions as estimated by Pearson distribution model in R.
Results from this program are displayed in Figure P.1 in the appendix

The R files are:
PearsonSIM_ER.R - the R file simulates a Pearson distribution using the results from table 3.
Results from this program are utilised in the STATA do file: Figure_Pearson distribution.do


