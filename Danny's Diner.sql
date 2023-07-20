CREATE schema Danny
USE Danny;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);


INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),

  ('B', '2021-01-09');
  
  
  SELECT * FROM members;
  SELECT * from menu;
  SELECT * FROM sales;
  
-- 1. What is the total amount each customer spent at the resturent?
  
   SELECT s.customer_id, SUM(m.price) as Total_Sale FROM 
   sales s JOIN menu m ON
   s.product_id = m.product_id
   GROUP BY s.customer_id
   
   
-- 2. How many days has each customer visited the restaurant?
  
SELECT customer_id, COUNT(DISTINCT(order_date)) AS NO_OF_Visits FROM sales
GROUP BY customer_id


-- 3. What was the first item from the menu purshes by each customer?

SELECT s.customer_id, MIN(m.product_name) AS first_item_purchased
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

SELECT s.customer_id, s.order_date, MIN(m.product_name) AS first_item_purchased
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, s.order_date;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name, COUNT(s.product_id) AS purchase_count FROM menu m
JOIN sales s ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY purchase_count DESC
LIMIT 1;


-- 5. Which item was the most popular for each customer?

SELECT customer_id, product_name AS most_popular_item
FROM (
  SELECT s.customer_id, s.product_id, m.product_name,
         ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) as rn
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
  GROUP BY s.customer_id, s.product_id, m.product_name
) ranked
WHERE rn = 1;

-- 6. Which item was purchased first by the customer after they became a member?

SELECT m.customer_id, m.join_date, MIN(s.order_date) AS first_purchase_date, menu.product_name AS first_item_purchased
FROM members m
LEFT JOIN sales s ON m.customer_id = s.customer_id
JOIN menu ON s.product_id = menu.product_id
WHERE s.order_date >= m.join_date
GROUP BY m.customer_id, m.join_date;

-- 7. Which item was purchased just before the customer became a member?

SELECT m.customer_id, m.join_date, MAX(s.order_date) AS last_purchase_date, menu.product_name AS last_item_purchased
FROM members m
LEFT JOIN sales s ON m.customer_id = s.customer_id
JOIN menu ON s.product_id = menu.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id, m.join_date;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT m.customer_id, m.join_date,
       COUNT(s.product_id) AS total_items_purchased,
       SUM(menu.price) AS total_amount_spent
FROM members m
LEFT JOIN sales s ON m.customer_id = s.customer_id
JOIN menu ON s.product_id = menu.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id, m.join_date;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have?


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

SELECT customer_id, SUM(points) AS points_total
FROM (
  SELECT s.customer_id,
         CASE
           WHEN s.order_date >= m.join_date AND s.order_date < DATE_ADD(m.join_date, INTERVAL 7 DAY) THEN menu.price * 10 * 2
           WHEN menu.product_name = 'sushi' THEN menu.price * 10 * 2
           ELSE menu.price * 10
         END AS points
  FROM sales s
  JOIN menu ON s.product_id = menu.product_id
  JOIN members m ON s.customer_id = m.customer_id
  WHERE EXTRACT(YEAR FROM s.order_date) = 2021 AND EXTRACT(MONTH FROM s.order_date) = 1
) points_calc
GROUP BY customer_id;




-- BONUS 1:
-- Recreate the table with — customer_id, order_date, product_name, price, member (Y/N) so that Danny would not need to join the underlying tables using SQL.

CREATE VIEW order_member_status AS
SELECT s.customer_id, s.order_date, m.product_name, m.price,
  (
    CASE
      WHEN m.join_date <= s.order_date THEN 'Y'
      ELSE 'N'
    END
  ) AS MEMBER
FROM sales s
JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mem ON s.customer_id = mem.customer_id;

SELECT * FROM order_member_status;












