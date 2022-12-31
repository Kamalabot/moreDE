/*This script deals with query plan in SQL*/

explain select ad.*
from aid_data ad 

/*QUERY PLAN                                                       
-----------------------------------------------------------------
Seq Scan on aid_data ad  (cost=0.00..2485.40 rows=98540 width=81)*/

explain analyze select aa.*
from aid_agg_2013 aa 

/*QUERY PLAN                                                                                                   |
-------------------------------------------------------------------------------------------------------------+
Seq Scan on aid_agg_2013 aa  (cost=0.00..16.30 rows=630 width=100) (actual time=0.017..0.024 rows=26 loops=1)|
Planning Time: 0.101 ms                                                                                      |
Execution Time: 0.048 ms                                                                                     |*/

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