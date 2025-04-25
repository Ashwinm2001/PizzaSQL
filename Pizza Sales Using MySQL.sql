-- Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza

SELECT 
    pt.name, 
    p.pizza_id, 
    p.size, 
    p.price
FROM pizzas p
JOIN pizza_types pt 
    ON pt.pizza_type_id = SUBSTRING_INDEX(p.pizza_id, '_', 2)  -- Adjust if needed
ORDER BY p.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT 
    p.size, 
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name AS pizza_name,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON pt.pizza_type_id = SUBSTRING_INDEX(p.pizza_id, '_', 1)
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON pt.pizza_type_id = SUBSTRING_INDEX(p.pizza_id, '_', 1)
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_date) AS order_hour,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_hour
ORDER BY order_hour;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    pt.category,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON pt.pizza_type_id = SUBSTRING_INDEX(p.pizza_id, '_', 1)
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

DESCRIBE orders;

SELECT 
    DATE(o.order_date) AS order_date,
    SUM(od.quantity) AS total_pizzas
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY DATE(o.order_date)
ORDER BY order_date;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name AS pizza_name,
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON pt.pizza_type_id = SUBSTRING_INDEX(p.pizza_id, '_', 1)
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.


SELECT 
    pt.name AS pizza_name,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue,
    ROUND(SUM(od.quantity * p.price) / (
        SELECT SUM(od2.quantity * p2.price)
        FROM order_details od2
        JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id
    ) * 100, 2) AS revenue_percentage
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = SUBSTRING_INDEX(p.pizza_id, '_', 1)
GROUP BY pt.name
ORDER BY revenue_percentage DESC;


-- Analyze the cumulative revenue generated over time.

SELECT 
    order_date,
    daily_revenue,
    ROUND(SUM(daily_revenue) OVER (ORDER BY order_date), 2) AS cumulative_revenue
FROM (
    SELECT 
        DATE(o.order_date) AS order_date,
        ROUND(SUM(od.quantity * p.price), 2) AS daily_revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY DATE(o.order_date)
) AS daily_data
ORDER BY order_date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


SELECT 
    category,
    pizza_name,
    revenue
FROM (
    SELECT 
        pt.category,
        pt.name AS pizza_name,
        ROUND(SUM(od.quantity * p.price), 2) AS revenue,
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS revenue_rank
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON pt.pizza_type_id = SUBSTRING_INDEX(p.pizza_id, '_', 1)
    GROUP BY pt.category, pt.name
) ranked_pizzas
WHERE revenue_rank <= 3
ORDER BY category, revenue DESC;




