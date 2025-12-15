-- Q1
-- Business Question: What is the total daily revenue
-- Why this metric matters: We can find some relations between the days with high revenue and investigate why company has lower revenue
-- Insight (1 sentence): In the first look we can see that some days revenue is under the 10000$ which is not normal according to overall situation

select orderDate, sum(quantityOrdered*priceEach) as Rev_PerDay
from orderdetails as order_d
join orders 
on orders.orderNumber = order_d.orderNumber
group by orderDate
;

-- You can see the daily revenue per each day in the table below


-- Q2
-- Business Question: En çok gelir getiren ilk 5 ürün hangileri? (For all time, according to total revenue)
-- Why this metric matters: Company can take actions for products that have low revenue
-- Insight (1 sentence): As you can see below the reason why some products has lower total revenue is their price is the 1/3 of the average price. 

select products.productCode, productName, sum(priceEach) as TotalRevenue
from orderdetails 
join products
on orderdetails.productCode = products.productCode
group by orderdetails.productCode
order by TotalRevenue
;

-- Now we can see which products has the lowest revenue: S24_1937, S24_2840, S24_3969, S24_2971, S32_2206, S50_1341 . Investigate why? 

select avg(priceEach)
from orders
join orderdetails
on orders.orderNumber = orderdetails.orderNumber
where productCode = 'S24_1937' or productCode = 'S24_2840'  or productCode = 'S24_3969' or productCode = 'S24_2971' or productCode = 'S32_2206' or productCode = 'S50_1341'
;

select avg(priceEach) from orderdetails;

-- The avg for price is the 90$. However average price of the products that has lower total revenue is the 35. That the reason why their total revenue is lower than the others


-- Q3
-- Business Question: What is the average revenue per order
-- Why this metric matters: Company can build a recommendation system so that they can sell more product per order
-- Insight (1 sentence): ALthouhg the quantity of products are normal, their prices are very half of the average price.

select orderNumber, sum(quantityOrdered * priceEach) as Rev_PerOrder
from orderdetails
group by orderNumber
order by Rev_PerOrder
;
-- Now we can see the revenue per order. Now investigate the reasons. Let's check what those orders are contains
-- first 8 order numbers are : 10408, 10144, 10158, 10116, 10345, 10242, 10364, 10286, 

select *
from orderdetails
join products
on products.productCode = orderdetails.productCode
where orderNumber = 10408 or orderNumber = 10144 or orderNumber = 10158 or orderNumber = 10116 or orderNumber = 10345 or orderNumber = 10242 or orderNumber = 10364 or orderNumber = 10286
;

-- Now compare the quantityOrdered and priceEach columns with the overall table.

select avg(quantityOrdered), avg(priceEach)
from orderdetails
join products
on products.productCode = orderdetails.productCode
where orderNumber = 10408 or orderNumber = 10144 or orderNumber = 10158 or orderNumber = 10116 or orderNumber = 10345 or orderNumber = 10242 or orderNumber = 10364 or orderNumber = 10286
;

-- average quantityOrdered is 32 and average price is 49$

select avg(priceEach)
from orderdetails;

-- average price is 90$

select avg(quantityOrdered)
from orderdetails;

-- average quantityOrdered is 35
-- quantityOrdered is very close but the average price for the products are nearly half of the overall average.


-- Q4
-- Business Question: According to total expenditure find the top 5 customer
-- Why this metric matters: We can find loyal customers and investigate why they are loyal. According to results company increase the loyalty of other customers
-- Insight (1 sentence): If credit limit of the customer is higher then the money they spend is also higher.

select customers.customerName, sum(quantityOrdered * priceEach) as total_exp
from customers
join orders
on customers.customerNumber = orders.customerNumber
join orderdetails
on orders.orderNumber = orderdetails.orderNumber
group by customerName
order by total_exp desc
limit 5
;

-- we can see the top 5 customer. Now let's investigate them.
select * 
from customers
where customerName = 'Euro+ Shopping Channel' or customerName = 'Mini Gifts Distributors Ltd.' or customerName = 'Australian Collectors, Co.' or customerName = 'Muscle Machine Inc' or customerName = 'La Rochelle Gifts'
;

-- there could be relations with the creditLimit

select customerName, creditLimit
from customers
order by creditLimit desc
;
-- We can see that those 5 customers are inside the top 15 according to highest credit limit. First 2 customers are also first two with the highest credit limit


-- Q5
-- Business Question: Which productLine is more profitable
-- Why this metric matters: It is highly beneficial for optimizing the profit of the company
-- Insight (1 sentence): We can see that customers are highly interested with the land vehicles

-- First we will find the total revenue for each product. Then we will calculate the profit according to buyPrice

select productLine, sum(priceEach*quantityOrdered) as TotalRev, sum(quantityOrdered) as TotalOrder, avg(buyPrice) as AvgCost, sum(priceEach*quantityOrdered)-sum(quantityOrdered)*avg(buyPrice) as TotalProfit
from orderdetails 
join products
on orderdetails.productCode = products.productCode
group by productLine
order by TotalProfit desc
;

