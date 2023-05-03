# Bixi Bikes Usage Trends Analysis Using SQL & Tableau 

This repository contains an analysis of Bixi Bikes usage trends in Montreal, Canada. Bixi is a public bicycle sharing system that offers a convenient and affordable means of transportation. The analysis is performed using SQL to explore usage patterns, popular routes, and user demographics.

![Bixi Bikes](https://github.com/ThaoNguyen22192/This-is-my-first-one-/blob/main/BIXI%20Cover.png)

## Dataset

The dataset used in this analysis is sourced from the [Bixi Bikes Open Data Portal](https://bixi.com/en/open-data). It includes data on bike trips, stations, and user information.

## Prerequisites

To run the SQL queries in this analysis, you will need:

- A SQL client or database management system (e.g., MySQL, PostgreSQL, SQLite)
- Access to the Bixi Bikes dataset

## Analysis Overview

The analysis consists of the following sections:

1. **Data Preparation**: Import the Bixi Bikes dataset into your SQL database management system.
2. **Usage Trends**: Explore the usage trends by time (hour, day, month, and year).
3. **Popular Stations and Routes**: Identify the most popular stations and routes based on the number of trips.
4. **Customer segment**: Analyze the usage behaviour by customer segments (members and non-members) 

## Findings 

1. **Usage trend** 
Number of trips by months in 2016 & 2017 

SELECT 
	YEAR(start_date),
    COUNT(*) AS no_trips
FROM trips
GROUP BY YEAR(start_date); 

-- The number of trips for the year of 2016 broken down by month 
SELECT 
    MONTH(start_date) AS start_month,
    COUNT(*) AS no_trips
FROM trips
WHERE YEAR(start_date) = 2016
GROUP BY start_month; -- Add GROUP BY command to show the year to the result 

## Contributing

Feel free to contribute to this project by submitting a pull request or opening an issue. All contributions are welcome.


