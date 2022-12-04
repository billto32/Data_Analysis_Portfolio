library(tidyverse)
x1 <- c("Dec","Nov","Jun")
x2 <- c("Dex","Nom","Jun")
sort(x1)
month_levels <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)

y1 <- factor(x1, levels = month_levels)
y1
y2 <- parse_factor(x2, levels = month_levels)
y2

#Omitting levels takes data in alphabethical
factor(x1)

#Factor in order
f1 <- factor(x1, levels = unique(x1))
f1
f2 <- x1 %>% 
  factor() %>% 
  fct_inorder()
f2
####Working data
gss_cat %>% 
  count(race)
gss_cat %>% 
  ggplot(gss_cat, mapping = aes(race))+
  geom_bar()+
  #Show dropped values
  scale_x_discrete(drop = FALSE)
View(gss_cat)
#Relationship of income
gss_cat %>% 
  ggplot(gss_cat, mapping = aes(rincome))+
  geom_bar()+
  #Fix the text lines
  theme(axis.text.x = element_text(angle = 40, hjust = 1))
##Alternative
gss_cat %>% 
  ggplot(gss_cat, mapping = aes(rincome))+
  geom_bar()+
  coord_flip()
##Improving the plot
gss_cat %>%
  #Filter out NA
  filter(!rincome %in% c("Not applicable", "Refused", "Don't know", "No answer")) %>% 
  mutate(rincome = 
           fct_recode(rincome, "Less than 10000" = "Lt $1000")) %>% 
  #Recategorizing Lt
  #Now plot 
  ggplot(gss_cat,mapping = aes(rincome))+
  geom_bar()+
  coord_flip()+
  #Labels naming
  scale_y_continuous("Total Responses") +
  scale_x_discrete("Income Level")

#Relgion
gss_cat %>% 
  count(relig) %>% 
  arrange(desc(n)) %>% 
            head()

levels(gss_cat$denom)
gss_cat %>% 
  filter(!denom %in% c("No answer", "Not applicable", "Other", "Don't Know", "No denomination")) %>% 
  count(relig)
gss_cat %>% 
  count(relig, denom) %>% 
  ggplot(mapping = aes(x = relig, y = denom, size = n))+
  geom_point()+
  theme(axis.text.x = element_text(angle = 90))
##TV hours and religon
religon_summary <- gss_cat %>% 
  group_by(relig) %>% 
  summarise(age = mean(age, na.rm = TRUE),
            tvhours = mean(tvhours, na.rm = TRUE),
            n = n())
###Use fct_reorder for better viz of trend
ggplot(religon_summary, mapping = 
         aes(x = tvhours, y = fct_reorder(relig,tvhours)))+
  geom_point()
###Using mutate, cleaner look
religon_summary %>% 
  mutate(relig = fct_reorder(relig, tvhours)) %>% 
  ggplot(mapping = aes(x = tvhours, y = relig))+
  geom_point()
###Checking income and tv
rincome_summary <- gss_cat %>% 
  group_by(rincome) %>%
  #Fixing order of NA
  mutate(rincome = fct_relevel(rincome, "Not applicable")) %>% 
  summarise(age = mean(age, na.rm = TRUE),
            tvhours = mean(tvhours, na.rm = TRUE),
            n = n()) %>% 
  ggplot(mapping = aes(x = age, y = rincome))+
  geom_point()
rincome_summary

#Marital Status
gss_cat %>% 
  #Reorder least to greatest with fct_infreq
  mutate(marital = marital %>% fct_infreq() %>% fct_rev()) %>% 
  ggplot(aes(marital))+
  geom_bar()
by_age <- gss_cat %>% 
  filter(!is.na(age)) %>% 
  count(age, marital) %>% 
  group_by(age) %>% 
  mutate(prop = n/sum(n),
         color = fct_reorder2(marital, age, prop)) %>% 
  ggplot(by_age, mapping = aes(x = age, y = prop, color = marital ))+
  geom_line(na.rm = TRUE)
by_age

summary(gss_cat[["tvhours"]])
gss_cat %>% 
  filter(!is.na("tvhours")) %>% 
  ggplot(mapping = aes(x = tvhours))+
  geom_histogram(binwidth = 1)
gss_cat %>% 
  ggplot(aes(x = marital))+
  geom_bar()+
  theme(axis.text.x = element_text(angle = 25))
gss_cat %>% 
  ggplot(aes(x = race))+
  geom_bar()+
  scale_x_discrete(drop = FALSE)
gss_cat %>% 
  ggplot(aes(x = relig))+
  geom_bar()+
  coord_flip()

#Partyid
gss_cat %>% 
  count(partyid) %>% 
  arrange(desc(n)) %>% 
  head()

gss_cat %>% 
  mutate(partyid = 
           fct_recode(partyid,
              "Republican, strong"    = "Strong republican",
              "Republican, weak"      = "Not str republican",
              "Independent, near rep" = "Ind,near rep",
              "Independent, near dem" = "Ind,near dem",
              "Democrat, weak"        = "Not str democrat",
              "Democrat, strong"      = "Strong democrat")) %>% 
  count(partyid)  

#Recateogrizing levels
gss_cat %>%
  mutate(partyid = 
           fct_collapse(partyid,
                  other = c("No answer", "Don't know", "Other party"),
                  rep = c("Strong republican", "Not str republican"),
                  ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                  dem = c("Not str democrat", "Strong democrat")
)) %>%
  count(partyid)  
##Change over time by party
gss_cat %>%
  #Reorganize party
  mutate(partyid = 
           fct_collapse(partyid,
                other = c("No answer", "Don't know", "Other party"),
                rep = c("Strong republican", "Not str republican"),
                ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                dem = c("Not str democrat", "Strong democrat")
           )) %>%
  #Find year
  count(year, partyid) %>% 
  group_by(year) %>% 
  #Calc probability, reorder colors
  mutate(p = n / sum(n),
         color = fct_reorder2(partyid, year, p)) %>% #calc prob
  #Plot
  ggplot(mapping = aes(x = year, y = p, color = color))+
  geom_point()+
  geom_line()+
  labs(color = "Party ID")
  