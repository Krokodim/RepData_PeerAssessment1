# Reproducible Research: Peer Assessment 1

[repdate-012](https://www.coursera.org/course/repdata) /
[Dmitry B. Grekov](https://www.coursera.org/user/i/ef65e2e142b164e9dab1e980c6e0547d) /
2015-03-14






## Packages 
The following packages were used during this research and are required to reproduce it:  


```r
library(dplyr)      # a Grammar of data manipulation
library(lubridate)  # make dealing with dates a little easier
library(ggplot2)    # an implementation of the Grammar of Graphics
```

If some of these packages are missing, you have first to install them using <code>install.packages()</code> function.  

## Loading and preprocessing the data
The source data is stored int the `activity.csv` file in the working directory. If the file is missing by the time the script starts, it is donloaded from the WEB (this is done behind the curtain).  

The raw data from the file is read into the `dt` variable:

```r
dt <-read.csv("activity.csv", stringsAsFactors=FALSE)
```

We perform some minor transformations: 

- first, convert the `date` into `POSIXct` format and convert interval into `hh:mm` character format:


```r
dt <- mutate(
        dt, 
        date     = ymd(date),                   # POSIXct date
        hh       = floor(interval/100),         # hours
        mm       = interval - hh*100,           # minutes
        interval = sprintf("%02d:%02d",hh,mm),  # now it is 'hh:mm'
        # eliminate temporary variables as unnecessary 
        hh = NULL, mm = NULL                                
      )
```

- then we create an additional `hour` variable which denotes the hour the time interval belongs to:


```r
dt <- mutate(dt, hour = factor(paste(substr(interval,1,2),"00", sep=":")))
```

## What is mean total number of steps taken per day?
In order to answer this question we have to aggregate the data by date and calculate total number of steps per day. We will also exclude `NA` values during the transformation. The dataset for this question will be stored in the `dt.daily` variable: 


```r
dt.daily <- dt                     %>%
  na.omit()                        %>%
  group_by(date)                   %>%
  summarise(value=sum(steps))      
```

Now we can make a histogram of the total number of steps taken each day:

```r
# build the plot
gg <- ggplot(dt.daily, aes(x=value)) 

# Set the plot title
gg <- gg + labs(list(title="Mean total number of steps per day"))

# draw the histogram
gg <- gg + geom_histogram(binwidth=1000, fill="steelblue", color="white", alpha=9/13)

# X-axis adjustments
gg <- gg + xlab("Number of steps per day") 
gg <- gg + scale_x_continuous(breaks=seq(0,21000, by=1000), limits=c(0,21000)) 
gg <- gg + theme(axis.text.x = element_text(angle=60, hjust= 1))

# Y-axis adjustments
gg <- gg + ylab("Number of days")
gg <- gg + scale_y_continuous(breaks=0:30) 

# draw the plot
print(gg)
```

![](PA1_template_files/figure-html/q1_hist-1.png) 

Let's calculate and report the mean and median of the total number of steps taken per day:

```r
mean(dt.daily$value)
```

```
## [1] 10766.19
```

```r
median(dt.daily$value)
```

```
## [1] 10765
```

## What is the average daily activity pattern?
In order to determine the daily activity pattern we have to group our data by the time interval and calculate mean number of steps for each interval. We will store the data in `dt.timely` variable:


```r
dt.timely <- dt                    %>%
  na.omit()                        %>%
  group_by(interval)               %>%
  summarise(value=mean(steps))
```


Now we can buid a plot showing the daily activity pattern:

```r
# construct the plot
gg <- ggplot(dt.timely, aes(x=interval, y=value, group=1)) 

# Set the plot title
gg <- gg + labs(list(title="Average daily activity pattern"))

# draw a line
gg <- gg + geom_line(color="steelblue") 

# adjust X-axis
gg <- gg + xlab("Time interval") 
gg <- gg + scale_x_discrete(breaks=levels(dt$hour)) 
gg <- gg + theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Y-axis adjustments
gg <- gg + ylab("Mean number of steps per 5 minutes")

# draw the plot
print(gg)
```

![](PA1_template_files/figure-html/q2_plot-1.png) 

**Question**: Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?

```r
dt.timely %>% arrange(desc(value)) %>% head(1)
```

```
## Source: local data frame [1 x 2]
## 
##   interval    value
## 1    08:35 206.1698
```

## Imputing missing values
Now we need to imput the missing values for the `steps` variable. Our strategy is quite simpel, we just use the mean values from `dt.timely` dataset. Such a strategy is powerful enough to provide  good values and easy enough to satisfy the rubric requirements. 

We will store the result in `dt.imp` variable:

```r
dt.imp <- dt                                                %>%
  inner_join(dt.timely, by=c("interval"))                   %>%
  mutate(steps2 = ifelse(is.na(steps), value, steps))   
```


```r
dt.daily.imp <- dt.imp             %>%
  group_by(date)                   %>%
  summarise(value=sum(steps))      
```

Now let's build a histogram for the daily totals. We will use ggplot plotting system:

```r
# build the plot
gg <- ggplot(dt.daily.imp, aes(x=value)) 

# Set the plot title
gg <- gg + labs(list(title="Mean total number of steps per day (imputed data)"))

# draw the histogram
gg <- gg + geom_histogram(binwidth=1000, fill="steelblue", color="white", alpha=9/13)

# X-axis adjustments
gg <- gg + xlab("Number of steps per day") 
gg <- gg + scale_x_continuous(breaks=seq(0,21000, by=1000), limits=c(0,21000)) 
gg <- gg + theme(axis.text.x = element_text(angle=60, hjust= 1))

# Y-axis adjustments
gg <- gg + ylab("Number of days")
gg <- gg + scale_y_continuous(breaks=0:30) 

gg <- gg + labs(list(title="Mean total number of steps per day"))

# draw the plot
print(gg)
```

![](PA1_template_files/figure-html/q3_hist-1.png) 

## Are there differences in activity patterns between weekdays and weekends?
We need to create a new factor variable `day.type` to distinguish between weekdays and weekends:

```r
dt <- dt %>% mutate(
    day.type = factor(
                  ifelse(wday(date) %in% 2:6, 1, 2),
                  labels = c("weekday","weekend")
                )
  )
```


We will compare the paterns for weekdays and weekends:


```r
dt.timely <- dt                                %>%
  na.omit()                                    %>%
  group_by(day.type, interval)                 %>%
  summarise(value=mean(steps))
```


Now we can buid a plot showing the daily activity pattern:

```r
# construct the plot
gg <- ggplot(dt.timely, aes(x=interval, y=value, group=1)) 

# draw a line
gg <- gg + geom_line(color="steelblue") 

# facet
gg <- gg + facet_grid(day.type~.)

# adjust X-axis
gg <- gg + xlab("Time interval") 
gg <- gg + scale_x_discrete(breaks=levels(dt$hour)) 
gg <- gg + theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Y-axis adjustments
gg <- gg + ylab("Mean number of steps per 5 minutes")

gg <- gg + labs(list(title="Activity patterns for weekdays and weekends"))

# draw the plot
print(gg)
```

![](PA1_template_files/figure-html/q4_plot-1.png) 
