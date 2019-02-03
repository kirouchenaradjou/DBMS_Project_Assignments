SELECT c.CustomerID, c.AccountNumber, SalesOrderID, OrderDate
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID;

SELECT c.CustomerID, c.AccountNumber, SalesOrderID, OrderDate
FROM Sales.Customer c
LEFT OUTER JOIN Sales.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID;

SELECT c.CustomerID, c.AccountNumber, SalesOrderID, OrderDate
FROM Sales.Customer c
RIGHT OUTER JOIN Sales.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID;

SELECT c.CustomerID,
 PersonID,
 COUNT(SalesOrderID) AS "Total Order"
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID
GROUP BY c.CustomerID, PersonID
ORDER BY "Total Order" DESC;

SELECT c.CustomerID,
 PersonID,
 COUNT(SalesOrderID) AS "Total Order"
FROM Sales.Customer c INNER JOIN Sales.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID
GROUP BY c.CustomerID, PersonID
HAVING COUNT(SalesOrderID) > 20
ORDER BY "Total Order" DESC;

SELECT ProductID, Name, Color, ListPrice, SellStartDate
FROM Production.Product
WHERE Color IN ('Red', 'Blue', 'White') -- character comparison
ORDER BY Color, Name;

SELECT ProductID, Name, Color, ListPrice, SellStartDate
FROM Production.Product
WHERE ListPrice IN (337.22, 594.83, 63.50, 8.99) -- numeric comparison
ORDER BY ListPrice;

SELECT FirstName, MiddleName, LastName
FROM Person.Person
WHERE LastName LIKE 'a%'
ORDER BY LastName;

SELECT FirstName, MiddleName, LastName
FROM Person.Person
WHERE LastName LIKE '[ace]%'
ORDER BY LastName;

SELECT Name [Product],
 ListPrice,
 (SELECT MAX(ListPrice) FROM Production.Product)
 AS [Max Price],
 (ListPrice / (SELECT MAX(ListPrice) FROM Production.Product)) * 100
 AS [Percent of MAX]
FROM Production.Product
WHERE ListPrice > 0
ORDER BY ListPrice DESC;

--2-1
/* Select product id, name and selling start date for all products
 that started selling before 01/01/2006 and had a silver color.
 Use the CAST function to display the date only.
 Hint: a: You need to work with the Production.Product table.
 B: The syntax for CAST is CAST(expression AS data_type),
 where expression is the column name we want to format and
 we can use DATE as data_type for this question to display
 just the date. */

SELECT CAST(2006-01-01 AS datetime) ProductID, Name, SellStartDate 
FROM Production.Product
WHERE SellStartDate <= '2006-01-01' AND Color IN ('Silver') -- character comparison;

--2-2
/* List the oldest and latest order dates for each customer.
 Include only the customer ID, account number, oldest order date
 and latest order date in the report. Use column aliases to make
 the report more presentable.
 Hint: You need to work with the Sales.SalesOrderHeader table. */

SELECT c.CustomerID, c.AccountNumber, OrderDate
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID
ORDER BY OrderDate DESC

--2-3
/* Write a query to select the product id, name, and list price
 for the product(s) that has the highest list price.
 Hint: You’ll need to use a simple subquery to get the maximum
 list price and use it in the WHERE clause. */



SELECT ProductID, Name, ListPrice
FROM Production.Product
WHERE ListPrice = (SELECT MAX(ListPrice) FROM Production.Product)


--2-4
/* Write a query to retrieve the total quantity sold for each product.
 Include only products that have a total quantity sold greater than
 3000. Sort the results by the total quantity sold in the descending
 order. Include the product ID, product name, and total quantity
 sold columns in the report.
 Hint: Use the Sales.SalesOrderDetail and Production.Product tables.
*/

SELECT a.ProductID , a.Name, COUNT(SalesOrderID) as "Total Order" 
FROM Production.Product a
INNER JOIN Sales.SalesOrderDetail b
ON a.ProductID =  b.ProductID
GROUP BY a.Name, a.ProductID 
ORDER BY "Total Order" DESC;


--2-5
/* Write a SQL query to generate a list of customer ID's and
 account numbers that have never placed an order before.
 Sort the list by CustomerID in the ascending order. */

SELECT c.CustomerID, c.AccountNumber
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID
ORDER BY c.CustomerID ASC


--2-6
/* Provide a unique list of product ids and product names that were ordered during March 2007 and sort the list by product id. */

SELECT * FROM Sales.SalesOrderHeader

SELECT DISTINCT ProductID , Name
FROM Sales.SalesOrderHeader 
INNER JOIN Production.Product oh
ON ProductID = ProductID
WHERE SellStartDate >= 2007-03-01 AND SellStartDate <= 2007-03-31 
--WHERE SellStartDate BETWEEN (2007-03-01) AND (2007-03-31)
--WHERE SellStartDate BETWEEN  ('2007/03/01', 'yyyy/mm/dd') AND ('2007/03/31', 'yyyy/mm/dd');
--ORDER BY oh.ProductID DESC
