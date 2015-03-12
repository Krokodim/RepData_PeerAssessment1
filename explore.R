library(dplyr)
library(lubridate)

dt <-read.csv("activity.csv", stringsAsFactors=FALSE) %>%
  mutate(
      interval      = sprintf("%04d", interval),
      char.datetime = sprintf("%s %s", date, interval),
      datetime      = ymd_hm(char.datetime),
      hour          = sprintf("%02d", hour(datetime))
    )                                                 %>%
  select (date, interval, hour, steps)



dt$date.time <- ymd_hm(paste(dt.raw$date, sprintf("%04d",dt.raw$interval)))
dt$date <- ymd
dt$interval <- NULL

  
  
  dt.raw$date +  minutes(dt.raw$interval)
dt.raw$hour <- hour(dt.raw$date.time) 

dt.raw$hour <- hour(dt.raw$date+minutes(interval) )

unique(dt.raw$date)

dt.timely.total <- dt.raw         %>%
  na.omit()                       %>%
  group_by(interval)              %>%
  summarise(value=sum(steps))     %>%
  select(interval,value)          %>%
  na.omit()      

str(dt.timely.total)


