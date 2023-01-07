/*This script will build the glass door dataset tables for 
 * future usage
 */

create table if not exists job_employer_details(job_id int primary key unique,
	Job_Title varchar,
	Salary_Estimate varchar,
	Job_Description varchar,
	Rating numeric,
	Company_Name varchar,Work_Location varchar,
	Headquarters varchar,
	Company_Size varchar,
	Founded int,
	Type_of_Ownership varchar,
	Industry varchar,Sector varchar,
	Revenue varchar,
	Competitors varchar)




