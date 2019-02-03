USE AdventureWorks2008R2;
/* Select product id, name and selling start date for all products
that started selling after 02/01/2006 and had a yellow color.
Use the CAST function to display the date only. Sort the returned
data by the selling start date.
Hint: a: You need to work with the Production.Product table.
b: The syntax for CAST is CAST(expression AS data_type),
where expression is the column name we want to format and
we can use DATE as data_type for this question to display
just the date. */

SELECT ProductID,Name,CAST(SellStartDate AS date) AS SellStartDate 
FROM Production.Product 
WHERE Color IN ('Yellow') AND SellStartDate > 02/01/2006 
ORDER BY SellStartDate;

/* List the latest order date and total number of orders for each
customer. Include only the customer ID, account number, latest
order date and the total number of orders in the report.
Use column aliases to make the report more presentable.
Sort the returned data by the customer id.
Hint: You need to work with the Sales.SalesOrderHeader table. */

SELECT c.CustomerID,MAX(oh.OrderDate),
COUNT(SalesOrderID) AS "Total Order"
FROM Sales.Customer c INNER JOIN Sales.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID
GROUP BY c.CustomerID
ORDER BY c.CustomerID;

/* Write a query to select the product id, name, and list price
for the products that have a list price greater than the average
list price. Sort the returned data by the product id.
Hint: You’ll need to use a simple subquery to get the average
list price and use it in a WHERE clause. */

SELECT ProductID,Name,ListPrice  
from Production.Product 
WHERE ListPrice > (SELECT AVG(ListPrice) FROM Production.Product)
ORDER BY ProductID;

/* Write a query to retrieve the number of times that a product has
been sold for each product. Include only the products that have
been sold more than 5 times. Use a column alias to make the report
more presentable. Sort the returned data by the number of times a
product has been sold in the descending order. Include the product
ID, product name and number of times a product has been sold
columns in the report.
Hint: Use the Sales.SalesOrderDetail and Production.Product tables. */

SELECT a.ProductID as "Product ID",a.Name as "Product Name",COUNT(s.SalesOrderID) as '# of Orders'
FROM Production.Product a
INNER JOIN Sales.SalesOrderDetail s
on a.ProductID = s.ProductID
GROUP BY a.ProductID,a.Name
HAVING COUNT(s.SalesOrderID) >5
ORDER BY '# of Orders' DESC;

/* Write a SQL query to generate a list of customer ID's and
account numbers that have never placed an order before.*/

SELECT c.CustomerID , c.AccountNumber 
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderHeader soh
ON c.CustomerID = soh.CustomerID
WHERE soh.SalesOrderID NOT IN (SELECT soh.SalesOrderID FROm Sales.SalesOrderHeader soh)
ORDER BY c.CustomerID;

/* Provide a unique list of product ids and product names that
were not ordered during 2007 and sort the list by product id. */

SELECT DISTINCT so.ProductID,p.Name,CAST(p.SellStartDate as DATE) AS SellStartDate
FROM Sales.SalesOrderDetail so
INNER JOIN Production.Product p
ON so.ProductID = p.ProductID
WHERE DATEPART(year,p.SellStartDate) !=2007 
ORDER BY so.ProductID