library(dplyr)      # a Grammar of data manipulation
library(lubridate)  # make dealing with dates a little easier
library(ggplot2)    # an implementation of the Grammar of Graphics

dt <-read.csv("activity.csv", stringsAsFactors=FALSE)

dt <- mutate(dt, date = ymd(date))

dt <- mutate(
  dt,
  hh       = floor(interval/100),
  mm       = interval - hh*100,
  interval = sprintf("%02d:%02d",hh,mm),
  hh = NULL, mm = NULL
)

dt <- mutate(
  dt,
  hour     =    factor(paste(substr(interval,1,2),"00", sep=":")),
  weekday  =    factor(wday(date, label=TRUE)),
  day.type =    factor(
    ifelse(wday(date) %in% 2:6, 1, 2), 
    levels = c(1,2),
    labels = c("weekday","weekend")
  )
)





sum(is.na(dt$steps))

unique(dt[is.na(dt$steps),]$date)



dt.imp <- dt                                                %>%
  inner_join(dt.timely, by=c("interval"))                   %>%
  mutate(steps = ifelse(is.na(steps), value, steps))     

dt.timely <- dt.imp                %>%
  na.omit()                        %>%
  group_by(interval)               %>%
  summarise(value=mean(steps))

ggplot(dt.timely) + geom_line(aes(x=interval, y=value,group=1))

ggplot(dt.timely) + geom_histogram(aes(x=value))

ggplot(dt.imp) + geom_line(aes(x=interval, y=steps,group=1))

