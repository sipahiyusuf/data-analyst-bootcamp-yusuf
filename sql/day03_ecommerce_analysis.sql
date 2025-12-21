select * from customers;
select * from employees;
select * from offices;
select * from orderdetails;
select * from orders;
select * from payments;
select * from productlines;
select * from products;


-- Q1
-- Business Question: Find the top 3 orders for each product category
-- Why this metric matters: It helps to company follow stocks and 
-- Insight (1 sentence):
select * 
from
(
select productLine, productName ,row_number() over (partition by productLine order by (priceEach*quantityOrdered)) as topOrders
from orderdetails
join products
on products.productCode = orderdetails.productCode
) as topOrderTable
where topOrders <= 3
;




-- Q2
-- Business Question: 
-- Why this metric matters: 
-- Insight (1 sentence):

select customerName, count(orderNumber) totalOrder
from orders 
join customers
on orders.customerNumber = customers.customerNumber
group by customerName
order by count(orderNumber) desc
;


-- Q3
-- Business Question: aylık kümülatif revenue
-- Why this metric matters: 
-- Insight (1 sentence):



select months, sum(monthlyTotal) over (order by months) as monthlyCumulative
from
(
select distinct date_format(orderDate, '%Y-%m') as months, sum(quantityOrdered*priceEach) over (partition by date_format(orderDate, '%Y-%m')) as monthlyTotal 
from orders
join orderdetails
on orders.orderNumber = orderdetails.orderNumber
where orders.status = 'Shipped'
) as monthlyRevenue
;


-- Q4
-- Business Question: order customers according to their first order date
-- Why this metric matters: 
-- Insight (1 sentence):


select customerName, orderDate, orderNumber
from(
select orders.customerNumber, customerName, orderDate, row_number() over (partition by customerNumber order by orderDate) as orderNumber
from orders
join customers
on orders.customerNumber = customers.customerNumber
order by orderDate
) as ordersTable
where orderNumber = 1
;



