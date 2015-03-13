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


dt.timely <- dt                   %>%
  na.omit()                       %>%
  group_by(interval)              %>%
  summarise(value=(mean(steps)/5))

# construct the plot
g2 <- ggplot(dt.timely, aes(x=interval, y=value, group=1), main="sd") +
      labs(list(main="SSS"))

# draw a line
g2 <- g2 + geom_line(aes(group=1), lwd=2, color="darkgrey") 

# adjust X-axis
g2 <- g2 + xlab("Time interval") 
g2 <- g2 + scale_x_discrete(breaks=unique(dt$hour)) 
g2 <- g2 + theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Y-axis adjustments
g2 <- g2 + ylab("Mean number of steps per minute")

# draw the plot
print(g2)