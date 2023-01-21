-- 1. discontinued product analysis

with details as (
select a.productid, a.productname, a.unitsinstock,
b.orderid, b.unitprice*b.quantity sales, b.discount,
c.customerid,
d.companyname, d.contactname, d.phone
from [Products] a
join [Order_Details] b on a.productid = b.productid
join orders c on b.orderid = c.orderid
join customers d on c.customerid = d.customerid
where discontinued = 1
and unitsinstock > 0
)

, company_sales as(
select productname, companyname, sum(sales) sales
from details
group by productname, companyname
)

, ranking as (
select productname, companyname, sales, row_number () over (partition by productname order by sales desc) rnk
from company_sales
)
select *
from ranking
where rnk <= 3

-- 2. customer analysis
with details as (
select 
b.orderid, b.unitprice*b.quantity sales,
c.customerid, cast(c.orderdate as date) orderdate, year(cast(c.orderdate as date)) orderyear,
d.companyname, d.city, d.country
from [order_details] b
join orders c on b.orderid = c.orderid
join customers d on c.customerid = d.customerid
)
, top_customer as (
select companyname,
country,
sales,
orderyear,
row_number () over (partition by orderyear order by sales desc) ranking
from details)

select * from top_customer
order by orderyear, ranking

-- 3. employee analysis
with details as (
select 
b.employeeid,
count(distinct b.orderid) count_order,
concat(c.firstname,c.lastname) fullname,
title,
year(HireDate) - year(birthdate) as hired_age,
city,
country
from orders b
join employees c on b.employeeid = c.employeeid
group by b.employeeid, concat(c.firstname,c.lastname) , title, year(HireDate) - year(birthdate), city, country
)
select * from details order by count_order desc