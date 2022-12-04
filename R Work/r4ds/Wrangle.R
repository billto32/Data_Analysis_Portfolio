library(tidyverse)
as_tibble(iris)
tibble(
  x = 1:5,
  y = 2,
  z = x^2 + y
)
tb <- tibble(
  `:)` = "smile",
  ` ` = "space",
  `2000` = "number"
)
tribble(
  ~x, ~y, ~z,
  #--|---|----
  "a", 2, 3.6,
  "b", 1, 8.5
)
#Main difference between tribble and data.frame is printing and subsetting
tibble(
  a = lubridate::now() + runif(1e3) * 86400,
  b = lubridate::today() + runif(1e3) * 30,
  c = 1:1e3,
  d = runif(1e3),
  e = sample(letters, 1e3, replace = TRUE)
)

nycflights13::flights %>% 
  print(n = 10, width = Inf)
#[[ Can extract name and position , $ can extract name
df <- tibble(
  x = runif(5),
  y = rnorm(5)
)
#Extract by Name
df$x
df[["x"]]
#Extract by  Position
df[[1]]
#To use these use the %>% .
df %>% .$x
df %>% .[["x"]]
mtcars
as_tibble(mtcars)
#Remember Tibbles show 10 rows unless stated otherwise
#is_tibble() to check
is_tibble(mtcars)
df <- data.frame(abc = 1, xyz = "a")
df$x
df[,"xyz"]
df[, c("abc", "xyz")]

tbl <- as_tibble(df)
tbl[,"xyz"]
tbl[, c("abc", "xyz")]

var <- "mpg"
df[["var"]]

a <- tibble(
  `1` = 1:10,
  `2` = 1 * 2 + rnorm(length(`1`))
)
a[["1"]] #a$`1`
ggplot(a, aes(x = `1`, y = `2`))+
  geom_point()
mutate(a, `3` = `2`/`1`)
a[["3"]] <- a[["2"]]/a[["1"]]
a <- rename(a, one = `1`, two = `2`, three = `3`)
glimpse(a)

#enframe converts vectors to df
enframe(c(a = 1, b = 2, c = 3))

#Pivot longer when the columns need to be condensed, stacks columns 
tidy4a <- table4a %>% 
  pivot_longer(c('1999','2000'), names_to = "year", values_to = "cases")
tidy4b <- table4b %>% 
  pivot_longer(c('1999','2000'), names_to = "year", values_to = "population")
#Assign data and left join to combine into a tibble
left_join(tidy4a, tidy4b)

#Pivot wider when values scattered across multiple rows, column names from values
table2 %>% 
  pivot_wider(names_from = type, values_from = count)

stocks <- tibble(
  year   = c(2015, 2015, 2016, 2016),
  half  = c(   1,    2,     1,    2),
  return = c(1.88, 0.59, 0.92, 0.17)
)
stocks %>% 
  pivot_wider(names_from = year, values_from = return) %>% 
  pivot_longer(`2015`:`2016`, names_to = "year", values_to = "return")

glimpse(stocks)
stocks %>% 
  pivot_wider(names_from = year , values_from = return) %>% 
  pivot_longer('2015' : '2016', names_to = "year", values_to = "return",
               names_transform = list(year = as.numeric))

table4a %>% 
  pivot_longer(c('1999','2000'), names_to = "year", values_to = "cases")

people <- tribble(
  ~name, ~key, ~value,
  #-----------------|--------|------
  "Phillip Woods",  "age", 45,
  "Phillip Woods", "height", 186,
  "Phillip Woods", "age", 50,
  "Jessica Cordero", "age", 37,
  "Jessica Cordero", "height", 156
)
glimpse(people)

people %>% 
  distinct(name, key, .keep_all = TRUE) %>% 
  pivot_wider(people, names_from = "name", values_from = "value")

preg <- tribble(
  ~pregnant, ~male, ~female,
  "yes", NA, 10,
  "no", 20, 12
)

preg_tidy <- preg %>% 
  pivot_longer(c('male', 'female'), names_to = "gender", values_to = "count" , values_drop_na = TRUE)
preg_tidy2 <- preg_tidy %>% 
  mutate(
    female = gender == "female",
    pregnant = pregnant == "yes"
  ) %>% 
  select(female, pregnant, count)
preg_tidy2
filter(preg_tidy2, gender == "female", pregnant == "no")
filter(preg_tidy2, gender == "female", pregnant == "yes")

table3 %>% 
  separate(rate, into = c('case', 'population'), sep = "/", convert = TRUE)
table5 %>% 
  unite(year, century, year, sep = "")

tibble(x = c("a,b,c", "d,e,f,g", "h,i,j")) %>% 
  separate(x, c("one", "two", "three"))

tibble(x = c("a,b,c", "d,e", "f,g,i")) %>% 
  separate(x, c("one", "two", "three"))

tibble(x = c("X_1", "X_2", "AA_1", "AA_2")) %>% 
 extract(x, c("variable", "int"), regex = "([A-Z])_([0-9])")
tibble(x = c("X1", "X2", "Y1", "Y2")) %>%
  extract(x, c("variable", "int"), regex = "([A-Z])([0-9])")
tibble(x = c("X1", "X20", "AA11", "AA2")) %>%
  extract(x, c("variable", "int"), regex = "([A-Z]+)([0-9]+)" )

stocks <- tibble(
  year   = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
  qtr    = c(   1,    2,    3,    4,    2,    3,    4),
  return = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)
stocks
stocks %>% 
  pivot_wider(names_from = year, values_from = return) %>% 
  pivot_longer(
    cols = c('2015','2016'),
    names_to = "year",
    values_to = "return",
    values_drop_na = TRUE
  )
stocks %>% 
  complete(year, qtr)

treatment <- tribble(
  ~ person,           ~ treatment, ~response,
  "Derrick Whitmore", 1,           7,
  NA,                 2,           10,
  NA,                 3,           9,
  "Katherine Burke",  1,           4
)
treatment %>% fill(person)
stocks %>% 
  pivot_wider(names_from = year, values_from = return, values_fill = 0)
#Fill long ways
stocks %>% 
  complete(year, qtr, fill = list(return = 0))
