create  database `restaurants`;
USE `restaurants`;

 #Section 1: Data Definition Language (DDL) – 40 pts
 #01. Table Design

create table `products`(
id int(11) primary key auto_increment,
name varchar(30) not null UNIQUE,
type varchar(30) not null,
price decimal(10, 2) not null
);

create table clients(
id int(11) primary key auto_increment,
first_name varchar (50) not null,
last_name varchar(50) not null,
birthdate date not null,
card varchar(50),
review text
);

create table `tables`(
id int(11) primary key auto_increment,
floor int not null,
reserved tinyint(1),
capacity int not null
);

create table waiters(
id int(11) primary key auto_increment,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(50) not null,
phone varchar(50),
salary decimal(10, 2)
);

create table orders(
id int(11) primary key auto_increment,
table_id int not null,
waiter_id int not null,
order_time time not null,
payed_status tinyint(1),
constraint fk_orders_tables
foreign key(table_id) references `tables`(id),
constraint fk_orders_waiters
foreign key(waiter_id) references waiters(id)

);

create table orders_clients(
order_id  int(11),
client_id int(11),
constraint fk_orders_clients_orders
foreign key (order_id) references orders(id),
constraint fk_orders_clients_clients
foreign key(client_id) references clients(id)
);

create table orders_products(
order_id int(11),
product_id int(11),
constraint fk_orders_products_orders
foreign key (order_id) references orders(id),
constraint fk_orders_products_products
foreign key (product_id) references products(id)
);


#Section 2: Data Manipulation Language (DML) – 30 pts

#02. Insert
INSERT INTO products (name, type, price)
SELECT CONCAT(w.last_name, ' ', 'specialty'),
	"Cocktail" AS type,
    CEIL(w.salary * 0.01) AS price
FROM waiters AS w
WHERE w.id > 6;

#03. Update

select * from `orders`where id > 11 and id < 24;
select * from `orders` where id between 12 and 23;

update orders 
set table_id = table_id - 1
where id between 12 and 23;

#04. Delete

DELETE FROM waiters 
WHERE id NOT IN (SELECT DISTINCT(waiter_id) FROM orders);

#Section 3: Querying – 50 pts
#05. Clients

select
id,
first_name,
last_name,
birthdate,
card,
review
from clients
order by birthdate desc, id desc;

#06. Birthdate

select
first_name,
last_name,
birthdate,
review
from clients
where card is null and birthdate between `1978-01-01` and `1993-12-31`
order by last_name desc, id desc
limit 5;

SELECT c.first_name, c.last_name, c.birthdate, c.review FROM clients as c
WHERE c.birthdate BETWEEN '1978-01-01' AND '1993-01-01' AND c.card IS NULL
ORDER BY c.last_name DESC, c.id ASC
LIMIT 5

#07. Accounts

SELECT
 CONCAT(last_name, first_name, char_length(first_name), 'Restaurant') AS `username`,
		reverse(substr(email, 2, 12)) AS `password` FROM waiters
WHERE salary > 0
ORDER BY password DESC;

#08. Top from menu


#09. Availability

select id, name, count(op.order_id) as `count`
from products as p
join orders_products as op on op.product_id = p.id
group by p.id
having `count` >= 5
order by `count` desc, name asc;

SELECT t.id AS 'table_id', t.capacity, COUNT(oc.client_id) AS 'count_clients',
	(CASE WHEN count(oc.client_id) > t.capacity THEN 'Extra seats'
		  WHEN count(oc.client_id) < t.capacity THEN 'Free seats'
          WHEN count(oc.client_id) = t.capacity THEN 'Full'
          END) AS 'availability' FROM tables AS t
JOIN orders AS o ON t.id = o.table_id
JOIN orders_clients AS oc ON oc.order_id = o.id
WHERE t.floor = 1
GROUP BY o.table_id
ORDER BY t.id DESC;

#10. Extract bill

DELIMITER $$
CREATE FUNCTION udf_client_bill(full_name VARCHAR(50))
RETURNS DECIMAL(19, 2)
DETERMINISTIC
BEGIN
	DECLARE bill DECIMAL(19, 2);
	SET bill := (SELECT SUM(p.price) FROM clients AS c
    JOIN orders_clients AS oc ON c.id = oc.client_id
    JOIN orders AS o ON oc.order_id = o.id
    JOIN orders_products AS op ON o.id = op.order_id
    JOIN products AS p ON op.product_id = p.id
    WHERE CONCAT(c.first_name, ' ', last_name) = full_name);
    RETURN bill;
END$$

#11. Happy hour

DELIMITER $$
CREATE PROCEDURE udp_happy_hour (type VARCHAR(50))
BEGIN
	START TRANSACTION;
		UPDATE products AS p1 SET p1.price = p1.price * 0.8
		WHERE p1.type = type AND p1.price >= 10;
        COMMIT;
END$$






