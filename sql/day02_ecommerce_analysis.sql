-- Q1
-- Business Question: Segment orders as small, medium, large
-- Why this metric matters: There might be reasons or patterns related with the small data
-- Insight (1 sentence): scaling is not appropriate for data

select orderNumber, sum(quantityOrdered*priceEach) as totalOrder,
case
	when sum(quantityOrdered*priceEach) < 1000 then 'Small Order'
    when sum(quantityOrdered*priceEach) >= 1000 and sum(quantityOrdered*priceEach) < 5000 then 'Medium Order'
    when sum(quantityOrdered*priceEach) >= 5000 then 'Large Order'
end as orderSegment
from orderdetails
group by orderNumber
order by orderSegment
;


select avg(totalOrders)
from
(select sum(quantityOrdered*priceEach) as totalOrders
from orderdetails
group by orderNumber
) as totalTable
;
-- we can see that average of the total amount of orders is almost 30000$. In this case our scaling is not seems appropriate. Limit for large orders might be grater than 15000$


-- Q2
-- Business Question: Monthly revenue + growth.
-- Why this metric matters: We can see that whether the revenue of the country getting higher or lower and take action to prevent mistakes.
-- Insight (1 sentence): Huge sales happened for every year's 11th month. Most probably this is the result of some marketing strategy such as traditional discounts or something like that.

with monthly_table as (
		select date_format(orderDate, '%Y-%m') as order_ym, sum(quantityOrdered*priceEach) as totalRevenue
        from orders
        join orderdetails
        on orders.orderNumber = orderdetails.orderNumber
        where orders.status = 'Shipped'
        group by order_ym
        )
select order_ym, totalRevenue, lag(totalRevenue) over (order by order_ym) as prev_month_rev, (totalRevenue - lag(totalRevenue) over (order by order_ym)) as monthly_change
from monthly_table
;


-- Q3
-- Business Question: Find the customers who has not payment record
-- Why this metric matters: We can see the percentage of the active customers and marketing team can create strategies to gain inactive customers
-- Insight (1 sentence): Almost 20 percent of the customers have not done any payments. 

select * 
from customers
left join payments
on payments.customerNumber = customers.customerNumber
where amount is null
;

select count(*)
from
(select customers.customerNumber 
from customers
left join payments
on payments.customerNumber = customers.customerNumber
where amount is null
) as inactive
;
-- There are 24 inactive customers

select count(*)
from customers
;
-- total number of customers is 122



-- Q4
-- Business Question: Performance of countries (total revenue, total order, average order revenue)
-- Why this metric matters: Marketing team can develop strategies to reach countries that has lower revenue and logistic team can also plays important roles for the countries that has higher totalRevenue
-- Insight (1 sentence): totalRevenue is directly proportional with the totalOrder and countries in the Far East and Scandinavia have the lowest total revenue while countries in the Europe have the highest totalRevenue which indicates the relations between location and orders.

select country, sum(quantityOrdered*priceEach) as totalRevenue, count(orders.status) as totalOrder, (sum(quantityOrdered*priceEach) / count(orders.status)) as avg_orderRev
from orderdetails
join orders
on orders.orderNumber = orderdetails.orderNumber
join customers
on orders.customerNumber = customers.customerNumber
where orders.status = 'Shipped'
group by country
order by totalRevenue desc
;


select * from customers;
select * from employees;
select * from offices;
select * from orderdetails;
select * from orders;
select * from payments;
select * from productlines;
select * from products;