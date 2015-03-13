# Reproducible Research: Peer Assessment 1

[repdate-012](https://www.coursera.org/course/repdata) /
[Dmitry B. Grekov](mailto:dmitry.grekov@gmail.com) /
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

### Initial data reading  
The raw data from the file is initially read into the `dt` variable:

```r
dt <-read.csv("activity.csv", stringsAsFactors=FALSE)
```

As the data is read, our `dt` variable is a data.frame with the following three columns:

- `steps` - an integer containing the number of steps made during the interval
- `date` - the data of measurement in a character format (yyyy-mm-dd)
- `interval` - an integer value denoting the 5-minute interval for the measurement <small>(the value 5 denotes to 00:05, 115 to 01:15AM, 1325 to 1:25PM (13:25) and so on)</small>

### Data preprocessing

First, we convert the `date` into `POSIXct` format:

```r
dt <- mutate(dt, date = ymd(date))
```

Next, we transform the `interval` into 24-hour 'hh:mm' form in order to add visibility and facilitate sorting:

```r
dt <- mutate(
        dt, 
        #step 1 - make it 'hhmm'
        interval = sprintf("%04d", interval),
        #step 2 - split hours and minutes with a colon
        interval = paste(substr(interval,1,2),substr(interval,3,4), sep=":")
      )
```

We also add new variables 

  - `hour` is the hour the interval belongs to, the format is `hh:00`
  - `weekday` is an abbreviated name of the weekday, we will need it to imput the missing values (see below)
  - `day.type` is a factor to distinguish betweeb weekdays (1) and weekends (2)


```r
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
```

So finally we have the following dataset:

```r
str(dt)
```

```
## 'data.frame':	17568 obs. of  6 variables:
##  $ steps   : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ date    : POSIXct, format: "2012-10-01" "2012-10-01" ...
##  $ interval: chr  "00:00" "00:05" "00:10" "00:15" ...
##  $ hour    : Factor w/ 24 levels "00:00","01:00",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ weekday : Ord.factor w/ 7 levels "Sun"<"Mon"<"Tues"<..: 2 2 2 2 2 2 2 2 2 2 ...
##  $ day.type: Factor w/ 2 levels "weekday","weekend": 1 1 1 1 1 1 1 1 1 1 ...
```

## What is mean total number of steps taken per day?
In order to answer this question we have to aggregate the data by date and calculate total number of steps per day. We will also exclude `NA` values during the transformation. The dataset for this question will be stored in the `dt.daily` variable: 


```r
dt.daily <- dt                     %>%
  na.omit()                        %>%
  group_by(date)                   %>%
  summarise(value=sum(steps))      
```

Now let's build a histogram for the daily totals. We will use ggplot plotting system:

```r
# build the plot
g1 <- ggplot(dt.daily, aes(x=value)) 

# draw the histogram
g1 <- g1 + geom_histogram(binwidth=1000, fill="steelblue", color="white", alpha=9/13)

# X-axis adjustments
g1 <- g1 + xlab("Number of steps per day") 
g1 <- g1 + scale_x_continuous(breaks=seq(0,21000, by=1000), limits=c(0,21000)) 
g1 <- g1 + theme(axis.text.x = element_text(angle=60, hjust= 1))

# Y-axis adjustments
g1 <- g1 + ylab("Number of days")
g1 <- g1 + scale_y_continuous(breaks=0:30) 

g1 <- g1 + labs(list(title="Mean total number of steps per day"))

# draw the plot
print(g1)
```

![](PA1_template_files/figure-html/q1_hist-1.png) 

The histogram shows that the mean total number of steps per day is about 10000-11000. If we calculate the value, we scan see that it is really so:

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
In order to determine the daily activity pattern we have to group the data by a time interval and calculate mean numer of steps for each interval. We will store the data in `dt.timely` variable:


```r
dt.timely <- dt                   %>%
  na.omit()                       %>%
  group_by(interval)              %>%
  summarise(value=mean(steps))
```


Now we can buid a plot showing the daily activity pattern:

```r
# construct the plot
g2 <- ggplot(dt.timely, aes(x=interval, y=value)) 

# draw a line
g2 <- g2 + geom_line(aes(group=1), color="steelblue", lwd=1) 

# adjust X-axis
g2 <- g2 + xlab("Time interval") 
g2 <- g2 + scale_x_discrete(breaks=levels(dt$hour)) 
g2 <- g2 + theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Y-axis adjustments
g2 <- g2 + ylab("Mean number of steps per 5 minutes")

g2 <- g2 + labs(list(title="Average daily activity pattern"))

# draw the plot
print(g2)
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
Now we need to imput the missing value. During the preliminary analysis, we found that the patterns of different days of the week are significantly different. So our strategy to imput the missing values will be as follows:

- select all the non-NA values for the same interval and the same weekday 
- calculate the median for this et of values, as median is more robust than mean

Such a strategy is powerful enough to provide  good values and easy enough to satisfy the rubric requirements. 

We will store the result in `dt.imp` variable. 


```r
dt.imp <- dt                                                 %>%
  na.omit()                                                  %>%
  group_by(weekday,interval)                                 %>%
  summarise(avg.value=mean(steps))                           %>%
  inner_join(dt, by=c("interval", "weekday"))                %>%
  transform(steps = ifelse(is.na(steps), avg.value, steps))
```


```r
dt.daily <- dt.imp                 %>%
  na.omit()                        %>%
  group_by(date)                   %>%
  summarise(value=sum(steps))      
```

Now let's build a histogram for the daily totals. We will use ggplot plotting system:

```r
# build the plot
g1 <- ggplot(dt.daily, aes(x=value)) 

# draw the histogram
g1 <- g1 + geom_histogram(binwidth=1000, fill="steelblue", color="white", alpha=9/13)

# X-axis adjustments
g1 <- g1 + xlab("Number of steps per day") 
g1 <- g1 + scale_x_continuous(breaks=seq(0,21000, by=1000), limits=c(0,21000)) 
g1 <- g1 + theme(axis.text.x = element_text(angle=60, hjust= 1))

# Y-axis adjustments
g1 <- g1 + ylab("Number of days")
g1 <- g1 + scale_y_continuous(breaks=0:30) 

g1 <- g1 + labs(list(title="Mean total number of steps per day"))

# draw the plot
print(g1)
```

![](PA1_template_files/figure-html/q3_hist-1.png) 

## Are there differences in activity patterns between weekdays and weekends?
We will compare the paterns for weekdays and weekends:


```r
dt.timely <- dt                   %>%
  na.omit()                       %>%
  group_by(day.type, interval)              %>%
  summarise(value=mean(steps))
```


Now we can buid a plot showing the daily activity pattern:

```r
# construct the plot
g4 <- ggplot(dt.timely, aes(x=interval, y=value)) 

# draw a line
g4 <- g4 + geom_line(aes(group=1), color="steelblue", lwd=1) 

# facet
g4 <- g4 + facet_grid(day.type~.)

# adjust X-axis
g4 <- g4 + xlab("Time interval") 
g4 <- g4 + scale_x_discrete(breaks=levels(dt$hour)) 
g4 <- g4 + theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Y-axis adjustments
g4 <- g4 + ylab("Mean number of steps per 5 minutes")

g4 <- g4 + labs(list(title="Activity patterns for weekdays and weekends"))

# draw the plot
print(g4)
```

![](PA1_template_files/figure-html/q4_plot-1.png) 
