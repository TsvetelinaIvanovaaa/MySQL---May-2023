DROP DATABASE fsd;
CREATE DATABASE fsd;
USE fsd;

/*Section 1: Data Definition Language (DDL) – 40 pts*/
CREATE TABLE countries(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(45) NOT NULL
);

CREATE TABLE towns(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(45) NOT NULL,
country_id INT NOT NULL,
CONSTRAINT fk_towns_countries
FOREIGN KEY (country_id)
REFERENCES countries(id)
);

CREATE TABLE stadiums(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(45) NOT NULL,
capacity INT NOT NULL,
town_id INT NOT NULL,
CONSTRAINT fk_stadiums_towns
FOREIGN KEY (town_id)
REFERENCES towns(id)
);

CREATE TABLE teams(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(45) NOT NULL,
established DATE NOT NULL,
fan_base BIGINT NOT NULL DEFAULT(0),
stadium_id INT NOT NULL,
CONSTRAINT fk_teams_stadiums
FOREIGN KEY (stadium_id)
REFERENCES stadiums(id)
);

CREATE TABLE skills_data(
id INT PRIMARY KEY AUTO_INCREMENT,
dribbling INT DEFAULT(0),
pace INT DEFAULT(0),
passing INT DEFAULT(0),
shooting INT DEFAULT(0),
speed INT DEFAULT(0),
strength INT DEFAULT(0)
);

CREATE TABLE coaches(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(10, 2) NOT NULL DEFAULT(0),
coach_level INT NOT NULL DEFAULT(0)
);

CREATE TABLE players(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
age INT NOT NULL DEFAULT(0),
position CHAR(1) NOT NULL,
salary DECIMAL(10, 2) NOT NULL DEFAULT(0),
hire_date DATETIME,
skills_data_id INT,
team_id INT,
CONSTRAINT fk_players_skills_data
FOREIGN KEY (skills_data_id)
REFERENCES skills_data(id),
CONSTRAINT fk_players_teams
FOREIGN KEY (team_id)
REFERENCES teams(id)
);

CREATE TABLE players_coaches(
player_id INT,
coach_id INT,
CONSTRAINT fk_players_coaches_players
FOREIGN KEY (player_id)
REFERENCES players(id),
CONSTRAINT fk_players_coaches_coaches
FOREIGN KEY (coach_id)
REFERENCES coaches(id)
);

/*Section 2: Data Manipulation Language (DML) – 30 pts*/

/*2.	Insert
You will have to insert records of data into the coaches table, based on the players table. 
For players with age over 45 (inclusive), insert data in the coaches table with the following values:
•	first_name – set it to first name of the player
•	last_name – set it to last name of the player.
•	salary – set it to double as player’s salary. 
•	coach_level – set it to be equals to count of the characters in player’s first_name.
*/

INSERT INTO coaches (first_name, last_name, salary, coach_level) (
SELECT 
    p.first_name,
    p.last_name,
    p.salary,
    char_length(p.first_name) AS coach_level
FROM
    players AS p
WHERE
    p.age >= 45
);

/*3.	Update
Update all coaches, who train one or more players and their first_name starts with ‘A’. Increase their level with 1.
*/

UPDATE coaches AS c 
SET 
    c.coach_level = c.coach_level + 1
WHERE
    c.id IN (SELECT 
            coach_id
        FROM
            players_coaches)
        AND first_name LIKE 'A%';
        
        
/*UPDATE coaches AS c
        JOIN
    players_coaches AS pc ON c.id = pc.coach_id 
SET 
    c.coach_level = coach_level + 1
WHERE
    pc.coach_id >= 1
        AND first_name LIKE 'A%';*/
        
/*4.	Delete
As you remember at the beginning of our work, we promoted several football players to coaches. Now you need to remove all of them from the table of players in order for our database to be updated accordingly.	
Delete all players from table players, which are already added in table coaches. 
*/

DELETE FROM players
WHERE age >= 45;

/*Section 3: Querying – 50 pts*/
/*5.	Players 
Extract from the Football Scout Database (fsd) database, info about all of the players. 
Order the results by players - salary descending.
Required Columns
•	first_name
•	age
•	salary
*/

SELECT first_name, age, salary FROM players
ORDER BY salary DESC;

/*6.	Young offense players without contract
One of the coaches wants to know more about all the young players (under age of 23) who can strengthen his team in the offensive (played on position ‘A’). As he is not paying a transfer amount, he is looking only for those who have not signed a contract so far (haven’t hire_date) and have strength of more than 50. Order the results ascending by salary, then by age.

Required Columns
•	id (player)
•	full_name 
•	age
•	position
•	hire_date
*/

SELECT p.id, CONCAT(p.first_name, ' ', p.last_name) AS 'full_name', p.age, p.position, p.hire_date FROM players AS p
JOIN skills_data AS sd
ON p.skills_data_id = sd.id
WHERE p.age < 23 AND sd.strength > 50 AND p.hire_date IS NULL AND p.position = 'A'
ORDER BY p.salary, p.age;

/*7.	Detail info for all teams
Extract from the database all of the teams and the count of the players that they have.
Order the results descending by count of players, then by fan_base descending. 
Required Columns
•	team_name
•	established
•	fan_base
•	count_of_players
*/

SELECT t.name AS team_name, t.established, t.fan_base, COUNT(p.id) AS players_count
FROM teams AS t
LEFT JOIN players AS p
ON t.id = p.team_id
GROUP BY t.id
ORDER BY players_count DESC, t.fan_base DESC;

/*8.	The fastest player by towns
Extract from the database, the fastest player (having max speed), in terms of towns where their team played.
Order players by speed descending, then by town name.
Skip players that played in team ‘Devify’

Required Columns
•	max_speed
•	town_name
*/

SELECT MAX(sd.speed) AS max_speed, tw.name AS town_name FROM skills_data as sd
RIGHT JOIN players AS p ON sd.id = p.skills_data_id
RIGHT JOIN teams AS t ON t.id = p.team_id
JOIN stadiums AS s ON s.id = t.stadium_id
RIGHT JOIN towns AS tw ON tw.id = s.town_id
WHERE t.name != 'Devify'
GROUP BY tw.id
ORDER BY max_speed DESC, tw.name;

/*9.	Total salaries and players by country

 And like everything else in this world, everything is ultimately about finances. Now you need to extract detailed information on the amount of all salaries given to football players by the criteria of the country in which they played.
If there are no players in a country, display NULL.  Order the results by total count of players in descending order, then by country name alphabetically.


Required Columns
•	name (country)
•	total_sum_of_salaries
•	total_count_of_players
*/

SELECT c.name, COUNT(p.id) AS total_count_of_players, SUM(p.salary) AS total_sum_of_salaries FROM countries AS c
LEFT JOIN towns AS tw ON c.id = tw.country_id
LEFT JOIN stadiums AS s ON s.town_id = tw.id
LEFT JOIN teams AS t ON t.stadium_id = s.id
LEFT JOIN players AS p ON p.team_id = t.id
GROUP BY c.id
ORDER BY total_count_of_players DESC, c.name;

/*Section 4: Programmability – 30 pts*/

/*10.	Find all players that play on stadium
Create a user defined function with the name udf_stadium_players_count (stadium_name VARCHAR(30)) that receives a stadium’s name and returns the number of players that play home matches there.
*/

DELIMITER $$
CREATE FUNCTION udf_stadium_players_count (stadium_name VARCHAR(30))
RETURNS int DETERMINISTIC
BEGIN
RETURN (
SELECT COUNT(p.id) FROM players AS p
RIGHT JOIN teams AS t ON t.id = p.team_id
RIGHT JOIN stadiums AS s ON s.id = t.stadium_id
WHERE s.name = stadium_name
GROUP BY s.id);
END $$
DELIMITER ;

/*11.	Find good playmaker by teams
Create a stored procedure udp_find_playmaker which accepts the following parameters:
•	min_dribble_points 
•	team_name (with max length 45)
 And extracts data about the players with the given skill stats (more than min_dribble_points), played for given team (team_name) and have more than average speed for all players. Order players by speed descending. Select only the best one.
Show all needed info for this player: full_name, age, salary, dribbling, speed, team name.
CALL udp_find_playmaker (20, ‘Skyble’);
*/

DELIMITER $$
CREATE PROCEDURE udp_find_playmaker (min_dribble_points INT, team_name VARCHAR(45))
BEGIN
SELECT concat_ws(' ', p.first_name, p.last_name) AS full_name, p.age, p.salary, sd.dribbling, sd.speed, t.name AS team_name FROM players AS p
JOIN skills_data AS sd ON p.skills_data_id = sd.id
JOIN teams AS t ON p.team_id = t.id
WHERE sd.dribbling > min_dribble_points AND t.name = team_name AND sd.speed > (SELECT AVG(speed) FROM skills_data)
ORDER BY sd.speed DESC LIMIT 1;
END $$
DELIMITER ;

CALL udp_find_playmaker (20, 'Skyble');