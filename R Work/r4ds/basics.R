install.packages("nycflights13")
library(nycflights13)
library(tidyverse)

nycflights13::flights
View(flights)

jan <- filter(flights, month == 1, day == 1)

#flights in nov and dec
nov_dec <- filter(flights, month %in% c(11,12))
nov_dec

2hrplus_delay <- filter(flights, !(arr_delay > 120 | dep_delay > 120))

filter(flights, arr_delay >= 120)
filter(flights, dest == "IAH" | dest == "HOU")
#filter(flights, dest %in% c("IAH","HOU"))
airlines
filter(flights, carrier %in% c("DL","AA","UA"))

filter(flights, month %in% 6:9)
#filter(flights, month >= 6, month <= 9)
#filter(flights, between(month,6,9))
filter(flights, arr_delay > 120 , dep_delay <=0 )
filter(flights, dep_delay >=60, dep_delay - arr_delay > 30 )

summary(flights$dep_delay)
filter(flights, is.na(dep_time))
filter(flights, dep_time <=600 | dep_time == 2400)
filter(flights, dep_time %% 2400 <= 600)

#Arranging
arrange(flights, year, month, day)
arrange(flights, desc(dep_time))
#NA First
arrange(flights, dep_time) %>% tail()
arrange(flights, desc(is.na(dep_time), dep_time))
arrange(flights, desc(is.na(dep_time), dep_time))
arrange(flights, desc(dep_delay))
arrange(flights, desc(distance/air_time))

#Mutate
flights_sml <- select(flights, year:day, ends_with("delay"),distance,air_time)
flights_sml

mutate(flights_sml, 
       gain = dep_delay - arr_delay, 
       speed = distance / air_time * 60,
       hours = air_time / 60,
       gain_per_hour = gain / hours)

transmute(flights_sml, 
       gain = dep_delay - arr_delay, 
       speed = distance / air_time * 60,
       hours = air_time / 60,
       gain_per_hour = gain / hours)

transmute(flights,
          dep_time,
          hour = dep_time %/% 100,
          min = dep_time %% 100)

#Create a function 
times2mins <- function(x){(x %/% 100 *60 + x %% 100) %%1440}

flighttimes <- mutate(flights,
                      dep_time_mins = times2mins(dep_time),
                      sched_dep_mins = times2mins(dep_time))  
select(flighttimes, dep_time, dep_time_mins, sched_dep_mins)

transmute(flights,
          dep_time,
          dep_hour = dep_time%/% 100,
          dep_min = (dep_time%/% 100 * 60 + dep_time %% 100) %% 1440,
          sched_dep_time,
          sched_hour = sched_dep_time%/% 100,
          sched_min = (dep_time%/% 100 * 60 + dep_time %% 100) %% 1440
          )
flights_airtime <- mutate(flights, 
                          dep_time =(dep_time %/% 100 * 60 + dep_time %%100) %% 1440,
                          arr_time = (arr_time %/% 100 * 60 + arr_time %%100) %% 1440,
                          air_time_diff = air_time - arr_time + dep_time)
nrow(filter(flights_airtime, air_time_diff !=0))
ggplot(flights_airtime, aes(x = air_time_diff)) +
  geom_histogram(binwidth = 1)
ggplot(filter(flights_airtime, dest == "LAX"), aes(x = air_time_diff))+
  geom_histogram(binwidth = 1)

flights_delay <- mutate(flights,
                        dep_delay_min_rank = min_rank(desc(dep_delay)),
                        dep_delay_row_num = row_number(desc(dep_delay)),
                        dep_delay_dense_rank = dense_rank(desc(dep_delay))
                        )
flights_delay <- filter(flights_delay,
                        !(dep_delay_min_rank > 10| 
                            dep_delay_row_num > 10| 
                            dep_delay_dense_rank > 10)
                        )
flights_delay <- arrange(flights_delay, dep_delay_min_rank)
print(select(flights_delay, month, day, carrier, flight, dep_delay, dep_delay_min_rank))

summarise(flights, delay = mean(dep_delay, na.rm = TRUE))

by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))

by_dest <- group_by(flights, dest)
delay <- summarise(by_dest,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE))
delay <- filter(delay, count > 20, dest != "HNL")
ggplot(data = delay, map = aes(x = dist, y = delay))+
  geom_point(aes(size = count), alpha = 1/3)+
  geom_smooth(se = FALSE)

delays <- flights %>% 
  group_by(dest) %>% 
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm =TRUE)
    ) %>% 
      filter(count > 20 , dest != "HNL")
ggplot(data = delay, map = aes(x = dist, y = delay))+
  geom_point(aes(size = count), alpha = 1/3)+
  geom_smooth(se = FALSE)

flights %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay, na.rm = TRUE))

not_canceled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))
not_canceled %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay))
  
delays <- not_canceled %>% 
  group_by(tailnum) %>% 
  summarise(delay = mean(arr_delay))
ggplot(data = delays, mapping = aes(x = delay))+
  geom_freqpoly(binwidth = 10)

delays <- not_canceled %>% 
  group_by(tailnum) %>% 
  summarise(delay = mean(arr_delay, na.rm = TRUE),
  n= n())
ggplot(data = delays, mapping = aes(x = n, y = delay))+
  geom_point(alpha = 1/10)

# Less variance
delays %>% 
  filter(n > 25) %>% 
  ggplot(mapping = aes(x = n , y = delay))+
  geom_point(alpha = 1/10)

install.packages("Lahman")

batting <- as_tibble(Lahman::Batting)
batters <- batting %>% 
  group_by(playerID) %>% 
  summarise(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
    )
batters %>% 
  filter(ab > 100) %>% 
  ggplot(mapping = aes(x = ab, y = ba))+
  geom_point()+
  geom_smooth(se = FALSE)

batters %>% 
  arrange(desc(ba))

not_canceled %>% 
  group_by(year , month, day) %>% 
  summarise(
    avg_delay1 = mean(arr_delay),
    avg_delay2 = mean(arr_delay[arr_delay > 0]) #positive delay
  )
#Spread measurement
not_canceled %>% 
  group_by(dest) %>% 
  summarise(distance_sd = sd(distance)) %>% 
  arrange(desc(distance_sd))

not_canceled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first = min(dep_time),
    last = max(dep_time))
not_canceled %>% 
  group_by(dest) %>% 
  summarise(
    carriers = n_distinct(carrier)) %>% 
  arrange(desc(carriers))

not_canceled %>% 
  group_by(year, month, day) %>% 
  summarise(
    n_earlier = sum(dep_time < 500))

not_canceled %>% 
  group_by(year, month, day) %>% 
  summarise(hours_prop = mean(arr_delay > 60))

daily <- group_by(flights, year, month, day)
(per_day <- summarise(daily, flights = n()))

daily %>% 
  ungroup() %>% 
  summarise(flights = n())

not_canceled %>% 
  count(dest)  
not_canceled %>% 
  count(tailnum, wt = distance)
not_canceled %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))
not_canceled %>% 
  group_by(dest) %>% 
  summarise(n = length(dest))
not_canceled %>% 
  group_by(dest) %>% 
  summarise(n = n())
not_canceled %>% 
  group_by(tailnum) %>% 
  tally()
not_canceled %>% 
  group_by(tailnum) %>% 
  summarise(n = n())
not_canceled %>% 
  group_by(tailnum) %>% 
  summarise(n = sum(distance))
not_canceled %>% 
  group_by(tailnum) %>% 
  tally()

filter(flights, !is.na(dep_delay), is.na(arr_delay)) %>% 
  select(dep_time, dep_delay, arr_delay)

#Relationship between cancelled and flights per day
cancelled_per_day <- 
  flights %>% 
  mutate(cancelled = (is.na(arr_delay) | is.na(dep_delay))) %>% 
  group_by(year, month, day) %>% 
  summarise(
    cancelled_num = sum(cancelled),
    flights_num = n(),)
#Plot relationship between number of flights and cancelled
ggplot(cancelled_per_day)+
  geom_point(aes(x = flights_num, y = cancelled_num))

cancelled_per_day <- 
  flights %>% 
  mutate(cancelled = is.na(arr_time), is.na(dep_time)) %>% 
  group_by(year, month, day) %>% 
  summarise(
    cancelled_num = sum(cancelled),
    flights_num = n()
  )
ggplot(data = cancelled_per_day) +
  geom_point(aes(x = flights_num, y = cancelled_num))

cancelled_and_delay <- 
  flights %>% 
  mutate(cancelled = (is.na(arr_delay) | is.na(dep_delay))) %>% 
  group_by(year, month, day) %>% 
  summarise(
    avg_cancelled = mean(cancelled),
    avg_dep_delay = mean(dep_delay, na.rm = TRUE),
    avg_arr_delay = mean(arr_delay, na.rm = TRUE)) %>% 
  ungroup()
ggplot(data = cancelled_and_delay)+
  geom_point(aes(x = avg_dep_delay, y = avg_cancelled))
ggplot(data = cancelled_and_delay)+
  geom_point(aes(x = avg_arr_delay, y = avg_cancelled))

flights %>% 
  group_by(carrier) %>% 
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE)) %>% 
  arrange(desc(arr_delay))
filter(airlines, carrier == "F9")

flights %>% 
  count(dest, sort = TRUE)
#Find worst members of ea group
flights_sml %>% 
  group_by(year, month, day) %>% 
  filter(rank(desc(arr_delay)) < 10)
#Find the best of ea group
pop_dest <- flights %>% 
  group_by(dest) %>% 
  filter(n() > 365)
pop_dest

pop_dest %>% 
  filter(arr_delay > 0) %>% 
  mutate(prop_delay = arr_delay / sum(arr_delay)) %>% 
  select(year:day, dest, arr_delay, prop_delay)

#Worst on time
flights %>% 
  filter(!is.na(tailnum)) %>% 
  mutate(on_time = !is.na(arr_time) & (arr_delay <= 0)) %>% 
  group_by(tailnum) %>% 
  summarise(on_time = mean(on_time), n = n()) %>% 
  filter(min_rank(on_time) == 1)
#Find which quartile
quantile(count(flights, tailnum)$n)
flights %>% 
  filter(!is.na(tailnum), !is.na(arr_time), !is.na(arr_delay)) %>% 
  mutate(on_time = !is.na(tailnum) & (arr_delay <= 0)) %>% 
  group_by(tailnum) %>% 
  summarise(on_time = mean(on_time), n = n()) %>% 
  filter(n >= 20) %>% 
  filter(min_rank(on_time) == 1)
flights %>% 
  filter(!is.na(arr_delay)) %>% 
  group_by(tailnum) %>% 
  summarise(arr_delay = mean(arr_delay), n = n()) %>% 
  filter(n >= 20) %>% 
  filter(min_rank(arr_delay) == 1)

flights %>% 
  group_by(hour) %>% 
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE)) %>% 
  arrange(arr_delay)

flights %>% 
  filter(arr_delay > 0) %>% 
  group_by(dest) %>% 
  mutate(
    arr_delay_tot = sum(arr_delay),
    arr_delay_prop = arr_delay / sum(arr_delay)) %>% 
  select(dest, month, day, dep_time, carrier, flight, arr_delay, arr_delay_prop) %>% 
  arrange(dest, desc(arr_delay_prop))

flights %>% 
  filter(arr_delay > 0) %>% 
  group_by(dest,origin, carrier, flight) %>% 
  mutate(arr_delay_tot = sum(arr_delay)) %>% 
  group_by(dest) %>% 
  mutate(arr_delay_prop = arr_delay/arr_delay_tot) %>% 
  arrange(dest, desc(arr_delay_prop)) %>% 
  select(dest, flight, origin, carrier, arr_delay_prop)

#Delayed flights
delayed_flights <- 
  flights %>% 
  arrange(origin, month, day, dep_time) %>% 
  group_by(origin) %>% 
  mutate(dep_delay_lag = lag(dep_delay)) %>% 
  filter(!is.na(dep_delay), !is.na(dep_delay_lag))
delayed_flights %>% 
  group_by(dep_delay_lag) %>% 
  summarise(dep_delay_mean = mean(dep_delay)) %>% 
  ggplot(aes(y = dep_delay_mean, x = dep_delay_lag))+
  geom_point()+
  scale_x_continuous(breaks = seq(0,1500, by =120))+
  labs(y = "Departure Delay", x = "Previous Depature Delay")
delayed_flights %>% 
  group_by(origin, dep_delay_lag) %>% 
  summarise(dep_delay_mean = mean(dep_delay)) %>% 
  ggplot(aes(x = dep_delay_lag, y = dep_delay_mean))+
  geom_point()+
  facet_wrap(~origin, ncol = 1)+
  labs(y = "Departure Delay", x = "Preiouvs Departure Delay")

#Standardized Flights
standardized_flights <- 
  flights %>% 
  filter(!is.na(air_time)) %>% 
  group_by(dest, origin) %>% 
  mutate(
    air_time_mean = mean(air_time),
    air_time_sd = sd(air_time),
    n = n()
  ) %>% 
  ungroup() %>% 
  mutate(air_time_standard = 
           (air_time - air_time_mean) / (air_time_sd) + 1)
ggplot(standardized_flights, aes(x = air_time_standard))+
  geom_density()

standardized_flights %>% 
  arrange(air_time_standard) %>% 
  select(carrier , flight, origin, dest, month, day,
         air_time, air_time_mean, air_time_standard) %>% 
  head(10) %>% 
  print(width = Inf)

standardized_flights2 %>% 
  filter(!is.na(air_time)) %>% 
  group_by(dest, origin) %>% 
  mutate(
    air_time_median = median(air_time),
    air_time_IQR = IQR(air_time),
    n = n(),
    air_time_standard = (air_time - air_time_median) / air_time_IQR)
ggplot(data = standardized_flights2, aes(x = air_time_standard))+
  geom_density()

standarized_flights2 %>% 
  arrange(air_standard_time) %>% 
  select(
    carrier, flight, origin, dest, month, day, air_time,
    air_time_median, air_time_standard
  ) %>% 
  head(10) %>% 
  print(width = Inf)