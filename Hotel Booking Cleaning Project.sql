
/*

Cleaning Data in SQL Queries

*/

------Populate all the data from the table hotel_bookings------

SELECT * FROM dbo.hotel_bookings

 
------Adding new column ID as a primary key------

ALTER TABLE hotel_bookings ADD ID INT IDENTITY CONSTRAINT unique_id PRIMARY KEY CLUSTERED

 ------Change meal types from FB, HB, SC and BB to 'Full Board','Half Board', 'Self Catering',
		  --and 'Bed and Breakfast' resp  ------
		  
SELECT distinct (meal), count (meal) FROM hotel_bookings
group by meal order by 2;



Select distinct (meal)
, CASE When meal = 'FB' THEN 'Full Board'
	   When meal = 'SC' THEN 'Self Catering'
	   When meal = 'HB' THEN 'Half Board'
	   When meal = 'BB' THEN 'Bed and Breakfast'
	   ELSE meal
	   END
From hotel_bookings

Update hotel_bookings
SET meal = CASE 
 When meal = 'FB' THEN 'Full Board'
	   When meal = 'SC' THEN 'Self Catering'
	   When meal = 'HB' THEN 'Half Board'
	   When meal = 'BB' THEN 'Bed and Breakfast'
	   ELSE meal
	   END

---Or, in a simple way---
		  
SELECT distinct meal FROM hotel_bookings;
update hotel_bookings set meal = 'Full Board' where meal = 'FB' ;
update hotel_bookings set meal = 'Half Board' where meal = 'HB' ;
update hotel_bookings set meal = 'Self Catering' where meal = 'SC' ;
update hotel_bookings set meal = 'Bed and Breakfast' where meal = 'BB' ;
		  

------is_repeated_guest, put yes and no instead of 1 and 0------
		     
			 
   -- Adding new column is_repeated_guest_YorN			
ALTER TABLE hotel_bookings ADD is_repeated_guest_YorN char (5) ;


Select distinct (is_repeated_guest)
, cast (CASE
		When is_repeated_guest = 1 THEN 'Yes'
	   ELSE 'No'  END
	   as varchar(256))
From hotel_bookings

 -- Updating the values
Update hotel_bookings
SET is_repeated_guest_YorN = cast (CASE
		When is_repeated_guest = 1 THEN 'Yes'
	   ELSE 'No'  END
	   as varchar(256))

	   select is_repeated_guest, is_repeated_guest_YorN from hotel_bookings

	   select 
	   distinct(is_repeated_guest_YorN),
	   count(is_repeated_guest_YorN)	
	   from hotel_bookings
	  group by is_repeated_guest_YorN
	  order by 2

------is_cancelled, put yes and no instead of 1 and 0------

-- Adding new column is_canceled_YorN

 ALTER TABLE hotel_bookings ADD is_canceled_YorN char (5) ;

Select distinct (is_canceled)
, cast (CASE
		When [is_canceled] = 1 THEN 'Yes'
	   ELSE 'No'  END
	   as varchar(256))
From hotel_bookings

 -- Updating the values
Update hotel_bookings
SET is_canceled_YorN = cast (CASE
		When [is_canceled] = 1 THEN 'Yes'
	   ELSE 'No'  END
	   as varchar(256))

	   select is_canceled, is_canceled_YorN from hotel_bookings

	   select 
	   distinct(is_canceled_YorN),
	   count(is_canceled_YorN)	
	   from hotel_bookings
	  group by is_canceled_YorN
	  order by 2


 ------Standardize Date Format of reservation_status_date------


 select reservation_status_date from hotel_bookings ;

 alter table hotel_bookings add convert_reservation_status_date date;

 select convert_reservation_status_date,reservation_status_date
	, CONVERT(Date,reservation_status_date) 
				from hotel_bookings ;

update hotel_bookings
set convert_reservation_status_date = CONVERT(Date,reservation_status_date) ;

---------Renaming country code with full country name ----

-- The country_code column fields had extra blanks at the end, 
--hence it was not mapping, so we extracted the required info

update country set country_code = left(country_code,3);

SELECT distinct (country) FROM hotel_bookings order by country asc;
	SELECT * FROM country;

	select c.country_name,c.country_code  from 
	country c
	Inner join hotel_bookings h
	on c.country_code = h.country
	where 
	country_code in (select country from hotel_bookings )

	-- adding a new column names country_name
	alter table hotel_bookings add country_name varchar (255);

	-- Updating the values for country code against country name in new column that we've added.
	update hotel_bookings 
	set country_name = c.country_name  from 
	country c
	Inner join hotel_bookings h
	on c.country_code = h.country
	where 
	country_code in (select country from hotel_bookings);

---- Delete unused columns -----

alter table hotel_bookings
drop column country, reservation_status_date,is_repeated_guest,is_canceled;