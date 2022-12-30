/*This is the analysis script of the pre-paired customer data. 
Tried understanding it a bit. Still unsure what to do with the data apart from simply 
sending it into the modeling pipeline.*/

select device_browser,
	device_deviceCategory,
	device_isMobile,
	device_operatingSystem,
	geoNetwork_city,
	geoNetwork_continent,
	geoNetwork_country,
	geoNetwork_metro,
	geoNetwork_networkDomain,
	geoNetwork_region,
	geoNetwork_subContinent,
 from train_filtered tf
 limit 5
 
 select device_browser,
	device_deviceCategory,
	device_isMobile,
	device_operatingSystem,
	geoNetwork_city,
	geoNetwork_continent,
	geoNetwork_country,
	geoNetwork_metro,
	geoNetwork_networkDomain,
	geoNetwork_region,
	geoNetwork_subContinent,
 from train_flat tf
 limit 5
 
 create table device_and_location
 as
 select count(1) as group_count, device_browser,
	device_deviceCategory,
	device_isMobile,
	device_operatingSystem,
	geoNetwork_city,
	geoNetwork_continent,
	geoNetwork_country,
	geoNetwork_metro,
	geoNetwork_networkDomain,
	geoNetwork_region,
	geoNetwork_subContinent
from train_filtered 
group by device_browser,
	device_deviceCategory,
	device_isMobile,
	device_operatingSystem,
	geoNetwork_city,
	geoNetwork_continent,
	geoNetwork_country,
	geoNetwork_metro,
	geoNetwork_networkDomain,
	geoNetwork_region,
	geoNetwork_subContinent
order by group_count desc

select count(1)
from device_and_location dl

/*84,778 different choices and location */

select count(1) as city_count, tf.geoNetwork_city
from train_filtered tf
group by tf.geoNetwork_city
order by city_count DESC

select count(1) as metro_count, tf.geoNetwork_metro
from train_filtered tf
group by tf.geoNetwork_metro
order by metro_count DESC

select count(1) as country_count, tf.geoNetwork_country
from train_filtered tf
group by tf.geoNetwork_country
order by country_count DESC
 
select count(1) as ismobile_count, tf.device_operatingSystem
from train_filtered tf
group by tf.device_operatingSystem
 
select count(1) as browser_count, tf.device_browser
from train_filtered tf
group by tf.device_browser

select count(1) as categ_count, tf.device_deviceCategory
from train_filtered tf
group by tf.device_deviceCategory

select count(1) as ismobile_count, tf.device_isMobile
from train_filtered tf
group by tf.device_isMobile
 
select count(1) as type_count, 
	trafficSource_adContent,
	"trafficSource_adwordsClickInfo.adNetworkType",
	"trafficSource_adwordsClickInfo.isVideoAd",
	"trafficSource_adwordsClickInfo.page",
	"trafficSource_adwordsClickInfo.slot",
	trafficSource_campaign,
	trafficSource_isTrueDirect,
	trafficSource_keyword,
	trafficSource_medium,
	trafficSource_referralPath,
	trafficSource_source
from train_filtered 
group by trafficSource_adContent,
	"trafficSource_adwordsClickInfo.adNetworkType",
	"trafficSource_adwordsClickInfo.isVideoAd",
	"trafficSource_adwordsClickInfo.page",
	"trafficSource_adwordsClickInfo.slot",
	trafficSource_campaign,
	trafficSource_isTrueDirect,
	trafficSource_keyword,
	trafficSource_medium,
	trafficSource_referralPath,
	trafficSource_source
order by type_count desc


select trafficSource_adContent,
	"trafficSource_adwordsClickInfo.adNetworkType",
	"trafficSource_adwordsClickInfo.isVideoAd",
	"trafficSource_adwordsClickInfo.page",
	"trafficSource_adwordsClickInfo.slot",
	trafficSource_campaign,
	trafficSource_isTrueDirect,
	trafficSource_keyword,
	trafficSource_medium,
	trafficSource_referralPath,
	trafficSource_source
from train_filtered 
limit 5