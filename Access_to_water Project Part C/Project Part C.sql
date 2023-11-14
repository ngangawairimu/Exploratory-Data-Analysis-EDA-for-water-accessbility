-- This third part of the integrated project covers Entity-relationship data models and Joins and set operations
 -- we will pull data from many different tables and apply some statistical analyses 
 -- to examine the consequences of an audit report that cross-references a random sample of records.
 
-- Entity-Relationship Diagram (ERD) 

-- Ok, I sent you a .csv file of the auditor's results. You should get it loaded into SQL. 
-- You will have to think back to the start of our journey on how to do that.


DROP TABLE IF EXISTS  auditor_report;
CREATE TABLE  auditor_report(
		 location_id VARCHAR(32),
		 type_of_water_source VARCHAR(64),
		 true_water_source_score int DEFAULT NULL,
		statements VARCHAR(255)
);

/*we will have to compare the quality scores in the water_quality table to the auditor's scores. The auditor_report table
used location_id, but the quality scores table only has a record_id we can use. The visits table links location_id and record_id, so we
can link the auditor_report table and water_quality using the visits table.*/

-- So first, grab the location_id and true_water_source_score columns from auditor_report.
SELECT
	location_ID,
	true_water_source_score
FROM
auditor_report;
    
-- we join the visits table to the auditor_report table. Make sure to grab subjective_quality_score(employee score), record_id and location_id
SELECT
	r.location_ID AS audited_location,
    r.true_water_source_score,
	v.record_id ,
	v.location_id AS visits_location
FROM
	auditor_report AS r
INNER JOIN
	visits  AS v
ON
r.location_ID = v.location_ID;
;

-- retrieve the corresponding scores from the water_quality table. 

-- we'll JOIN the visits table and the water_quality table, using the record_id as the connecting key.    
-- We are particularly interested in the subjective_quality_score in water_quality Table.  
-- We join now 3 tables(viists,water_quality,auditors report)
SELECT
		auditor_report.location_id AS audit_location,
		auditor_report.true_water_source_score,
		visits.location_id AS visit_location,
		visits.record_id,
		water_quality.employee_score
FROM
auditor_report
JOIN
	visits
ON auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
water_quality.record_id = visits.record_id;

-- Let's leave record_id and rename the scores to surveyor_score and auditor_score to make it clear which scores
-- we're looking at in the results set.

SELECT
		auditor_report.location_id AS audit_location,
		auditor_report.auditor_score  ,
		visits.location_id AS visit_location,
		visits.record_id,
		water_quality.employee_score
FROM
auditor_report
JOIN
	visits
ON auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
water_quality.record_id = visits.record_id;

-- UPDATING auditor_report TABLE
ALTER TABLE
auditor_report
RENAME COLUMN true_water_source_score to auditor_score;

ALTER TABLE
water_quality
RENAME COLUMN subjective_quality_score to employee_score;

/*Since were joining 1620 rows of data, we want to keep track of the number of rows we get each time we run a query. We can either set the
maximum number of rows we want from "Limit to 1000 rows" to a larger number like 10000, or we can force SQL to give us all of the results, using
LIMIT 10000.*/

SELECT
	auditor_report.location_id ,
	auditor_report.auditor_score,
	visits.record_id,
	water_quality.employee_score
FROM
auditor_report
JOIN
	visits
ON auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
water_quality.record_id = visits.record_id
WHERE
	water_quality.employee_score = auditor_report.auditor_score 
LIMIT 10000 ;

-- But that means that 102 records are incorrect. So let's look at those. You can do it by adding one character in the last query(!=)
SELECT
	auditor_report.location_id ,
	auditor_report.auditor_score,
	visits.record_id,
	water_quality.employee_score
FROM
	auditor_report
JOIN
	visits
ON auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
water_quality.record_id = visits.record_id
WHERE
	water_quality.employee_score != auditor_report.auditor_score AND  visits.visit_count
= 1;

-- Once you're done, remove the columns and JOIN statement for water_sources again.

/* we need to grab the type_of_water_source column from the water_source table and call it survey_source, using the
source_id column to JOIN. Also select the type_of_water_source from the auditor_report table, and call it auditor_source*/
SELECT
	r.location_id,
	r.auditor_score,
	visits.record_id,
	water_quality.employee_score,
	r.type_of_water_source AS auditor_source,
	s.type_of_water_source AS survey_source
FROM
auditor_report AS r
JOIN
	visits
ON
visits.location_id = r.location_id
JOIN
	water_quality
ON
water_quality.record_id = visits.record_id
JOIN
	water_source AS s
ON 
s.source_id =visits.source_id 
WHERE
	water_quality.employee_score <> r.auditor_score AND  visits.visit_count
	= 1
    ;

-- -- Once you're done, remove the columns and JOIN statement for water_sources again.

SELECT
	r.location_id,
	r.auditor_score,
	visits.record_id,
	water_quality.employee_score,
	r.type_of_water_source AS auditor_source,
	s.type_of_water_source AS survey_source
FROM
auditor_report AS r
JOIN
	visits
ON
visits.location_id = r.location_id
JOIN
	water_quality
ON
water_quality.record_id = visits.record_id
JOIN
	water_source AS s
ON 
s.source_id =visits.source_id 
WHERE
	water_quality.employee_score <> r.auditor_score AND  visits.visit_count
	= 1
    ;

-- So, to do this, we need to grab the type_of_water_source column from the water_source table and call it survey_source,
--  using the  source_id column to JOIN. Also select the type_of_water_source from the auditor_report table, and call it auditor_source.

SELECT
	r.location_id,
	r.auditor_score,
	visits.record_id,
	water_quality.employee_score,
	r.type_of_water_source AS auditor_source,
	s.type_of_water_source AS survey_source
FROM
auditor_report AS r
JOIN
	visits
ON
visits.location_id = r.location_id
JOIN
	water_quality
ON
water_quality.record_id = visits.record_id
JOIN
	water_source AS s
ON 
s.source_id =visits.source_id 
WHERE
	water_quality.employee_score <> r.auditor_score AND  visits.visit_count
	= 1;


-- LINKING RECORDS TO EMPLOYEES
/*In either case, the employees are the source of the errors, so let's JOIN the assigned_employee_id for all the people on our list from the visits
table to our query. Remember, our query shows the shows the 102 incorrect records, so when we join the employee data, we can see which
employees made these incorrect records.*/

SELECT
	r.location_id,
	r.auditor_score,
	visits.record_id,
	water_quality.employee_score,
	employee.assigned_employee_id
FROM
auditor_report AS r
JOIN
	visits
ON
visits.location_id = r.location_id
JOIN
	water_quality
	ON
	water_quality.record_id = visits.record_id
JOIN
	water_source AS s
	ON 
	s.source_id =visits.source_id 
JOIN
	employee
	ON
	employee.assigned_employee_id = visits.assigned_employee_id
WHERE
	water_quality.employee_score <> r.auditor_score AND  visits.visit_count
	= 1;

/* we can link the incorrect records to the employees who recorded them. The ID's don't help us to identify them. 
We have employees' names stored along with their IDs, so let's fetch their names from the employees table instead of the ID's.*/

SELECT
	employee.employee_name,
	r.location_id,
	r.auditor_score,
	visits.record_id,
	water_quality.employee_score,
	employee.assigned_employee_id
FROM
auditor_report AS r
JOIN
	visits
	ON
	visits.location_id = r.location_id
JOIN
	water_quality
	ON
	water_quality.record_id = visits.record_id
JOIN
	water_source AS s
	ON 
	s.source_id =visits.source_id 
 JOIN
	employee
	ON
	employee.assigned_employee_id = visits.assigned_employee_id
WHERE
	water_quality.employee_score <> r.auditor_score AND  visits.visit_count
	= 1;

/*Well this query is massive and complex, so maybe it is a good idea to save this as a CTE, so when we do more analysis, we can just call that CTE
like it was a table. Call it something like Incorrect_records. Once you are done, check if this query SELECT * FROM Incorrect_records, gets
the same table back*/

with Incorrect_records_3 as 
			(select 
				 auditor_report.location_id,
				 auditor_report.auditor_score,
				 visits.record_id,
				 water_quality.employee_score,
				 employee.employee_name
			FROM auditor_report
			JOIN 
				 visits 
				 ON auditor_report.location_id =visits.location_id
			 JOIN 
				 water_quality
				 ON water_quality.record_id = visits.record_id
			 JOIN
				 employee
				 ON employee.assigned_employee_id = visits. assigned_employee_id
			AND
				auditor_report.auditor_score <> water_quality.employee_score
			AND
				 visits.visit_count = 1 
				 limit 10000)
 select  *
 from Incorrect_records_3; 
 
 -- Let's first get a unique list of employees from this table. Think back to the start of your SQL journey to answer this one. 
 -- I got 17 employees.
with Incorrect_records_3 as 
			(select 
			 auditor_report.location_id,
			 auditor_report.auditor_score,
			 visits.record_id,
			 water_quality.employee_score,
			 employee.employee_name
			FROM auditor_report
			JOIN visits 
			 ON auditor_report.location_id =visits.location_id
			 JOIN water_quality
			 on water_quality.record_id = visits.record_id
			 join employee
			 on employee.assigned_employee_id = visits. assigned_employee_id
			and
			 auditor_report.auditor_score <> water_quality.employee_score
			 and 
			 visits.visit_count = 1 
			 limit 10000)
 SELECT DISTINCT employee_name
FROM Incorrect_records_3;
 
/* calculate how many mistakes each employee made. So basically we want to count how many times their name is in
Incorrect_records list, and then group them by name, right?*/
WITH Incorrect_records_3 as 
			(select 
				 auditor_report.location_id,
				 auditor_report.auditor_score,
				 visits.record_id,
				 visits.visit_count,
				 water_quality.employee_score,
				 employee.employee_name
			FROM auditor_report
			JOIN 
				visits 
				 ON auditor_report.location_id =visits.location_id
			 JOIN 
				 water_quality
				 on water_quality.record_id = visits.record_id
			 join
				 employee
				 on employee.assigned_employee_id = visits. assigned_employee_id
			and
			 auditor_report.auditor_score <> water_quality.employee_score
			 and 
			 visits.visit_count = 1 
			 )			
SELECT
    employee_name,
    COUNT(*) AS number_of_mistakes
FROM Incorrect_records_3
GROUP BY employee_name
ORDER BY employee_name;

-- GATHERING SOME EVIDENCE (involve  find all of the employees who have an above-average number of mistakes). 
-- First you calculate the number of times someone's name comes up. (we just did that in the previous query).
-- break it down
-- calculate the average number of mistakes employees made             
	WITH error_count AS (
		SELECT 
			employee_name,
			COUNT(employee_name) AS no_of_mistakes
		FROM
			incorrect_records
		GROUP BY
			employee_name)
SELECT 
	AVG(no_of_mistakes) AS avg_error_count_per_empl
FROM 
	error_count;

-- Save CTE as  a view
 
/*compare each employee's error_count with avg_error_count_per_empl.
 We will call this results set our suspect_list.
Remember that we can't use an aggregate result in WHERE, so we have to use avg_error_count_per_empl as a subquery*/  

 -- SUSPECT LIST
WITH error_count AS (
				SELECT 
					employee_name,
					COUNT(employee_name) AS no_of_mistakes
				FROM
					incorrect_records
				GROUP BY
				employee_name)
SELECT
	employee_name,
	no_of_mistakes
FROM
	error_count
WHERE
no_of_mistakes > (WITH error_count AS (
									SELECT 
										employee_name,
										COUNT(employee_name) AS no_of_mistakes
									FROM
										incorrect_records
									GROUP BY
										employee_name)
SELECT 
	AVG(no_of_mistakes) AS avg_error_count_per_empl
FROM 
	error_count);

-- CREATE VIEW for above-workbench
CREATE VIEW Incorrect_records AS (
								SELECT
									auditor_report.location_id,
									visits.record_id,
									employee.employee_name,
									auditor_report.auditor_score AS auditor_score,
									wq.employee_score AS employee_score,
									auditor_report.statements AS statements
								FROM
									auditor_report
								JOIN
									visits
									ON auditor_report.location_id = visits.location_id
								JOIN
									water_quality AS wq
									ON visits.record_id = wq.record_id
								JOIN
									employee
									ON employee.assigned_employee_id = visits.assigned_employee_id
								WHERE
									visits.visit_count =1
								AND 
									auditor_report.auditor_score != wq.employee_score
                                    );
-- SELECT * FROM Incorrect_records gives us the same result as the CTE did.
SELECT *
FROM incorrect_records;

-- Convert the query error_count, we made earlier, into a CTE.
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
					SELECT
						employee_name,
						COUNT(employee_name) AS number_of_mistakes
					FROM
						Incorrect_records/*Incorrect_records is a view that joins the audit report
                        to the database for records where the auditor 	and employees scores are different*/
					GROUP BY
					employee_name)-- Query
SELECT * FROM error_count;
    
-- Convert the query error_count, we made earlier, into a CTE.
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
					SELECT
					employee_name,
					COUNT(employee_name) AS number_of_mistakes
					FROM
					Incorrect_records
					/*
					Incorrect_records is a view that joins the audit report to the database
					for records where the auditor and
					employees scores are different*/
					GROUP BY
					employee_name)
-- Query
SELECT AVG( number_of_mistakes) FROM error_count;

-- find the employees who made more mistakes than the average person
-- employee's names, the number of mistakes each one made,and filter the employees with an above-average number of mistakes.
-- HINT: Use SELECT AVG(mistake_count) FROM error_count as a custom filter in the WHERE part of our query.
-- Convert the query error_count, we made earlier, into a CTE.

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
						SELECT
						employee_name,
						COUNT(employee_name) AS number_of_mistakes
						FROM
						Incorrect_records
						GROUP BY
						employee_name)
-- Query These are the employees who made more mistakes, on average, than their peers
SELECT
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT 
								AVG(number_of_mistakes)
							FROM error_count)
ORDER BY employee_name;

/*We should look at the Incorrect_records table again, and isolate all of the records these four employees gathered. We should also look at the
statements for these records to look for patterns*/
-- First, convert the suspect_list to a CTE,
-- so we can use it to filter the records from these four employees
WITH suspect_list AS (
			SELECT 
				employee_name,
				COUNT(employee_name) AS no_of_mistakes
			FROM
				incorrect_records
			GROUP BY
			employee_name)
SELECT
	employee_name,
	no_of_mistakes
FROM
	suspect_list
WHERE
no_of_mistakes > (WITH error_count AS (
				SELECT 
					employee_name,
					COUNT(employee_name) AS no_of_mistakes
				FROM
					incorrect_records
				GROUP BY
				employee_name)
SELECT 
	AVG(no_of_mistakes) AS avg_error_count_per_empl
FROM
	suspect_list);
    
/*You should get a column of names back. So let's just recap here...
1. We use Incorrect_records to find all of the records where the auditor and employee scores don't match.
2. We then used error_count to aggregate the data, and got the number of mistakes each employee made.
3. Finally, suspect_list retrieves the data of employees who make an above-average number of mistakes.
*/
-- Firstly, let's add the statements column to the Incorrect_records CTE.
-- HINT: Use SELECT employee_name FROM suspect_list as a subquery in WHERE
   -- This query filters all of the records where the "corrupt" employees gathered data.
 -- This query filters all of the records where the "corrupt" employees gathered data.
-- This query filters all of the records where the "corrupt" employees gathered data.
WITH suspect_list AS (
					SELECT 
						employee_name,
						COUNT(employee_name) AS no_of_mistakes
					FROM
						incorrect_records
					GROUP BY
					employee_name)
SELECT
	employee_name,
	auditor_score,
	statements
FROM
	Incorrect_records
WHERE
	employee_name IN (SELECT 
						employee_name 
					FROM 
						suspect_list); 
            
-- This query is complex, right! But, if we document it well, it is simpler to understand. Oh, 
-- and you don't want to see what this query looks like using only subqueries!

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
					SELECT
						employee_name,
						COUNT(employee_name) AS number_of_mistakes
					FROM
						Incorrect_records
		/*Incorrect_records is a view that joins the audit report to the database
		for records where the auditor and
		employees scores are different*/
GROUP BY
employee_name),
suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
				SELECT
					employee_name,
					number_of_mistakes
				FROM
					error_count
				WHERE
					number_of_mistakes > (SELECT
											AVG(number_of_mistakes) 
										FROM 
											error_count))
-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
	employee_name,
	location_id,
	statements
FROM
	Incorrect_records
WHERE
employee_name in (SELECT employee_name FROM suspect_list);

-- Filter the records that refer to "cash"

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
					SELECT
					employee_name,
					COUNT(employee_name) AS number_of_mistakes
					FROM
					Incorrect_records/*Incorrect_records is a view that joins the audit report to the database
										for records where the auditor and
										employees scores are different*/
				GROUP BY
				employee_name),
suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
				SELECT
				employee_name,
				number_of_mistakes
				FROM
				error_count
				WHERE
				number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
                
-- This query filters all of the records where the "corrupt" employees gathered data and cash was involved.
SELECT
	employee_name,
	location_id,
	statements
FROM
	Incorrect_records
WHERE
employee_name in (SELECT employee_name FROM suspect_list) AND statements LIKE '%cash%';

-- also Check if there are any employees in the Incorrect_records table with 
-- statements mentioning "cash" that are not in our suspect list.
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
					SELECT
					employee_name,
					COUNT(employee_name) AS number_of_mistakes
					FROM
					Incorrect_records
					/*Incorrect_records is a view that joins the audit report to the database
					for records where the auditor and
					employees scores are different*/
					GROUP BY
					employee_name),
					suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
										SELECT
										employee_name,
										number_of_mistakes
										FROM
										error_count
										WHERE
										number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
	employee_name,
	location_id,
	statements
FROM
	Incorrect_records
WHERE
employee_name in (SELECT employee_name FROM incorrect_records) AND  statements LIKE '%cash%';

-- MCQ QUESTION(Test your knowledge of database structures and how to combine data from multiple sources.)
-- question 1
/*The following query results in 2,698 rows of data being retrieved, but the auditor_report table only has 1,620 rows. 
Analyse the query and select the reason why this discrepancy occurs.
 Hint: Think about the type of relationship between our tables.*/ 
 -- note for my querry to work  I have converted editorsr and visitors table scores.
		 ALTER TABLE auditor_report 
		 RENAME COLUMN   true_water_source_score TO auditor_score;
		  ALTER TABLE  water_quality
		 RENAME COLUMN  subjective_quality_score  TO employee_score ;
 
 SELECT
    auditorRep.location_id,
    visitsTbl.record_id,
    Empl_Table.employee_name,
    auditorRep.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS employee_score
FROM auditor_report AS auditorRep
JOIN visits AS visitsTbl
ON auditorRep.location_id = visitsTbl.location_id
JOIN water_quality AS wq
ON visitsTbl.record_id = wq.record_id
JOIN employee as Empl_Table
ON Empl_Table.assigned_employee_id = visitsTbl.assigned_employee_id;
-- ANSWER 
/*The visits table has multiple records for each location_id,
 which when joined with auditor_report, results in multiple records for each location_id.*/
 
-- QUESTION 2
-- What is the function of Incorrect_records in the following query?
WITH Incorrect_records AS ( -- This CTE fetches all of the records with wrong scores
							SELECT
								auditorRep.location_id,
								visitsTbl.record_id,
								Empl_Table.employee_name,
								auditorRep.true_water_source_score AS auditor_score,
								wq.subjective_quality_score AS employee_score
							FROM auditor_report AS auditorRep
							JOIN visits AS visitsTbl
							ON auditorRep.location_id = visitsTbl.location_id
							JOIN water_quality AS wq
							ON visitsTbl.record_id = wq.record_id
							JOIN employee as Empl_Table
							ON Empl_Table.assigned_employee_id = visitsTbl.assigned_employee_id
							WHERE visitsTbl.visit_count =1 AND auditorRep.true_water_source_score != wq.subjective_quality_score)
SELECT
    employee_name,
    count(employee_name)
FROM Incorrect_records
GROUP BY Employee_name;
-- ANSWER
/*Incorrect_records serves as a temporary result set  to store aggregated data of
 records with different scores between auditor and employee for the main query.*/
 
-- QUESTION 3
-- In the suspect_list CTE, a subquery is used. What type of subquery is it, and what is its purpose in the query?
WITH suspect_list AS (
						SELECT 
							employee_name,
							number_of_mistakes
						FROM error_count
						WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
					);

-- QUESTION 4
-- A colleague proposed the following CTE as an alternative to the suspect_list we used previously, 
-- but it does not give the desired results. What will be the result of this subquery?

WITH suspect_list AS (
					SELECT 
						ec1.employee_name, 
						ec1.number_of_mistakes
					FROM error_count ec1
				   HAVING ec1.number_of_mistakes >= (
													SELECT AVG(ec2.number_of_mistakes)
													FROM error_count ec2
													WHERE ec2.employee_name = ec1.employee_name)
                                                    -- (not complete nothing to retrive from cte)													
                                    
-- Question 7
/*How would you modify the Incorrect_records CTE to join the well_pollution data?*/
-- -- (not complete nothing to retrive from cte)
WITH Incorrect_records AS (
						SELECT
							auditorRep.location_id,
							visitsTbl.record_id,
							Empl_Table.employee_name,
							auditorRep.true_water_source_score AS auditor_score,
							wq.subjective_quality_score AS employee_score,
							auditorRep.statements AS statements
						FROM auditor_report AS auditorRep
						JOIN visits AS visitsTbl
						ON auditorRep.location_id = visitsTbl.location_id
						JOIN water_quality AS wq
						ON visitsTbl.record_id = wq.record_id
						JOIN employee as Empl_Table
						ON Empl_Table.assigned_employee_id = visitsTbl.assigned_employee_id                        
				WHERE visitsTbl.visit_count =1
				 AND auditorRep.true_water_source_score != wq.subjective_quality_score);
                 
      -- QUESTION 8           
-- which employee just avoided our classification of having an above-average number of mistakes? 
-- Hint: Use one of the queries we used to aggregate data from Incorrect_records.

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
					SELECT
					employee_name,
					COUNT(employee_name) AS number_of_mistakes
					FROM
					Incorrect_records
					GROUP BY
					employee_name)
-- Query These are the employees who made more mistakes, on average, than their peers
SELECT
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes < (SELECT AVG(number_of_mistakes) FROM error_count)
ORDER BY employee_name;

-- QUESTION 10 
/*Which of the following “suspects” is connected to the following civilian statement:
“Suspicion coloured villagers' descriptions of an official's aloof demeanour and apparent laziness.
 The reference to cash transactions casts doubt on their motives.”*/
SELECT
	employee_name,
	statements
 FROM
	md_water_services.incorrect_records
 WHERE 
	statements =  'Suspicion colored villagers\' descriptions of an official\'s aloof demeanor and apparent laziness. The reference to cash transactions cast doubt on their motives.'
 ;
 
 -- question 10
 /*Consider the provided SQL query. What does it do?*/
 SELECT
	auditorRep.location_id,
	visitsTbl.record_id,
	auditorRep.true_water_source_score AS auditor_score,
	wq.subjective_quality_score AS employee_score,
	wq.subjective_quality_score - auditorRep.true_water_source_score  AS score_diff
FROM auditor_report AS auditorRep
JOIN 
	visits AS visitsTbl
	ON auditorRep.location_id = visitsTbl.location_id
JOIN 
	water_quality AS wq
	ON visitsTbl.record_id = wq.record_id
WHERE (wq.subjective_quality_score - auditorRep.true_water_source_score) > 9;
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/
GROUP BY
employee_name),
suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
				SELECT
					employee_name,
					number_of_mistakes
				FROM
					error_count
				WHERE
				number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
	employee_name,
	location_id,
	statements
FROM
Incorrect_records
WHERE
employee_name in (SELECT employee_name FROM suspect_list) AND statements LIKE
 'Suspicion coloured villagers descriptions%'
;
