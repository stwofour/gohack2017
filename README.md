# README

### Original Problem Description

    https://go-hack.hackerearth.com/sprints/go-hack-1/dashboard/Ticoisa/idea/

Based on Go-JEK App usage data collected when App is used, Incoming API requests, Driver’s drop off Location/Time
of the day/weekday/month, Driver's ride patterns etc, App can suggest whether a Go-JEK driver should wait at drop-off
location for some more time (say X more minutes) for next pickup after a drop off or not.

App could just show Nothing/Red/Yellow/Green colors as recommendation. If there is an insufficient data or
if confidence is very low, App may not show anything. Based on chosen confidence interval, App could show appropriate color.

I had written down 6 or 7 thoughts. Half of them are based on data. I picked above one after reading below paragraph
in https://www.techinasia.com/startups-in-indonesia-indonesia-motorcycle-hailing-taxi-apps-jakarta-gojek

> However, the situation remained tense, because some Go-Jek drivers resorted to hiding their helmets and turning their
green jackets inside out to avoid being spotted. They then continued to sneak inside the apartment complex.
“It’s ridiculous. That they turn their jackets inside out makes it worse,” Marto says.

Even though above thought can't be completed in 24 hours, a basic thought/ideas along with basic implementation
in R (by assuming certain things around Go-JEK's data collection patterns) could be done.
This thought could be extended to send Go-JEK drivers to a location where demand could be high but supply is relatively less.

### In 24 hours...

I had learned some basic data analysis by completing one of rigorous online courses around Analytics in 2016. Based on the 
confidence that I had gained in that course, I decided to explore time series analysis for the first time. 
I took this hackathon as an opportunity (with some focus) to explore it. You might have seen me watching YouTube videos, 
reading Stackoverflow/random blogs during Hackathon hours :)

I tried to understand high level ideas of various mathematical models around time series analysis and associated R methods.
I know I can't master everything over a night (literally) but I think I learned some stuff and tried to apply the same.
Before this Hackathon _I don't know what I don't know_. Now, _I know what I don't know_.

### Assumptions

1. Required data is available with GoJEK.
1. To simplify, GoJEK operates in Bangalore.
1. GoJEK has split Bangalore in to multiple regions. Standard Term is S2?
1. Domlur has been split in to multiple regions. One of them is "Domlur Region 3". Each region has its own center - lat/long
1. *Domlur Region 3* includes Domlur Post Office, Diamond District.
1. Peak hours 7AM-10AM, 4PM-7PM.

### Approach

1. Data Extraction (from various sources)
1. Data Massaging (this can be combined with above step)
1. Group above data in 10-min windows (Tumbling Windows)
1. Train using one or more of the available methods. Pick a model based on data pattern and model's AIC or AIC(corrected) or BIC.
1. Predict for the number of requests from given "Region" in next 10 mins

### Step 1 - Data Extraction

From various GoJEK data sources, following data should be extracted.
One row per trip.

*Columns*

- driver id
- trip id
- user requested at (timestamp)
- pick up location lat
- pick up location lang
- pick up location (lat/lang to Human Readable Form)
- pick up region (Human Readable Form/Standardised)
- drop off location lat
- drop off location lang
- drop off location (lat/lang to Human Readable Form)
- drop off region (Human Readable Form/Standardised)
- time taken by this driver to accept this trip on his mobile (in ms)
- accepted from location lat
- accepted from location lang
- accepted from location (lat/lang to Human Readable Form)
- accepted from region (Human Readable Form/Standardised)
- start timestamp
- end timestamp
- wday (1-7)
- start date - weekend?
- end date - weekend?
- start day holiday season?
- end day holiday season?
- status of the trip (completed, cancelled by user, cancelled by driver, in progress, other)

### Step 2 - Tumbling Windows

For each region...
accumulate the number of ride requests in 10-min window. Based on amount of real data, we can adjust this time window.
But, for this exercise, let it be 10-min window.

*Columns*

- Region (Human Readable Form/Standardized)
- Region Center's Lat
- Region Center's Lang
- Timestamp (10-min window)
- number of requests (completed/started) # only column required for R time series analysis for a given region.

### Data

Since whole work is based on data, with the assumptions in *Assumptions* section, with a simple ruby script I generated
sample data for Step 1 and Step 2. Since these are random data, I directly generated data for Step 2. It is for date range
7 January 2015 to 30 June 2017 (Yes, in to the future) - it is a random data anyway.

Number of rides for each 10-min window starting from January 7, 2015 midnight was generated based on following rules. For this
exercise, we don't have to worry much about rules.

 - between 1 and 4 ride requests during normal hours...
 - between 3 and 6 ride requests during peak hours...
 - between 1 and 6 ride requests during normal hours between Sept and Feb as B'lore will have lots of incoming tourists (source: web)
 - between 1 and 8 ride requests during peak hours between Sept and Feb as B'lore will have lots of incoming tourists (source: web)

For Prediction, just the number of requests is sufficient (filtered by *Region*). In R, we can configure the *frequency*
and *start/end times* while loading time series data.

Generated Data is in *data* folder.

### Ruby Scripts

1. lib/generate_go_trips.rb - To generate output of Step 1 but I realized it is not really necessary as part of this
exercise. I don't have to feed this to Step 2 at this moment. I can straightaway generate sample data for Step 2.
I didn't include this script in this repo.
2. lib/generate_tumbling_windows.rb - To generate data that will be the outcome of Step 2

### R Scripts

In last 20 hours or so, I explored HoltWinters, ARIMA _{Autoregression Integration Moving Average}_ approach to do time series analysis.
Spent some time on other approaches as well. 

Random data that I have generated is not seasonal. It was not an intentional step. Generating seasonal data and try various models
would be one of next steps. 

I tried out ARIMA with various values. Then, I tried out *auto.arima* that would work for both
seasonal and non-seasonal data. For the data that I have generated, ARIMA(4,1,1) model was picked by *auto.arima*.

I had random data from January 7, 2015 to July 1, 2017 (Yes, Yes, in to the future - It is a random data anyway). I trained
a model with 2015 & 2016 data. Then, I tried to predict number of expected requests for below 10-min windows.

Jan 1, 2017 00:00, 6 (generated), 4.68 (predicted by ARIMA model)
Jan 1, 2017 00:10, 6 (generated), 4.67 (predicted by ARIMA model)

You can examine r_scripts/Rhistory file (which has just commands) and [r_scripts/log.md](https://github.com/stwofour/gohack2017/r_scripts/r_script_auto_arima.log.md) file (which shows results as well)

I did many iterations to get to the stage described in R scripts.

### Next Steps

1. Go deeper in theoretical ideas behind time series analysis. Explore UCM {Unobserved Component Models},
ETS _{Error, Trend, Seasonal}_, MSTS _{MultiSeasonal Time Series}_/TBATS etc. Use them based on data.
2. Expose it as API. API could recommend based on Prediction for given Region, number of available drivers in that region,
Driver (who is about to drop off a customer at given Region)'s time to accept new request etc. In some version of API, consider
driver's riding pattern as well - i.e. model has to consider the possible destinations as well.
3. Think about monitoring and evaluating the performance of chosen model constantly. Make it cloud friendly.
