library(tidyverse)
library(nycflights13)

#Verify primary keys
planes %>% 
  count(tailnum) %>% 
  filter(n > 1)
weather %>% 
  count(year, month, day, hour, origin) %>% 
  filter(n > 1)
flights %>% 
  count(year, month, day, flight) %>% 
  filter(n > 1)
flights %>% 
  count(year, month, day, tailnum) %>% 
  filter(n > 1)

#Join Origins of flights to destination. FLights and airports table
flights_latlon <- flights %>% 
  #Assign new variable, flights joining with airports
  inner_join(select(airports, origin = faa, origin_lat = lat, origin_lon = lon),
             by = "origin") %>% 
  #inner join with airports using origin lat lon
  inner_join(select(airports, dest = faa, dest_lat = lat, dest_lon = lon),
             by = "dest")
  #inner join with airports using dest lat lon

flights_latlon %>% 
  slice(1:100) %>% 
  ggplot(aes(x = origin_lon , xend = dest_lon,
             y = origin_lat, yend = dest_lat))+
  borders("state") +
  geom_segment(arrow = arrow(length = unit(0.1, "cm")))+
  coord_quickmap()+
  labs(y = "Latitude", x = "Longitude")

special_days <- tribble(
  ~year, ~month, ~day, ~holiday,
  2013, 01, 01, "New Years Day",
  2013, 07, 04, "Independence Day",
  2013, 11, 29, "Thanksgiving Day",
  2013, 12, 25, "Christmas Day"
)

#Make a surrogate key with rownumber in flights
flights %>% 
  arrange(year, month, day, sched_dep_time, carrier, flight) %>% 
  mutate(flight_id = row_number()) %>% 
  glimpse

flight2 <- flights %>% 
  select(year:day, hour, origin, dest, tailnum, carrier,)
flight2

#Adding airline name
flight2 %>% 
  select(-origin, -dest) %>% 
  left_join(airlines, by = "carrier")
#Avg delay by dest
avg_dest_delay <- 
  flights %>% 
  group_by(dest) %>% 
  #cancelled flights
  summarise(delay = mean(arr_delay), na.rm = TRUE) %>% 
  inner_join(airports, by = c(dest = 'faa'))
avg_dest_delay %>% 
  ggplot(aes(lon, lat, color = delay))+
  borders("state")+
  geom_point()+
  coord_quickmap()

#Join location of origin and destination
airport_locations <- airports %>% select(faa, lat, lon)
flights %>% 
  select(year:day, hour, origin, dest) %>% 
  left_join(airport_locations, by = c('origin' = 'faa')) %>% 
  left_join(airport_locations, by = c('dest' = 'faa'))
airport_location <- airports %>% select(faa, lat , lon)
flights %>% 
  select(year:day, hour, origin, dest) %>% 
  left_join(airport_locations, by = c('origin' = 'faa')) %>%
  left_join(airport_locations, by = c('dest' = 'faa'), 
            suffix = c('_origin', '_dest')) 
#Relationship between age of planes and delays
View(planes)
View(flights)
##Merge planes to flights
##join flights from planes using tailnum, wanting plane years by tailnum
old_planes <- inner_join(flights,
  select(planes, tailnum, plane_years = "year"), by = "tailnum") %>%
  #Have years, mutate to get age
  mutate(age = year - plane_years) %>% 
  filter(!is.na(age)) %>% 
  mutate(age = if_else(age > 25, 25L, age)) %>% 
  group_by(age) %>% 
  summarise(
    dep_delay_avg = mean(dep_delay, na.rm = TRUE),
    arr_delay_avg = mean(arr_delay, na.rm = TRUE),
  )
old_planes %>% 
  ggplot(mapping = aes(x = age , y = dep_delay_avg))+
  geom_point()+
  scale_x_continuous("Age of Planes", breaks = seq(0,30, by = 10))+
  scale_y_continuous("Avg Departure Delay")
##Increase in delays when < 10 but declines in delay after > 10 years
old_planes %>% 
  ggplot(mapping = aes(x = age , y = arr_delay_avg))+
  geom_point()+
  scale_x_continuous("Age of Planes", breaks = seq(0,30, by = 10))+
  scale_y_continuous("Avg Arrival Delay")
##Similar spread compared to departure delays
#Weather conditions effect on delays
##Join weather with flights
flights_weather <- 
  flights %>% 
  inner_join(weather, by = c(
    "origin" = "origin",
    "year" = "year",
    "month" = "month",
    "day" = "day",
    "hour" = "hour"
  ))
flights_weather %>% 
  ##group by lookup
  group_by(precip) %>% 
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>% 
  ggplot(aes(x = precip, y = dep_delay))+
  geom_point()+
  geom_line()
##Possible strong relationship between delays and precip
View(weather)
#Effect of visibility and delays
##Group by lookup > strong relationship between delay and visib
flights_weather %>% 
  group_by(visib) %>% 
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>% 
  ggplot(aes(x = visib, y = dep_delay))+
  geom_point()
##Focus on dep_delay 30
flights_weather %>% 
  ungroup() %>% 
  mutate(cut_visib = cut_interval(visib, n = 10)) %>% 
  group_by(cut_visib) %>% 
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>% 
  ggplot(aes(x = cut_visib, y = dep_delay))+
  geom_point()
# June 13, 2013
flights %>% 
  ##Filter for date, group by dest
  filter(year == 2013, month == 6, day == 13) %>% 
  group_by(dest) %>% 
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE)) %>% 
  ##Join with airports
  inner_join(airports, by = c("dest" = "faa")) %>% 
  ggplot(aes(y = lat, x = lon, size = arr_delay, color = arr_delay))+
  borders("state")+
  geom_point()+
  coord_quickmap()+
  scale_color_viridis()

#Top 10 dest
top_dest <- 
  flights %>% 
  count(dest, sort = TRUE) %>% 
  head(10)
top_dest
#Flights reaching dest
flights %>% 
  filter(dest %in% top_dest$dest)
flights %>% 
  semi_join(top_dest)
#How many fights don't match a plane?
flights %>% 
  anti_join(planes, by = "tailnum") %>% 
  count(tailnum, sort = TRUE)
##Missing tailnum = cancelled flight
flights %>% 
  filter(is.na(tailnum), !is.na(arr_time)) %>% 
  nrow()
flights %>% 
  anti_join(planes, by = "tailnum") %>% 
  count(carrier, sort = TRUE) %>% 
  mutate(p = n / sum(n))
## MQ and AA don't report tailnum however
#Planes with at least 100 flights
flight_100 <- flights %>% 
  filter(!is.na(tailnum)) %>% 
  group_by(tailnum) %>% 
  count() %>% 
  filter(n >= 100)
flights %>% 
  semi_join(flight_100, by = "tailnum")
flights %>% 
  filter(!is.na(tailnum)) %>% 
  group_by(tailnum) %>% 
  mutate(n = n()) %>% 
  filter(n >= 100)
fueleconomy::vehicles %>% 
  semi_join(fueleconomy::common, by = c("make", "model")) 
fueleconomy::vehicles %>% 
  distinct(model, make) %>% 
  group_by(model) %>% 
  filter(n() > 1) %>% 
  arrange(model)
fueleconomy::common %>% 
  distinct(model, make) %>% 
  group_by(model) %>% 
  filter(n() > 1) %>% 
  arrange(model)
#48 hrs with the worst delays
worst_hr <- 
  flights %>% 
  mutate(hour = sched_dep_time %/% 100) %>% 
  #%/% 100 for hour
  group_by(origin, year , month, day, hour) %>% 
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>% 
  ungroup() %>% 
  arrange(desc(dep_delay)) %>% 
  #Too many points slice down
  slice(1:40)
worst_hr
## join with weather
worst_delay <-  semi_join(weather, worst_hr, by = c('origin', 'year', 'month', 'hour'))
worst_delay
select(worst_delay, temp, wind_speed, precip) %>% 
  print(n = 30)
ggplot(worst_delay, aes(x = precip, y = wind_speed, color = temp))+
  geom_point()
