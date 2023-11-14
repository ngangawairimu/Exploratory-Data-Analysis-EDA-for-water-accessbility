-- SQL project part 4
-- Considering the previus part now we nned 
-- All of the information about the location of a water source is in the location table, specifically the town and province of that water source.
 -- • water_source has the type of source and the number of people served by each source.
-- • visits has queue information, and connects source_id to location_id. There were multiple visits to sites, so we need to be careful to
				-- include duplicate data (visit_count > 1 ).
-- • well_pollution has information about the quality of water from only wells, so we need to keep that in mind when we join this table
-- question 1, we will need province_name and town_name from the location table. We also need to know type_of_water_source and
-- number_of_people_served from the water_source table.
SELECT
		v.location_id,
		v.visit_count,
        l.province_name,
        l.town_name
FROM
		visits AS v
JOIN
	location AS l
ON
	l.location_id = v.location_id
;
--  we can join the water_source table on the key shared between water_source and visits.
SELECT
		v.location_id,
		v.visit_count, -- Note that there are rows where visit_count > 1 -- For example, add this to your query: WHERE visits.location_id = 'AkHa00103'
        l.province_name,
        l.town_name,
        ws.type_of_water_source,
        ws.number_of_people_served
FROM
		visits AS v 
JOIN
	location AS l
ON
	l.location_id = v.location_id
JOIN
	water_source AS ws
ON
	ws.source_id = v.source_id
WHERE v.location_id = 'AkHa00103' -- remove after you query where part
-- there are rows where visit_count > 1
;-- If we aggregate, we will include these rows, so our results will be incorrect.

-- To fix this, we can just select rows where visits.visit_count = 1.
SELECT
		v.location_id,
		v.visit_count, 
        l.province_name,
        l.town_name,
        ws.type_of_water_source,
        ws.number_of_people_served
FROM
		visits AS v 
JOIN
	location AS l
ON
	l.location_id = v.location_id
JOIN
	water_source AS ws
ON
	ws.source_id = v.source_id
WHERE 
 v.visit_count = 1;
 
 -- Since we have confirmed the joins work correctly
 -- we can remove the location_id and visit_count columns and 
 -- Add the location_type column from location and time_in_queue from visits to our results set.
 SELECT
		l.location_type,
        l.province_name,
        l.town_name,
        ws.type_of_water_source,
        ws.number_of_people_served,
        v.time_in_queue
FROM
		visits AS v 
JOIN
	location AS l
ON
	l.location_id = v.location_id
JOIN
	water_source AS ws
ON
	ws.source_id = v.source_id
WHERE 
 v.visit_count = 1;
 
 -- Last one! Now we need to grab the results from the well_pollution table
 /*This one is a bit trickier. The well_pollution table contained only data for well. If we just use JOIN, we will do an inner join, so that only records
that are in well_pollution AND visits will be joined. We have to use a LEFT JOIN to join theresults from the well_pollution table for well
sources, and will be NULL for all of the rest. Play around with the different JOIN operations to make sure you understand why we used LEFT JOIN.*/
 SELECT
		l.location_type,
        l.province_name,
        l.town_name,
        ws.type_of_water_source,
        ws.number_of_people_served,
        v.time_in_queue,
        w.results
FROM
		visits AS v 
LEFT JOIN 
well_pollution AS w
ON
w.source_id = v.source_id
INNER JOIN
	location AS l
ON
	l.location_id = v.location_id
INNER JOIN
	water_source AS ws
ON
	ws.source_id = v.source_id
WHERE 
 v.visit_count = 1;
 
 /*this table contains the data we need for this analysis. Now we want to analyse the data in the results set. We can either create a CTE, and then
query it, or in my case, I'll make it a VIEW so it is easier to share with you. I'll call it the combined_analysis_table.*/

 CREATE VIEW combined_analysis_table AS
-- This view assembles data from different tables into one to simplify analysis
SELECT
water_source.type_of_water_source AS source_type,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served AS people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;
 -- This view creates a "table" that pulls all of the important information from different tables into one
 
 -- THE LAST ANALYSIS
 --  Create pivot table! This time, we want to break down our data into provinces or towns and source types. 
 
WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name; -- province_totals is a CTE that calculates the sum of all the people surveyed grouped by province

-- If you replace the query above with this one
-- to get a table of province names and summed up populations for each province.
WITH province_totals AS (-- This CTE calculates the population of each province
							SELECT
							province_name,
							SUM(people_served) AS total_ppl_serv
							FROM
							combined_analysis_table
							GROUP BY
							province_name
							)
SELECT
*
FROM
province_totals;


-- Let's aggregate the data per town now
-- Remeber  that there are two towns in Maji Ndogo called Harare. One is in Akatsi, and one is in Kilimani.
-- So when we just aggregate by town, SQL doesn't distinguish between the different Harare's, so it combines their results.
-- To solve we have to group by province first, then by town, so that the duplicate towns are distinct because they are in different towns.
 -- Since there are two Harare towns, we have to group by province_name and town_name
WITH town_totals AS (-- This CTE calculates the population of each town
SELECT 
		province_name, 
		town_name, 
		SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY
		province_name,town_name
)
SELECT
		ct.province_name,
		ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
		combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
	town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name -- tt  This CTE calculates the population of each town
GROUP BY -- We group by province first, then by town.
		ct.province_name,
		ct.town_name
ORDER BY
	ct.town_name;

-- Let's store it as a temporary table first, so it is quicker to access
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (-- This CTE calculates the population of each town
SELECT 
		province_name, 
		town_name, 
		SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY
		province_name,town_name
)
SELECT
		ct.province_name,
		ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
		combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
	town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name -- tt  This CTE calculates the population of each town
GROUP BY -- We group by province first, then by town.
		ct.province_name,
		ct.town_name
ORDER BY
	ct.town_name;
    -- order the results set by each column -- river DESC
										-- sort the data by province_name
-- which town has the highest ratio of people who have taps, but have no running water?
SELECT
		province_name,
		town_name,
		ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *100,0) AS Pct_broken_taps
FROM
town_aggregated_water_access;

-- SUMMARY REPORT In page 22 23
-- CREATE A PROGRESS TABLE
-- see page  27 


CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
Address VARCHAR(50),
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50),
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Date_of_completion DATE,
Comments TEXT
);

-- Project_progress_query
SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id;

INSERT INTO project_progress (
    `source_id`,
    `Address`,
    `Town`,
    `Province`,
    `Source_type`,
    `Improvement`
)
SELECT
    water_source.source_id,
    location.address,
    location.town_name,
    location.province_name,
    water_source.type_of_water_source,
    CASE
        WHEN well_pollution.results = "Contaminated: Chemical" THEN "Install RO filter"
        WHEN well_pollution.results = "Contaminated: Biological" THEN "Install UV and RO filter"
        WHEN water_source.type_of_water_source = "river" THEN "Drill well"
        WHEN water_source.type_of_water_source = "shared_tap" AND visits.time_in_queue >= 30
            THEN CONCAT("Install ", FLOOR(visits.time_in_queue / 30), " taps nearby"
                            -- " tap", IF(FLOOR(visits.time_in_queue / 30) > 1, "s", ""), " nearby" -- comment line above and then uncomment this if you want: 1 tap, 2 taps, 3 taps...
                        )
        WHEN water_source.type_of_water_source = "tap_in_home_broken" THEN "Diagnose local infrastructure"
        ELSE NULL
    END Improvements
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1 -- This must always be true
    AND ( -- AND one of the following (OR) options must be true as well.
        well_pollution.results != 'Clean'
            OR
        water_source.type_of_water_source IN ('tap_in_home_broken','river')
            OR (
                water_source.type_of_water_source = 'shared_tap'
                    AND
                visits.time_in_queue >= 30
            )
    )
;

--  let's filter the data to only contain sources we want to improve by thinking through the logic first.

/*1. Only records with visit_count = 1 are allowed.
2. Any of the following rows can be included:
a. Where shared taps have queue times over 30 min.
b. Only wells that are contaminated are allowed -- So we exclude wells that are Clean
c. Include any river and tap_in_home_broken sources.*/


SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND ( -- AND one of the following (OR) options must be true as well.
results != 'Clean'
OR type_of_water_source IN ('tap_in_home_broken','river') 
OR (type_of_water_source = 'shared_tap' AND time_in_queue >=30 )
)-- queue times over 30 min
;



-- MCQ question 1
-- How many UV filters do we have to install in total?
SELECT
s.type_of_water_source,
biological
FROM
water_source AS s
join
well_pollution
ON
well_pollution.source_id = s.source_id
WHERE type_of_water_source = 'well'

;

-- QUESTION 2
-- Which province should we send drilling equipment to first?
WITH town_totals AS (-- This CTE calculates the population of each town
						SELECT 
								province_name, 
								town_name, 
								SUM(people_served) AS total_ppl_serv
						FROM combined_analysis_table
						GROUP BY
								province_name,town_name
						)
SELECT
		ct.province_name,
		ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
		combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
	town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name 
    WHERE source_type = 'river'
    -- tt  This CTE calculates the population of each town
GROUP BY -- We group by province first, then by town.
		ct.province_name,
		ct.town_name
ORDER BY
	ct.town_name;   
    
    -- question 4 Why was the LEFT JOIN operation used with the well_pollution table in the queries?
    SELECT
		l.location_type,
        l.province_name,
        l.town_name,
        ws.type_of_water_source,
        ws.number_of_people_served,
        v.time_in_queue,
        w.results
FROM
		visits AS v 
LEFT JOIN 
well_pollution AS w
ON
w.source_id = v.source_id
INNER JOIN
	location AS l
ON
	l.location_id = v.location_id
INNER JOIN
	water_source AS ws
ON
	ws.source_id = v.source_id
WHERE 
 v.visit_count = 1;
 
 -- Question 5 Which towns should we upgrade shared taps first?
 WITH town_totals AS (-- This CTE calculates the population of each town
SELECT 
		province_name, 
		town_name, 
		SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY
		province_name,town_name
)
SELECT
		ct.province_name,
		ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap
FROM
		combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
	town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name -- tt  This CTE calculates the population of each town
GROUP BY -- We group by province first, then by town.
		ct.province_name,
		ct.town_name
;
 
-- Question 7 What is the maximum percentage of the population using rivers in a single town in the Amanzi province?

WITH town_totals AS (-- This CTE calculates the population of each town
SELECT 
		province_name, 
		town_name, 
		SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY
		province_name,town_name
)
SELECT
		ct.province_name,
		ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river
FROM
		combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
	town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name -- tt  This CTE calculates the population of each town

WHERE ct.province_name = 'Amanzi'
GROUP BY -- We group by province first, then by town.
		ct.province_name,
		ct.town_name
;

    