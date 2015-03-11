library(dplyr)

dt.raw<-read.csv("activity.csv")

dt.timely.total <- dt.raw         %>%
  na.omit()                       %>%
  group_by(interval)              %>%
  summarise(value=sum(steps))     %>%
  select(interval,value)          %>%
  na.omit()      

str(dt.timely.total)


