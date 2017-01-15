```
> # R Studio CLI
> # plotForecastErrors source : https://media.readthedocs.org/pdf/a-little-book-of-r-for-time-series/latest/a-little-book-of-r-for-time-series.pdf
> plotForecastErrors <- function (forecasterrors)
{
    # make a histogram of the forecast errors:
    mybinsize <- IQR(forecasterrors)/4
    mysd   <- sd(forecasterrors)
    mymin  <- min(forecasterrors) - mysd * 5
    mymax  <- max(forecasterrors) + mysd * 3
    # generate normally distributed data with mean 0 and standard deviation mysd
    mynorm <- rnorm(10000, mean=0, sd=mysd)
    mymin2 <- min(mynorm)
    mymax2 <- max(mynorm)
    if (mymin2 < mymin) { mymin <- mymin2 }
    if (mymax2 > mymax) { mymax <- mymax2 }
    # make a red histogram of the forecast errors, with the normally distributed data overlaid:
    mybins <- seq(mymin, mymax, mybinsize)
    hist(forecasterrors, col="red", freq=FALSE, breaks=mybins)
    # freq=FALSE ensures the area under the histogram = 1
    # generate normally distributed data with mean 0 and standard deviation mysd
    myhist <- hist(mynorm, plot=FALSE, breaks=mybins)
    # plot the normal curve as a blue line on top of the histogram of forecast errors:
    points(myhist$mids, myhist$density, type="l", col="blue", lwd=2)
}
```

```
> library(forecast)
> library(xts)
```

```
> rides = read.csv("number_of_requests_domlur_region_3.csv")
> rides$window = strptime(rides$window, "%Y-%m-%d %H:%M")
```

```
> # convert the data to timeseries and to xts for easy subsetting of data
> rides.xts = xts(x=rides$requested_rides, order.by=rides$window, start=c(2015, 7))
> rides.xts.train = rides.xts["/2016"] # start of data to end of 2016
```

```
> rides.auto.arima.train.model1 = auto.arima(rides.xts.train, trace=TRUE) # Auto Select
> rides.xts.train.diff1 = diff(rides.xts.train, differences = 1) # auto.arima chose a model with d = 1
> plot.ts(rides.xts.train.diff1)
```


```
> acf(rides.xts.train.diff1, lag.max=20, na.action = na.omit)
> pacf(rides.xts.train.diff1, lag.max=20, na.action = na.omit)
> rides.auto.arima.train.model1
```

```
> confint(rides.auto.arima.train.model1) # whichever row has the same sign, that variable is significant (when it comes to prediction)
```

```
> rides.auto.arima.train.model1.forecasts = forecast.Arima(rides.auto.arima.train.model1, h=6) # for next one hour
> rides.auto.arima.train.model1.forecasts
```

```
acf(rides.auto.arima.train.model1.forecasts$residuals, lag.max=20)
Box.test(rides.auto.arima.train.model1.forecasts$residuals, lag=20, type="Ljung-Box")
plotForecastErrors(rides.auto.arima.train.model1.forecasts$residuals)
mean(rides.auto.arima.train.model1.forecasts$residuals)
```

```
# what's the generated/real value?
rides.xts.rest = rides.xts["2017-01-01/"]
rides.xts.rest[1:6,]
```
