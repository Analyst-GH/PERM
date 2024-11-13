library(PearsonDS)
library(haven) # import non-native libraries

##Diagram to choose the appropriate Pearson Distribution (Y-Kurtosis X-skewness squared)
pearsonDiagram(max.skewness = 1.06, max.kurtosis = 4.68, squared.skewness = TRUE, lwd = 2, legend = TRUE, n = 30100)

##Unionization
pearsonFitM(1.9625324, 0.16545586, -0.17870407, 4.0925642)
## define Pearson type IV parameter set with a=2, b=3, location=1, scale=2
pIVpars <- list(m=5.394671, nu=0.9609222, location=2.085912, scale=1.128525)
## calculate probability density function
dpearsonIV(-2:2,params=pIVpars)
## calculate cumulative distribution function
ppearsonIV(-2:2,params=pIVpars)
## calculate quantile function
qpearsonIV(seq(0.1,0.9,by=0.2),params=pIVpars)
## generate random numbers
data <- rpearsonIV(1000000,params=pIVpars)
hist(data)
df <- data.frame(data)
write_dta(df,"G:\\Shared drives\\Inequality Decomposition\\FFL2009UQR-data\\Simulated gld\\simdata_observed_pear_nokur.dta")

pearsonFitM(1.7854935, .33097398, 0.2321705, 4.0925642)
## define Pearson type I parameter set with a=2, b=3, location=1, scale=2
pIVpars <- list(m=5.505238, nu=-1.309026, location=1.551399, scale=1.611353)
## calculate probability density function
dpearsonIV(seq(1,3,by=0.5),params=pIVpars)
## calculate cumulative distribution function
ppearsonIV(seq(1,3,by=0.5),params=pIVpars)
## calculate quantile function
qpearsonIV(seq(0.1,0.9,by=0.2),params=pIVpars)
## generate random numbers
data <- rpearsonIV(1000000,params=pIVpars)
hist(data)
df <- data.frame(data)
write_dta(df,"G:\\Shared drives\\Inequality Decomposition\\FFL2009UQR-data\\Simulated gld\\simdata_counterfactual_pear_nokur.dta")
