-- Lab 3 Solutions

-- Lab 3-1

SELECT c.CustomerID,
       c.TerritoryID,
	   COUNT(o.SalesOrderID) [Total Orders],
	   CASE
		  WHEN COUNT(o.SalesOrderID) = 0
			 THEN 'No Order'
		  WHEN COUNT(o.SalesOrderID) = 1
			 THEN 'One Time'
		  WHEN COUNT(o.SalesOrderID) BETWEEN 2 AND 5
			 THEN 'Regular'
		  WHEN COUNT(o.SalesOrderID) BETWEEN 6 AND 10
			 THEN 'Often'
		  ELSE 'Loyal'
	   END AS [Order Frequency] 
FROM Sales.Customer c
LEFT OUTER JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
WHERE DATEPART(year, OrderDate) = 2007
GROUP BY c.TerritoryID, c.CustomerID;


-- Lab 3-2
   
SELECT c.CustomerID,
       c.TerritoryID,
	   COUNT(o.SalesOrderID) [Total Orders],
	   RANK() OVER (PARTITION BY c.TerritoryID 
	                ORDER BY COUNT(o.SalesOrderID) DESC)
	   AS [Rank]
FROM Sales.Customer c
LEFT OUTER JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
WHERE DATEPART(year, OrderDate) = 2007
GROUP BY c.TerritoryID, c.CustomerID;


-- Lab 3-3

SELECT MAX(SP.Bonus) AS HighestBonus
FROM [Sales].[SalesPerson] SP
JOIN [Sales].[SalesTerritory] ST
ON SP.TerritoryID = ST.TerritoryID
JOIN [HumanResources].[Employee] E
ON SP.BusinessEntityID = E.BusinessEntityID
WHERE E.Gender = 'M' AND ST.CountryRegionCode = 'US';


-- 3-4

select * from 
(select a.OrderDate, b.ProductID, c.Name, sum(b.OrderQty) as total
	   ,RANK() OVER   
       (PARTITION BY a.OrderDate ORDER BY sum(b.OrderQty) DESC) AS Rank 
from [Sales].[SalesOrderHeader] a
join [Sales].[SalesOrderDetail] b
on a.SalesOrderID =  b.SalesOrderID
join [Production].[Product] c
on c.ProductID = b.ProductID
group by a.OrderDate, b.ProductID, c.Name
) temp
where rank = 1
order by OrderDate;


-- 3-5

select CustomerID, AccountNumber
from [Sales].[SalesOrderHeader] a
join [Sales].[SalesOrderDetail] b
on a.SalesOrderID = b.SalesOrderID
where a.OrderDate > '07-01-2008'
and b.ProductID = 711

intersect

select CustomerID, AccountNumber
from [Sales].[SalesOrderHeader] a
join [Sales].[SalesOrderDetail] b
on a.SalesOrderID = b.SalesOrderID
where a.OrderDate > '07-01-2008'
and b.ProductID = 712

order by CustomerID;
