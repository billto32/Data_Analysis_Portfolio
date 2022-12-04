library(tidyverse)
paste('bar')
paste0('bar', ' bar')
str_c('bar','bar', NA)
x <- c('a','b','c','d','e','f')
L <- str_length(x)
m <- ceiling(L/2)
str_sub(x,L,m)
str_trim(" abc  ", side = "right")
str_pad("abc", 5, side = "both")
x <- c("appla","bannana","pear")
str_view(x, "a$")
str_subset(stringr::words, "i(ng|se)$")

#Matching patterns
str_detect(x, "e")
##common words start with t
sum(str_detect(words, "^t"))
##What proportions start with a vowel?
mean(str_detect(words, "^[aeiou]"))
##Find all words that don't have a vowel
###Words with one vowel
no_vowels <- !str_detect(words, "[aeiou]")
###Words with constonants 
no_vowels2 <- str_detect(words, "^[^aeiou]+$")
identical(no_vowels,no_vowels2)

#words start with x or end with x
words[str_detect(words, "^x|x$")]
#words start with vowel end with constant
words[str_detect(words, "^[aeiou].*[aeiou]$")]

length(sentences)
head(sentences)
colors <- c("red","orange","blue","green")
color_match <- str_c(colors, collapse = "|")
color_match
has_color <- str_subset(sentences, color_match)
matches <- str_extract(has_color, color_match)
head(matches)
more <- sentences[str_count(sentences, color_match)>1]
str_view_all(more, color_match)

#First word
str_extract(sentences, "[A-ZAa-z]+") %>% 
  head()
str_extract(sentences, "[A-ZAa-z][A-Za-z']*") %>% 
  head()
