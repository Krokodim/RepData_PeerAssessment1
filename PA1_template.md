# Reproducible Research: Peer Assessment 1

[repdate-012](https://www.coursera.org/course/repdata) /
[Dmitry B. Grekov](mailto:dmitry.grekov@gmail.com) /
2015-03-12


### Packages 
The following packages were used during this research and are required to reproduce it:  

- `dplyr` - a Grammar of data manipulation
- `lubridate` - make dealing with dates a little easier
- `ggplot2` - an implementation of the Grammar of Graphics

If some of these packages are missing, you have to install them using <code>install.packages()</code> function.  


```r
  suppressPackageStartupMessages(
    {
      library(dplyr)
      library(lubridate)
      library(ggplot2)
    }
  )
```

### Loading and preprocessing the data
<small>**Sidenote.** If the <tt>activity.csv</tt> file doesn't exist in the current directory, we download the archive from the original location on the WEB, unzip and store the file to the working directory. As the assignment instructions say that we may assume that the file is already in the working directory, this is done behind the curtain by an invisible R script.</small>



The raw data from the file is then read into the `dt.raw` variable:

```r
dt.raw <- read.csv("activity.csv") 
dt.raw$date <- as.Date(dt.raw$date)
```

### What is mean total number of steps taken per day?
In order to answer this question we need to aggregate the data by `date` and calculate total number of steps per day. Then we calculate total number of steps per day and exclude `NA` values.


```r
dt.daily.total <- dt.raw        %>%
  group_by(date)                %>%
  summarise(value=sum(steps))   %>%
  select(date,value)            %>%
  na.omit()         
```

Here's a histogram fo the daily totals:  
![](PA1_template_files/figure-html/q1_hist-1.png) 



Mean total number of steps per day equals **10766.19**, median equals **10765**.

### What is the average daily activity pattern?
In order to determine the daily activity pattern we have to we have to calculate the mean total steps over all teh dates grouped by time interval:


```r
dt.timely.total <- dt.raw         %>%
  na.omit()                       %>%
  group_by(interval)              %>%
  summarise(value=sum(steps))     %>%
  select(interval,value)                

str(dt.timely.total)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	288 obs. of  2 variables:
##  $ interval: int  0 5 10 15 20 25 30 35 40 45 ...
##  $ value   : int  91 18 7 8 4 111 28 46 0 78 ...
##  - attr(*, "drop")= logi TRUE
```


Here we build the plot:

```r
  ggplot(dt.timely.total, aes(x=interval, y=value)) +
    geom_point() +
    geom_smooth()
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using loess. Use 'method = x' to change the smoothing method.
```

![](PA1_template_files/figure-html/unnamed-chunk-2-1.png) 

### Imputing missing values



### Are there differences in activity patterns between weekdays and weekends?
