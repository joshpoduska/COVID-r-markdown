setwd("~/Documents/COVID-r-markdown/")
install.packages('cdcfluview')
library(cdcfluview)

mortality <- pi_mortality()
write.csv(mortality, "mortality.csv", row.names = FALSE)