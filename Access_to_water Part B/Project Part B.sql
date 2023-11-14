-- PART 2 Beginning Our Data-Driven Journey in Maji Ndogo
-- Cleaning our data

-- Bring up the employee table. It has info on all of our workers, but note that the email addresses have not been added. 
-- We will have to send them reports and figures, so let's update it.
--  Luckily the emails for our department are easy: first_name.last_name@ndogowater.gov.

USE md_water_services ;

-- Bring up the employee table

SELECT*
FROM
employee;

--   Create eamail adress using this format (first_name.last_name@ndogowater.gov.)
SELECT
    LOWER(REPLACE(employee_name," ",".")) AS Email_address
FROM
employee;

SELECT
    CONCAT(
    LOWER(REPLACE(employee_name," ",".")),'@ndogowater.gov') AS Email_address
FROM
employee;

-- We have to update the database again with these email addresses, so before we do, 
-- let's use a SELECT query to get the format right, then use
-- UPDATE and SET to make the changes.

SET SQL_SAFE_UPDATES = 0;
UPDATE
employee
SET email =
    CONCAT(
    LOWER(REPLACE(employee_name," ",".")),'@ndogowater.gov') 
;

-- The phone numbers should be 12 characters long, consisting of the plus sign, area code (99), and the phone number digits.
-- However, it returns 13 characters,
-- WE USE LENGTH(to check how many character contained) and TRIM (to remove leading spaces) function 


SELECT
employee_name,
phone_number,
LENGTH(TRIM(phone_number))
FROM employee
;

-- UPDATING THE TABLE
UPDATE employee
SET phone_number = SUBSTRING(TRIM(phone_number), 1, 12)
WHERE LENGTH(TRIM(phone_number)) > 12;

-- Let's have a look at where our employees live in each town

SELECT 
	town_name,
    COUNT(*) AS employee_count
FROM
	employee

GROUP BY town_name;

/* let's use the database to get the employee_ids and use those to get the names,
 email and phone numbers of the three field surveyors with the most location visits.*/

   SELECT 
	assigned_employee_id,
    COUNT(*) AS Location_count
    FROM
    visits
    GROUP BY assigned_employee_id
    ORDER BY Location_count DESC 
    LIMIT 3 ;

-- Analysing locations
-- Create a query that counts the number of records per town

SELECT 
  town_name,
  COUNT(*) AS records_per_town
FROM 
	location
GROUP BY town_name
order by records_per_town DESC
;  
-- Now count the records per province.

SELECT 
province_name ,
  COUNT(*) AS records_per_province
FROM 
	location
GROUP BY province_name
order by   records_per_province DESC
;  
-- From this table, it's pretty clear that most of the water sources in the survey are situated in small rural communities, scattered across Maji Ndogo.

-- Create a result set showing:
	-- province_name ,town_name
-- An aggregated count of records for each town (consider naming this records_per_town)
SELECT
    province_name,
    town_name,
    COUNT(*) AS records_per_town
FROM
	employee
GROUP BY province_name, town_name
ORDER BY province_name
;

-- Within each province, further sort the towns by their record counts in descending order.

SELECT
    province_name,
    town_name,
	COUNT(*) AS records_per_town
FROM
	employee
GROUP BY province_name, town_name
ORDER BY province_name, records_per_town DESC
;

-- Finally, look at the number of records for each location type
SELECT DISTINCT
	location_type,
    COUNT(*) AS number_of_sources
FROM
	location
GROUP BY
	location_type;
    
-- lETS use Percntages to see the differences
-- Rural 

SELECT ROUND(23740 / (15910 + 23740) * 100,0);
-- URBAN
SELECT ROUND(15910 / (15910 + 23740) * 100,0);

-- Return all rows in water source

SELECT*
FROM water_source;


-- we want to count how many of each of the different water source types there are, and remember to sort them.

SELECT
	type_of_water_source,
    COUNT(*) AS number_of_sources
 FROM
	water_source 
GROUP BY type_of_water_source
ORDER  BY number_of_sources DESC;
    
-- question 3: What is the average number of people that are served by each water source?
-- Remember to make the numbers easy to read
SELECT
	type_of_water_source,
    AVG(ROUND(number_of_people_served,1)) AS Avg_poeple_per_source
 FROM
	water_source 
GROUP BY type_of_water_source
ORDER  BY Avg_poeple_per_source DESC;   

-- Now let’s calculate the total number of people served by each type of water source in total,
-- to make it easier to interpret, order them so the most people served by a source is at the top.

SELECT
	type_of_water_source,
    SUM(number_of_people_served)  AS Sum_poeple_per_source
 FROM
	water_source 
GROUP BY type_of_water_source
ORDER  BY Sum_poeple_per_source DESC; 

-- To Understand  let's use percentages
-- First, we need the total number of citizens then use the result of that 
-- Total Number of population  =27628140 from the querry below

SELECT
    SUM(number_of_people_served)  AS Sum_poeple_per_source
 FROM
	water_source ;
    
-- And divide each of the SUM(number_of_people_served) by that number, times 100, to get percentages.
    
SELECT
	type_of_water_source,
    (SUM(number_of_people_served)/27628140) *100 AS Sum_poeple_per_source 
 FROM
	water_source 
GROUP BY type_of_water_source
ORDER  BY Sum_poeple_per_source DESC; 

-- Let's round that off to 0 decimals, and order the results

SELECT
	type_of_water_source,
    ROUND((SUM(number_of_people_served)/27628140) *100,0) AS Sum_poeple_per_source 
 FROM
	water_source 
GROUP BY type_of_water_source
ORDER  BY Sum_poeple_per_source DESC; 


-- START OUR SOLUTION

-- write a query that ranks each type of source based on how many people in total use it

-- RANKING

SELECT
	type_of_water_source,
	SUM(number_of_people_served) as sum_w, 
    RANK() OVER (ORDER BY SUM(number_of_people_served)  DESC) AS rank_value
FROM
water_source
GROUP BY type_of_water_source
ORDER BY SUM(number_of_people_served)
;

-- we should remove tap_in_home from the ranking before we continue (because tap in home dont need improvement)
SELECT
    type_of_water_source,
    Sum_people_per_source,
    RANK() OVER (ORDER BY Sum_people_per_source DESC) AS rank_value
FROM (
    SELECT
        type_of_water_source,
        SUM(number_of_people_served) AS Sum_people_per_source
    FROM
        water_source
    WHERE type_of_water_source <> 'tap_in_home'
    GROUP BY
        type_of_water_source
) AS subquery
ORDER BY Sum_people_per_source DESC;

-- which shared taps or wells should be fixed first?
-- Querry below returs  all water source nee to be upgraded

SELECT
	source_id,
    type_of_water_source,
    number_of_people_served
FROM
	water_source
WHERE
type_of_water_source IN ('river','shared_tap')
ORDER BY 'number_of_people_served' 
;

 -- USING RANK 
 -- We rank to see our priority first
SELECT
    source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER (ORDER BY number_of_people_served DESC) AS rank_value
FROM
    water_source
WHERE
    type_of_water_source IN ('river', 'shared_tap')
ORDER BY number_of_people_served DESC;


-- ANALYSING THE  QUEQUES

/*These are some of the things I think are worth looking at:
1. How long did the survey take?
2. What is the average total queue time for water?
3. What is the average queue time on different days?
4. How can we communicate this information efficiently?*/
-- HINT: I had to read up a bit on control flow, DateTime and window functions to do these, so you probably will have to as well


/*Question 1:


To calculate how long the survey took, we need to get the first and last dates 
(which functions can find the largest/smallest value), 
and subtract them. Remember with DateTime data, we can't just subtract the values. We have to use a function to get the difference in days.*/

-- Find the Earliest Date:
-- -- MINIMUM  DATE 2021-01-01 09:10:00
SELECT
MIN(time_of_record)
FROM visits;

-- MAXIMUM DATE 2023-07-14 13:53:00
SELECT
MAX(time_of_record)
FROM visits;

-- Difference = 924 days 
SELECT
	DATEDIFF( MAX(time_of_record),MIN(time_of_record)) AS Time_taken
FROM visits;

/*Question 2:
Let's see how long people have to queue on average in Maji Ndogo. Keep in mind that many sources like taps_in_home have no queues. These
are just recorded as 0 in the time_in_queue column, so when we calculate averages, we need to exclude those rows. Try using NULLIF() do to
this.*/
-- Avg_time_in_queue = 123.2574
SELECT
	AVG(NULLIF(time_in_queue,0)) AS Avg_time_in_queue
FROM
	visits;    
    
-- Question 3:

-- So let's look at the queue times aggregated across the different days of the week.
-- we need to calculate the average queue time, grouped by day of the week.
SELECT	
    DAYNAME(time_of_record) AS day_of_week,
    AVG(time_in_queue) AS avg_time_in_queue
FROM
	visits
GROUP BY day_of_week;

-- Question 4
-- Question We can also look at what time during the day people collect water. Try to order the results in a meaningful way

SELECT	
	HOUR(time_of_record) AS hour_of_day,
    AVG(time_in_queue) AS avg_time_in_queue
FROM
	visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- To format time into a specific display format, we can use TIME_FORMAT(time, format)
-- converts it into a format like %H:00 which is easy to read
-- 
SELECT	
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(time_in_queue),0) AS avg_time_in_queue
FROM
	visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- break down the queue times for each hour of each day? In a spreadsheet, we can just create a pivot table.
-- focusing on Sunday

SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record),
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END AS Sunday
FROM
visits
WHERE
time_in_queue != 0; -- this exludes other sources with 0 queue times.

/*By adding AVG() around the CASE() function, we calculate the average, but since all of the other days' values are 0, 
we get an average for Sunday only, rounded to 0 decimals. To aggregate by the hour,
 we can group the data by hour_of_day, and to make the table chronological, we also order
by hour_of_day.*/

SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,

-- SUNDAY

ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,

-- MONDAY

ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,

-- TUESDAY

ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,
	
-- UPPER(Wednesday)

ROUND(AVG(
 CASE 
 WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
 ELSE NULL
 END
 ),0) AS Wednesday,
 
 -- Thursday
 
 ROUND(AVG(
 CASE
 WHEN
 DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
 ELSE NULL
 END
 ),0) AS Thursday,
 
-- Friday

ROUND(AVG(
CASE
WHEN
DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Friday,

-- saturday

 ROUND(AVG(
CASE
WHEN
DAYNAME(time_of_record) = 'saturday' THEN time_in_queue
ELSE NULL
END
),0) AS sarturday 
 
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;
--  END OF QUERY FOR WEEKDAYS

-- How many employees live in Dahabu? Rely on one of the queries we used in the project to answer this

SELECT 
	town_name,
	assigned_employee_id,
    COUNT(*) AS 
	town_name
	FROM
	employee
where
	town_name = 'Dahabu'
    group by assigned_employee_id
  ;
  
-- How many employees live in Harare, Kilimani? Modify one of your queries from the project to answer this question. 
 
SELECT
	assigned_employee_id,
	town_name,
    COUNT(*) AS asde
FROM
	employee
where
	town_name  IN ('Kilimani' )    
    GROUP BY assigned_employee_id
    order by  town_name    
  ;
  
-- How many people share a well on average? Round your answer to 0 decimals.

SELECT
	type_of_water_source,
    AVG(number_of_people_served) AS s
FROM water_source 
group by type_of_water_source ;

-- ADDITIONAL QUESTION FROM DATASET

--	-- Question 1
---- Which SQL query will produce the date format "DD Month YYYY" from the time_of_record column in the visits
-- table, as a single column? Note: Monthname() acts in a similar way to DAYNAME().

SELECT CONCAT(day(time_of_record), " ", month(time_of_record), " ", year(time_of_record)) FROM visits;


-- Question 2

/*You are working with an SQL query designed to calculate the Annual Rate of Change (ARC) for basic rural water services:
SELECT
name,
wat_bas_r - LAG(wat_bas_r) OVER (PARTITION BY (a) ORDER BY (b)) 
FROM 
global_water_access
ORDER BY
name;*/

SELECT 
	name,
    wat_bas_r,
    LAG(wat_bas_r) OVER (PARTITION BY name ORDER BY year),
	wat_bas_r - LAG(wat_bas_r) OVER (PARTITION BY name ORDER BY year)AS ARC
FROM 
	global_water_access
WHERE 
wat_bas_r IS NOT NULL
ORDER BY name
;

-- QUESTION 3

/*What are the names of the two worst-performing employees who visited the fewest sites, 
and how many sites did the worst-performing employee visit?Modify your queries from the “Honouring the workers” section.*/
SELECT
employee_name,
assigned_employee_id
FROM  
employee 
;

-- QUESTION  4

-- What are the names of the two worst-performing employees who visited the fewest sites, and how many 
-- sites did the worst-performing employee visit? Modify your queries from the “Honouring the workers” section.
SELECT
	employee.assigned_employee_id,
	visit_count
FROM
	visits,
    employee 
WHERE
    ;
    
 -- Question 6
 
 /*One of our employees, Farai Nia, lives at 33 Angelique Kidjo Avenue. What would be the result if we TRIM() her address? */
    SELECT
        employee_name,
        TRIM(address)    AS trimmed_name
    FROM
    employee
    WHERE address in ('33 Angelique Kidjo Avenue')AND
     employee_name = 'Farai Nia';

-- Question 7
-- How many employees live in Dahabu? Rely on one of the queries we used in the project to answer this

SELECT
    town_name,
    COUNT(*) AS counts
FROM
 employee
WHERE
town_name = 'Dahabu';
-- question 8 How many employees live in Harare, Kilimani? Modify one of your queries from the project to answer this question.
SELECT
	employee_name,
	town_name,
    province_name
FROM
	employee
WHERE
	town_name IN ('Harare');
    
-- question 9
--  How many people share a well on average? Round your answer to 0 decimals.

SELECT
ROUND(AVG(number_of_people_served),0) AS avg
FROM
	water_source
WHERE
   type_of_water_source = 'well'
ORDER BY number_of_people_served;

-- Question 10
--  Consider the query we used to calculate the total number of people served by each water source:

SELECT
	type_of_water_source,
	SUM(number_of_people_served) AS population_served
FROM
	water_source
WHERE type_of_water_source LIKE "%tap%"
GROUP BY
	type_of_water_source
ORDER BY
	population_served DESC;
    -- question 10 begin
    -- Use the pivot table we created to answer the following question.
   -- What are the average queue times for the following times?
-- Saturday from 12:00 to 13:00
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,

-- surtaday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'saturday' THEN time_in_queue
ELSE NULL
END
),0) AS saturday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,

-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,
-- Tuesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday
-- Wednesday
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;
-- END OF PROJECT PART 2(SEE PART 3)