library(tidyverse)
library(skimr)
library(janitor)
library(ggplot2)
library(treemapify)
library(gridExtra)

hr <- read_csv("HR_Attrition.csv")

#Variable types/ Check data 
skim(hr)
##1470 rows, no missing data, positive skewed
##Check nulls
colSums(is.na(hr)) > 0
## which(is.na(hr))
which(duplicated(hr)) # Duplicates

#Tidy 
##Drop columns, constant variables unecessary
levels(as.factor(hr$Over18))
table(as.factor(hr$Over18))
summary(hr$StandardHours)
summary(hr$EmployeeCount)

hr1 <- hr %>% 
  clean_names() %>% 
  #Reorganizing column names, recode departments
  mutate(job_level = factor(job_level),
         performance_rating = factor(performance_rating),
         department = recode_factor(department, 
                                    "Research & Development" = "R&D",
                                    "Human Resources" = "HR"
                                    ),
  #bining age groups
         age_group = case_when(
           age > 17 & age <= 25 ~ "18-25",
           age > 25 & age <= 35 ~ "26-35",
           age > 35 & age <= 45 ~ "36-45",
           age > 45 & age <= 55 ~ "46-55",
           age > 55 & age <= 65 ~ "56-65",        
           age > 65             ~ "> 65"
         )
  ) %>% 
  mutate(age_group = factor(age_group,
    level = c("18-25","26-35", "36-45","46-55","56-65","> 65")
  )) %>% 
  select(-over18, -standard_hours, -employee_count)

hr1 %>% glimpse()
View(hr2)

#Check attrition counts
##237 employees left the company
hr1 %>% 
  count(attrition)
##16% of employee left the company while 84% stayed
hr1 %>% 
  group_by(attrition) %>% 
  summarise(total = n()) %>% 
  mutate(prop = (total / sum(total)) * 100) %>% 
  arrange(desc(prop))
  
hr1 %>% 
  group_by(attrition) %>% 
  ggplot(mapping = aes(x = attrition))+
  geom_bar()+
  coord_flip()

##Treemap attempt
hr1 %>% 
  group_by(attrition) %>% 
  summarise(total = n()) %>% 
  mutate(prop = (total / sum(total)) * 100) %>% 
  arrange(desc(prop)) %>% 
  ggplot(mapping = aes(area = prop , fill = attrition, label = prop))+
  geom_treemap()+
  geom_treemap_text(color = "white",
                    place = "centre",
                    size = 5)

#Demographics Analysis
hr_demo <- hr1%>% 
  select(age, gender, marital_status, education, education_field, distance_from_home) %>% 
  skim()
hr_demo
##Average age is 37, 

#Professional Background
hr_pb <- hr1 %>% 
  select(total_working_years, num_companies_worked, years_at_company,
         years_in_current_role, years_since_last_promotion, 
         years_with_curr_manager)
  skim(hr_pb)
##Average total working experience is 11, decrease afterwards
##Oldest working age at 10 or less years with avg of 7
##Average time with manager is 4 years with 4 years at their current role
##Majority of employees have had a promotion within 2 years

hr_pb %>% count(num_companies_worked)
##0 (197) number of companies impossible, meaning only worked at ibm. Those with 1 company should include ibm only as well
hr_pb %>% 
  filter(years_at_company == total_working_years) %>% 
  count(num_companies_worked)
##474 people worked at ibm only, intepretation question error
hr_pb %>% filter(years_at_company != total_working_years) %>% 
  count(num_companies_worked)
## 47 worked at ibm only

ptwy <- ggplot(hr_pb, mapping = aes(total_working_years))+
  geom_density()+
  ggtitle("Total Working Years")
pncw <- ggplot(hr_pb, mapping = aes(num_companies_worked))+
  geom_density()+
  ggtitle("Number of Companies Worked")
pyac <- ggplot(hr_pb, mapping = aes(years_at_company))+
  geom_density()+
  ggtitle("Years At Company")
pyicr <- ggplot(hr_pb, mapping = aes(years_in_current_role))+
  geom_density()+
  ggtitle("Years At Current Role")
pyslp <- ggplot(hr_pb, mapping = aes(years_since_last_promotion))+
  geom_density()+
  ggtitle("Years Since Last Promotion")
pywcm <- ggplot(hr_pb, mapping = aes(years_with_curr_manager))+
  geom_density()+
  ggtitle("Years With Current Manager")
grid.arrange(ptwy, pncw, pyac, pyicr, pyslp, pywcm, ncol = 2)

#Job Descriptors
hr_jd <- hr1 %>% 
  select(department, job_involvement, job_level, job_role, 
         business_travel, training_times_last_year, over_time)
skim(hr_jd)
##R&D accounts for majority of the company 

jd_bt <- hr_jd %>% 
  ggplot(aes(x = fct_infreq(business_travel), fill = business_travel))+
  geom_bar()+
  ggtitle("Business Travel")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())
jd_d <- hr_jd %>% 
  ggplot(aes(x = fct_infreq(department), fill = department))+
  geom_bar()+
  ggtitle("Department")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())
jd_jr <- hr_jd %>% 
  ggplot(aes(x = fct_infreq(job_role), fill = job_role))+
  geom_bar()+
  ggtitle("Job Role")+
  coord_flip()+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())

jd_jl <- hr_jd %>% 
  ggplot(aes(x = fct_infreq(job_level), fill = job_level))+
  geom_bar()+
  ggtitle("Job Level")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())

jd_ji <- hr_jd %>% 
  ggplot(aes(x = job_involvement))+
  geom_bar()+
  ggtitle("Job Involvment")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())

jd_tly <- hr_jd %>% 
  ggplot(aes(x = training_times_last_year))+
  geom_bar()+
  ggtitle("Training Last Year")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())

jd_d <- hr_jd %>% 
  ggplot(aes(x = fct_infreq(department), fill = department))+
  geom_bar()+
  ggtitle("Department")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())
jd_ot <- hr_jd %>% 
  ggplot(aes(x = fct_infreq(over_time), fill = over_time))+
  geom_bar()+
  ggtitle("Over Time")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())

grid.arrange(jd_jr, arrangeGrob(jd_ji, jd_tly), arrangeGrob(jd_ot,jd_jl),
             arrangeGrob(jd_bt, jd_d), ncol = 2)

#Finance
hr_f <- hr1 %>% select(stock_option_level, daily_rate, hourly_rate, monthly_rate, percent_salary_hike) %>% 
  skim()

f_dr <- ggplot(hr_f, aes(log(daily_rate))) + 
  geom_density() +
  ggtitle("Daily Rate") + 
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())
f_hrr <- ggplot(hr_f, aes(log(hourly_rate))) + 
  geom_density() +
  ggtitle("Hourly Rate") + 
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())
f_mr <- ggplot(hr_f, aes(log(monthly_rate))) + 
  geom_density() +
  ggtitle("Monthly Rate") + 
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())
f_psh <- ggplot(hr_f, aes(log(percent_salary_hike))) + 
  geom_density() +
  ggtitle("Percent Salary Hike") + 
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())
f_mi <- ggplot(hr_f, aes(log(monthly_income))) + 
  geom_density() +
  ggtitle("Monthly Income") + 
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())
f_so <- hr_f %>% 
  ggplot(aes(x = stock_option_level, fill = stock_option_level))+
  geom_bar()+
  ggtitle("Stock Option Level")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())
grid.arrange(f_dr, f_hrr, f_mr, f_psh, f_mi, f_so)

#Employee Ratings/ Satisfactions
hr_sat <- hr1 %>% 
  select(environment_satisfaction, job_satisfaction, performance_rating,
         relationship_satisfaction, work_life_balance)
skim(hr_sat)                         

hr_sat %>% 
  count(environment_satisfaction) %>% 
  mutate(prop = round(prop.table(n),2))

sat_es <- hr_sat %>% 
  ggplot(aes(x = environment_satisfaction, fill = environment_satisfaction))+
  geom_bar()+
  ggtitle("Environment Satisfaction")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())
sat_js <- hr_sat %>% 
  ggplot(aes(x = job_satisfaction, fill = job_satisfaction))+
  geom_bar()+
  ggtitle("Job Satisfaction")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())
sat_pr <- hr_sat %>% 
  ggplot(aes(x = performance_rating, fill = performance_rating))+
  geom_bar()+
  ggtitle("Performance Rating")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())

sat_rs <- hr_sat %>% 
  ggplot(aes(x = relationship_satisfaction, fill = relationship_satisfaction))+
  geom_bar()+
  ggtitle("Relationship Satisfaction")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())
sat_wlb <- hr_sat %>% 
  ggplot(aes(x = work_life_balance, fill = work_life_balance))+
  geom_bar()+
  ggtitle("Work Life Balance")+
  theme(legend.position="none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank())
grid.arrange(sat_es, sat_js, sat_rs, sat_wlb, sat_pr)
