CREATE DATABASE softuni_imdb;
USE softuni_imdb;

/*01.	Table Design*/
CREATE TABLE countries(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(30) NOT NULL UNIQUE,
continent VARCHAR(30) NOT NULL,
currency VARCHAR(5) NOT NULL
);

CREATE TABLE genres(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE actors(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
birthdate DATE NOT NULL,
height INT,
awards INT,
country_id INT NOT NULL,
CONSTRAINT fk_actors_countries
FOREIGN KEY (country_id)
REFERENCES countries(id)
);

CREATE TABLE movies_additional_info(
id INT PRIMARY KEY AUTO_INCREMENT,
rating DECIMAL(10, 2) NOT NULL,
runtime INT NOT NULL,
picture_url VARCHAR(80) NOT NULL,
budget DECIMAL(10, 2),
release_date DATE NOT NULL,
has_subtitles BOOLEAN,
`description` TEXT
);

CREATE TABLE movies(
id INT PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(70) NOT NULL UNIQUE,
country_id INT NOT NULL,
movie_info_id INT NOT NULL UNIQUE,
CONSTRAINT fk_movies_countries
FOREIGN KEY (country_id)
REFERENCES countries(id),
CONSTRAINT fk_movies_movies_additional_info
FOREIGN KEY (movie_info_id)
REFERENCES movies_additional_info(id)
);

CREATE TABLE movies_actors(
movie_id INT,
actor_id INT,
CONSTRAINT fk_movies_actors_movies
FOREIGN KEY (movie_id)
REFERENCES movies(id),
CONSTRAINT fk_movies_actors_actors
FOREIGN KEY (actor_id)
REFERENCES actors(id)
);

CREATE TABLE genres_movies(
genre_id INT,
movie_id INT,
CONSTRAINT fk_genres_movies_genres
FOREIGN KEY (genre_id)
REFERENCES genres(id),
CONSTRAINT fk_genres_movies_movies
FOREIGN KEY (movie_id)
REFERENCES movies(id)
);

#02.Insert

INSERT INTO actors(first_name, last_name, birthdate , height, awards, country_id) (
SELECT (reverse(first_name)), (reverse(last_name)), (DATE(birthdate  - 2)), (height + 10), (country_id), (3) FROM actors 
WHERE id <= 10);

#03.Update

UPDATE movies_additional_info AS m
SET 
    m.runtime = m.runtime - 10
WHERE
    m.id BETWEEN 15 AND 25;


#04.Delete
#Delete all countries that don’t have movies

DELETE c FROM countries AS c
LEFT JOIN movies AS m ON c.id = m.country_id
WHERE title is null;

DELETE FROM countries
WHERE id NOT IN (SELECT country_id FROM movies)

#05. Countries

#Extract from the softuni_imdb system database, info about the name of countries.
#Order the results by currency in descending order and then by id.
#Required Columns
#	id (countries)
#	name
#	continent
#	currency

SELECT * FROM countries
ORDER BY currency DESC, id;

#06. Old movies
#Write a query that returns: title, runtime, budget and release_date from table movies_additional_info.
#Filter movies which have been released from 1996 to 1999 year (inclusive).
#Order the results ascending by runtime then by id and show only the first 20 results.
#Required Columns
#	id
#	title
#	runtime
#	budget
#	release_date

SELECT m.id, m.title, mi.runtime, mi.budget, mi.release_date FROM movies AS m
JOIN movies_additional_info AS mi ON m.movie_info_id = mi.id
WHERE year(mi.release_date) BETWEEN 1996 and 1999
ORDER BY mi.runtime ASC, m.id
LIMIT 20;

#07. Movie casting
#Some actors are free and can apply the casting for a new movie. You must search for them and prepare their documents.
#Write a query that returns:  full name, email, age and height for all actors that are not participating in a movie.
#To find their email you must take their last name reversed followed by the number of characters of their last name 
#and then the casting email “@cast.com”
#Order by height in ascending order.
#Required Columns
#	full_name (first_name + " " + last_name)
#	email (last_name reversed + number of characters from the last_name + @cast.com)
#	age (2022 – the year of the birth)
#	heigh

SELECT 
    CONCAT_WS(' ', first_name, last_name) AS full_name,
    CONCAT(REVERSE(last_name), LENGTH(last_name), "@cast.com") AS email,
    2022 - YEAR(birthdate) AS age,
    height
FROM
    actors
WHERE id NOT IN (SELECT actor_id FROM movies_actors)
ORDER BY height;

/*08.	International festival
The international movie festival is about to begin. We need to find the countries which are nominated to host the event.
Extract from the database, the name the country and the number of movies created in this country. 
The number of movies must be higher or equal to 7.
Order the results descending by name.
Required Columns
•	name (country)
•	movies_count (number of movies created in the country)
*/

SELECT c.name, COUNT(m.id) AS movies_count
FROM countries AS c
JOIN movies AS m ON c.id = m.country_id
GROUP BY c.name
HAVING movies_count >= 7
ORDER BY c.name DESC;

/*09.	Rating system
From the database extract the title, rating, subtitles, and the budget of movies. If the rating is equal or less than 4 the user must see “poor”, 
above 4 and less or equal to 7 “good” and above that it should display “excellent”. If the movie has subtitles the user should see “english”, 
otherwise “-“.
Order the results descending by budget. 
Required Columns
•	title
•	rating (less or equal to 4 – “poor”, above 4 and less or equal to 7 – “good”, above 7 – “excellent”)
•	subtitles (if it has subtitles it– “english”, otherwise – “-“)
•	budget
*/

SELECT m.title, 
	   (CASE
			WHEN mi.rating <= 4 THEN 'poor'
            WHEN mi.rating <= 7 THEN 'good'
            ELSE 'excellent'
       END) AS 'rating',
       IF (mi.has_subtitles = 1, 'english', '-') AS 'subtitles',
       mi.budget
FROM movies AS m
JOIN movies_additional_info AS mi ON m.movie_info_id = mi.id
ORDER BY mi.budget DESC;

/*10.	History movies
Create a user defined function with the name udf_actor_history_movies_count(full_name VARCHAR(50)) that receives an actor’s full name 
and returns the total number of history movies in which the actor has a role.

Required Columns
•	history_movies(udf_customer_products_count)
*/

DELIMITER $$
CREATE FUNCTION udf_actor_history_movies_count(full_name VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE history_movies_count INT; #count of historical movies for current actor
    SET history_movies_count := (
		SELECT COUNT(g.name) AS 'history_movies' FROM actors AS a
        JOIN movies_actors AS ma ON a.id = ma.actor_id
        JOIN movies AS m ON ma.movie_id = m.id
        JOIN genres_movies AS gm ON m.id = gm.movie_id
        JOIN genres AS g ON gm.genre_id = g.id
        WHERE g.name = "History" AND full_name = CONCAT(a.first_name, " ", a.last_name)
        GROUP BY g.name 
    );
    RETURN history_movies_count;
END$$

DELIMITER ;

SELECT udf_actor_history_movies_count('Stephan Lundberg')  AS 'history_movies';
SELECT udf_actor_history_movies_count('Jared Di Batista')  AS 'history_movies';

/*11.	Movie awards
A movie has won an award. Your task is to find all actors and give them the award.
Create a stored procedure udp_award_movie which accepts the following parameters:
•	movie_title(VARCHAR(50))
Extracts data about the movie with the given title and find all actors that play in it and increase their awards with 1.
*/

DELIMITER $$
CREATE PROCEDURE udp_award_movie(movie_title VARCHAR(50))
BEGIN
	UPDATE actors AS a
    JOIN movies_actors AS ma ON a.id = ma.actor_id
    JOIN movies AS m ON ma.movie_id = m.id
    SET a.awards = a.awards + 1
    WHERE m.title = movie_title;
END$$

DELIMITER ;

CALL udp_award_movie('Tea For Two');





