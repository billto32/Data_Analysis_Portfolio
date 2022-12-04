library(tidyverse)
#Visualize with categorical
ggplot(data = diamonds )+
  geom_bar(mapping = aes(cut))
diamonds %>% 
  count(cut)
#Visualize with contious
ggplot(data = diamonds)+
  geom_histogram(mapping = aes(x = carat), binwidth = .5)
diamonds %>% 
  count(cut_width(carat, 0.5))
smaller <- diamonds %>% 
  filter(carat < 3)
ggplot(data = smaller, mapping = aes(x = carat))+
  geom_histogram(binwidth = 0.1)
ggplot(data = smaller, mapping = aes(x = carat))+
  geom_histogram(binwidth = 0.1)+
  facet_wrap(~cut)
#Using multiple historgrams with freqpoly instead
ggplot(data = smaller, mapping = aes(x = carat, color = cut))+
  geom_freqpoly(binwidth = 0.1)
#
ggplot(data = smaller, mapping = aes(x = carat))+
  geom_histogram(binwidth = 0.01)
#Why are there more diamonds at whole carats and common fractions of carats?
#Why are there more diamonds slightly to the right of each peak than there are slightly to the left of each peak?
#Why are there no diamonds bigger than 3 carats?
View(diamonds)
diamonds %>% 
  count(cut_width(carat,0.1))
ggplot(data = faithful, mapping = aes(x = eruption))+
  geom_histogram(binwidth = .25)
#Zoom in
ggplot(diamonds)+
  geom_histogram(mapping = aes(x = y), binwidth = 0.5)+
  coord_cartesian(ylim = c(0,50))
unusal <- diamonds %>% 
  filter(y < 3 | y >20) %>% 
  select(price,x ,y , z) %>% 
  arrange(y)
unusal
# Size 0 of diamonds impossible, 32mm and 59 mm too large
summary(select(diamonds, x , y, z))
ggplot(diamonds) +
  geom_histogram(mapping = aes(x = x), binwidth = 0.25)+
  coord_cartesian(xlim = c(0,15))
ggplot(diamonds)+
  geom_histogram(mapping = aes(x = y), binwidth = 0.25)+
  coord_cartesian(xlim = c(0,15))
ggplot(diamonds)+
  geom_histogram(mapping = aes(x = z), binwidth = 0.25)+
  coord_cartesian(xlim = c(0,15))
#X, Y are larger than Z; outliers ; right skewed; spiky
summary(select(diamonds, x, y, z))
#Data entry errors or undocumented conventions. Rounding possible
filter(diamonds, x == 0 | y == 0 | z == 0)

diamonds %>% 
  arrange(desc(y)) %>% 
  head()
diamonds %>% 
  arrange(desc(z)) %>% 
  head()
ggplot(diamonds, aes(x = x, y = y)) +
  geom_point()
#Spiking at certain integers, possibly used more often than others
filter(diamonds, x > 0 , x < 10) %>% 
  ggplot() +
  geom_histogram(mapping = aes(x = x), binwidth = 0.01)+
  scale_x_continuous(breaks = 1:10)
filter(diamonds, z > 0 , z < 10) %>% 
  ggplot() +
  geom_histogram(mapping = aes(x = z), binwidth = 0.01)+
  scale_x_continuous(breaks = 1:10)
summarise(diamonds, mean(x > y), mean(x > z), mean(y > z))
#Z is always smaller than x and y, inserting into jewelry
ggplot(diamonds, mapping = aes(x = price))+
  geom_histogram(binwidth = 100, center = 0)
#Zoom into price
ggplot(filter(diamonds, price < 2500), aes(x = price))+
  geom_histogram(binwidth = 10, center = 0)
#No diamonds sold at 1500, high spike around 750
diamonds %>% 
  mutate(ending = price%%100) %>% 
  ggplot(aes(x = ending)) +
  geom_histogram(binwidth = 1)
diamonds %>% 
  filter(carat >= .99 , carat <= 1) %>% 
  count(carat)
#More than 70x amount of 1 carat compared to .99
#Possibly some are rounded up or clerical error in diamond extraction
diamonds %>% 
  filter(carat >= .9, carat <= 1.1) %>% 
  count(carat) %>% 
  print(n = Inf)
#geom_bar counts NA as a separate category, histogram does not count
#na.rm removes na values when calculatin sum and mean
ggplot(diamonds)+
  geom_bar(mapping = aes(x = cut))
ggplot(data = diamonds, mapping = aes(x = price, y = ..density..))+
  geom_freqpoly(mapping = aes(color = cut), binwidth = 500)
#Fair diamonds have the highest average price
ggplot(data = diamonds, mapping = aes(x = cut, y =price))+
  geom_boxplot()
#Higher quality cuts are have lower prices on average
nycflights13::flights %>% 
#What needs to be measured? Is flight cancelled, what time?
mutate(
  cancelled = is.na(dep_time),
  sched_hour = sched_dep_time%/%100,
  sched_min = sched_dep_time%%100,
  sched_dep_time = sched_hour+sched_min / 60) %>% 
ggplot()+
  geom_boxplot(mapping = aes(x = cancelled, y = sched_dep_time)
)
#Correlation between price and carat
ggplot(diamonds, aes(x = carat, y = price))+
  geom_point()
#Too much data, use a box plot
ggplot(diamonds, aes(x = carat, y = price))+
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)), orientation = "x")
diamonds %>% 
  mutate(color = fct_rev(color)) %>% 
  ggplot(aes(x = color, y = price))+
  geom_boxplot()
#Negative relationship between color and price
ggplot(diamonds)+
  geom_boxplot(aes(x = clarity , y = price))
#Negative relationship between clarity and price
ggplot(diamonds)+
  geom_boxplot(aes(x = cut , y = price))
#Negative relationship between cut and price.
#Larges diamonds "Fair" have lowest price. Smaller diamonds require better cut
install.packages("ggstance")
ggplot(data = mpg)+
  geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy))+
  coord_flip()
ggplot(data = mpg)+
  geom_boxplot(mapping = aes(y = reorder(class, hwy, FUN = median), x = hwy ))
install.packages("lvplot")
library("lvplot")
ggplot(diamonds, aes(x = cut, y = price))+
  geom_lv()
diamonds %>% 
  count(color, cut) %>% 
  group_by(cut) %>% 
  mutate(prop = n/ sum(n)) %>% 
  ggplot(mapping = aes(x = color, y = cut))+
  geom_tile(mapping = aes(fill = prop))
ggplot(data = diamonds)+
  geom_count(mapping = aes(x = cut, y = color))
diamonds %>% 
  count(color, cut) %>%
  group_by(cut) %>% 
  mutate(prop = n/sum(n)) %>% 
  ggplot(mapping = aes(x = color, y = cut))+
  geom_tile(mapping = aes(fill = prop))

flights %>%
  group_by(month, dest) %>%
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  ggplot(aes(x = factor(month), y = dest, fill = dep_delay)) +
  geom_tile() +
  labs(x = "Month", y = "Destination", fill = "Departure Delay")

ggplot(data = smaller)+
  geom_bin2d(mapping = aes(x = carat , y = price))
install.packages("hexbin")
ggplot(data = smaller)+
  geom_hex(mapping = aes(x = carat, y = price))
ggplot(data = smaller, mapping = aes(x = carat, y = price))+
  geom_boxplot(mapping = aes(group = cut_width(carat,0.1)))
ggplot(diamonds, aes(x = cut_width(price,2000,boundary = 0) , y = carat))+
  geom_boxplot(varwidth = TRUE)+
  coord_flip()
ggplot(diamonds, mapping = aes(x = carat, y = price))+
  geom_hex()+
  facet_wrap(~cut, ncol = 1)
ggplot(diamonds, mapping = aes(x = cut_number(carat, 10), y = price, color=cut))+
  geom_boxplot()
