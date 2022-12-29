INSERT
	INTO
	hr_table (employee_id,
	first_name,
	last_name,
	email,
	phone,
	hire_dt,
	job_id,
	salary,
	commission,
	manager_id,
	department_id)
VALUES(105,
'David',
'Austin',
'DAUSTIN',
'590.423.4569',
'1997-06-25',
'IT_DEV',
4800.00,
'null',
103,
60),
(106,
'Valli',
'Pataballa',
'VPATABAL',
'590.423.4560',
'1998-02-05',
'IT_DEV',
4800.00,
'null',
103,
60),
(107,
'Diana',
'Lorentz',
'DLORENTZ',
'590.423.5567',
'1999-02-07',
'IT_DEV',
4200.00,
'null',
103,
60)

UPDATE
	hr_table
SET
	commission = '587%'
WHERE
	job_id = 'IT_PROG'

UPDATE
	hr_table
SET
	salary = 577086.00
WHERE
	job_id = 'ST_MAN'

SELECT
	DISTINCT job_id
FROM
	hr_table 

ALTER TABLE hr_table ADD COLUMN user_full_name VARCHAR (50)

UPDATE
	hr_table
SET
	user_full_name = upper(concat(first_name, last_name)) 

DELETE
FROM
	hr_table
WHERE
	job_id = 'IT_DEV'

CREATE TABLE courses (id SERIAL PRIMARY KEY,
	course_name VARCHAR(150),
	course_authon VARCHAR(150),
	course_status VARCHAR(15),
	course_date DATE)

INSERT
	INTO
	courses(course_name,
	course_authon,
	course_status,
	course_date)
VALUES 
('Programming using Python',
'Bob Dillon',
'published',
'2020-09-30'),
('Data Engineering using Python',
'Bob Dillon',
'published',
'2020-07-15'),
('Programming using Scala',
'Elvis Presley',
'published',
'2020-05-12'),
('Programming using Java',
'Mike Jack',
'inactive',
'2020-08-10'),
('Web Applications - Python Flask',
'Bob Dillon',
'inactive',
'2020-07-20'),
('Streaming Pipelines - Python',
'Bob Dillon',
'published',
'2020-10-05'),
('Web Applications - Scala Play',
'Elvis Presley',
'inactive',
'2020-09-30'),
('Web Applications - Python Django',
'Bob Dillon',
'published',
'2020-06-23'),
('Server Automation - Ansible',
'Uncle Sam',
'published',
'2020-07-05')

INSERT
	INTO
	courses(course_name,
	course_authon,
	course_status,
	course_date)
VALUES
('Pipeline Orchestration - Python',
'Bob Dillon',
'draft',
NULL)

SELECT
	COUNT(*)
FROM
	courses
GROUP BY
	course_status
HAVING
	course_status = 'inactive'

##starting the TABLE creations FOR Predictive Maintenance Dataset

CREATE database maintenance;
