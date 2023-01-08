drop table if exists initial_data
drop table if exists test_data

create table test_data(
	grocery VARCHAR,
	date_purchase DATE,
	qty INT
)

insert into test_data(grocery,date_purchase,qty)
values
('biscuit','2023-05-02',17),
('sugar','2023-05-02',1),
('custard','2023-05-02',5),
('biscuit','2023-05-03',10),
('sugar','2023-05-03',7),
('tea','2023-05-04',1),
('coffee','2023-05-04',5),
('bread','2023-05-04',12),
('sugar','2023-05-04',7),
('biscuit','2023-05-05',9),
('tea','2023-05-05',2),
('sugar','2023-05-05',5)


select td.grocery, td.date_purchase, 
from test_data td 

/*Order by can achieve the sorting. Filtering will be the challenge*/
select td.*
from test_data td
order by td.date_purchase, td.qty

select td.*, 
	dense_rank () over(partition by td.date_purchase order by td.qty) as drnk
from test_data td

select td.*, 
	dense_rank() over(order by td.qty desc) as drnk
from test_data td

select td.*, 
	rank() over(order by td.qty desc) as drnk
from test_data td

select td.*, 
	row_number() over(order by td.qty desc) as drnk
from test_data td

select td.*, 
	sum(td.qty) over(order by td.grocery desc) as sum_purchased
from test_data td

select td.*, 
	sum(td.qty) over(partition by td.date_purchase 
						order by td.grocery desc) as sum_purchased
from test_data td

select td.*, 
	sum(td.qty) over(partition by td.date_purchase) as sum_purchased
from test_data td

select td.*, 
	sum(td.qty) over(partition by td.grocery) as sum_purchased
from test_data td

SELECT td.*,
	sum(td.qty) over(partition by td.date_purchase
					order by td.grocery
					rows between unbounded preceding and current row) as cum_sum	
FROM test_data td

SELECT td.*,
	sum(td.qty) over(order by td.grocery
					rows between unbounded preceding and current row) as cum_sum	
FROM test_data td

SELECT td.*,
	sum(td.qty) over(partition by td.date_purchase
					order by td.grocery
					rows between current row and unbounded following) as cum_sum	
FROM test_data td

SELECT td.*,
	sum(td.qty) over(order by td.grocery
					rows between current row and unbounded following) as cum_sum	
FROM test_data td

SELECT td.*,
	sum(td.qty) over(order by td.grocery
					rows between unbounded preceding and unbounded following) as cum_sum	
FROM test_data td

SELECT td.*,
	sum(td.qty) over(order by td.grocery
					rows between 2 preceding and current row) as cum_sum	
FROM test_data td

SELECT td.*,
	sum(td.qty) over(order by td.grocery
					rows between current row and 2 following) as cum_sum	
FROM test_data td

SELECT td.*,
	sum(td.qty) over(partition by td.date_purchase
					order by td.grocery
					rows between current row and 2 following) as cum_sum	
FROM test_data td



CREATE TABLE initial_data (
    thing TEXT, 
    start_date TEXT 
)

INSERT INTO initial_data(thing, start_date)
VALUES 
('a', '2022-07-01'),
('b', '2022-07-01'),
('c', '2022-07-01'),
('a', '2022-08-01'),
('a', '2022-08-01'),
('d', '2022-08-01'),
('a', '2022-09-01'),
('e', '2022-09-01')
;

WITH ranking AS (
    SELECT 
        thing, 
        start_date, 
        DENSE_RANK() OVER (PARTITION BY thing ORDER BY start_date) AS ranked 
    FROM initial_data
), 
ranking_filtered AS (
    SELECT * FROM ranking
    WHERE ranked = 1
)
SELECT
    thing, 
    start_date, 
    sum(ranked) OVER (ORDER BY start_date) AS roller
FROM ranking_filtered
; 
