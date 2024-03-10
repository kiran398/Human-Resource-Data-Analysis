CREATE DATABASE humanresource;
USE humanresource;
SELECT * FROM hr;
ALTER TABLE hr
	CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;
DESCRIBE hr;
SELECT birthdate from hr;

-- Update all the noisy and messy date formats
UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
    ELSE null
    END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE; 

SELECT hire_date FROM hr;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
    ELSE null
    END;
    
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

SELECT termdate FROM hr;

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from hr;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

# add new column called age
ALTER TABLE hr
	ADD COLUMN age INT;

-- calculate age using birthdate 
UPDATE hr
	SET age=timestampdiff(YEAR,birthdate,CURDATE());
    
SELECT * FROM hr;

SELECT 
	max(age) AS max_age,
	min(age) AS min_age
	FROM hr;

SELECT COUNT(*)
	FROM hr WHERE age< 18 ;

-- QUESTIONS FOR ANALYSIS
-- what is the gender breakdown for the employees in the company ?
SELECT  gender,
	COUNT(*) AS count FROM hr
    WHERE age>=18 AND termdate='0000-00-00'
    GROUP BY gender;
    
-- what is the gender breakdown for the employees in the company ?
 SELECT race,
	COUNT(*) AS count FROM hr
    WHERE age>=18 AND termdate='0000-00-00'
    GROUP BY race
    ORDER BY count DESC;
    
-- what is the age distribution of the employees in the company ?
SELECT min(age) AS youngest,
		max(age) AS oldest
        FROM hr
        WHERE age>=18 AND termdate='0000-00-00';
        
SELECT
	CASE
    WHEN age>=18 AND age<=24 THEN '18-24' 
     WHEN age>=25 AND age<=34 THEN '25-34' 
      WHEN age>=35 AND age<=44 THEN '35-44' 
       WHEN age>=45 AND age<=54 THEN '45-54'
        WHEN age>=55 AND age<=64 THEN '55-64' 
        ELSE '65+'
        END AS age_group, gender,
        COUNT(*) AS count
        FROM hr
        WHERE age>=18 AND termdate='0000-00-00'
        GROUP BY age_group,gender
        ORDER BY age_group,gender;
        
-- How many workers work at headquaters versus remote locations ?
SELECT location ,
	COUNT(*) AS location_cnt
    FROM hr
    WHERE age>=18 AND termdate='0000-00-00'
    GROUP BY location
    ORDER BY location_cnt DESC;
       
-- What is the avg lenght of employement for employees who have terminated ?
SELECT 
    ROUND(AVG(DATEDIFF(termdate, hire_date))/365) AS avg_employment_duration
FROM hr
WHERE termdate<=CURDATE() AND termdate<>'0000-00-00' AND age>=18;

-- How does the gender distribution varies among departments and job titles ?
SELECT 
	department,
    gender,
    COUNT(*) AS gen_count
    FROM hr
    WHERE age>=18 AND termdate='0000-00-00'
    GROUP BY gender,department
    ORDER BY department ;
    
-- Distribution of job titles across the company ?
SELECT jobtitle,
	COUNT(*) AS job_count
    FROM hr
	WHERE age>=18 AND termdate='0000-00-00'
    GROUP BY jobtitle
    ORDER BY jobtitle DESC;
    
-- highest department termination rate
SELECT 
	department,
    total_count,
    termination_count,
    termination_count/total_count AS termination_rate
    FROM(
    SELECT department,
		COUNT(*) AS total_count,
        SUM(CASE WHEN termdate<>'0000-00-00' AND termdate<= CURDATE() THEN 1 ELSE 0 END) AS termination_count
        FROM hr
        WHERE age>=18
        GROUP BY department
        ) AS sub_query
        ORDER BY termination_rate DESC;
        
-- Distribution of employees across location by city and state ?
Select location_state,
	COUNT(*) as loc_cnt
    FROM hr
    WHERE age>=18 AND termdate='0000-00-00'
    GROUP BY location_state
    ORDER BY loc_cnt DESC;
    
-- how has the companys employees count has changed over time based on hire and term dates ?
SELECT 
	YEAR,
	hires,
    termination,
    (hires-termination) AS net_change,
    ROUND((hires-termination)/hires*100,2) AS net_change_percent
    FROM (
		SELECT
		YEAR(hire_date) AS year,
        COUNT(*) AS hires,
        SUM(CASE WHEN termdate<>'0000-00-00' AND termdate<= CURDATE() THEN 1 ELSE 0 END) AS termination
        FROM hr
        WHERE age>=18
        GROUP BY year(hire_date)
        ) AS sub_query
        ORDER BY YEAR ASC;
    
-- What is the tenure distribution for each department ?
SELECT department, ROUND(AVG(DATEDIFF(termdate,hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate<=CURDATE() AND termdate<>'0000-00-00' AND age>=18
GROUP BY department;        
    





    
    
    
    