/*REMEMBER ==> FJWGSO*/

/*This script will deal with the pre-paired customer data, understand it and then 
load it in in-memory db or postgres db*/

/*data_all_features.pkl              test_flat.csv                       train_flat.csv
test_categorial_features_moda.csv  train_categorial_features_moda.csv
test_filtered.csv                  train_filtered.csv*/

/*We will deal with the train files first. */

/*Using in-memory database works. But the performance detoriates steadily.
So moving the data to postgres*/

create table categorical_features as 
select * from read_csv_auto('/home/solverbot/Desktop/pre_paired/train_categorial_features_moda.csv', sample_size=-1)

/*immediately stuck with visitorId number crossing the int64 range. The error raised by 
 * duck db is resolved using the sample_size = -1
 */*/
 
 select * 
 from categorical_features 
 limit 5
 
/*Following are the columns, and rightly they are made into numeric*/

DROP TABLE categorical_features;

CREATE TABLE categorical_features (
	fullVisitorId numeric primary key unique,
	device_browser NUMERIC,
	device_operatingSystem NUMERIC,
	geoNetwork_city NUMERIC,
	geoNetwork_metro NUMERIC,
	geoNetwork_country NUMERIC,
	geoNetwork_networkDomain NUMERIC,
	geoNetwork_region NUMERIC,
	trafficSource_adContent NUMERIC,
	trafficSource_campaign NUMERIC,
	trafficSource_keyword NUMERIC,
	trafficSource_source NUMERIC,
	trafficSource_referralPath NUMERIC,
	weekday NUMERIC
);

copy categorical_features from '/run/media/solverbot/repoA/gitFolders/pre_paired/train_categorial_features_moda.csv' csv header delimiter ',';

select count(1)
from categorical_features 
/*There is 714,167 rows*/

select *
from categorical_features 
limit 5

create table train_flat as
select * from read_csv_auto('/home/solverbot/Desktop/pre_paired/train_flat.csv', sample_size=-1)

select count(1)
from train_flat
/*That has 903,653 rows*/

select count(1) as by_visitor, fullVisitorId
from train_flat
group by fullVisitorId
order by by_visitor DESC
/*That has 903,653 rows*/


select tf.*
from train_flat tf 
limit 5

DROP TABLE if exists train_flat;

/*That is a whole lot of data.*/

CREATE TABLE train_flat (
	channelGrouping VARCHAR,
	"date" INTEGER,
	fullVisitorId NUMERIC references categorical_features(fullvisitorid),
	sessionId VARCHAR,
	socialEngagementType INTEGER,
	visitId INTEGER,
	visitNumber INTEGER,
	visitStartTime INTEGER,
	totals_bounces INTEGER,
	totals_hits INTEGER,
	totals_newVisits INTEGER,
	totals_pageviews INTEGER,
	totals_transactionRevenue BIGINT,
	totals_visits INTEGER,
	device_browser VARCHAR,
	device_browserSize VARCHAR,
	device_browserVersion VARCHAR,
	device_deviceCategory VARCHAR,
	device_flashVersion VARCHAR,
	device_isMobile BOOLEAN,
	device_language VARCHAR,
	device_mobileDeviceBranding VARCHAR,
	device_mobileDeviceInfo VARCHAR,
	device_mobileDeviceMarketingName VARCHAR,
	device_mobileDeviceModel VARCHAR,
	device_mobileInputSelector VARCHAR,
	device_operatingSystem VARCHAR,
	device_operatingSystemVersion VARCHAR,
	device_screenColors VARCHAR,
	device_screenResolution VARCHAR,
	geoNetwork_city VARCHAR,
	geoNetwork_cityId VARCHAR,
	geoNetwork_continent VARCHAR,
	geoNetwork_country VARCHAR,
	geoNetwork_latitude VARCHAR,
	geoNetwork_longitude VARCHAR,
	geoNetwork_metro VARCHAR,
	geoNetwork_networkDomain VARCHAR,
	geoNetwork_networkLocation VARCHAR,
	geoNetwork_region VARCHAR,
	geoNetwork_subContinent VARCHAR,
	trafficSource_adContent VARCHAR,
	"trafficSource_adwordsClickInfo.adNetworkType" VARCHAR,
	"trafficSource_adwordsClickInfo.criteriaParameters" VARCHAR,
	"trafficSource_adwordsClickInfo.gclId" VARCHAR,
	"trafficSource_adwordsClickInfo.isVideoAd" BOOLEAN,
	"trafficSource_adwordsClickInfo.page" INTEGER,
	"trafficSource_adwordsClickInfo.slot" VARCHAR,
	trafficSource_campaign VARCHAR,
	trafficSource_campaignCode VARCHAR,
	trafficSource_isTrueDirect BOOLEAN,
	trafficSource_keyword VARCHAR,
	trafficSource_medium VARCHAR,
	trafficSource_referralPath VARCHAR,
	trafficSource_source VARCHAR
);


copy train_flat from '/run/media/solverbot/repoA/gitFolders/pre_paired/train_flat.csv' csv header delimiter ',';

/*selecting the above columns DDL shows there are 55 columns. It better we split them for 
 * our analysis*/

create table train_filtered as
select * from read_csv_auto('/home/solverbot/Desktop/pre_paired/train_filtered.csv', sample_size=-1)

select count(1)
from train_filtered 

/*This is another 902,755 rows*/

select tl.*
from train_filtered tl
limit 5

DROP TABLE train_filtered;

CREATE TABLE train_filtered (
	channelGrouping VARCHAR,
	"date" varchar,
	fullVisitorId numeric references categorical_features(fullvisitorid),
	visitNumber INTEGER,
	visitStartTime INTEGER,
	totals_bounces numeric,
	totals_hits INTEGER,
	totals_newVisits numeric,
	totals_pageviews numeric,
	totals_transactionRevenue numeric,
	device_browser VARCHAR,
	device_deviceCategory VARCHAR,
	device_isMobile INTEGER,
	device_operatingSystem VARCHAR,
	geoNetwork_city VARCHAR,
	geoNetwork_continent VARCHAR,
	geoNetwork_country VARCHAR,
	geoNetwork_metro VARCHAR,
	geoNetwork_networkDomain VARCHAR,
	geoNetwork_region VARCHAR,
	geoNetwork_subContinent VARCHAR,
	trafficSource_adContent VARCHAR,
	"trafficSource_adwordsClickInfo.adNetworkType" VARCHAR,
	"trafficSource_adwordsClickInfo.isVideoAd" INTEGER,
	"trafficSource_adwordsClickInfo.page" numeric,
	"trafficSource_adwordsClickInfo.slot" VARCHAR,
	trafficSource_campaign VARCHAR,
	trafficSource_isTrueDirect INTEGER,
	trafficSource_keyword VARCHAR,
	trafficSource_medium VARCHAR,
	trafficSource_referralPath VARCHAR,
	trafficSource_source VARCHAR
);

copy train_filtered from '/run/media/solverbot/repoA/gitFolders/pre_paired/train_filtered.csv' csv header delimiter ',';

/*the question is what is filtered in the train_filtered dataset? Need to understand more closely*/

select tf.channelGrouping,tf."date"::date as visit_date,tf.fullVisitorId,tf.visitNumber,
	to_timestamp(tf.visitStartTime) as visit_timestamp,tf.totals_bounces,tf.totals_hits,tf.totals_newVisits,
	tf.totals_pageviews,tf.totals_transactionRevenue
from train_filtered tf
limit 5

/*the varchar date and unix time stamp can be casted into date format. Not the integer type*/


select tf.channelGrouping,tf."date",tf.fullVisitorId,tf.visitNumber,
	tf.visitStartTime,tf.totals_bounces,tf.totals_hits,tf.totals_newVisits,
	tf.totals_pageviews,tf.totals_transactionRevenue
from train_flat tf
limit 5

/*The gold is in the "totals_transactionRevenue"
 * 1) The date is in wrong format, I think a simple cast will correct that
 * 2) visitStartTime is in unix timestamp, need to work on that
 */*/
/*Moving the analytics code to the respective file*/ 
 
