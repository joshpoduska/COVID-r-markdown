setwd("~/Documents/COVID-r-markdown/")
rmarkdown::render("covid_mortality_report.Rmd", 
                  output_file = 'covid_mortality_report.html')