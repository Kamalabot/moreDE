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

/*Doing calculation using the Group By clause*/
select td.date_purchase, sum(td.qty) 
from test_data td 
group by td.date_purchase 

select td.grocery , sum(td.qty) 
from test_data td 
group by td.grocery  

with group_date
as (
	select td.date_purchase, 
		sum(td.qty) as sum_qty,
		avg(td.qty) as avg_qty,
		max(td.qty) as max_qty,
		min(td.qty) as min_qty
	from test_data td 
	group by td.date_purchase 
) select td.grocery, td.date_purchase , td.qty , 
		gd.sum_qty as day_total, 
		round(gd.avg_qty,1) as day_average, 
		gd.max_qty as day_max, 
		gd.min_qty as day_min
	from test_data td join group_date gd 
	on td.date_purchase = gd.date_purchase
	
with group_grocery
as (
	select td.grocery , 
		sum(td.qty) as sum_qty,
		avg(td.qty) as avg_qty 
	from test_data td 
	group by td.grocery  
) select td.grocery, td.date_purchase , td.qty , 
		round(gg.avg_qty,1) as grocery_avg,
		gg.sum_qty as grocery_total 
	from test_data td join group_grocery gg 
	on td.grocery  = gg.grocery


/*End of Group by calculation*/

/*Starting the Over Clause calculations*/
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
	sum(td.qty) over(order by td.grocery desc, 
						td.date_purchase) as sum_purchased
from test_data td

select td.*, 
	sum(td.qty) over(partition by td.grocery  
						order by td.date_purchase  desc) as sum_purchased
from test_data td

select td.*, 
	sum(td.qty) over(partition by td.date_purchase) as day_total,
	round(avg(td.qty) over(partition by td.date_purchase), 1) as day_average,
	max(td.qty) over(partition by td.date_purchase) as day_max,
	min(td.qty) over(partition by td.date_purchase) as day_min
from test_data td

select td.*, 
	sum(td.qty) over(partition by td.grocery) as sum_purchased,
	round(avg(td.qty) over(partition by td.grocery), 1) as grocery_avg
from test_data td

select td.*, 
	sum(td.qty) over(partition by td.grocery order by td.date_purchase) as sum_purchased,
	round(avg(td.qty) over(partition by td.grocery order by td.date_purchase), 1) as grocery_avg
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
	sum(td.qty) over(order by td.grocery
					rows between unbounded preceding and current row) as cum_sum	
FROM test_data td

SELECT td.*,
	sum(td.qty) over(rows between unbounded preceding and unbounded following) as cum_sum	
FROM test_data td

SELECT td.*,
	sum(td.qty) over(rows between unbounded preceding and current row) as cum_sum	
FROM test_data td

SELECT td.*,
	sum(td.qty) over(rows between current row and  unbounded following) as cum_sum	
FROM test_data td

SELECT td.*,
	sum(td.qty) over(rows between current row and 2 following) as two_row,
	round(avg(td.qty) over(rows between current row and 2 following), 2) as two_row_avg
FROM test_data td

select td.*, q.sum_total, q.grocery
from (SELECT sum(td.qty) as sum_total,  'Total' as grocery
	FROM test_data td
	) q join test_data as td
on q.grocery = td.grocery


insert into test_data (grocery, qty)
SELECT  'Total' as grocery, sum(td.qty)
	FROM test_data td
	
select td.*
	from test_data td 	

SELECT td.*,
	sum(td.qty) over(partition by td.date_purchase
					order by td.grocery desc
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

/*Discussing the leading and lagging*/

select td.*,
	lead(td.qty) over(order by td.grocery) as next_qty
from test_data td

select td.*,
	lead(td.qty, 2) over(order by td.grocery) as next_qty
from test_data td

select td.*,
	lag(td.qty,1, 0.0) over(partition by td.grocery 
								order by td.grocery) as next_qty
from test_data td

select td.*,
	lag(td.qty) over(order by td.grocery) as next_qty
from test_data td 

select td.*,
	lag(td.qty, 2) over(order by td.grocery) as next_qty
from test_data td 

/*Discussing the Ranking and Filtering*/

select td.*,
		rank() over(order by td.grocery) as g_rank
from test_data td 

select td.*,
		rank() over(order by td.grocery desc) as g_rank
from test_data td 

select td.*,
		rank() over(partition by td.date_purchase 
					order by td.grocery) as g_rank
from test_data td 

select td.*, rank() over(order by td.qty desc) as q_rnk
from test_data td 

select td.*, dense_rank() over(order by td.qty desc) as q_rnk
from test_data td 

select td.*, row_number() over(order by td.qty desc) as q_rnk
from test_data td 

with rank_filter
as(
select td.*, dense_rank() over(partition by td.date_purchase
								order by td.qty desc) as d_rnk
from test_data td 
) select grocery, date_purchase , qty, d_rnk
from rank_filter
where d_rnk <= 2


SELECT PERCENTILE_CONT(0.9) WITHIN GROUP(ORDER BY td.qty) FROM test_data td;

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
