CREATE DATABASE stc;
USE stc;

/*Data Definition Language (DDL) – 40 pts
Make sure you implement the whole database correctly on your local machine so that you can work with it.
The instructions you will be given will be the minimal required for you to implement the database.

1.	Table Design
*/

CREATE TABLE addresses(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(100) NOT NULL
);

CREATE TABLE categories(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(10) NOT NULL
);

CREATE TABLE clients(
id INT PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR(50) NOT NULL,
phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE drivers(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
age INT NOT NULL,
rating FLOAT DEFAULT 5.5
);

CREATE TABLE cars(
id INT PRIMARY KEY AUTO_INCREMENT,
make VARCHAR(20) NOT NULL,
model VARCHAR(20),
year INT NOT NULL DEFAULT 0,
mileage INT DEFAULT 0,
`condition` CHAR(1) NOT NULL,
category_id INT NOT NULL,
CONSTRAINT fk_cars_categories
FOREIGN KEY (category_id)
REFERENCES categories(id)
);

CREATE TABLE courses(
id INT PRIMARY KEY AUTO_INCREMENT,
from_address_id INT NOT NULL,
`start` DATETIME NOT NULL,
bill DECIMAL(10, 2) DEFAULT 10,
car_id INT NOT NULL,
client_id INT NOT NULL,
CONSTRAINT fk_courses_addresses
FOREIGN KEY (from_address_id)
REFERENCES addresses(id),
CONSTRAINT fk_courses_cars
FOREIGN KEY (car_id)
REFERENCES cars(id),
CONSTRAINT fk_courses_clients
FOREIGN KEY (client_id)
REFERENCES clients(id)
);

CREATE TABLE cars_drivers(
car_id INT NOT NULL,
driver_id INT NOT NULL,
PRIMARY KEY (car_id, driver_id),
CONSTRAINT fk_cars_drivers_drivers
FOREIGN KEY (driver_id)
REFERENCES drivers(id),
CONSTRAINT fk_cars_drivers_cars
FOREIGN KEY (car_id)
REFERENCES cars(id)
);

/*Data Manipulation Language (DML) – 30 pts
Here we need to do several manipulations in the database, like changing data, adding data etc.

2.	Insert
When drivers are not working and need a taxi to transport them, they will also be registered 
at the database as customers.
You will have to insert records of data into the clients table, based on the drivers table. 
For all drivers with an id between 10 and 20 (both inclusive), insert data in the clients table with the following values:
•	full_name – get first and last name of the driver separated by single space
•	phone_number – set it to start with (088) 9999 and the driver_id multiplied by 2
o	 Example – the phone_number of the driver with id = 10 is (088) 999920
*/

INSERT INTO clients(full_name, phone_number)
SELECT concat(first_name, ' ', last_name), concat('(088) 9999', id * 2) FROM drivers
WHERE id BETWEEN 10 AND 20;

/*3.	Update
After many kilometers and over the years, the condition of cars is expected to deteriorate.
Update all cars and set the condition to be 'C'. The cars  must have a mileage greater than 800000 (inclusive) or NULL and must be older than 2010(inclusive).
Skip the cars that contain a make value of Mercedes-Benz. They can work for many more years.
*/

UPDATE cars AS c
SET c.`condition` = 'C'
WHERE NOT make = 'Mercedes-Benz' AND mileage >= 800000 OR mileage IS NULL AND year <= 2010;

/*4.	Delete
Some of the clients have not used the services of our company recently, so we need to remove them 
from the database.	
Delete all clients from clients table, that do not have any courses and the count of the characters in the full_name is more than 3 characters. 
*/

DELETE FROM clients
WHERE id NOT IN (SELECT client_id FROM courses) 
	AND char_length(full_name) > 3;

/*Querying – 50 pts
And now we need to do some data extraction. Note that the example results from this section use a fresh database. It is highly recommended that you clear the database that has been manipulated by the previous problems from the DML section and insert again the dataset you have been given, to ensure maximum consistency with the examples given in this section.

5.	Cars
Extract the info about all the cars. 
Order the results by car’s id.
Required Columns
•	make
•	model
•	condition
*/

SELECT make, model, `condition` FROM cars
ORDER BY id;

/*6.	Drivers and Cars
Now, we need a more detailed information about drivers and their cars.
Select all drivers and cars that they drive. Extract the driver’s first and last name from the drivers table and the make, 
the model and the mileage from the cars table. Order the result by the mileage in descending order, then by the first name alphabetically. 
Skip all cars that have NULL as a value for the mileage.

Required Columns
•	first_name
•	last_name 
•	make
•	model
•	mileage
*/

SELECT(d.first_name, d.last_name, c.make, c.model, c.mileage) FROM drivers AS d
LEFT JOIN cars_drivers AS cd ON cd.driver_id = d.id
LEFT JOIN cars AS c ON c.id = cd.cars_id
WHERE c.mileage IS NOT NULL
ORDER BY c.mileage DESC, first_name;

# 07. Number of courses

/*Extract from the database all the cars and the count of their courses. Also display the average bill of 
each course by the car, rounded to the second digit.
Order the results descending by the count of courses, then by the car’s id. 
Skip the cars with exactly 2 courses.
Required Columns
•	car_id - courses
•	make - cars
•	mileage -cars
•	count_of_courses -
•	avg_bill -
*/

SELECT co.car_id, c.make, c.mileage, COUNT(co.car_id) AS count_of_courses, ROUND(AVG(co.bill), 2) AS avg_bill FROM cars AS c
LEFT JOIN cources AS co ON c.id = co.id
GROUP BY c.id
HAVING count_of_courses != 2
ORDER BY count_of_courses DESC, c.id;

/*8.	Regular clients
Extract the regular clients, who have ridden in more than one car. 
The second letter of the customer's full name must be 'a'. Select the full name,
 the count of cars that he ridden and total sum of all courses.
Order clients by their full_name.

Required Columns
•	full_name
•	count_of_cars
•	total_sum
*/

SELECT cl.full_name, COUNT(c.id) AS count_of_cars, SUM(co.bill) AS total_sum FROM clients AS cl
JOIN courses AS co ON cl.id = co.client_id
JOIN cars AS c ON co.car_id = c.id
GROUP BY cl.id
HAVING full_name LIKE '_a%' AND count_of_cars > 1
ORDER BY cl.full_name;


/*9.	Full information of courses

The headquarters want us to make a query that shows the complete information about all courses in the database. The information that they need is the address, if the course is made in the Day (between 6 and 20(inclusive both)) or in the Night (between 21 and 5(inclusive both)), the bill of the course, the full name of the client, the car maker, the model and the name of the category.
Order the results by course id.


Required Columns
•	name (address)
•	day_time
•	bill
•	full_name (client)
•	make
•	model
•	category_name (category)
*/

SELECT a.name ,
			IF (HOUR(c.start) BETWEEN 6 AND 20, 'Day', 'Night') AS day_time, c.bill, cl.full_name, ca.make, ca.model, cat.name FROM courses AS c
JOIN addresses AS a ON c.from_address_id = a.id
JOIN clients AS cl ON c.client_id = cl.id
JOIN cars AS ca ON c.car_id = ca.id
JOIN categories AS cat ON ca.category_id = cat.id
ORDER BY c.id;

/*Section 4: Programmability – 30 pts
The time has come for you to prove that you can be a little more dynamic on the database. So, you will have to write several procedures.


10.	Find all courses by client’s phone number
Create a user defined function with the name udf_courses_by_client (phone_num VARCHAR (20)) that receives a client’s phone number and returns the number of courses that clients have in database.
*/

DELIMITER $$

CREATE FUNCTION udf_courses_by_client(phone_num VARCHAR(20))
RETURNS INT 
DETERMINISTIC
BEGIN
RETURN	(SELECT count(*) FROM courses AS c
		JOIN clients AS cl ON cl.id = c.client_id
		WHERE cl.phone_number = phone_num);
END$$

DELIMITER ;

SELECT udf_courses_by_client ('(803) 6386812') as `count`; 
SELECT udf_courses_by_client ('(831) 1391236') as `count`;
SELECT udf_courses_by_client ('(704) 2502909') as `count`;

/*11.	Full info for address
Create a stored procedure udp_courses_by_address which accepts the following parameters:
•	address_name (with max length 100)

Extract data about the addresses with the given address_name. The needed data is the name of the address, full name of the client, level of bill (depends of course bill – Low – lower than 20(inclusive), Medium – lower than 30(inclusive), and High), make and condition of the car and the name of the category.
 Order addresses by make, then by client’s full name.
Required Columns
•	name (address)
•	full_name
•	level_of_bill
•	full_name (client)
•	make
•	condition
•	cat_name (category)
*/

DELIMITER $$

CREATE PROCEDURE udp_courses_by_address(address_name VARCHAR(100))
BEGIN
SELECT a.name,cl.full_name,
		(CASE WHEN c.bill <= 20 THEN 'Low'WHEN c.bill <= 30 THEN 'Medium'WHEN c.bill > 30 THEN 'High'END),
        cr.make,cr.`condition`,ct.name 
        FROM courses AS c
JOIN addresses AS a ON c.from_address_id = a.id
JOIN clients AS cl ON cl.id = c.client_id
JOIN cars AS cr ON cr.id = c.car_id
JOIN categories AS ct ON ct.id = cr.category_id
WHERE a.name = address_name
ORDER BY cr.make,cl.full_name;
END$$

DELIMITER ;

CALL udp_courses_by_address('700 Monterey Avenue');
CALL udp_courses_by_address('66 Thompson Drive');