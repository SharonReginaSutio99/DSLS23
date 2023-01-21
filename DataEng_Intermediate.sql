-- 1
select year(OrderDate) order_year, 
	month(OrderDate) order_month,
	count(CustomerID) count_customer
from dbo.Orders
where year(OrderDate) = 1997
group by year(OrderDate) , 
	month(OrderDate) 
;

-- 2
select concat(LastName,', ', FirstName) employee_name
from dbo.Employees
where Title = 'Sales Representative'

-- 3

select c.ProductName, 
	count(a.OrderID) count_orders
from dbo.Orders a
join dbo.OrderDetails b on a.OrderID = b.OrderID
join dbo.Products c on b.ProductID = c.ProductID
where year(OrderDate) = 1997
and month(OrderDate) = 1
group by c.ProductName
order by count(a.OrderID) desc
offset 0 rows
fetch next 5 rows only

-- 4
select CompanyName, ProductName
from dbo.Products a
join dbo.OrderDetails b on a.ProductID = b.ProductID
join dbo.Orders c on b.OrderID = c.OrderID
join dbo.Customers d on c.CustomerID = d.CustomerID
where ProductName like ('%Chai%')
and month(OrderDate) = 6
and year(OrderDate) = 1997

-- 5
with 
grouping as (
	select 
		case when sum(UnitPrice * quantity) <= 100 then '<=100'
		when sum(UnitPrice * quantity) > 100 and sum(UnitPrice * quantity)<= 250 then '100<x<=250'
		when sum(UnitPrice * quantity) > 250 and sum(UnitPrice * quantity)<= 500 then '250<x<=500'
		when sum(UnitPrice * quantity) >500 then '>500'
		end as sales_group,
		OrderID
	from dbo.OrderDetails
	group by orderid
)
select sales_group, count(OrderID) count_order
from grouping
group by sales_group

-- 6

select companyname, sum(unitprice* quantity) sales
from dbo.orders a
join dbo.orderdetails b on a.orderid = b.orderid
join dbo.customers c on a.customerid = c.customerid
where year(orderdate) = 1997
group by companyname
having sum(unitprice*quantity) > 500


-- 7
with products as (
	select month(orderdate) order_month,
		productid, 
		sum(unitprice * quantity) as sales
	from orders a
	join orderdetails b on a.orderid = b.orderid
	where year(orderdate) = 1997
	group by month(orderdate), productid
),
ranking as (
	select order_month,
	productid,
	sales,
	row_number () over (partition by order_month order by sales desc) rank
	from products
)
select order_month, productid, sales
from ranking
where rank <= 5

-- 8
create view order_details as 
select a.*, productname, a.unitprice - discount as price_aft_disc
from dbo.orderdetails a
join products b on a.productid = b.productid

-- 9
create procedure SelectCustomers @customerid nchar(5)
as
select a.customerid,
	companyname as customername,
	a.orderid,
	orderdate,
	requireddate,
	shippeddate
from dbo.orders a
join dbo.customers b on a.customerid = b.customerid
where a.customerid = @customerid
