library(PearsonDS)
library(haven) # import non-native libraries


##years of edu
#education - observed
pearsonFitM(11.05, 5.68, 1.06, 4.68)
## define Pearson type I parameter set with a=2, b=3, location=1, scale=2
pIpars <- list(a=3.526042, b=1416.696, location=6.567601, scale=1805.425)
## calculate probability density function
dpearsonI(seq(1,3,by=0.5),params=pIpars)
## calculate cumulative distribution function
ppearsonI(seq(1,3,by=0.5),params=pIpars)
## calculate quantile function
qpearsonI(seq(0.1,0.9,by=0.2),params=pIpars)
## generate random numbers
data <- rpearsonI(10000000,params=pIpars)
hist(data)
df <- data.frame(data)
write_dta(df,"G:\\Shared drives\\Inequality Decomposition\\FFL2009UQR-data\\Simulated gld\\simdata_observed_yrsedu_pear_nokur.dta")

#education - counterfactual
pearsonFitM(10.58, 6.51, 1.01, 4.68)
## define Pearson type I parameter set with a=2, b=3, location=1, scale=2
pVIpars <- list(a=5.474591, b=54.25125, location=4.948812, scale=54.77447)
## calculate probability density function
dpearsonVI(seq(1,3,by=0.5),params=pVIpars)
## calculate cumulative distribution function
ppearsonVI(seq(1,3,by=0.5),params=pVIpars)
## calculate quantile function
qpearsonVI(seq(0.1,0.9,by=0.2),params=pVIpars)
## generate random numbers
data <- rpearsonVI(10000000,params=pVIpars)
hist(data)
df <- data.frame(data)
write_dta(df,"G:\\Shared drives\\Inequality Decomposition\\FFL2009UQR-data\\Simulated gld\\simdata_cf_yrsedu_pear_nokur.dta")


#income - observed
pearsonFitM(2.37, 2.17, 6.29, 201.28)
## define Pearson type VI parameter set with a=2, b=3, location=1, scale=2
pVIpars <- list(a=0.6307112, b=4.47034, location=1.462021, scale=4.995942)
## calculate probability density function
dpearsonVI(-2:2,params=pVIpars)
## calculate cumulative distribution function
ppearsonVI(-2:2,params=pIVpars)
## calculate quantile function
qpearsonVI(seq(0.1,0.9,by=0.2),params=pVIpars)
## generate random numbers
data <- rpearsonVI(10000000,params=pVIpars)
hist(data)
df <- data.frame(data)
write_dta(df,"G:\\Shared drives\\Inequality Decomposition\\FFL2009UQR-data\\Simulated gld\\simdata_observed_inc_pear_nokur.dta")

#income - counterfactual
pearsonFitM(2.35, 1.99, 4.74, 201.28)
## define Pearson type IV parameter set with a=2, b=3, location=1, scale=2
pIVpars <- list(m=2.620615, nu=-17.09121, location=0.275099, scale=0.3934907)
## calculate probability density function
dpearsonIV(-2:2,params=pIVpars)
## calculate cumulative distribution function
ppearsonIV(-2:2,params=pIVpars)
## calculate quantile function
qpearsonIV(seq(0.1,0.9,by=0.2),params=pIVpars)
## generate random numbers
data <- rpearsonIV(10000000,params=pIVpars)
hist(data)
df <- data.frame(data)
write_dta(df,"G:\\Shared drives\\Inequality Decomposition\\FFL2009UQR-data\\Simulated gld\\simdata_cf_inc_pear_nokur.dta")
