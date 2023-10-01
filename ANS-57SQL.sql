/** beginning**/
/**1.Which shippers do we have?**/
SELECT * FROM Shippers

/**2.Certain fields from Categories**/
SELECT CategoryName,Description FROM Categories

/**3.Sales Representatives**/
SELECT * FROM Employees

/**4.Sales Representatives in the United States**/
SELECT FirstName,LastName,HireDate FROM Employees
WHERE Title = 'Sales Representative' and Country = 'USA'

/**5.Orders placed by specific EmployeeID**/
SELECT * FROM Orders
WHERE EmployeeID = 5

/**6.Suppliers and ContactTitles**/
SELECT SupplierID,ContactName,ContactTitle FROM Suppliers
WHERE ContactTitle <> 'Marketing Manager'

/**7.**/
SELECT ProductID,ProductName FROM Products
WHERE ProductName LIKE '%queso%'

/**8.**/
Select OrderID,CustomerID,ShipCountry
From Orders
where ShipCountry = 'France' or ShipCountry = 'Belgium'

/**9.**/
SELECT OrderID,CustomerID,ShipCountry FROM Orders
WHERE ShipCountry IN ('Brazil' ,'Mexico' ,'Argentina', 'Venezuela')

/**10**/
Select FirstName,LastName,Title,BirthDate From Employees
Order By Birthdate

/**11.**/
SELECT LastName,CONVERT(DATE,BirthDate) FROM Employees ORDER BY BirthDate ASC

/**12.**/
SELECT FirstName,LastName,CONCAT(FirstName,' ',LastName) AS 'FULL NAME' FROM Employees

/**13.**/
SELECT OrderID,ProductID,UnitPrice,Quantity, UnitPrice * Quantity AS TOTAL_PRICE FROM [Order Details]
ORDER BY ORDERID

/**14.**/
SELECT COUNT(*) AS Total_Customer FROM Customers

/**15.**/
SELECT MIN(OrderDate) AS FIRST_DATE FROM Orders

/**16.**/
SELECT City FROM Customers GROUP BY City 

/**17.**/
SELECT COUNT(ContactTitle),ContactTitle FROM Customers GROUP BY ContactTitle ORDER BY COUNT(ContactTitle) DESC

/**18.**/
SELECT ProductID,ProductName,Suppliers.CompanyName FROM Products
JOIN Suppliers 
ON Products.SupplierID = Suppliers.SupplierID 
ORDER BY Products.ProductID

/**19.**/
SELECT OrderID,CONVERT(date,OrderDate),Shippers.CompanyName FROM Orders
JOIN Shippers 
ON Orders.ShipVia = Shippers.ShipperID
where Orders.OrderID < 10300
ORDER BY Orders.OrderID


/**INTERMEDIATE**/
/**20.**/
SELECT COUNT(ProductID),CategoryID FROM Products
GROUP BY CategoryID
ORDER BY COUNT(ProductID) DESC
/**21.**/
SELECT Country,City,COUNT(*) AS NUMBER_CUSTOMERS FROM Customers
GROUP BY City,Country
ORDER BY COUNT(*) DESC

/**22.**/
SELECT * FROM Products
WHERE UnitsInStock < ReorderLevel

/**23.**/
SELECT * FROM Products
WHERE (UnitsInStock + UnitsOnOrder) < ReorderLevel
AND
Discontinued = 0

/**24.**/
SELECT CompanyName,Region FROM Customers
order by
case
	when Region is null then 1
	else 0
end


/**25.**/
SELECT top 3 AVG(Freight) AS average,ShipCountry FROM Orders
GROUP BY ShipCountry
ORDER BY average desc

/**26.**/
SELECT top 3 AVG(Freight) AS average,ShipCountry FROM Orders
where Datename(year,OrderDate) = '1997'
GROUP BY ShipCountry
ORDER BY average desc

/**27.**/
SELECT Freight AS average,ShipCountry,OrderDate FROM Orders
where OrderDate between '1/1/1997' and '12/31/1997'
ORDER BY OrderDate desc

/**28.**/
SELECT top 3 AVG(Freight) AS average,ShipCountry FROM Orders
where OrderDate >= DATEADD(MONTH,-12,(select Max(OrderDate) from Orders))
GROUP BY ShipCountry
ORDER BY average desc


/**29.**/
select d.EmployeeID,d.LastName,c.OrderID,b.ProductName,a.Quantity from [Order Details] as a
join Products as b
on a.ProductID = b.ProductID
join Orders as c
on a.OrderID = c.OrderID
join Employees as d
on d.EmployeeID = c.EmployeeID

/**30.**/
SELECT Customers.CustomerID,Orders.CustomerID from Customers
left join Orders
on Customers.CustomerID = Orders.CustomerID
where Orders.CustomerID is null

/**31.**/
SELECT Customers.CustomerID,Orders.CustomerID FROM Customers
LEFT JOIN Orders
on Customers.CustomerID = Orders.CustomerID and Orders.EmployeeID = 4
where EmployeeID is null


/**ADVANCED**/
/**32.high value customers**/
select a.CustomerID,SUM(Quantity*UnitPrice) as total from Customers as a
join Orders as b
ON a.CustomerID = b.CustomerID
JOIN [Order Details] as c
ON c.OrderID = b.OrderID
where DATENAME(year,b.OrderDate) = '1998'
group by a.CustomerID,b.OrderID
having SUM(Quantity*UnitPrice) > 10000
order by SUM(Quantity*UnitPrice) desc

/**33**/

select a.CustomerID,SUM(Quantity*UnitPrice) as total from Customers as a
join Orders as b
ON a.CustomerID = b.CustomerID
JOIN [Order Details] as c
ON c.OrderID = b.OrderID
where DATENAME(year,b.OrderDate) = '1998'
group by a.CustomerID
having SUM(Quantity*UnitPrice) >= 15000
order by SUM(Quantity*UnitPrice) desc

/**34**/
select a.CustomerID,SUM(Quantity*UnitPrice) as total_before,SUM(Quantity*(UnitPrice-UnitPrice*Discount)) as total_after from Customers as a
join Orders as b
ON a.CustomerID = b.CustomerID
JOIN [Order Details] as c
ON c.OrderID = b.OrderID
where DATENAME(year,b.OrderDate) = '1998'
group by a.CustomerID
having SUM(Quantity*(UnitPrice-UnitPrice*Discount)) >= 10000
order by total_after desc

/**35**/

create function dayspermonth2(@y int, @m int ) returns int
as
begin
declare @days int
 
 if @m in (1,3,5,7,8,10,12) set @days = 29
 else if @m in (4,6,9,11) set @days =  30
 else if  @m = 2
	begin
		if(@y % 4 = 0 and (@y % 100 <> 0 or @y % 400 = 0)) set @days = 29
		else set @days =  28
	end
 return @days
end

select EmployeeID,OrderID,OrderDate from Orders
where DATENAME(DAY,OrderDate) = (select dbo.dayspermonth2(DATEPART(YEAR,OrderDate),DATEPART(MONTH,OrderDate)))
ORDER BY EmployeeID,OrderID

/**36**/
SELECT top 10 a.OrderID, count(a.OrderID) FROM Orders AS a
JOIN [Order Details] as b
ON a.OrderID = b.OrderID
group by a.OrderID
order by count(a.OrderID) desc,a.OrderID desc

/**37**/
select TOP 10 * from Orders
order by NEWID()

/**38**/
  select OrderID from [Order Details]
  where Quantity>=60
  group by OrderID, Quantity
  having COUNT(ProductID) > 1

/**39**/


select * from [Order Details] as b
where OrderID in (  select OrderID from [Order Details]
  where Quantity>=60
  group by OrderID, Quantity
  having COUNT(ProductID) > 1)

/**40**/
with a(ProductID)
as
(
  select OrderID from [Order Details]
  where Quantity>=60
  group by OrderID, Quantity
  having COUNT(ProductID) > 1
)
select * from [Order Details] as b
join a
on a.ProductID = b.OrderID

/**41**/
SELECT * FROM Orders
WHERE ShippedDate >= RequiredDate
/**42**/
SELECT TOTAL,* FROM Employees
JOIN
(SELECT EmployeeID,COUNT(*) AS TOTAL FROM Orders
WHERE ShippedDate > RequiredDate
GROUP BY EmployeeID
)AS DREIVED
on DREIVED.EmployeeID = Employees.EmployeeID
order by DREIVED.TOTAL DESC

/**43**/
SELECT A.EmployeeID,LastName,TOTAL_ORD,TOTAL FROM Employees AS A
JOIN
(SELECT EmployeeID,COUNT(*) AS TOTAL FROM Orders
WHERE ShippedDate >= RequiredDate
GROUP BY EmployeeID
HAVING COUNT(*) > 1
)AS DREIVED
on DREIVED.EmployeeID = A.EmployeeID
JOIN
(SELECT EmployeeID,COUNT(*) AS TOTAL_ORD FROM Orders
GROUP BY EmployeeID
)AS ORG
on ORG.EmployeeID = A.EmployeeID
order by A.EmployeeID


/**44**/
SELECT A.EmployeeID,LastName,TOTAL_ORD,TOTAL FROM Employees AS A
LEFT JOIN
(SELECT EmployeeID,COUNT(*) AS TOTAL FROM Orders
WHERE ShippedDate >= RequiredDate
GROUP BY EmployeeID
HAVING COUNT(*) > 1
)AS DREIVED
on DREIVED.EmployeeID = A.EmployeeID
JOIN
(SELECT EmployeeID,COUNT(*) AS TOTAL_ORD FROM Orders
GROUP BY EmployeeID
)AS ORG
on ORG.EmployeeID = A.EmployeeID
order by A.EmployeeID


/**45**/
CREATE FUNCTION DEF(@VAL INT) RETURNS INT
AS
BEGIN
IF(@VAL IS NULL ) RETURN 0
ELSE RETURN @VAL
RETURN @VAL
END

SELECT A.EmployeeID,LastName,TOTAL_ORD,dbo.DEF(TOTAL) FROM Employees AS A
LEFT JOIN
(SELECT EmployeeID,COUNT(*) AS TOTAL FROM Orders
WHERE ShippedDate >= RequiredDate
GROUP BY EmployeeID
HAVING COUNT(*) > 1
)AS DREIVED
on DREIVED.EmployeeID = A.EmployeeID
JOIN
(SELECT EmployeeID,COUNT(*) AS TOTAL_ORD FROM Orders
GROUP BY EmployeeID
)AS ORG
on ORG.EmployeeID = A.EmployeeID

order by A.EmployeeID

/**46**/

SELECT A.EmployeeID,LastName,TOTAL_ORD,dbo.DEF(TOTAL) AS Tot,CAST(dbo.DEF(TOTAL) AS float)/CAST(TOTAL_ORD AS float ) AS PERC   FROM Employees AS A
LEFT JOIN
(SELECT EmployeeID,COUNT(*) AS TOTAL FROM Orders
WHERE ShippedDate >= RequiredDate
GROUP BY EmployeeID
HAVING COUNT(*) > 1
)AS DREIVED
on DREIVED.EmployeeID = A.EmployeeID
JOIN
(SELECT EmployeeID,COUNT(*) AS TOTAL_ORD FROM Orders
GROUP BY EmployeeID
)AS ORG
on ORG.EmployeeID = A.EmployeeID
order by A.EmployeeID
/**47**/

SELECT A.EmployeeID,LastName,TOTAL_ORD,dbo.DEF(TOTAL) AS Tot,

CAST(CAST(dbo.DEF(TOTAL) AS float)/CAST(TOTAL_ORD AS float ) AS decimal(12,3)) AS PERC   FROM Employees AS A
LEFT JOIN
(SELECT EmployeeID,COUNT(*) AS TOTAL FROM Orders
WHERE ShippedDate >= RequiredDate
GROUP BY EmployeeID
HAVING COUNT(*) > 1
)AS DREIVED
on DREIVED.EmployeeID = A.EmployeeID
JOIN
(SELECT EmployeeID,COUNT(*) AS TOTAL_ORD FROM Orders
GROUP BY EmployeeID
)AS ORG
on ORG.EmployeeID = A.EmployeeID
order by A.EmployeeID
/**48**/

CREATE FUNCTION CAT(@TOTAL INT) RETURNs char(10)
AS
BEGIN
IF(@TOTAL >=0 AND @TOTAL <= 1000) return 'LOW'
ELSE IF(@TOTAL >1000 AND @TOTAL <= 5000) return 'MED'
ELSE IF(@TOTAL >5000 AND @TOTAL <= 10000) return 'HIGH'
ELSE IF(@TOTAL >10000) return 'VERY HIGH'
return null
END

select a.CustomerID,SUM(Quantity*UnitPrice) as total, dbo.CAT(SUM(Quantity*UnitPrice)) as category from Customers as a
LEFT join Orders as b
ON a.CustomerID = b.CustomerID
JOIN [Order Details] as c
ON c.OrderID = b.OrderID
where DATENAME(year,b.OrderDate) = '1998'
group by a.CustomerID
/**HAVING dbo.CAT(SUM(Quantity*UnitPrice)) IS NULL**/
order by a.CustomerID


/**49**/
select a.CustomerID,SUM(Quantity*UnitPrice) as total, dbo.CAT(SUM(Quantity*UnitPrice)) as category from Customers as a
LEFT join Orders as b
ON a.CustomerID = b.CustomerID
left JOIN [Order Details] as c
ON c.OrderID = b.OrderID
where DATENAME(year,b.OrderDate) = '1998'
group by a.CustomerID
order by a.CustomerID


/**50**/
with beforegroup
as
(
select COUNT(*) as total from Customers as a
where a.CustomerID in (select a.CustomerID from Customers as a
LEFT join Orders as b
ON a.CustomerID = b.CustomerID
where DATENAME(year,b.OrderDate) = '1998'
group by a.CustomerID)
),
cat_info(id,total_price,category)
as
(
select a.CustomerID as id,SUM(Quantity*UnitPrice) as total_price, dbo.CAT(SUM(Quantity*UnitPrice)) as category from Customers as a
LEFT join Orders as b
ON a.CustomerID = b.CustomerID
left JOIN [Order Details] as c
ON c.OrderID = b.OrderID
where DATENAME(year,b.OrderDate) = '1998'
group by a.CustomerID
)
select cat_info.category ,count(cat_info.category) ,
CAST(count(cat_info.category) as decimal) / cast(beforegroup.total as decimal) as percent_cat
from  beforegroup,cat_info
group by cat_info.category , beforegroup.total
order by count(cat_info.category) desc
 

/**51**/
/**missing table**/
/**52**/



/**53**/
SELECT DISTINCT A.Country AS SUPPLIERS_COUNTRY,B.Country AS CUSTOMER_COUNTRY FROM Suppliers AS A
FULL JOIN Customers AS B
ON A.Country = B.Country
ORDER BY A.Country,B.Country
/**54**/
create function supp_country(@supp varchar(50)) returns int
as
begin
return (
select count(*) from Suppliers
where Country = @supp)
end
create function customer_country(@supp varchar(50)) returns int
as
begin
return (
select count(*) from Customers
where Country = @supp)
end

with cte
as
(
SELECT Country FROM Suppliers
UNION
SELECT Country FROM Customers
)
select Country,dbo.supp_country(Country) as suppliers_in_country,dbo.customer_country(Country) as customers_in_country from cte

/**55**/

with cte
as
(
select ShipCountry,CustomerID,OrderID,OrderDate ,ROW_NUMBER() over(partition by ShipCountry order by orderid) as i
from Orders
)
select * from cte
where cte.i = 1

/**56**/
Select InitialOrder.CustomerID
,InitialOrderID = InitialOrder.OrderID
,InitialOrderDate = convert(date, InitialOrder.OrderDate) ,NextOrderID =
NextOrder.OrderID
,NextOrderDate = convert(date, NextOrder.OrderDate) ,DaysBetween =
datediff(day, InitialOrder.OrderDate, NextOrder.OrderDate) from Orders
InitialOrder join Orders NextOrder 
on InitialOrder.CustomerID =NextOrder.CustomerID
where InitialOrder.OrderID < NextOrder.OrderID
and datediff(day, InitialOrder.OrderDate, NextOrder.OrderDate) <= 5
Order by InitialOrder.CustomerID
,InitialOrder.OrderID
/**57**/



