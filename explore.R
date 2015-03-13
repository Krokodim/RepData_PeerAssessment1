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
  hour     =    factor(paste(substr(interval,1,2),"00", sep=":")),
  weekday  =    factor(wday(date, label=TRUE)),
  day.type =    factor(
    ifelse(wday(date) %in% 2:6, 1, 2), 
    levels = c(1,2),
    labels = c("weekday","weekend")
  )
)


dt.imp <- dt                                                %>%
  na.omit()                                                 %>%
  group_by(weekday,interval)                                %>%
  summarise(avg.value=mean(steps))                          %>%
  inner_join(dt, by=c("interval", "weekday"))               %>%
  transform(steps = ifelse(is.na(steps), avg.value, steps)))

dt2[is.na(dt2$steps),]

