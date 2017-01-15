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
> rides.xts = xts(x=rides$requested_rides, order.by=rides$window, start=c(2015, 7))
> rides.xts.train = rides.xts["/2016"]
> rides.auto.arima.train.model1 = auto.arima(rides.xts.train, trace=TRUE)


 ARIMA(2,1,2) with drift         : 396367
 ARIMA(0,1,0) with drift         : 447643.7
 ARIMA(1,1,0) with drift         : 419455.4
 ARIMA(0,1,1) with drift         : 396367.2
 ARIMA(0,1,0)                    : 447641.7
 ARIMA(1,1,2) with drift         : 396372.1
 ARIMA(3,1,2) with drift         : 396366.4
 ARIMA(3,1,1) with drift         : 396362.5
 ARIMA(2,1,0) with drift         : 408669.3
 ARIMA(4,1,2) with drift         : 396361.3
 ARIMA(4,1,2)                    : 396359.3
 ARIMA(3,1,2)                    : 396364.4
 ARIMA(5,1,2)                    : Inf
 ARIMA(4,1,1)                    : 396353.1
 ARIMA(3,1,0)                    : 403547
 ARIMA(4,1,1) with drift         : 396355.1
 ARIMA(3,1,1)                    : 396360.5
 ARIMA(5,1,1)                    : Inf
 ARIMA(4,1,0)                    : 400600.9

 Best model: ARIMA(4,1,1)
```
```
> rides.xts.train.diff1 = diff(rides.xts.train, differences = 1)
> plot.ts(rides.xts.train.diff1)
```

```
> acf(rides.xts.train.diff1, lag.max=20, na.action = na.omit)
```
![ACF on Diff](https://www.dropbox.com/sh/kwe2dusjwbh1zow/AADDN8tGTFMiO7jflzlX5O7ea?dl=0&preview=ACF+on+Diff.png)


```
> pacf(rides.xts.train.diff1, lag.max=20, na.action = na.omit)
```
![PACF on Diff](https://www.dropbox.com/sh/kwe2dusjwbh1zow/AADDN8tGTFMiO7jflzlX5O7ea?dl=0&preview=Partial+ACF+on+Diff.png)


```
> rides.auto.arima.train.model1
Series: rides.xts.train
ARIMA(4,1,1)

Coefficients:
         ar1     ar2     ar3     ar4      ma1
      0.0273  0.0200  0.0190  0.0119  -0.8238
s.e.  0.0074  0.0063  0.0054  0.0047   0.0067

sigma^2 estimated as 2.608:  log likelihood=-198173.4
AIC=396358.8   AICc=396358.8   BIC=396416.2
```

```
> confint(rides.auto.arima.train.model1)
           2.5 %      97.5 %
ar1  0.012702472  0.04186891
ar2  0.007709660  0.03226112
ar3  0.008448904  0.02956412
ar4  0.002644589  0.02120110
ma1 -0.836966116 -0.81057718
```

```
> rides.auto.arima.train.model1.forecasts = forecast.Arima(rides.auto.arima.train.model1, h=6) # for next one hour
> rides.auto.arima.train.model1.forecasts
         Point Forecast    Lo 80    Hi 80    Lo 95    Hi 95
62640001       4.679048 2.609391 6.748706 1.513781 7.844316
62640601       4.669529 2.557446 6.781612 1.439377 7.899681
62641201       4.644827 2.491858 6.797796 1.352146 7.937509
62641801       4.633023 2.438724 6.827323 1.277132 7.988915
62642401       4.640123 2.406491 6.873755 1.224078 8.056168
62643001       4.639498 2.370763 6.908232 1.169768 8.109228
```

```
> acf(rides.auto.arima.train.model1.forecasts$residuals, lag.max=20)
```
![ACF on Forecast Residuals](https://www.dropbox.com/sh/kwe2dusjwbh1zow/AADDN8tGTFMiO7jflzlX5O7ea?dl=0&preview=ACF+on+Forecast+Residuals.png)


```
> Box.test(rides.auto.arima.train.model1.forecasts$residuals, lag=20, type="Ljung-Box")

	Box-Ljung test

data:  rides.auto.arima.train.model1.forecasts$residuals
X-squared = 255.33, df = 20, p-value < 2.2e-16

> plotForecastErrors(rides.auto.arima.train.model1.forecasts$residuals)
```
![ForecastErrors](https://www.dropbox.com/sh/kwe2dusjwbh1zow/AADDN8tGTFMiO7jflzlX5O7ea?dl=0&preview=Histogram+of+Forecast+Errors.png)


```
> mean(rides.auto.arima.train.model1.forecasts$residuals)
[1] 1.982045e-05
```

```
> rides.xts.rest = rides.xts["2017-01-01/"]
> rides.xts.rest[1:6,] # Actual Data
                    [,1]
2017-01-01 00:00:00    6
2017-01-01 00:10:00    6
2017-01-01 00:20:00    6
2017-01-01 00:30:00    5
2017-01-01 00:40:00    3
2017-01-01 00:50:00    5

```