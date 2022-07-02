use fortunedb

--Create table

CREATE TABLE all_data_202101_202112 (
ride_id nvarchar(255),
rideable_type nvarchar(50),
started_at datetime2,
ended_at datetime2,
start_lat float,
start_lng float,
end_lat float,
end_lng float,
start_station_name nvarchar(100),
member_casual nvarchar(50) )

--Insert all data into table

INSERT INTO [dbo].[all_data_202101_202112] (ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual)
(Select ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual
From fortunedb.dbo.[202101-divvy-tripdata]) 

UNION ALL
(Select ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual
From fortunedb.dbo.[202102-divvy-tripdata]) 

UNION ALL
(Select ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual
From fortunedb.dbo.[202103-divvy-tripdata])

UNION ALL
(Select ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual
From fortunedb.dbo.[202104-divvy-tripdata])

UNION ALL
(Select ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual
From fortunedb.dbo.[202105-divvy-tripdata])

UNION ALL
(Select ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual
From fortunedb.dbo.[202106-divvy-tripdata])

UNION ALL
(Select ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual
From fortunedb.dbo.[202107-divvy-tripdata])

UNION ALL
(Select ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual
From fortunedb.dbo.[202108-divvy-tripdata])

UNION ALL
(Select ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual
From fortunedb.dbo.[202109-divvy-tripdata])

UNION ALL
(Select ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual
From fortunedb.dbo.[202110-divvy-tripdata])

UNION ALL
(Select ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual
From fortunedb.dbo.[202111-divvy-tripdata])

UNION ALL
(Select ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng, start_station_name, member_casual
From fortunedb.dbo.[202112-divvy-tripdata])

ALTER TABLE [dbo].[all_data_202101_202112]
ADD ride_length int

UPDATE [dbo].[all_data_202101_202112]
SET ride_length = DATEDIFF(MINUTE, started_at, ended_at)

ALTER TABLE [dbo].[all_data_202101_202112]
ADD day_of_week nvarchar(50),
month_m nvarchar(50),
year_y nvarchar(50)

UPDATE [dbo].[all_data_202101_202112]
SET day_of_week = DATENAME(WEEKDAY, started_at),
month_m = DATENAME(MONTH, started_at),
year_y = year(started_at)

ALTER TABLE [dbo].[all_data_202101_202112]       
ADD month_int int

-- Extracting month num from datetime2 format

UPDATE [dbo].[all_data_202101_202112]             
SET month_int = DATEPART(MONTH, started_at)

ALTER TABLE [dbo].[all_data_202101_202112]       
ADD date_yyyy_mm_dd date

-- datetime2 format to date

UPDATE [dbo].[all_data_202101_202112]             
SET date_yyyy_mm_dd = CAST(started_at AS date)

--Delete NULL values

DELETE FROM [dbo].[all_data_202101_202112]
Where ride_id IS NULL OR
start_station_name IS NULL OR
ride_length IS NULL OR
ride_length = 0 OR
ride_length < 0 OR
ride_length > 1440

----------------Final table

SELECT *
From all_data_202101_202112

Select Count(DISTINCT(ride_id)) AS uniq,
Count(ride_id) AS total
From [dbo].[all_data_202101_202112]

--Users per day

Create View users_per_day AS
Select 
Count(case when member_casual = 'member' then 1 else NULL END) AS num_of_members,
Count(case when member_casual = 'casual' then 1 else NULL END) AS num_of_casual,
Count(*) AS num_of_users,
day_of_week
From [dbo].[all_data_202101_202112]
Group BY day_of_week

--Calculate average ride length

Create View avg_ride_length AS
SELECT member_casual AS user_type, AVG(ride_length)AS avg_ride_length
From [dbo].[all_data_202101_202112]
Group BY member_casual

CREATE TABLE #member_table (
ride_id nvarchar(50),
rideable_type nvarchar(50),
member_casual nvarchar(50),
ride_length int,
day_of_week nvarchar(50),
month_m nvarchar(50),
year_y int )

INSERT INTO #member_table (ride_id, rideable_type, member_casual, ride_length, day_of_week, month_m, year_y)
(Select ride_id, rideable_type, member_casual, ride_length, day_of_week, month_m, year_y
From [dbo].[all_data_202101_202112]
Where member_casual = 'member')

CREATE TABLE #casual_table (
ride_id nvarchar(50),
rideable_type nvarchar(50),
member_casual nvarchar(50),
ride_length int,
day_of_week nvarchar(50),
month_m nvarchar(50),
year_y int )

INSERT INTO #casual_table (ride_id, rideable_type, member_casual, ride_length, day_of_week, month_m, year_y)
(Select ride_id, rideable_type, member_casual, ride_length, day_of_week, month_m, year_y
From [dbo].[all_data_202101_202112]
Where member_casual = 'casual')

Select *
From #casual_table

Select *
From #member_table

--monthly user traffic
Select month_int AS Month_Num,
month_m AS Month_Name, 
year_y AS Year_Y,
Count(case when member_casual = 'member' then 1 else NULL END) AS num_of_member,
Count(case when member_casual = 'casual' then 1 else NULL END) AS num_of_casual,
Count(member_casual) AS total_num_of_users
From [dbo].[all_data_202101_202112]
Group BY year_y, month_int, month_m
ORDER BY year_y, month_int, month_m

--daily user traffic
Select 
Count(case when member_casual = 'member' then 1 else NULL END) AS num_of_members,
Count(case when member_casual = 'casual' then 1 else NULL END) AS num_of_casual,
Count(*) AS num_of_users,
date_yyyy_mm_dd AS date_d
From [dbo].[all_data_202101_202112]
Group BY date_yyyy_mm_dd
ORDER BY date_yyyy_mm_dd

Alter Table [dbo].[all_data_202101_202112]
ADD hour_of_day int

UPDATE [dbo].[all_data_202101_202112]
SET hour_of_day = DATEPART(hour, started_at)

--hourly user traffic
Select
hour_of_day AS Hour_of_day,
Count(case when member_casual = 'member' then 1 else NULL END) AS num_of_members,
Count(case when member_casual = 'casual' then 1 else NULL END) AS num_of_casual,
Count(*) AS num_of_users
From [dbo].[all_data_202101_202112]
Group By Hour_Of_Day
Order By Hour_Of_Day

--Top 20 station
Select
TOP 20 start_station_name AS Station_name,
Count(case when member_casual = 'casual' then 1 else NULL END) AS num_of_casual
From [dbo].[all_data_202101_202112]
Group By start_station_name
Order By num_of_casual DESC
