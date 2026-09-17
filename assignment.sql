CREATE TABLE customers (
  customer_id NUMBER PRIMARY KEY,
  customer_name VARCHAR2(100),
  email VARCHAR2(100),
  city VARCHAR2(50)
);

CREATE TABLE products (
  product_id NUMBER PRIMARY KEY,
  product_name VARCHAR2(100),
  category VARCHAR2(50),
  price NUMBER(10,2)
);

CREATE TABLE orders (
  order_id NUMBER PRIMARY KEY,
  customer_id NUMBER REFERENCES customers(customer_id),
  order_date DATE
);

CREATE TABLE order_items (
  order_item_id NUMBER PRIMARY KEY,
  order_id NUMBER REFERENCES orders(order_id),
  product_id NUMBER REFERENCES products(product_id),
  quantity NUMBER
);
--insert 5 customers
insert into customers values (1,'Simbi Gretta', 'simbig2@gmail.com', 'Bugesera');
insert into customers values (2,'Kankindi Nancy', 'nancy303@gmail.com', 'Huye');
insert into customers values (3,'Cecile Bwiza', 'Bwiza22@gmail.com', 'Bugesera');
insert into customers values (4,'Mutoni Jean', 'Jeanmu@gmail.com', 'Kigali');
insert into customers values (5,'Masimbi Diane', 'madiane32@gmail.com', 'Musanze');
--8 products
INSERT INTO products VALUES (1, 'Milk', 'Dairy', 12.50);
INSERT INTO products VALUES (2, 'Cheese', 'Dairy', 24.00);
INSERT INTO products VALUES (3, 'Yogurt', 'Dairy', 31.20);
INSERT INTO products VALUES (4, 'Biscuits', 'Snacks', 42.50);
INSERT INTO products VALUES (5, 'Chocolate', 'Snacks', 51.80);
INSERT INTO products VALUES (6, 'Virunga', 'Drinks', 16.00);
INSERT INTO products VALUES (7, 'Orange Juice', 'Drinks', 26.20);
INSERT INTO products VALUES (8, 'Water', 'Drinks', 10.80);
--15 orders
INSERT INTO orders VALUES (1, 1, DATE '2026-03-05');
INSERT INTO orders VALUES (2, 2, DATE '2026-04-06');
INSERT INTO orders VALUES (3, 1, DATE '2026-05-15');
INSERT INTO orders VALUES (4, 3, DATE '2026-06-20');
INSERT INTO orders VALUES (5, 4, DATE '2026-07-22');
INSERT INTO orders VALUES (6, 2, DATE '2026-08-01');
INSERT INTO orders VALUES (7, 5, DATE '2026-02-03');
INSERT INTO orders VALUES (8, 1, DATE '2026-05-10');
INSERT INTO orders VALUES (9, 3, DATE '2026-07-15');
INSERT INTO orders VALUES (10, 4, DATE '2026-09-02');
INSERT INTO orders VALUES (11, 2, DATE '2026-01-01');
INSERT INTO orders VALUES (12, 5, DATE '2026-02-05');
INSERT INTO orders VALUES (13, 1, DATE '2026-04-10');
INSERT INTO orders VALUES (14, 5, DATE '2026-08-12');
INSERT INTO orders VALUES (15, 3, DATE '2026-03-20');
--25 order items
INSERT INTO order_items VALUES (1, 1, 1, 2);
INSERT INTO order_items VALUES (2, 1, 6, 3);
INSERT INTO order_items VALUES (3, 2, 2, 1);
INSERT INTO order_items VALUES (4, 2, 7, 2);
INSERT INTO order_items VALUES (5, 3, 3, 4);
INSERT INTO order_items VALUES (6, 3, 5, 1);
INSERT INTO order_items VALUES (7, 4, 4, 2);
INSERT INTO order_items VALUES (8, 5, 1, 1);
INSERT INTO order_items VALUES (9, 5, 8, 5);
INSERT INTO order_items VALUES (10, 6, 6, 2);
INSERT INTO order_items VALUES (11, 6, 2, 1);
INSERT INTO order_items VALUES (12, 7, 7, 3);
INSERT INTO order_items VALUES (13, 8, 5, 2);
INSERT INTO order_items VALUES (14, 8, 3, 1);
INSERT INTO order_items VALUES (15, 9, 4, 1);
INSERT INTO order_items VALUES (16, 9, 1, 3);
INSERT INTO order_items VALUES (17, 10, 8, 2);
INSERT INTO order_items VALUES (18, 11, 2, 2);
INSERT INTO order_items VALUES (19, 11, 6, 1);
INSERT INTO order_items VALUES (20, 12, 7, 1);
INSERT INTO order_items VALUES (21, 12, 3, 2);
INSERT INTO order_items VALUES (22, 13, 5, 3);
INSERT INTO order_items VALUES (23, 14, 1, 2);
INSERT INTO order_items VALUES (24, 14, 4, 1);
INSERT INTO order_items VALUES (25, 15, 8, 4);
--join tables
select o.order_id, c.customer_name, c.city, o.order_date from orders o inner join customer c on o.customer_id = c.customer_id;

SELECT oi.order_item_id, p.product_name, p.category, p.price, oi.quantity FROM order_items oi JOIN products p ON oi.product_id = p.product_id;

SELECT c.customer_id, c.customer_name, c.city, o.order_id, o.order_date FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id;

--calculating the customer's total spend
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name, SUM(oi.quantity * p.price) AS total_spend
    FROM customers c JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
)

SELECT customer_id, customer_name,total_spend FROM customer_totals
WHERE total_spend > (SELECT AVG(total_spend) FROM customer_totals
);

--ranking customers
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name, SUM(oi.quantity * p.price) AS total_spend
    FROM customers c JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_spend,
       RANK() OVER (ORDER BY total_spend DESC) AS spend_rank
FROM customer_totals ORDER BY spend_rank;

--numbering each customer's order
SELECT customer_id, order_id, order_date,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_sequence
FROM orders ORDER BY customer_id, order_sequence;

--running total of revenue
WITH order_revenue AS (SELECT o.order_id, o.order_date, SUM(oi.quantity * p.price) AS order_total
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY o.order_id, o.order_date
)

SELECT order_id, order_date, order_total, SUM(order_total) OVER (ORDER BY order_date, order_id) AS running_total
FROM order_revenue ORDER BY order_date, order_id;

--Days btwn current and previous order
SELECT customer_id, order_id, order_date, order_date - LAG(order_date) 
    OVER ( PARTITION BY customer_id ORDER BY order_date) AS days_between_orders FROM orders;
    