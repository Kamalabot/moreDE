/*This script will explore the snldb tables with intention to create a dash board, 
 * that will be useful for taking some interesting decisions. (learnt from Data School)
 * */

/*Fill the decisions here, after exploring the data below
 * 1)
 * 2)
 * 3)
 * */


/*table actors*/

select a.* 
from actors a 
limit 5

/*aid           |url        |type|gender |
--------------+-----------+----+-------+
Kate McKinnon |/Cast/?KaMc|cast|female |
Alex Moffat   |/Cast/?AlMo|cast|male   |
Ego Nwodim    |/Cast/?EgNw|cast|unknown|
Chris Redd    |/Cast/?ChRe|cast|male   |
Kenan Thompson|/Cast/?KeTh|cast|male   |*/

/*table apperances */

select a.* 
from apperances a 
limit 5

/*aid|tid      |capacity|role                   |charid|impid|voice|epid    |sid|
--------------+---------+--------+-----------------------+------+-----+-----+--------+---+
Kate McKinnon |202104101|cast    |Joanne                 |      |     |false|20210410| 46|
Alex Moffat   |202104101|cast    |Craig Matthew Yorgensen|      |     |false|20210410| 46|
Ego Nwodim    |202104101|cast    |anchor                 |      |     |false|20210410| 46|
Chris Redd    |202104101|cast    |Calvin                 |      |     |false|20210410| 46|
Kenan Thompson|202104101|cast    |anchor                 |      |     |false|20210410| 46|*/

/*table casts*/

select c.* 
from casts c 
limit 6

/*aid|sid|featured|first_epid|last_epid|update_anchor|n_episodes|season_fraction   |
----------------+---+--------+----------+---------+-------------+----------+------------------+
A. Whitney Brown| 11|true    |19860222.0|         |false        |         8|0.4444444444444444|
A. Whitney Brown| 12|true    |          |         |false        |        20|               1.0|
A. Whitney Brown| 13|true    |          |         |false        |        13|               1.0|
A. Whitney Brown| 14|true    |          |         |false        |        20|               1.0|
A. Whitney Brown| 15|true    |          |         |false        |        20|               1.0|
A. Whitney Brown| 16|true    |          |         |false        |        20|               1.0|*/

select cd."name" , cd.charid 
from character_details cd
limit 6

/*name                      |charid|
--------------------------+------+
Rebecca                   |  1098|
Elliott Pants             |  1087|
Vaneta Starkie            |  1079|
Wylene Starkie            |  1080|
Guy Who Just Bought a Boat|  1024|
Edith Puthie              |  1099|*/

select count(*)
from character_details cd 

select e.*
from episodes e 
limit 5

/*sid|epid  |aired            |epno|
---+--------+-----------------+----+
 46|20210410|April 10, 2021   |  17|
 46|20210403|April 3, 2021    |  16|
 46|20210327|March 27, 2021   |  15|
 46|20210227|February 27, 2021|  14|
 46|20210220|February 20, 2021|  13|*/

select *, split_part(e.aired,',',2) as year, 
	split_part(split_part(e.aired,',',1), ' ',2) as day,
	split_part(split_part(e.aired,',',1), ' ',1) as month,
	e.aired :: date as aired_date
from episodes e
order by aired_date 

select h.*
from hosts h 
limit 5

/*epid  |aid           |
--------+--------------+
20210410|Carey Mulligan|
20210403|Daniel Kaluuya|
20210327|Maya Rudolph  |
20210227|Nick Jonas    |
20210220|Rege-Jean Page|*/


select i.*
from impressions i 
limit 5

/*impid|aid          |name             |
-----+-------------+-----------------+
 4142|Chris Redd   |Barack Obama     |
 4143|Beck Bennett |Bruce Springsteen|
 4141|Pete Davidson|Matt Gaetz       |
 4057|Chloe Fineman|Britney Spears   |
 4140|Chris Redd   |Lil Nas X        |*/

select *
from impressions i 
where i.aid = 'Chris Redd'

select i.aid ,count(i.impid) as imp_count
from impressions i
group by i.aid
order by imp_count desc

select s.*
from seasons s
limit 5

/*
sid|year|first_epid|last_epid|n_episodes|
---+----+----------+---------+----------+
  1|1975|  19751011| 19760731|        24|
  2|1976|  19760918| 19770521|        22|
  3|1977|  19770924| 19780520|        20|
  4|1978|  19781007| 19790526|        20|
  5|1979|  19791013| 19800524|        20|*/


select s.*
from sketches s
limit 7

/*skid|name                          |
----+------------------------------+
 300|What's Wrong With This Picture|
 298|The War In Words              |
 303|Oops, You Did It Again        |
 302|The Dionne Warwick Talk Show  |
 299|Tucker Carlson Tonight        |
 250|Secret Word                   |
 233|The Situation Room            |*/

select t.*
from tenure t 
order by eps_present desc
limit 5

/*aid            |n_episodes|eps_present|n_seasons|
---------------+----------+-----------+---------+
Kenan Thompson |       361|        358|       18|
Darrell Hammond|       272|        267|       14|
Seth Meyers    |       253|        251|       13|
Fred Armisen   |       220|        219|       11|
Bobby Moynihan |       193|        192|        9|*/

select t.*, round((t.eps_present::numeric/ t.n_episodes::numeric) ,2) as attendance
from tenure t 
order by attendance
limit 5
/*
aid         |n_episodes|eps_present|n_seasons|attendance|
------------+----------+-----------+---------+----------+
Emily Prager|         1|          0|        1|      0.00|
Tom Schiller|         5|          1|        1|      0.20|
Dan Vitale  |        18|          4|        1|      0.22|
Don Novello |        38|         18|        2|      0.47|
Jim Downey  |        12|          6|        1|      0.50|*/

select t.*, round((t.eps_present::numeric/ t.n_episodes::numeric) ,2) as attendance
from tenure t 
order by attendance desc
limit 5

/*aid          |n_episodes|eps_present|n_seasons|attendance|
-------------+----------+-----------+---------+----------+
Michael Che  |       140|        140|        7|      1.00|
Beck Bennett |       161|        161|        8|      1.00|
Kate McKinnon|       187|        187|       10|      1.00|
Colin Jost   |       148|        148|        8|      1.00|
Martin Short |        17|         17|        1|      1.00|*/

select t.*
from titles t 
limit 5

/*order|epid    |tid      |name                          |category    |skid|sid|
----+--------+---------+------------------------------+------------+----+---+
   0|20210410|202104101|Eye On Minnesota              |Cold Opening|    | 46|
   1|20210410|202104102|                              |Monologue   |    | 46|
   2|20210410|202104103|What's Wrong With This Picture|Game Show   | 300| 46|
   3|20210410|202104104|Tremfalta                     |Commercial  |    | 46|
   4|20210410|202104105|Study Buddy                   |Sketch      |    | 46|*/

select count(*)
from titles t 

select t.category , count(t.order) as categ_count
from titles t 
group by t.category 
order by categ_count desc 

select split_part(e2.aired,',',2) as year, 
split_part(split_part(e2.aired,',',1), ' ',2) as day,
split_part(split_part(e2.aired,',',1), ' ',1) as month,
e2.aired :: date as aired_date,
t.epid ,t."name" , t.category 
from titles t join episodes e2 
on t.epid = e2.epid 
limit 5

select count(t."order") as serial_count, 
t.category, 
e2.aired :: date as aired_date 
from titles t join episodes e2 
on t.epid = e2.epid
group by e2.aired::date, t.category 
order by serial_count desc

select count(t."order") as serial_count, 
e2.aired :: date as aired_date 
from titles t join episodes e2 
on t.epid = e2.epid
group by e2.aired::date
order by aired_date desc
