/* Bixi Project Deliverable 1
 
 Brainstation Jan 26, 2023 
 
 Author: Thao Nguyen, student
  */ 
-- check if using right sql mode 
SELECT @@GLOBAL.sql_mode;

USE bixi; 

-- Question 1.1: The total number of trips for the year of 2016 
SELECT YEAR(start_date), COUNT(*) 
FROM trips
WHERE YEAR(start_date) = 2016
GROUP BY YEAR(start_date); -- Add GROUP BY command to show the year to the result 

-- Question 1.2: The total number of trips for the year of 2017
SELECT YEAR(start_date),COUNT(*) 
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY YEAR(start_date); -- Add GROUP BY command to show the year to the result 

-- Summary of Question 1.1 & 1.2 in one result for better comparison using GROUP BY 
SELECT 
	YEAR(start_date),
    COUNT(*) AS no_trips
FROM trips
GROUP BY YEAR(start_date); 

-- Question 1.3: The number of trips for the year of 2016 broken down by month 
SELECT 
    MONTH(start_date) AS start_month,
    COUNT(*) AS no_trips
FROM trips
WHERE YEAR(start_date) = 2016
GROUP BY start_month; -- Add GROUP BY command to show the year to the result 


-- Question 1.4: The number of trips for the year of 2017 broken down by month 
SELECT 
    MONTH(start_date) AS start_month,
    COUNT(*) AS no_trips
FROM trips
WHERE YEAR(end_date) = 2017
GROUP BY start_month; -- Add GROUP BY command to show the year to the result 

-- Summary of Question 1.3 & 1.4 in one result for better comparison using GROUP BY
SELECT 
	YEAR(start_date) AS start_year,
    MONTH(start_date) AS start_month,
	COUNT(*) AS no_trips
FROM trips
GROUP BY start_year, start_month;

-- Question 1.5: The average number of trips a day for each year-month combination in the dataset
SELECT 
	YEAR(start_date) AS start_year,
    MONTH(start_date) AS start_month,
	COUNT(*) AS total_trips_month, 
    COUNT(*)/ COUNT(DISTINCT DAY(start_date)) AS avg_trips_per_day -- Total trips divided by the number of days having at least 1 trip started
FROM trips
GROUP BY start_year, start_month;

-- Question 1.6: Save query results from the previous question by creating a table called working_table1
CREATE TABLE working_table1 AS
SELECT 
	YEAR(start_date) AS start_year,
    MONTH(start_date) AS start_month,
	COUNT(*) AS total_trips_month, 
    COUNT(*)/ COUNT(DISTINCT DAY(start_date)) AS avg_trips_per_day -- Total trips divided by the number of days having at least 1 trip started
FROM trips
GROUP BY start_year, start_month;

SELECT *
FROM working_table1;

DESC working_table1; 

-- Question 2.1: The total number of trips broken down by membership status 
SELECT 
	is_member, 
    COUNT(*) AS no_trips 
    
FROM trips 
WHERE YEAR(start_date) = 2017
GROUP BY is_member; 

-- Question 2.2: The percentage of total trips by menbers for the year 2017 broken down by month 
SELECT 
    YEAR(start_date) AS year_, 
    MONTH(start_date) AS month_, 
    SUM(is_member) AS no_members,
    COUNT(*) AS total_trips,
    CONCAT( ROUND (SUM(is_member)/ COUNT(*)*100,2),'%') AS percent_members
FROM trips 
WHERE YEAR(start_date) = 2017
GROUP BY 
    YEAR(start_date),  
    MONTH(start_date);

-- Question 4.1: 5 most popular starting station (no subquery) ~25s 
SELECT 
	t.start_station_code, 
    s.name AS station_name,
	COUNT(*) AS no_trips 
FROM trips AS t 
LEFT JOIN stations AS s
ON t.start_station_code = s.code
GROUP BY 
	t.start_station_code,
    station_name
ORDER BY no_trips DESC
LIMIT 5; 

-- Question 4.2: 5 most popular starting station (w/ sub query) ~5s
-- w/ sub query the executing time is much short by avoiding joining large dataset, the subquery shorten to dataset by grouping it by station code. 
SELECT 
	st.start_station_code, 
	s.name AS station_name, 
    st.no_trips
FROM (
	SELECT 
		start_station_code,
        COUNT(*) AS no_trips
	FROM trips 
    GROUP BY start_station_code) AS st
LEFT JOIN stations AS s
ON s.code = st.start_station_code
ORDER BY st.no_trips DESC
LIMIT 5; 

-- Question 5.1a: break up the hours of the day for for starts

SELECT 
	st.start_station_code, 
	s.name AS station_name, 
	start_time_of_day,
    st.no_starts
FROM (
	SELECT 
		start_station_code,
        start_time_of_day,
		COUNT(start_time_of_day) AS no_starts
	FROM 
		(SELECT 
			start_station_code,
			CASE 
				WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning" 
				WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon" 
				WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening" 
				ELSE "night" 
				END AS "start_time_of_day"
		FROM trips) AS sub_start_table
	GROUP BY
			start_station_code,
            start_time_of_day)
	AS st
LEFT JOIN stations AS s
ON s.code = st.start_station_code  
WHERE s.name LIKE '%Mackay%'
ORDER BY no_starts DESC;
    

-- Question 5.1b: break up the hours of the day for ends

SELECT 
	st.end_station_code, 
	s.name AS station_name, 
    st.end_time_of_day,
    st.no_ends
FROM (
	SELECT 
		end_station_code,
        end_time_of_day,
        COUNT(end_time_of_day) AS no_endS
	FROM 
		(SELECT 
			end_station_code,
			CASE 
				WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN "morning" 
				WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN "afternoon" 
				WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN "evening" 
				ELSE "night" 
				END AS "end_time_of_day" 
		FROM trips) AS sub_end_table
	GROUP BY
			end_station_code,
            end_time_of_day)
	AS st
LEFT JOIN stations AS s
ON s.code = st.end_station_code  
WHERE s.name LIKE '%Mackay%'
ORDER BY no_ends DESC;

-- Question 5extra: Starts by time of days of all stations
SELECT 
	start_time_of_day,
    no_starts,
    percent
FROM (
	SELECT 
        start_time_of_day,
		COUNT(*) AS no_starts, 
        CONCAT (ROUND (100 * COUNT(*)/ (SELECT COUNT(*) FROM trips),2),'%') AS percent
	FROM 
		(SELECT 
			CASE 
				WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning" 
				WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon" 
				WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening" 
				ELSE "night" 
			END AS "start_time_of_day"
		FROM trips) AS sub_start_table
	GROUP BY
            start_time_of_day)
	AS st
ORDER BY no_starts DESC; 

-- Question 5extra: Ends by time of days of all stations
SELECT 
	end_time_of_day,
    no_ends,
    percent
FROM (
	SELECT 
        end_time_of_day,
		COUNT(*) AS no_ends, 
        CONCAT (ROUND (100 * COUNT(*)/ (SELECT COUNT(*) FROM trips),2),'%') AS percent
	FROM 
		(SELECT 
			CASE 
				WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN "morning" 
				WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN "afternoon" 
				WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN "evening" 
				ELSE "night" 
			END AS "end_time_of_day"
		FROM trips) AS sub_ens_table
	GROUP BY
            end_time_of_day)
	AS st
ORDER BY no_ends DESC; 

-- Question 6.1: count the number of starting trips per station 
SELECT 
	start_station_code, 
    COUNT(*) AS no_starts
FROM trips
GROUP BY start_station_code
ORDER BY start_station_code;

-- Question 6.2: count the number fo round trips per station 
SELECT 
	start_station_code, 
    COUNT(*) AS no_round_trips
FROM trips
WHERE start_station_code = end_station_code
GROUP BY start_station_code
ORDER BY start_station_code;

-- Question 6.3: Combine the above querries to calculate the % round trips
SELECT 
	rt.start_station_code, 
    rt.station_name,
    COUNT(*) AS no_starts, 
    rt.no_round_trips, 
    CONCAT(ROUND(rt.no_round_trips/ COUNT(*)*100,2),'%') AS percent_round_trips
FROM 
	( SELECT 
		trips.start_station_code, 
		COUNT(*) AS no_round_trips, 
        stations.name AS station_name 
	FROM trips 
    LEFT JOIN stations -- add names of stations to the View
    ON trips.start_station_code = stations.code
	WHERE start_station_code = end_station_code
	GROUP BY 
		start_station_code,
        station_name)
    AS rt 
LEFT JOIN trips AS t
ON t.start_station_code = rt.start_station_code
GROUP BY 
	rt.start_station_code, 
    rt.station_name
ORDER BY rt.start_station_code; 
    
-- Question 6.4
SELECT 
	rt.start_station_code, 
    rt.station_name,
    COUNT(*) AS no_starts, 
    rt.no_round_trips, 
    CONCAT(ROUND(rt.no_round_trips/ COUNT(*)*100,2),'%') AS percent_round_trips
FROM 
	( SELECT 
		trips.start_station_code, 
		COUNT(*) AS no_round_trips, 
        stations.name AS station_name 
	FROM trips 
    LEFT JOIN stations -- add names of stations to the View
    ON trips.start_station_code = stations.code
	WHERE start_station_code = end_station_code
	GROUP BY 
		start_station_code,
        station_name)
    AS rt 
LEFT JOIN trips AS t
ON t.start_station_code = rt.start_station_code
GROUP BY 
	rt.start_station_code, 
    rt.station_name
HAVING
	COUNT(*) >=500 AND 
    ROUND(rt.no_round_trips/ COUNT(*)*100,2) >= 10
ORDER BY percent_round_trips DESC;

-- Exploration % member at top 10% round trip stations
SELECT 
	start_station_code,
    is_member,
    AVG(duration_sec),
    COUNT(is_member)
FROM trips
WHERE start_station_code IN
	(SELECT 
		start_station_code
	FROM percent_round_trips
	WHERE 
		no_starts >=500 AND 
		percent_round_trips >= 10)
GROUP BY 
	start_station_code,
    is_member; 

-- Exploration All stations durations and % member 
SELECT 
    is_member,
    AVG(duration_sec),
    COUNT(*),
    COUNT(*)/(SELECT COUNT(*) FROM trips) 
FROM trips
GROUP BY is_member;

-- Exploration Top round trips (>10% round trips) duration and % members 
-- The % of members in top round trips city is much less then that of total stations 
SELECT 
    is_member,
    AVG(duration_sec),
    COUNT(is_member), 
    COUNT(is_member)/ 
		(SELECT SUM(no_starts)
		FROM percent_round_trips
		WHERE 
		no_starts >=500 AND 
		percent_round_trips >= 10) AS percent_members
FROM trips
WHERE start_station_code IN
	(SELECT 
		start_station_code
	FROM percent_round_trips
	WHERE 
		no_starts >=500 AND 
		percent_round_trips >= 10)
GROUP BY 
    is_member; 
    
SELECT 
	SUM(no_starts),
    SUM(no_starts)/ (SELECT COUNT(*) FROM trips)
FROM percent_round_trips
WHERE 
	no_starts >=500 AND 
	percent_round_trips >= 10;
