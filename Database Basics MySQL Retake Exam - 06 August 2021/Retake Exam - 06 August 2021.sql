CREATE DATABASE SoftUni_Game_Dev_Branch;
USE SoftUni_Game_Dev_Branch;

# 01. Table Design

CREATE TABLE addresses(
id INT PRIMARY KEY AUTO_INCREMENT,
`name`  VARCHAR(50) NOT NULL
);

CREATE TABLE categories(
id INT PRIMARY KEY AUTO_INCREMENT,
`name`VARCHAR(10) NOT NULL
);

CREATE TABLE offices(
id INT PRIMARY KEY AUTO_INCREMENT,
workspace_capacity INT NOT NULL,
website VARCHAR(50),
address_id INT NOT NULL,
CONSTRAINT fk_offices_addresses
FOREIGN KEY (address_id)
REFERENCES addresses (id)
);

CREATE TABLE employees(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
age INT NOT NULL,
salary DECIMAL (10, 2) NOT NULL,
job_title VARCHAR(20) NOT NULL,
happiness_level CHAR(1) NOT NULL
);

CREATE TABLE teams(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL,
office_id INT NOT NULL,
leader_id INT NOT NULL UNIQUE,
CONSTRAINT fk_teams_offices
FOREIGN KEY (office_id)
REFERENCES offices (id),
CONSTRAINT fk_teams_employees
FOREIGN KEY (leader_id)
REFERENCES employees (id)
);


CREATE TABLE games(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
description TEXT,
rating FLOAT NOT NULL DEFAULT(5.5),
budget DECIMAL(10, 2) NOT NULL,
release_date DATE,
team_id INT NOT NULL,
CONSTRAINT fk_games_teams
FOREIGN KEY (team_id)
REFERENCES teams (id)
);

CREATE TABLE games_categories(
game_id INT NOT NULL,
category_id INT NOT NULL,
PRIMARY KEY (game_id, category_id)
);

# 02. Insert

/*The bosses urgently want to announce 9 new games and because there is no time, the developers decide not to waste time thinking about details but to announce something as soon as possible.
You will have to insert records of data into the games table, based on the teams table. 
For all teams with id between 1 and 9 (both inclusive), insert data in the games table with the following values:
•	name:
o	 the name of the team but reversed
o	 all letters must be lower case
o	 omit the starting character of the team's name
	 Example: Team name – Thiel -> leih
•	rating – set it to be equal to the team's id
•	budget – set it to be equal to the leader's id multiplied by 1000
•	team_id – set it to be equal to the team's id
*/

INSERT INTO games (name, rating, budget, team_id)
SELECT LOWER(REVERSE(SUBSTR(name, 2))) , t.id, (t.leader_id * 1000), t.id FROM teams AS t 
WHERE t.id BETWEEN 1 AND 9;

# 03. Update

/*After a good work in recent months, management has decided to raise the salaries of all young team leaders.
Update all young employees (only team leaders) with age under 40(exclusive) and increase their salary with 1000. 
Skip the employees with salary over 5000(inclusive). Their salaries are already high.
*/

UPDATE employees
SET salary = salary + 1000
WHERE age < 40 AND salary <= 5000;

# 04. Delete

/*After a lot of manipulations on our base, now we must clean up.
Delete all games from table games, which do not have a category and release date. 
*/

DELETE g FROM games AS g 
LEFT JOIN games_categories AS gc ON gc.game_id = g.id
WHERE g.release_date IS NULL AND gc.category_id IS NULL;

#05. Employees

/*Extract from the SoftUni Game Dev Branch (sgd) database, info about all the employees. 
Order the results by the employee's salary, then by their id.
Required Columns
•	first_name
•	last_name
•	age
•	salary	
•	happiness_level
*/

SELECT first_name, last_name, age, salary, happiness_level FROM employees
ORDER BY salary, id;

# 06. Addresses of the teams

/*Extract from the database all the team names and their addresses. Also display the count of the characters of the address names.
Skip those teams whose office does not have a website. 
Order the results by team names, then by the address names. 
Required Columns
•	team_name
•	address_name
•	count_of_characters(of the address name)
*/

SELECT t.name AS 'team_name', a.name AS 'address_name', char_length(a.name) AS 'count_of_characters' FROM teams AS t
LEFT JOIN offices AS o ON o.id = t.office_id
LEFT JOIN addresses AS a ON o.address_id = a.id
WHERE o.website IS NOT NULL
ORDER BY team_name, address_name;

# 07. Categories Info

/*Now, we need a more detailed information about categories – count of game, average budget and max rating.
Select all categories names, count of the games from each category, the average budget (rounded to the second digit after the decimal point) of all games from the current category and the max rating of games from a category.
Order the result by count of games in descending order, then by the name of the category alphabetically. 
Skip categories with max r	ating lower than 9.5(exclusive).

Required Columns
•	name
•	games_count
•	avg_budget (rounded to the second digit after the decimal point)
•	max_rating
*/

SELECT c.name, COUNT(gc.game_id) AS games_count, ROUND(AVG(g.budget), 2) AS avg_budget, MAX(g.rating) AS max_rating FROM games_categories AS gc
LEFT JOIN categories AS c ON c.id = gc.category_id
LEFT JOIN games AS g ON g.id = gc.game_id
GROUP BY c.name
HAVING MAX(g.rating) >= 9.5
ORDER BY games_count DESC , c.name;

# 08. Games of 2022

/*Now, we need to find all interesting upcoming games.
Extract from the database all games that are being released in the year 2022. Also, the month must be even. We need only the first game sequel (ends with '…2'). We need the information of the game name, the game release date, a short summary (only the first 10 characters + '…') and the name of the team.
At last, a column ‘Quarters’ depends on the month of the release date:
•	January, February, and March (Q1)
•	April, May, and June (Q2)
•	July, August, and September (Q3)
•	October, November, and December (Q4)

Order by Quarters.
*/

SELECT g.name, g.release_date, CONCAT(LEFT(g.description, 10), '...') AS summary,
		(CASE WHEN MONTH(release_date) IN (1, 2, 3) THEN 'Q1'
			  WHEN MONTH(release_date) IN (4, 5, 6) THEN 'Q2'
              WHEN MONTH(release_date) IN (7, 8, 9) THEN 'Q3'
              WHEN MONTH(release_date) IN (10, 11, 12) THEN 'Q4'
              END) AS quarter,
              t.name AS team_name 
FROM games AS g
LEFT JOIN teams AS t ON g.team_id = t.id
WHERE YEAR(release_date) = 2022 AND MONTH(release_date) %2 = 0 AND g.name LIKE '%2'
ORDER BY quarter;          

# 09. Full info for games

/*Our managers want to monitor all games that don’t have a release date nor a category. 
They want us to create a query, which shows the main information about the games. 
The information that they need is the name of the game, the name of the team, the name of the address 
and if the budget is less than 50000. If it is, we need to display 'Normal budget'. If it doesn’t - 'Insufficient budget'. 
Finally, we should order the result by the name of the game.

Required Columns
•	name (of the game)
•	budget_level
•	team_name
•	address_name 
*/

SELECT g.name, IF(g.budget < 50000, 'Normal budget', 'Insufficient budget') AS budget_level, t.name AS team_name, a.name AS address_name
FROM games AS g
JOIN teams AS t ON g.team_id = t.id
JOIN offices AS o ON t.office_id = o.id
LEFT JOIN addresses AS a ON o.address_id = a.id
LEFT JOIN games_categories AS gc ON g.id = gc.game_id
LEFT JOIN categories AS c ON gc.category_id = c.id
WHERE  g.release_date IS NULL AND gc.category_id IS NULL
ORDER BY g.name;

/*10.	Find all basic information for a game
Create a user defined function with the name udf_game_info_by_name (game_name VARCHAR (20)) that receives a game's name and returns the basic information as a text sentence.
•	Example
o	The "game_name" is developed by a "team_name" in an office 
with an address "address_text"

Example 1
Query
SELECT udf_game_info_by_name('Bitwolf') AS info;
info
The Bitwolf is developed by a Rempel-O'Kon in an office with an address 92 Memorial Park

*/

DELIMITER %%
CREATE FUNCTION udf_game_info_by_name (game_name VARCHAR (20))
RETURNS TEXT
DETERMINISTIC
BEGIN
RETURN (SELECT CONCAT_WS(' ', 'The', g.name, 'is developed by a', t.name, 'in an office with an address', a.name)
AS info FROM games AS g
LEFT JOIN teams AS t ON g.team_id = t.id
LEFT JOIN offices AS o ON t.office_id = o.id
LEFT JOIN addresses AS a ON a.id = o.address_id
WHERE g.name = game_name);
END %%

DELIMITER ;

SELECT udf_game_info_by_name('Bitwolf') AS info;
SELECT udf_game_info_by_name('Fix San') AS info;
SELECT udf_game_info_by_name('Job') AS info;

/*11.	Update budget of the games 
We will have to increase the support of the games that do not have any categories yet. 
We should find them and increase their budget, as well as push their release date
The procedure must increase the budget by 100,000 
and add one year to their release_date to the games that do not have any categories and their rating is more than (not equal) 
the given parameter min_game_rating and release date is NOT NULL.
Create a stored procedure udp_update_budget which accepts the following parameters:
•	min_game_rating(floating point number) 

Query
CALL udp_update_budget (8);
This execution will update three games – Quo Lux, Daltfresh and Span.
Result
Quo Lux - 23384.32 -> 123384.32 | 2022-06-26 -> 2023-06-26
Daltfresh - 86012.38 -> 186012.38 | 2021-06-17 -> 2022-06-17
Span - 47468.36 -> 147468.36 | 2022-06-05 -> 2023-06-05
*/

DELIMITER %%
CREATE PROCEDURE udp_update_budget(min_game_rating FLOAT)
BEGIN 
UPDATE games AS g
LEFT JOIN games_categories AS gc ON g.id = gc.game_id
LEFT JOIN categories AS c ON gc.category_id = c.id
SET g.budget = (g.budget + 100000), g.release_date = date_add(g.release_date, INTERVAL 1 YEAR)
WHERE gc.game_id IS NULL AND g.rating > min_game_rating AND min_game_rating IS NOT NULL AND g.release_date IS NOT NULL;
END %%

DELIMITER ;

CALL udp_update_budget (8);

