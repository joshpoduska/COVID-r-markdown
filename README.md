# COVID-r-markdown

### Build a web-based report of annual deaths due to all causes in the US to assess COVID impact

data_pull.R is a separate file in case you need to pull the data on a regular basis as part of a scheduled job.

covid_mortality_report.Rmd is the main file with the R code and markdown that will be run to generate the report.

render.R runs the command to build the final html report. It is in a separate file for easier use in automated jobs.

covid_mortality_report.html is the output.

Each of the .R and .RMD files has setwd("...") at the top. Be sure to check that it matches the home of your files before running.
