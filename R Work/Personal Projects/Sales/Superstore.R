library(tidyverse)
library(skimr)
library(janitor)
library(lubridate)
library(readxl)
library(here)
library(kableExtra)

salesdata <- read_csv("Superstore.csv")
skim(salesdata)
colSums(is.na(salesdata))
which(duplicated(salesdata))
View(salesdata1)

#Tidy
salesdata1 <- salesdata %>% 
  clean_names() %>% 
  mutate(order_date = as.Date(order_date, format = "%m/%d/%Y"),
         ship_date = as.Date(ship_date, format = "%m/%d/%Y"),
         order_year = lubridate::year(order_date)) %>% 
  select(-row_id)


#Pivot Tables
salesdata1 %>% 
  group_by(sub_category) %>% 
  summarise(total_units = n()) %>% 
  arrange(desc(total))

salesdata1 %>% 
  group_by(sub_category) %>% 
  summarise(total_units = n(), total_sales = sum(sales)) %>% 
  arrange(desc(total_sales))

salesdata1 %>% 
  group_by(category, order_year) %>% 
  summarise(total_units = n(), total_sales = sum(sales))

salesdata1 %>% 
  group_by(category, region) %>% 
  summarise(total_units = n(), total_sales = sum(sales))

salesdata1 %>% 
  group_by(state, region) %>% 
  summarise(total_units = n(), total_sales = sum(sales)) %>% 
  filter(region == "West", total_sales > 100000 ) %>% 
  arrange(desc(total_sales))
