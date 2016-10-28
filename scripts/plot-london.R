#! /usr/bin/R

library(dplyr)
library(ggplot2)

data <- read.csv('data/summaries_by_stat/median.csv')
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

london_period_flats <- london_period%>% filter(Type=="Flat")
london_period_houses <- london_period%>% filter(Type=="House")

width <- 17
height <- 15

ggplot(london_period_flats, aes(x=Month, y=Price)) +
  geom_line(aes(color=Type)) +
  facet_wrap(~LocalAuthority, scales="free")

ggsave('plots/london_period_flats.tmp.pdf', width=width, height=height)

ggplot(london_period_houses, aes(x=Month, y=Price)) +
  geom_line(aes(color=Type)) +
  facet_wrap(~LocalAuthority, scales="free")

ggsave('plots/london_period_houses.tmp.pdf', width=width, height=height)
