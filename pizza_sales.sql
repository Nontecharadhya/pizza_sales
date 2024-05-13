use pizza

--Retrive the total number of order places

select count(quantity) as total_order from dbo.order_details;

--calculate the total revenue generated from pizza sales.

select round(sum(order_details.quantity*pizzas.price),2) as Revenue from order_details
join pizzas on pizzas.pizza_id=order_details.pizza_id

--Identify the highest price of pizza

select round(max(price),2) as highest_price from dbo.pizzas;

--Identify the most common size of pizza;

select size,count(size) as fr_size from dbo.pizzas join 
order_details on pizzas.pizza_id =order_details.pizza_id
group by size order by fr_size desc;

--list the top 5 ordered pizza types along with their quantities

select top 5 name,count(quantity) as count from dbo.pizza_types join 
pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id join 
order_details on order_details.pizza_id =pizzas.pizza_id
group by name order by count desc;

--join the necessery table to find the total quantity of each pizza ordered

select name ,count(quantity)as total from dbo.pizza_types join pizzas
on pizzas.pizza_type_id=pizza_types.pizza_type_id join order_details
on order_details.pizza_id=pizzas.pizza_id group by name order by total desc;

--Determination the distribution of orders by hour of the day.

SELECT DATEPART(HOUR, [time]) AS per_hr,
       COUNT(order_id) AS total
FROM dbo.orders
GROUP BY DATEPART(HOUR, [time]) order by total desc;

--category wise distribution of pizza

select category,count(quantity)as total from pizza_types join 
pizzas on pizza_types.pizza_type_id =pizzas.pizza_type_id join
order_details on order_details.pizza_id =pizzas.pizza_id 
group by category order by total desc;

--Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT AVG(quantity) AS avg_order
FROM (
    SELECT orders.date, SUM(order_details.quantity) AS quantity
    FROM dbo.orders
    JOIN order_details ON order_details.order_id = orders.order_id
    GROUP BY orders.date
) AS subquery;

--Determine the top 3 most ordered pizza types based on revenue

select top 3 name,round(sum(order_details.quantity*pizzas.price),2) 
as Revenue from pizza_types join pizzas on
pizzas.pizza_type_id=pizza_types.pizza_type_id join 
order_details on order_details.pizza_id=pizzas.pizza_id
group by name order by Revenue desc;

--Calcualtion of contribution of each pizza types to total revenue.

SELECT pizza_types.category, 
       ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_sales,
       ROUND(SUM(order_details.quantity * pizzas.price) / 
             (SELECT SUM(order_details.quantity * pizzas.price) FROM order_details JOIN pizzas 
			 ON order_details.pizza_id = pizzas.pizza_id) * 100, 2) AS Revenue
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;

--Analyze the cumulative revenue generated over time.

SELECT date, 
       SUM(Revenue) OVER (ORDER BY date) AS cum_revenue 
FROM (
    SELECT orders.date,
           SUM(pizzas.price * order_details.quantity) AS Revenue
    FROM order_details
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY orders.date
) AS sales;

--Determine the top 3 most ordered by types
--based on revenue for each pizza category

select category,name ,revenue from 
(select category,name,revenue,rank() 
over(partition by category order by revenue desc) as rn from
(select pizza_types.category,pizza_types.name,
sum((order_details.quantity)*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id =pizzas.pizza_id 
group by pizza_types.category,pizza_types.name)as a)as b
where rn<=3;
