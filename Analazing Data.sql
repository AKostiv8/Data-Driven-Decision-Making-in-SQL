--Exploring the renting table
SELECT *
FROM renting

-- Count NULL values in columns

-- rating column
SELECT count(*) as total_records, 
	   count(rating) as not_null_values, 
	   count(*)-count(rating) AS null_records
FROM renting
	
-- date_renting column
SELECT count(*) as total_records, 
	   count(date_renting) as not_null_values, 
	   count(*)-count(date_renting) AS null_records
FROM renting


--Select all records from renting which are not null for 2018
SELECT *
FROM renting
WHERE date_renting BETWEEN '2018-01-01' AND '2018-12-31' -- Renting in 2018
AND rating IS NOT NULL -- Rating exists

-- Count the number of countries in database
SELECT count(DISTINCT(country))  
FROM customers;

-- Ratings of movie 25
SELECT MIN(rating) as min_rating, -- Calculate the minimum rating and use alias min_rating
	   MAX(rating) AS max_rating, -- Calculate the maximum rating and use alias max_rating
	   AVG(rating) AS avg_rating, -- Calculate the average rating and use alias avg_rating
	   COUNT(rating) AS number_ratings -- Count the number of ratings and use alias number_ratings
FROM renting
WHERE movie_id = 25; -- Select all records of the movie with ID 25

--Examining annual rentals
SELECT 
	COUNT(*) AS number_renting, -- Count the total number of rented movies
	AVG(rating) AS average_rating, -- Add the average rating
	COUNT(rating) AS number_ratings -- Add the total number of ratings here.
FROM renting
WHERE date_renting >= '2019-01-01';

--First account for each country.
SELECT country, -- For each country report the earliest date when an account was created
	MIN(date_account_start) AS first_account
FROM customers
GROUP BY country
ORDER BY first_account;

--Average movie ratings
SELECT movie_id, 
       AVG(rating) AS avg_rating,
       COUNT(rating) AS number_ratings,
       COUNT(*) AS number_renting
FROM renting
GROUP BY movie_id
ORDER BY avg_rating; -- Order by average rating in decreasing order

--Average rating per customer
SELECT customer_id, -- Report the customer_id
      AVG(rating),  -- Report the average rating per customer
      COUNT(rating) AS number_rating_per_cust,  -- Report the number of ratings per customer
      COUNT(*) AS number_rentals_per_cust -- Report the number of movie rentals per customer
FROM renting
GROUP BY customer_id
HAVING COUNT(*) > 7 -- Select only customers with more than 7 movie rentals
ORDER BY AVG(rating) asc; -- Order by the average rating in ascending order

-- Join renting and customers
SELECT AVG(rating) -- Average ratings of customers from Belgium
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
WHERE c.country='Belgium';

-- Aggregating revenue, rentals and active customers
SELECT 
	SUM(m.renting_price), 
	COUNT(*), -- Count the number of rentals
	COUNT(DISTINCT r.customer_id)
FROM renting AS r
LEFT JOIN movies AS m
ON r.movie_id = m.movie_id
-- Only look at movie rentals in 2018
WHERE date_renting BETWEEN '2018-01-01' AND '2018-12-31';

--Movies and actors
SELECT m.title, -- Create a list of movie titles and actor names
       a.name
FROM actsin AS ai
LEFT JOIN movies AS m
ON m.movie_id = ai.movie_id
LEFT JOIN actors AS a
ON a.actor_id = ai.actor_id;

--Income from movies
SELECT rm.title, -- Report the income from movie rentals for each movie 
       SUM(renting_price) AS income_movie
FROM
       (SELECT m.title,  
               m.renting_price
       FROM renting AS r
       LEFT JOIN movies AS m
       ON r.movie_id=m.movie_id) AS rm
GROUP BY rm.title
ORDER BY income_movie desc; -- Order the result by decreasing income


--Age of actors from the USA
SELECT a.gender, -- Report for male and female actors from the USA 
       MIN(year_of_birth), -- The year of birth of the oldest actor
       MAX(year_of_birth) -- The year of birth of the youngest actor
FROM
    -- Use a subsequen SELECT to get all information about actors from the USA
   (SELECT *
    FROM actors
    WHERE nationality = 'USA') AS a  -- Give the table the name a
GROUP BY a.gender;

--Identify favorite movies for a group of customers
SELECT m.title, 
	   COUNT(*), -- Report number of views per movie
	   AVG(r.rating)
FROM renting AS r
	LEFT JOIN customers AS c
	ON c.customer_id = r.customer_id
	LEFT JOIN movies AS m
	ON m.movie_id = r.movie_id
WHERE c.date_of_birth BETWEEN '1970-01-01' AND '1979-12-31'
GROUP BY m.title
HAVING COUNT(*) > 1 -- Remove movies with only one rental
ORDER BY avg; -- Order with highest rating first

--Identify favorite actors for Spain
SELECT a.name,  c.gender,
       COUNT(*) AS number_views, 
       AVG(r.rating) AS avg_rating
FROM renting as r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
LEFT JOIN actsin as ai
ON r.movie_id = ai.movie_id
LEFT JOIN actors as a
ON ai.actor_id = a.actor_id
WHERE country = 'Spain' -- Select only customers from Spain
GROUP BY a.name, c.gender
HAVING AVG(r.rating) IS NOT NULL 
  AND COUNT(*) > 5 
ORDER BY avg_rating DESC, number_views DESC;


--KPIs per country
SELECT 
	c.country, -- For each country report
	COUNT(*) AS number_renting, -- The number of movie rentals
	AVG(rating) AS average_rating, -- The average rating
	SUM(renting_price) AS revenue -- The revenue from movie rentals
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE date_renting >= '2019-01-01'
GROUP BY c.country;


-- NESTED QUERIES
-- Often rented movies
SELECT *
FROM movies
WHERE movie_id IN  -- Select movie IDs from the inner query
	(SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(*) > 5)
	
--Frequent customers
SELECT *
FROM customers
WHERE customer_id IN -- Select all customers with more than 10 movie rentals
	(SELECT customer_id
	FROM renting
	GROUP BY customer_id
	HAVING COUNT(*) > 10);

--Movies with rating above average
SELECT title -- Report the movie titles of all movies with average rating higher than the total average
FROM movies
WHERE movie_id IN
	(SELECT movie_id
	 FROM renting
     GROUP BY movie_id
     HAVING AVG(rating) > 
		(SELECT AVG(rating)
		 FROM renting));
	
-- Correlated nested queries

-- Analyzing customer behavior
-- Select customers with less than 5 movie rentals
SELECT *
FROM customers as c
WHERE 5 > 
	(SELECT count(*)
	FROM renting as r
	WHERE r.customer_id = c.customer_id);
	

--Customers who gave low ratings
SELECT *
FROM customers AS c
WHERE 4 > -- Select all customers with a minimum rating smaller than 4 
	(SELECT MIN(rating)
	FROM renting AS r
	WHERE r.customer_id = c.customer_id);

--Movies and ratings with correlated queries
SELECT *
FROM movies AS m
WHERE 8 <  -- Select all movies with an average rating higher than 8
	(SELECT AVG(rating)
	FROM renting AS r
	WHERE r.movie_id = m.movie_id);
	

--Customers with at least one rating
SELECT *
FROM customers AS c -- Select all customers with at least one rating
WHERE EXISTS
	(SELECT *
	FROM renting AS r
	WHERE rating IS NOT NULL 
	AND r.customer_id = c.customer_id);


--Actors in comedies
SELECT a.nationality,
COUNT(*)-- Report the nationality and the number of actors for each nationality
FROM actors AS a
WHERE EXISTS
	(SELECT ai.actor_id
	 FROM actsin AS ai
	 LEFT JOIN movies AS m
	 ON m.movie_id = ai.movie_id
	 WHERE m.genre = 'Comedy'
	 AND ai.actor_id = a.actor_id)
GROUP BY a.nationality;

--Young actors not coming from the USA
SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE nationality <> 'USA'
INTERSECT -- Select all actors who are not from the USA and who are also born after 1990
SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE year_of_birth > 1990;


SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE nationality <> 'USA'
UNION -- Select all actors who are not from the USA and all actors who are born after 1990
SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE year_of_birth > 1990;

--Dramas with high ratings
SELECT *
FROM movies
WHERE movie_id IN -- Select all movies of genre drama with average rating higher than 9
   (SELECT movie_id
    FROM movies
    WHERE genre = 'Drama'
    INTERSECT
    SELECT movie_id
    FROM renting
    GROUP BY movie_id
    HAVING AVG(rating)>9);

--Groups of customers (CUBE)
SELECT gender, -- Extract information of a pivot table of gender and country for the number of customers
	   country,
	   COUNT(*)
FROM customers
GROUP BY CUBE (gender, country)
ORDER BY country;
 
--Categories of movies
SELECT year_of_release,
       genre,
       COUNT(*)
FROM movies
GROUP BY CUBE (year_of_release, genre)
ORDER BY year_of_release;

--Analyzing average ratings
SELECT 
	country, 
	genre, 
	AVG(r.rating) AS avg_rating -- Calculate the average rating 
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY CUBE (country, genre); -- For all aggregation levels of country and genre

--Number of customers (ROLLUP)
-- Count the total number of customers, the number of customers for each country, and the number of female and male customers for each country
SELECT country,
       gender,
	   COUNT(*)
FROM customers
GROUP BY ROLLUP (country, gender)
ORDER BY country, gender; -- Order the result by country and gender

--Analyzing preferences of genres across countries
-- Group by each county and genre with OLAP extension
SELECT 
	c.country, 
	m.genre, 
	AVG(r.rating) AS avg_rating, 
	COUNT(*) AS num_rating
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY ROLLUP (c.country, m.genre)
ORDER BY c.country, m.genre;


--Exploring nationality and gender of actors (GROUPING SETS)
SELECT 
	nationality, -- Select nationality of the actors
    gender, -- Select gender of the actors
    COUNT(*) -- Count the number of actors
FROM actors
GROUP BY GROUPING SETS ((nationality), (gender), ()); -- Use the correct GROUPING SETS operation

--Exploring rating by country and gender (GROUPING SETS)
SELECT 
	c.country, 
    c.gender,
	AVG(r.rating)
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
-- Report all info from a Pivot table for country and gender
GROUP BY GROUPING SETS ((country, gender), (country), (gender), ());

--Customer preference for genres
SELECT genre,
	   AVG(rating) AS avg_rating,
	   COUNT(rating) AS n_rating,
       COUNT(*) AS n_rentals,     
	   COUNT(DISTINCT m.movie_id) AS n_movies 
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE r.movie_id IN ( 
	SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(rating) >= 3)
AND r.date_renting >= '2018-01-01'
GROUP BY genre
ORDER BY avg_rating DESC; -- Order the table by decreasing average rating

--Customer preference for actors
SELECT a.nationality,
       a.gender,
	   AVG(r.rating) AS avg_rating,
	   COUNT(r.rating) AS n_rating,
	   COUNT(*) AS n_rentals,
	   COUNT(DISTINCT a.actor_id) AS n_actors
FROM renting AS r
LEFT JOIN actsin AS ai
ON ai.movie_id = r.movie_id
LEFT JOIN actors AS a
ON ai.actor_id = a.actor_id
WHERE r.movie_id IN ( 
	SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(rating) >= 4)
AND r.date_renting >= '2018-04-01'
GROUP BY CUBE (a.nationality, a.gender); -- Provide results for all aggregation levels represented in a pivot table
