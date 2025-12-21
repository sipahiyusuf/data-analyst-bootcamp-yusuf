
select * from customers;
select * from employees;
select * from offices;
select * from orderdetails;
select * from orders;
select * from payments;
select * from productlines;
select * from products;

-- Q1
-- Business Question: Revenue Concentration Analysis
-- Why this metric matters: It helps to control dependencies to the customers
-- Insight (1 sentence): 41% of the revenue comes from the 20 customers and rest of the revenue is coming from 78 customers which might be cause to problem in case 
-- of losing couple of the first 20 customers.

with customer_revenue as
(
select c.customerName,
	   sum(quantityOrdered*priceEach) as totalRev
from orderdetails as od
join orders as o
on od.orderNumber = o.orderNumber
join customers as c
on o.customerNumber = c.customerNumber
where status = 'Shipped'
group by c.customerName
),
perc_analysis as
(
select dense_rank() over (order by totalRev desc) as rank_no,
	   customerName,
       totalRev,
       totalRev/sum(totalRev) over() as percentage
from customer_revenue
order by percentage desc
)
select sum(percentage)
from perc_analysis
where rank_no <= 20
;



-- Q2
-- Business Question: Check the orders of the last 6 months and detect the lower order number customers
-- Why this metric matters: It could be very beneficial for churn analysis
-- Insight (1 sentence): Most of the customers have ordered less than 3 times for the last 6 month which indicates that most of the orders 
-- comes from small group of customers. 

with orderNumbers as
(
select customerName, date_format(orderDate, '%Y-%m') as orderDate, count(customerName) over (partition by customerName) as orderCount
from orders
join customers
on orders.customerNumber = customers.customerNumber
where status = 'Shipped'
and orderDate >= '2004-12-01'
order by customerName
)
select customerName, max(orderDate) as orderDate, orderCount
from orderNumbers
group by customerName, orderCount
order by orderCount desc
;




-- Q3
-- Business Question: Find total revenue, number of products and revenue per product for each productline.
-- Why this metric matters: We can find which productline has more demand and its revenue.
-- Insight (1 sentence): Classic Cars are the most demanded productline with the highest RPO while vintage cars are the 2nd demanded productline with the lower RPO.

with total as 
(
select productLine, sum(quantityOrdered) as totalOrder ,sum(quantityOrdered*priceEach) as totalRev
from orderdetails
join products
on products.productCode = orderdetails.productCode
group by productLine
)
select productLine, totalOrder, totalRev/totalOrder as RPO
from total
order by RPO desc
;



-- Q4
-- Business Question: Find revenue volality, avg monthly revenue, standart deviaton and max min values
-- Why this metric matters: Very critical to check whether company has a regular cash flow or not
-- Insight (1 sentence): According to the 75% coefficient of variation company cash flow is highly irregular and needs immediate actions


with rev_permonth as
(
select date_format(paymentDate, '%Y-%m') as orderMonth, sum(amount) as totalRevenue
from payments
group by orderMonth
)
select avg(totalRevenue), stddev(totalRevenue), max(totalRevenue), min(totalRevenue), stddev(totalRevenue)/avg(totalRevenue) as CV
from rev_permonth
;



