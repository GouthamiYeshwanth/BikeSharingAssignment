# Create a database to store bike_share company details
create database bike_share;

# Use created database
use bike_share;

# Load trip data 
-- LOAD DATA LOCAL INFILE 'C:/Users/Admin/Downloads/trip (2).csv'
-- INTO TABLE trip
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (`MyUnknownColumn`, `id`,`duration`,@start_date,`start_station_name`,`start_station_id`,@end_date,`end_station_name`,`end_station_id`,`bike_id`,`subscription_type`)
-- set `start_date` = STR_TO_DATE(@start_date, '%m/%d/%Y %H:%i'),
-- `end_date` = STR_TO_DATE(@end_date, '%m/%d/%Y %H:%i');

#Task 1 Know you're company
# 1.1 Find total number of bike stations
select count(distinct(id)) as STATION_COUNT from station;

# 1.2 Find total number of bikes
select sum(bikes_available) as BIKES_COUNT from status;

# 1.3 Find total number of trips
select count(id) as TRIP_COUNT from trip;

# 4. Find the first and the last trip in the data.
SELECT * FROM trip order by id asc limit 1;
SELECT * FROM trip order by id desc limit 1;

# 5. What is the average duration:
# 5.1 Of all the trips?
select avg(duration) as AVG_DURATION from trip;

# 5.2 Of trips on which customers are ending their rides at the same station from where they started?
select avg(duration), start_station_id, end_station_id from trip 
where start_station_id = end_station_id 
group by start_station_id 
order by avg(duration) desc;

# 6. Which bike has been used the most in terms of duration? (Answer with the Bike ID)
select count(bike_id) as Rented_Count , bike_id from trip group by bike_id order by Rented_Count desc limit 1;

-- Task 2: Demand Prediction
-- Zulip is running under a loss and has decided to shut operations for three of its stations. 
-- You have to use the data provided to help Zulip decide which three stations should be shut.
# 2.1 What are the top 10 least popular stations? Hint: Find the least frequently appearing start stations from the Trip table.
select start_station_name, count(start_station_id) as Freq_Station 
from trip 
group by start_station_name 
order by Freq_Station asc
limit 10;

# 2.2 Idle time is the duration for which a station remains inactive. 
-- You can consider this as the time for which a station has more than 3 bikes available.

select station_id, bikes_available, time 
from status
where bikes_available > 3;

#2.3 Find the idle time on station 2 on date "2013/08/29"
#No data available on "2013/08/29"
select station_id, bikes_available, time
from status where bikes_available>3 and station_id=2 
group by time 
having time >= "2013/08/29 00:00:00" and time <= "2013/08/30 23:59:59"
order by bikes_available desc;

#2.3 Find the consecutive distance between two stores using Harversine's formula 
select *,
acos(
cos(radians( st.lat ))
* cos(radians( st.lead_lat ))
* cos(radians( st.long ) - radians( st.lead_long ))
+ sin(radians( st.lat ))
* sin(radians( st.lead_lat ))
) AS consecutiveStationDistance from (select *, 
LEAD(station.lat) OVER(ORDER BY station.id) as lead_lat,
LEAD(station.long) OVER(ORDER BY station.id ) as lead_long,
LEAD(station.name) OVER(ORDER BY station.id) as close_station_name,
LEAD(station.dock_count) OVER(ORDER BY station.id) as close_dock_count
from station) AS st order by consecutiveStationDistance asc limit 20;

# Find the freq of station used based on the start_station name from trip table
select count(t.id) as Number_Of_Trips, t.start_station_name as Station_Name, st.city from trip t
inner join station st
on t.start_station_id = st.id
group by t.start_station_name order by Number_Of_Trips asc limit 10;

-- Task 3: Optimizing Operations
-- Throughout the day, bikes keep moving around the city due to the trips.
--  Zulip has to find out how to effectively move bikes around to ensure the demand is met with adequate supply. 
--  This is to ensure that at any time, there are sufficient bikes available at a given station. 
-- Here are some points that you will have to consider while deciding on the transportation of bikes from one place to another:
# 3.1 Calculate the average number of bikes and docks available for Station 2. (Hint: Use the Status table.)
select avg(bikes_available) as avg_bikes_available, 
avg(docks_available) as avg_docks_available, station_id
from status
where station_id = 2;