/*This script deals with query plan in SQL*/

explain select ad.*
from aid_data ad 

/*QUERY PLAN                                                       
-----------------------------------------------------------------
Seq Scan on aid_data ad  (cost=0.00..2485.40 rows=98540 width=81)*/

explain select ad.*
from aid_data ad 
order by ad."year" 


/* Notice the startup cost comes up due to sorting
QUERY PLAN                                                             |
-----------------------------------------------------------------------+
Sort  (cost=15376.52..15622.87 rows=98540 width=81)                    |
  Sort Key: year                                                       |
  ->  Seq Scan on aid_data ad  (cost=0.00..2485.40 rows=98540 width=81)|
*/


explain analyze select aa.*
from aid_agg_2013 aa 

/*QUERY PLAN                                                                                                   |
-------------------------------------------------------------------------------------------------------------+
Seq Scan on aid_agg_2013 aa  (cost=0.00..16.30 rows=630 width=100) (actual time=0.017..0.024 rows=26 loops=1)|
Planning Time: 0.101 ms                                                                                      |
Execution Time: 0.048 ms                                                                                     |*/


explain analyze select aa.*
from aid_agg_2013 aa
where aa.aid_donor = 'Germany'

/*QUERY PLAN                                                                                                                                  |
--------------------------------------------------------------------------------------------------------------------------------------------+
Index Scan using aid_agg_2013_aid_donor_key on aid_agg_2013 aa  (cost=0.15..8.17 rows=1 width=100) (actual time=0.406..0.408 rows=1 loops=1)|
  Index Cond: ((aid_donor)::text = 'Germany'::text)                                                                                         |
Planning Time: 29.610 ms                                                                                                                    |
Execution Time: 22.511 ms                                                                                                                   |*/

explain analyze select aa.*
from aid_agg_2013 aa
where aa.donated_amount > 5000000

/*QUERY PLAN                                                                                                   |
-------------------------------------------------------------------------------------------------------------+
Seq Scan on aid_agg_2013 aa  (cost=0.00..17.88 rows=210 width=100) (actual time=0.024..0.033 rows=25 loops=1)|
  Filter: (donated_amount > '100000'::numeric)                                                               |
  Rows Removed by Filter: 1                                                                                  |
Planning Time: 13.411 ms                                                                                     |
Execution Time: 0.058 ms                                                                                     |*/

explain select aa.*
from aid_data aa
where aa.commitment_amount_usd_constant > 50000 and aa.donor = 'Kuwait'

/*QUERY PLAN                                                                                           |
-----------------------------------------------------------------------------------------------------+
Seq Scan on aid_data aa  (cost=0.00..2978.10 rows=8 width=81)                                        |
  Filter: ((commitment_amount_usd_constant > '50000'::double precision) AND (donor = 'Kuwait'::text))|*/


explain select pc.country_name, a.nationality ,a."name" ,a.sex ,a.date_of_birth 
from athletes a join primary_country pc 
on a.nationality = pc.country_code 
limit 5
/*
QUERY PLAN                                                                                                      |
----------------------------------------------------------------------------------------------------------------+
Limit  (cost=0.16..0.42 rows=5 width=45)                                                                        |
  ->  Nested Loop  (cost=0.16..604.78 rows=11538 width=45)                                                      |
        ->  Seq Scan on athletes a  (cost=0.00..282.38 rows=11538 width=32)                                     |
        ->  Memoize  (cost=0.16..0.18 rows=1 width=17)                                                          |
              Cache Key: a.nationality                                                                          |
              Cache Mode: logical                                                                               |
              ->  Index Scan using primary_country_pkey on primary_country pc  (cost=0.15..0.17 rows=1 width=17)|
                    Index Cond: ((country_code)::text = a.nationality)                                          |*/

explain analyze select pc.country_name, a.nationality ,a."name" ,a.sex ,a.date_of_birth 
from athletes a join primary_country pc 
on a.nationality = pc.country_code 
limit 5
/*
QUERY PLAN                                                                                                                                                |
----------------------------------------------------------------------------------------------------------------------------------------------------------+
Limit  (cost=0.16..0.42 rows=5 width=45) (actual time=0.034..0.073 rows=5 loops=1)                                                                        |
  ->  Nested Loop  (cost=0.16..604.78 rows=11538 width=45) (actual time=0.033..0.069 rows=5 loops=1)                                                      |
        ->  Seq Scan on athletes a  (cost=0.00..282.38 rows=11538 width=32) (actual time=0.012..0.013 rows=5 loops=1)                                     |
        ->  Memoize  (cost=0.16..0.18 rows=1 width=17) (actual time=0.009..0.009 rows=1 loops=5)                                                          |
              Cache Key: a.nationality                                                                                                                    |
              Cache Mode: logical                                                                                                                         |
              Hits: 0  Misses: 5  Evictions: 0  Overflows: 0  Memory Usage: 1kB                                                                           |
              ->  Index Scan using primary_country_pkey on primary_country pc  (cost=0.15..0.17 rows=1 width=17) (actual time=0.006..0.006 rows=1 loops=5)|
                    Index Cond: ((country_code)::text = a.nationality)                                                                                    |
Planning Time: 0.378 ms                                                                                                                                   |
Execution Time: 0.122 ms                                                                                                                                  |*/





/*The tables for the below scripts may not there... so don't execute*/

explain analyze with 
donor_table as (
select ad."year" , ad.donor, pc.country_code,ad .commitment_amount_usd_constant, ad.coalesced_purpose_code ,ad.coalesced_purpose_name
from aid_data ad join primary_country pc 
on pc.country_name  = ad.donor 
),
athlete_code as(
select pc.country_name, a.nationality ,a."name" ,a.sex ,a.date_of_birth 
from athletes a join primary_country pc 
on a.nationality = pc.country_code 
) select dt.*, ac.*
from donor_table dt join athlete_code ac 
on dt.country_code = ac.nationality
limit 5

/*QUERY PLAN                                                                                                                                              |
--------------------------------------------------------------------------------------------------------------------------------------------------------+
Limit  (cost=2781.46..2782.49 rows=5 width=56) (actual time=58.804..58.827 rows=5 loops=1)                                                              |
  ->  Hash Join  (cost=2781.46..3128.54 rows=1692 width=56) (actual time=58.802..58.822 rows=5 loops=1)                                                 |
        Hash Cond: (a.nationality = (pc.country_code)::text)                                                                                            |
        ->  Hash Join  (cost=2773.48..3116.05 rows=1692 width=60) (actual time=58.530..58.544 rows=5 loops=1)                                           |
              Hash Cond: (a.nationality = (pc2.country_code)::text)                                                                                     |
              ->  Seq Scan on athletes a  (cost=0.00..282.38 rows=11538 width=40) (actual time=0.007..0.009 rows=6 loops=1)                             |
              ->  Hash  (cost=2772.99..2772.99 rows=39 width=20) (actual time=58.492..58.495 rows=26 loops=1)                                           |
                    Buckets: 1024  Batches: 1  Memory Usage: 10kB                                                                                       |
                    ->  Hash Join  (cost=2767.62..2772.99 rows=39 width=20) (actual time=58.315..58.469 rows=26 loops=1)                                |
                          Hash Cond: ((pc2.country_name)::text = ad.donor)                                                                              |
                          ->  Seq Scan on primary_country pc2  (cost=0.00..4.66 rows=266 width=17) (actual time=0.011..0.077 rows=266 loops=1)          |
                          ->  Hash  (cost=2767.13..2767.13 rows=39 width=16) (actual time=58.220..58.221 rows=26 loops=1)                               |
                                Buckets: 1024  Batches: 1  Memory Usage: 10kB                                                                           |
                                ->  HashAggregate  (cost=2766.35..2766.74 rows=39 width=16) (actual time=58.162..58.181 rows=26 loops=1)                |
                                      Group Key: ad.donor                                                                                               |
                                      Batches: 1  Memory Usage: 24kB                                                                                    |
                                      ->  Seq Scan on aid_data ad  (cost=0.00..2731.75 rows=6921 width=16) (actual time=0.865..48.416 rows=6754 loops=1)|
                                            Filter: (year = 2012)                                                                                       |
                                            Rows Removed by Filter: 91786                                                                               |
        ->  Hash  (cost=4.66..4.66 rows=266 width=4) (actual time=0.257..0.258 rows=266 loops=1)                                                        |
              Buckets: 1024  Batches: 1  Memory Usage: 18kB                                                                                             |
              ->  Seq Scan on primary_country pc  (cost=0.00..4.66 rows=266 width=4) (actual time=0.018..0.116 rows=266 loops=1)                        |
Planning Time: 2.302 ms                                                                                                                                 |
Execution Time: 58.961 ms                                                                                                                               |*/


explain analyze select ap.name, ap.sport, ap.gold, ap.silver, ap.bronze, ap.nationality, agg.aid_donor, agg.donated_amount
from aid_agg_2013 agg join athletes_pc ap 
on agg.donor_code = ap.nationality

/*QUERY PLAN                                                                                                                 |
---------------------------------------------------------------------------------------------------------------------------+
Hash Join  (cost=323.94..1071.03 rows=28271 width=104) (actual time=10.468..12.942 rows=4156 loops=1)                      |
  Hash Cond: ((agg.donor_code)::text = (ap.nationality)::text)                                                             |
  ->  Seq Scan on aid_agg_2013 agg  (cost=0.00..16.30 rows=630 width=96) (actual time=0.014..0.028 rows=26 loops=1)        |
  ->  Hash  (cost=211.75..211.75 rows=8975 width=40) (actual time=10.342..10.344 rows=8975 loops=1)                        |
        Buckets: 16384  Batches: 1  Memory Usage: 780kB                                                                    |
        ->  Seq Scan on athletes_pc ap  (cost=0.00..211.75 rows=8975 width=40) (actual time=0.007..4.743 rows=8975 loops=1)|
Planning Time: 0.777 ms                                                                                                    |
Execution Time: 13.286 ms                                                                                                  |*/

explain analyse select * from donor_athlete_table dat order by athlete_id

/*QUERY PLAN                                                                                                                   |
-----------------------------------------------------------------------------------------------------------------------------+
Sort  (cost=340.36..350.75 rows=4156 width=60) (actual time=5.849..6.979 rows=4156 loops=1)                                  |
  Sort Key: athlete_id                                                                                                       |
  Sort Method: quicksort  Memory: 777kB                                                                                      |
  ->  Seq Scan on donor_athlete_table dat  (cost=0.00..90.56 rows=4156 width=60) (actual time=0.027..1.510 rows=4156 loops=1)|
Planning Time: 0.398 ms                                                                                                      |
Execution Time: 7.617 ms                                                                                                     |*/



explain select * from donor_athlete_table dat 



