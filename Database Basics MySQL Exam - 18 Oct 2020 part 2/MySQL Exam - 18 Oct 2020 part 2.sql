CREATE DATABASE SoftUniStoresSystem;
USE SoftUniStoresSystem;

/*Data Definition Language (DDL) – 40 pts
Make sure you implement the whole database correctly on your local machine, so that you could work with it.
The instructions you’ll be given will be the minimal required for you to implement the database.

1.	Table Design
You have been tasked to create the tables in the database by the following models:
*/

CREATE TABLE pictures(
id INT PRIMARY KEY AUTO_INCREMENT,
url VARCHAR(100) NOT NULL,
added_on DATETIME NOT NULL
);

CREATE TABLE categories(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE products(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL UNIQUE,
best_before DATE,
price DECIMAL(10, 2) NOT NULL,
description TEXT,
category_id INT NOT NULL,
picture_id INT NOT NULL,
CONSTRAINT fk_products_categories
FOREIGN KEY (category_id)
REFERENCES categories(id),
CONSTRAINT fk_products_pictures
FOREIGN KEY (picture_id)
REFERENCES pictures(id)
);

CREATE TABLE towns(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE addresses(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL UNIQUE,
town_id INT NOT NULL,
CONSTRAINT fk_addresses_towns
FOREIGN KEY (town_id)
REFERENCES towns(id)
);

CREATE TABLE stores(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(20) NOT NULL UNIQUE,
rating FLOAT NOT NULL,
has_parking TINYINT(1) DEFAULT FALSE,
address_id INT NOT NULL,
CONSTRAINT fk_stores_addresses
FOREIGN KEY (address_id)
REFERENCES addresses(id)
);


CREATE TABLE employees(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(15) NOT NULL,
middle_name CHAR,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(19, 2) DEFAULT 0,
hire_date DATE NOT NULL,
manager_id INT,
store_id INT NOT NULL,
CONSTRAINT fk_employee_store
FOREIGN KEY (store_id)
REFERENCES stores(id),
CONSTRAINT sf_fk_employee_manager
FOREIGN KEY (manager_id)
REFERENCES employees(id)
);

CREATE TABLE products_stores(
product_id INT NOT NULL,
store_id INT NOT NULL,
PRIMARY KEY (product_id, store_id),
CONSTRAINT fk_product_store_product 
FOREIGN KEY (product_id)
REFERENCES products(id),
CONSTRAINT fk_product_store_store  
FOREIGN KEY (store_id)
REFERENCES stores(id)
);

/*Data Manipulation Language (DML) – 30 pts
Here we need to do several manipulations in the database, like changing data, adding data etc.

2.	Insert
You will have to insert records of data into the products_stores table, based on the products table. 
Find all products that are not offered in any stores (don’t have a relation with stores) and insert data in the 
products_stores. For every product saved -> product_id and 1(one) as a store_id. And now this product will be offered in store with name Wrapsafe and id 1.
•	product_id – id of product
•	store_id – set it to be 1 for all products.
*/

INSERT INTO products_stores (product_id, store_id) 
(SELECT p.id, 1 FROM products AS p
		WHERE p.id NOT IN 
        (SELECT product_id FROM products_stores));


/*3.	Update
Update all employees that hire after 2003(exclusive) year and not work in store Cardguard and Veribet. 
Set their manager to be Carolyn Q Dyett (with id 3) and decrease salary with 500.
*/

UPDATE employees AS e
SET e.salary = e.salary - 500, e.manager_id = 3
WHERE year(e.hire_date) >= 2003
AND e.store_id NOT IN (SELECT s.id FROM stores AS s
						WHERE s.name = 'Cardguard' OR s.name = 'Veribet');

/*4.	Delete
It is time for the stores to start working. All good employees already are in their stores. 
But some of the employers are too expensive and we need to cut them, because of finances restrictions.
Be careful not to delete managers they are also employees.
Delete only those employees that have managers and a salary is more than 6000(inclusive)
*/

DELETE FROM employees
WHERE salary >= 6000 AND manager_id IS NOT NULL;

/*Querying – 50 pts
And now we need to do some data extraction. Note that the example results from this section use a fresh database. It is highly recommended that you clear the database that has been manipulated by the previous problems from the DML section and insert again the dataset you’ve been given, to ensure maximum consistency with the examples given in this section.

5.	Employees 
Extract from the SoftUni Stores System database, info about all of the employees. 
Order the results by employees hire date in descending order.
Required Columns
•	first_name
•	middle_name
•	last_name
•	salary
•	hire_date
*/

SELECT first_name, middle_name, last_name, salary, hire_date FROM employees
ORDER BY hire_date DESC;

/*6.	Products with old pictures
A photographer wants to take pictures of products that have old pictures. You must select all of the products that have a description more than 100 characters long description, and a picture that is made before 2019 (exclusive) and the product price being more than 20. Select a short description column that consists of first 10 characters of the picture's description plus '…'. Order the results by product price in descending order.

Required Columns
•	name (product)
•	price 
•	best_before
•	short_description  
o	only first 10 characters of product description + '...'
•	url 
*/

SELECT p.name AS 'product_name', p.price, p.best_before, CONCAT(left(p.description, 10), "...") AS short_description, pi.url FROM products AS p
JOIN pictures AS pi ON p.picture_id = pi.id
WHERE year(pi.added_on) < 2019 AND length(p.description) > 100 AND p.price > 20
ORDER BY p.price DESC;

/*7.	Counts of products in stores and their average 
The managers needs to know in which stores sell different products and their average price.
Extract from the database all of the stores (with or without products) and the count of the products that they have. Also you can show the average price of all products (rounded to the second digit after decimal point) that sells in store.
Order the results descending by count of products in store, then by average price in descending order and finally by store id. 
Required Columns
•	Name (store)
•	product_count
•	avg
*/

SELECT s.name, COUNT(p.id) AS product_count, round(avg(p.price), 2) AS avg FROM  stores AS s
LEFT JOIN products_stores AS ps ON s.id = ps.store_id
LEFT JOIN products AS p ON ps.product_id = p.id
GROUP BY s.id
ORDER BY product_count desc, avg DESC, s.id;

/*8.	Specific employee

There are many employees in our shop system, but we need to find only the one that passes some specific criteria. 
Extract from the database, the full name of employee, name of store that he works, address of store, and salary. The employee's salary must be lower than 4000, the address of the store must contain '5' somewhere, the length of the store name needs to be more than 8 characters and the employee’s last name must end with an 'n'.
Required Columns
•	Full name (employee)
•	Store name 
•	Address
•	Salary
*/

SELECT concat_ws(" ", e.first_name, e.last_name) AS Full_name, s.name AS Store_name, a.name AS address, e.salary FROM employees AS e
JOIN stores AS s ON e.store_id = s.id
JOIN addresses AS a ON s.address_id = a.id
WHERE e.salary < 4000 AND a.name LIKE '%5%' 
	AND char_length(s.name) > 8 AND e.last_name LIKE '%n';

/*9.	Find all information of stores
The managers always want to know how the business goes. 
Now, they want from us to show all store names, but for security, the name must be in the reversed order.
Select the name of stores (in reverse order). 
After that, the full_address in format: {town name in upper case}-{address name}.
The next info is the count of employees, that work in the store.
Filter only the stores that have a one or more employees.
Order the results by the full_address in ascending order.

Required Columns
•	reversed_name (store name) 
•	full_address (full_address)
•	employees_count
*/

SELECT reverse(s.name) AS reversed_name,
		CONCAT(UPPER(t.name), '-', a.name) AS full_address,
		(SELECT COUNT(e.id) FROM employees as e 
        WHERE e.store_id = s.id) AS employees_count FROM stores AS s
JOIN addresses AS a ON s.address_id = a.id
JOIN towns AS t ON t.id = a.town_id
WHERE (SELECT COUNT(e.id) FROM employees as e 
        WHERE e.store_id = s.id) > 0
ORDER BY full_address;

/*10.	Find full name of top paid employee by store name
Create a user defined function with the name udf_top_paid_employee_by_store(store_name VARCHAR(50)) that receives a store name and returns the full name of top paid employee. 
Full info must be in format:
 	{first_name} {middle_name}. {last_name} works in store for {years of experience} years
The years of experience is the difference when they were hired and 2020-10-18
*/
DELIMITER $$
CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
RETURNS VARCHAR(255)
BEGIN
RETURN (SELECT concat(e.first_name, " ", e.middle_name, ". ", e.last_name, " works in store for ", 2020 - YEAR(e.hire_date), " years") 
					AS full_info FROM employees AS e
JOIN stores AS s ON e.store_id = s.id
WHERE s.name = store_name
ORDER BY e.salary DESC
LIMIT 1);
END $$

DELIMITER ;

SET GLOBAL log_bin_trust_function_creators = 1;

SELECT udf_top_paid_employee_by_store('Stronghold') as 'full_info';
SELECT udf_top_paid_employee_by_store('Keylex') as 'full_info';

/*11.	Update product price by address
CREATE user define procedure udp_update_product_price (address_name VARCHAR (50)), that receives as parameter an address name.
Increase the product's price with 100 if the address starts with 0 (zero) otherwise increase the price with 200.
*/

DELIMITER $$
CREATE PROCEDURE udp_update_product_price (address_name VARCHAR (50))
BEGIN
	DECLARE increase_level INT;
    IF address_name LIKE '0%' THEN SET increase_level = 100;
    ELSE SET increase_level = 200;
    END IF;
UPDATE products AS p SET price = price + increase_level
WHERE p.id IN (SELECT ps.product_id FROM addresses AS a
				JOIN stores AS s ON a.id = s.address_id
                JOIN products_stores AS ps ON ps.store_id = s.id
                WHERE a.name = address_name);
END$$

DELIMITER ;

CALL udp_update_product_price('07 Armistice Parkway');
CALL udp_update_product_price('1 Cody Pass');