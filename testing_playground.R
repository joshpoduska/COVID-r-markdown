setwd("~/Documents/COVID-r-markdown/")
install.packages('cdcfluview')
install.packages('ggplot2')
install.packages('rmarkdown')
install.packages("data.table")
library("data.table")
library(cdcfluview)
library(ggplot2)
library(rmarkdown)
library(dplyr)

mortality <- pi_mortality()
write.csv(mortality, "mortality.csv", row.names = FALSE)

# Bring in CDC US mortality data
df <- read.csv('mortality.csv', header = TRUE, stringsAsFactors = FALSE)
df <- df[c('total_pni','all_deaths','week_start', 'week_end')]
df$week_end <- as.Date(df$week_end, format = "%Y-%m-%d")
df$week_start <- as.Date(df$week_start, format = "%Y-%m-%d")
df <- df %>% arrange(desc(week_end))
head(df)

#remove 3 recent weeks
exc_date <- df$week_start[3]
df <- subset(df, week_start < exc_date)
head(df)


#remove any 2015 data - using week_start
exc_date2 <- as.Date("2016-01-01")
df <- subset(df, week_start > exc_date2)
tail(df)


# trend line---------------------
p <- ggplot(df, aes(x=week_start, y=all_deaths)) + 
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  geom_line(color="#69b3a2") + 
  xlab("") + ylab("weekly deaths") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) + 
  ggtitle("Weekly US Deaths Due to Any Cause")
p


# bar plot----------------------
# sum by year first
df$year <- format(as.Date(df$week_start, format="%d/%m/%Y"),"%Y")
df_year <- df %>% 
  group_by(year) %>% 
  summarise(deaths = sum(all_deaths)) %>% 
  as.data.frame()
df_year$deaths_label <- paste(round(df_year$deaths / 1000000,2), "M") 
df_year <- df_year[df_year$year != 2013,]
head(df_year)

# calculate y axis limits
y_min <- round(min(df_year$deaths)*0.75,0)
y_max <- round(max(df_year$deaths)*1.05,0)

# plot
b <- ggplot(df_year, aes(x=year, y=deaths)) +
  geom_bar(stat="identity", fill="steelblue") +
  coord_cartesian(ylim = c(y_min, y_max)) + 
  geom_text(aes(label=deaths_label), vjust=1.6, color="white",
            position = position_dodge(0.9), size=3.0) +
  ggtitle("Yearly US Deaths Due to Any Cause")
b



# YTD bar plot-----------------------
# get the current year and the number of weeks reported so far in that year
cyear <- year(exc_date)
cweek <- nrow(subset(df, format(week_end, "%Y") == cyear))

# filter the first cweek weeks in each year
df_ytd <- df %>%
  group_by(year) %>%
  slice_max(year, n=cweek) %>% 
  as.data.frame()

# get the first cweek rows by year
df_ytd <- data.table(df, key = "year")
df_ytd <- df_ytd[ , tail(.SD, cweek), by = year]

# sum by year first
df_ytd_sum <- df_ytd %>% 
  group_by(year) %>% 
  summarise(deaths = sum(all_deaths), n = n()) %>% 
  as.data.frame()

df_ytd_sum$deaths_label <- paste(round(df_ytd_sum$deaths / 1000000,2), "M") 
# df_ytd_sum <- df_ytd_sum[df_ytd_sum$year,]
df_ytd_sum

# calculate y axis limits
y_min <- round(min(df_ytd_sum$deaths)*0.75,0)
y_max <- round(max(df_ytd_sum$deaths)*1.05,0)

# plot
b <- ggplot(df_ytd_sum, aes(x=year, y=deaths)) +
  geom_bar(stat="identity", fill="steelblue") +
  coord_cartesian(ylim = c(y_min, y_max)) + 
  geom_text(aes(label=deaths_label), vjust=1.6, color="white",
            position = position_dodge(0.9), size=3.0) +
  ggtitle("Year to Date US Deaths Due to Any Cause")
b
