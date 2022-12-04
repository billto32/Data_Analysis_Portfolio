library(tidyverse)
library(skimr)
emp_attr <- read_csv("HR_Attrition.csv")
#Basic overview
head(emp_attr)
skim(emp_attr)
#Attrition
att <- emp_attr %>% 
  group_by(Attrition) %>% 
  summarise(count = n())
att
##Attrition perct
att_prop <- emp_attr %>% 
  group_by(Attrition) %>% 
  summarise(total = n()) %>% 
  mutate(prop = (total / sum(total)) * 100)
att_prop
##Plotting
ggplot(data = att_prop, 
       aes(fill = Attrition, x = Attrition, y = prop)) + 
  geom_bar(position = "stack", stat = "identity") + 
  scale_fill_manual(values = c("red", "green")) + 
  labs(title = "Total Employee Attrition")
#Gender Breakdown
att_gender <- emp_attr %>% 
  group_by(Attrition, Gender) %>% 
  summarise(count = n())
##Pivot
att_gender %>% 
  pivot_wider(names_from = "Gender", values_from = "count")
##Prop
att_gprop <- emp_attr %>% 
  group_by(Attrition, Gender) %>% 
  summarise(total = n()) %>% 
  mutate(prop = (total / sum(total)) * 100) 
att_gprop
#Income
ggplot(emp_attr, mapping = 
         aes(x = Gender, y = MonthlyIncome, fill = Gender)) + 
  geom_boxplot() + 
  facet_wrap(~Attrition)
#Departments
ggplot(emp_attr, mapping = 
         aes(x = Attrition, y = MonthlyIncome, fill = Attrition))+
  geom_boxplot()+
  facet_wrap(~Gender~Department)
##Higher levels of attrition due to income except in Sales