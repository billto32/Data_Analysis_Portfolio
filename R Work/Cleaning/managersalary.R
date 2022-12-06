library(tidyverse)
library(janitor)
library(data.table)

salary_sur <- read_csv("Manager Salary Survey.csv")
str(salary_sur)

#Tidy
salary_sur1 <- salary_sur %>% 
  clean_names() %>% 
  select(-if_your_job_title_needs_additional_context_please_clarify_here,-if_your_income_needs_additional_context_please_provide_it_here,-x19,-x20,-x21,-x22,-x23,-x24) %>% 
  setnames(old = c("timestamp", "how_old_are_you",
                          "what_industry_do_you_work_in","what_is_your_annual_salary_youll_indicate_the_currency_in_a_later_question_if_you_are_part_time_or_hourly_please_enter_an_annualized_equivalent_what_you_would_earn_if_you_worked_the_job_40_hours_a_week_52_weeks_a_year",
                          "how_much_additional_monetary_compensation_do_you_get_if_any_for_example_bonuses_or_overtime_in_an_average_year_please_only_include_monetary_compensation_here_not_the_value_of_benefits",
                          "please_indicate_the_currency", "if_other_please_indicate_the_currency_here",
                          "what_country_do_you_work_in","if_youre_in_the_u_s_what_state_do_you_work_in",
                          "what_city_do_you_work_in","how_many_years_of_professional_work_experience_do_you_have_overall",
                          "how_many_years_of_professional_work_experience_do_you_have_in_your_field",
                          "what_is_your_highest_level_of_education_completed","what_is_your_gender",
                          "what_is_your_race_choose_all_that_apply"),
          new = c("date", "age","industry","annual_salary","other_monetary_salary","currency",
             "other_currency","country","state","city","work_experience", "field_experience", "education",
             "gender","race"), skip_absent = TRUE) %>% 
  filter(!is.na(annual_salary)) %>% #Measuring salaries, no NA
  mutate(across(where(is.character)),
    gender = recode_factor(gender, 
                              "Other or prefer not to answer" = "NA",
                              "Prefer not to answer" = "NA"),
    country = tolower(country), #normalize country
    country = gsub("\\b([a-z])", "\\U\\1", country, perl=TRUE),
    country = gsub("\\.","", country),
    race = sub("\\,.*", "",race))#Filter out multiple race choices 
 

View(salary_sur1)
head(salary_sur1)
colnames(salary_sur1)
str(salary_sur1)
unique(salary_sur1$race)


ss <- salary_sur1 %>% 
  mutate(country = tolower(country),
         country = gsub("\\b([a-z])", "\\U\\1", country, perl=TRUE),
         country = gsub("\\.","", country)
         )
View(ss)

country = case_when(when %in% c("Us","Usa","United States","United States of America","The United States","United State Of America","United Stated","United Statws","U S","United Sates","United Sates","United States Is America","Usa, But For Foreign Gov'T"))

str_replace_all(ss$country, ("^U[a-zA-z][a-zA-z]$", "USA"),("^U[a-zA-z]$"), "USA" )
stri_replace_all_regex(ss$country,)
ss %>% 
  amatch()

str_extract(ss, regex("usa?", ignore_case = TRUE))
str_extract(ss, "U(sa|as)")

unique(ss$country)

View(ss)
salary_sur1[salary_sur1 == "US"] 
