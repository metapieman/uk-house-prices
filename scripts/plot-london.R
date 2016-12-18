#! /usr/bin/R

library(dplyr)
library(ggplot2)

args <- commandArgs(trailingOnly=TRUE)
stat <- args[1]
datafile <- sprintf("data/summaries_by_stat/%s.csv", args[1])

data <- read.csv(datafile)
data$Month <- as.Date(data$Month)

london_period <-
  data %>% filter(
        LocalAuthority == "BARKING AND DAGENHAM" |
        LocalAuthority == "BARNET" |
        LocalAuthority == "BEXLEY" |
        LocalAuthority == "BRENT" |
        LocalAuthority == "BROMLEY" |
        LocalAuthority == "CAMDEN" |
        LocalAuthority == "CITY OF LONDON" |
        LocalAuthority == "CITY OF WESTMINSTER" |
        LocalAuthority == "CROYDON" |
        LocalAuthority == "EALING" |
        LocalAuthority == "ENFIELD" |
        LocalAuthority == "EPPING FOREST" |
        LocalAuthority == "GREENWICH" |
        LocalAuthority == "HACKNEY" |
        LocalAuthority == "HAMMERSMITH AND FULHAM" |
        LocalAuthority == "HARINGEY" |
        LocalAuthority == "HARROW" |
        LocalAuthority == "HAVERING" |
        LocalAuthority == "HILLINGDON" |
        LocalAuthority == "HOUNSLOW" |
        LocalAuthority == "ISLINGTON" |
        LocalAuthority == "KENSINGTON AND CHELSEA" |
        LocalAuthority == "KINGSTON UPON THAMES" |
        LocalAuthority == "LAMBETH" |
        LocalAuthority == "LEWISHAM" |
        LocalAuthority == "MERTON" |
        LocalAuthority == "NEWHAM" |
        LocalAuthority == "REDBRIDGE" |
        LocalAuthority == "RICHMOND UPON THAMES" |
        LocalAuthority == "SOUTHWARK" |
        LocalAuthority == "SUTTON" |
        LocalAuthority == "TOWER HAMLETS" |
        LocalAuthority == "WALTHAM FOREST" |
        LocalAuthority == "WANDSWORTH"
    ) %>%
  filter(Age == "Period") %>%
  filter(Month != max(data$Month))


y_label_map = c()
y_label_map["len"] = "Number_of_transactions_by_month"
y_label_map["mean"] = "Mean_price_by_month"
y_label_map["median"] = "Median_price_by_month"

y_label <- y_label_map[stat]

colnames(london_period)[which(colnames(london_period) == 'Price')] <- y_label

london_period_flats <- london_period%>% filter(Type=="Flat")
london_period_houses <- london_period%>% filter(Type=="House")

width <- 17
height <- 15

ggplot(london_period_flats, aes_string(x="Month", y=y_label)) +
  geom_line(aes(color=Type)) +
  facet_wrap(~LocalAuthority, scales="free")

ggsave(sprintf('plots/london_period_flats_%s.tmp.pdf', stat), width=width, height=height)

ggplot(london_period_houses, aes_string(x="Month", y=y_label)) +
  geom_line(aes(color=Type)) +
  facet_wrap(~LocalAuthority, scales="free")

ggsave(sprintf('plots/london_period_houses_%s.tmp.pdf', stat), width=width, height=height)
