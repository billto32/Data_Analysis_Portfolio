library(tidyverse)
ggplot(diamonds, aes(carat, price))+
  geom_hex()
ggsave("diamonds.pdf")

write_csv(diamonds, "diamonds.csv")

read_csv("a,b,c
         1,2,3
         4,5,6")
read_csv("skip
         x,y,z
         1,2,3")
read_csv("1,2,3\n4,5,6", col_names = FALSE)
read_csv("1,2,3\n4,5,6,.",na = "." )
