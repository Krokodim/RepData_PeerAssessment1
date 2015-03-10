# Reproducible Research: Peer Assessment 1
<<<<<<< HEAD
<tt>
[repdate-012](https://www.coursera.org/course/repdata) /
[Dmitry B. Grekov](mailto:dmitry.grekov@gmail.com) / March 2015
</tt>

### Packages 
The following packages are required to reproduce this research:

```r
suppressPackageStartupMessages( {
  library(dplyr)
  library(data.table)
  }
)
```
If some of these packages are missing, you have to install them using <code>install.packages()</code> function.  

### Loading and preprocessing the data
If the file doesn't exist in the current directory, we download it from the original location:  
  - Dataset: [Activity monitoring data](https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip) [~52K]  


```r
if (!file.exists("activity.csv")) {
  file.url <-"http://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
  file.tmp <- tempfile(pattern="activity")
  file.res <- download.file(file.url, file.tmp, quiet=TRUE)
  file.csv <- unzip(file.tmp, overwrite=TRUE)
}
```

The raw data from the file is then read into the <code>dt.raw</code> variable:

```r
dt.raw <- read.csv("activity.csv") 
```
### What is mean total number of steps taken per day?



### What is the average daily activity pattern?



### Imputing missing values



### Are there differences in activity patterns between weekdays and weekends?
=======


## Loading and preprocessing the data



## What is mean total number of steps taken per day?



## What is the average daily activity pattern?



## Imputing missing values



## Are there differences in activity patterns between weekdays and weekends?
>>>>>>> b12262575d6ff34b39a584bb0960babcaa07f2a9
