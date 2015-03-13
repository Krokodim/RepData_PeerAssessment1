library(dplyr)      # a Grammar of data manipulation
library(lubridate)  # make dealing with dates a little easier
library(ggplot2)    # an implementation of the Grammar of Graphics

dt <-read.csv("activity.csv", stringsAsFactors=FALSE)

dt <- mutate(dt, date = ymd(date))

dt <- mutate(
  dt, 
  #step 1 - make it 'hhmm'
  interval = sprintf("%04d", interval),
  #step 2 - split hours and minutes with a colon
  interval = paste(substr(interval,1,2),substr(interval,3,4), sep=":")
)

dt <- mutate(
  dt,
  hour     =    paste(substr(interval,1,2),"00", sep=":"),
  day.type =    factor(
    ifelse(wday(date) %in% 2:6, 1, 2), 
    levels = c(1,2),
    labels = c("weekday","weekend")
  )
)


dt.daily <- dt                     %>%
  na.omit()                        %>%
  group_by(date)                   %>%
  summarise(value=sum(steps)) 

# build the plot
g1 <- ggplot(dt.daily, aes(x=value)) 

# draw the histogram
g1 <- g1 + geom_histogram(binwidth=1000, fill="steelblue", color="white", alpha=7/13)

# X-axis adjustments
g1 <- g1 + xlab("Number of steps per day") 
g1 <- g1 + scale_x_continuous(breaks=seq(0,21000, by=1000), limits=c(0,21000)) 
g1 <- g1 + theme(axis.text.x = element_text(angle=60, hjust= 1))

# Y-label adjustments
g1 <- g1 + ylab("Number of days")
g1 <- g1 + scale_y_continuous(breaks=0:30) 

print(g1)


