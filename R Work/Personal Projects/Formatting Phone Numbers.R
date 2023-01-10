p <- c("(123)-456-7890", "1234567890", "456890  ", "456-7890", "   (123)-4567890")
p

p <- trimws(gsub("[[:punct:]]","",p))

p[!nchar(p) %in% c(10)] <- NA

p <- gsub("(^\\d{3})(\\d{3})(\\d{4}$)", "\\1-\\2-\\3",p)

p <- p[!is.na(p)]
p


^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$
  
^\s*                #Line start, match any whitespaces at the beginning if any.
(?:\+?(\d{1,3}))?   #GROUP 1: The country code. Optional.
[-. (]*             #Allow certain non numeric characters that may appear between the Country Code and the Area Code.
(\d{3})             #GROUP 2: The Area Code. Required.
[-. )]*             #Allow certain non numeric characters that may appear between the Area Code and the Exchange number.
(\d{3})             #GROUP 3: The Exchange number. Required.
[-. ]*              #Allow certain non numeric characters that may appear between the Exchange number and the Subscriber number.
(\d{4})             #Group 4: The Subscriber Number. Required.
(?: *x(\d+))?       #Group 5: The Extension number. Optional.
\s*$                #Match any ending whitespaces if any and the end of string.
