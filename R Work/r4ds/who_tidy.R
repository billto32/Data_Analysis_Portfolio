library(tidyverse)
#Glimpse into Who df
head(who)
#country, iso2, iso3 repeating country names
  # year is a variable
#Lots of redundant columns and na values
#Check into column names
colnames(who)
#How many na values
sum(is.na(who))
  #329,394 missing values
#Building up the pipe
#Drop the na, new df
who_clean <- who %>% 
  pivot_longer(
    cols = new_sp_m014:newrel_f65,
#All other columns seem to be values
    names_to = "key", 
    values_to = "cases",
    values_drop_na = TRUE
  )
who_clean %>% 
  count(key)
#Parse data to find directory
colnames(who)
#newrel error
who_clean2 <- who_clean %>% 
  mutate(key = stringr::str_replace(key, "newrel", "new_rel"))
#Breakup the key into new, type, sexage -> drop redundant -> sex age
who_clean3 <- who_clean2 %>% 
  separate(key, c("new", "type", "sexage"), sep = "_")
#Colnames checked the new column earlier or :
#Check iso3, iso2
select(who_clean3, country, iso2 , iso3) %>% 
  #distinct countries
  distinct() %>% 
  group_by(country) %>% 
  #Where count > 1
  filter(n() > 1)
#
who_clean3 %>% 
  count(new)
who_clean4 <- who_clean3 %>% 
  select(-iso2, -iso3, -new)
who_cleanf <- who_clean4 %>% 
  separate(sexage, c("sex", "age"), sep = 1)

#Build complete pipe
who_t <- who %>% 
  pivot_longer(
    cols = new_sp_m014:newrel_f65,
    names_to = "key",
    values_to = "cases",
    values_drop_na = TRUE
    ) %>% 
  mutate(key = stringr::str_replace(key, "newrel", "new_rel")
    ) %>% 
  separate(key, c("new", "type", "sexage")
    ) %>% 
  select(-new, -iso2, -iso3) %>% 
  separate(sexage, c("sex", "age"), sep = 1)
who_t  
# How do 0's effect usage of na.rm vs values_drop_na
who_clean %>% 
  filter(cases == 0) %>% 
  nrow()
#11,080 values of 0, possibily meaning 0 is no TB
#
pivot_longer(who, 
             c(new_sp_m014:newrel_f65), 
             names_to = "key", 
             values_to = "cases") %>% 
  group_by(country, year) %>% 
  mutate(prop_missing = sum(is.na(cases)) / n()) %>% 
  filter(prop_missing > 0, prop_missing < 1)
#Check for implicit missing values
who %>% 
  complete(country, year) %>% 
  nrow()
#Values of those completed cases are greater than rows in who meaning
#implict values
#Anti-join finding relational

anti_join(complete(who, country, year), who, by = c("country", "year")
  )%>% 
  select(country, year) %>% 
  group_by(country) %>% 
  summarise(min_year = min(year), max_year = max(year))
#Implicit values meaning that TB not existing within at year

#Relationship between country, year, and sex
who_cleanf %>% 
  group_by(country, year, sex) %>% 
  filter(year > 1995) %>% 
  summarise(cases = sum(cases)) %>% 
  #relationship between country and sex united
  unite(country_sex , country, sex , remove = FALSE) %>% 
  ggplot(who_cleanf, mapping = aes(x = year , y = cases, group = country_sex, color = sex))+
  geom_line()
