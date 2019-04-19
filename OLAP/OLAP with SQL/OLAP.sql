--a. Cuboid Creation
SELECT S.Name "Supplier Name", S.City "Supplier City", S.State "Supplier State", C.Name "Consumer Name",C.City "Consumer City",C.State "Consumer State",
	P.Name "Product Name", P.Product_Packaging "Product Packaging", P.Product_Category "Product Category", P.Product_Line "Product Line",
	D.DateYear "Year", D.DateQuarter "Quarter",D.DateMonth "Month", D.DateMonthName "Month Name",
	SUM(Quantity) "Total Transactions Quantity",
	SUM(Quantity*Price) "Total Transactions Value",
	MAX(Price) "Maximum Transaction Price",
	MIN(Price) "Minimum Transaction Price",
	COUNT(DISTINCT S.Supp_ID) "Count of Suppliers",
	COUNT(DISTINCT C.Con_ID) "Count of Consumers",
	COUNT(DISTINCT P.Prod_ID) "Count of Products"
INTO Tb_Transactions_Cube 
FROM Tb_Supplier S, Tb_Consumer C, Tb_Product P, Tb_Transactions T, Tb_Date D
WHERE S.Supp_ID=T.Supp_ID AND
		   C.Con_ID=T.Con_ID AND
		   P.Prod_ID=T.Prod_ID AND
		   D.DateKey = T.DateKey
GROUP BY cube((S.State, S.City, S.Name), (C.State, C.City,C.Name), (P.Product_Packaging, P.Product_Category ,P.Product_Line , P.Name), (D.DateYear, D.DateQuarter, D.DateMonth, D.DateMonthName)),
			rollup(S.State, S.City),
			rollup(C.State, C.City),
			rollup(P.Product_Packaging),
			rollup(P.Product_Category, P.Product_Line),
			rollup(D.DateYear, D.DateQuarter, D.DateMonth)
ORDER BY S.Name, C.Name, P.Name, D.DateMonthName
	
--b.Calculate the number of cuboids in Tb_Transactions_Cube
--Ans: (3+1)*(3+1)*(2+1)*(3+1)*(3+1) = 768 cuboids

--c. Solutions
--1. Quantity of sales aggregated by product category and supplier state? 
SELECT "Product Category", "Supplier State", "Total Transactions Quantity"
FROM Tb_Transactions_Midterm_Cube
WHERE "Supplier Name" IS NULL
  	AND "Supplier City" IS NULL
  	AND "Supplier State" IS NOT NULL
 	AND "Consumer Name" IS NULL
 	AND "Consumer City" IS NULL
  	AND "Consumer State" IS NULL
	AND "Product Name" IS NULL
	AND "Product Packaging" IS NULL
	AND "Product Category" IS NOT NULL
	AND "Product Line" IS NULL 
	AND "Year" IS NULL
	AND "Quarter" IS NULL
	AND "Month" IS NULL
	AND "Month Name" IS NULL

--2.Quantity of each product sold by each supplier in Madison to each consumer in Illinois?
SELECT "Product Name", "Supplier City", "Consumer State", "Total Transactions Quantity"
FROM Tb_Transactions_Midterm_Cube
WHERE "Supplier Name" IS NULL
  	AND "Supplier City" = 'Madison'
  	AND "Supplier State" IS NOT NULL
 	AND "Consumer Name" IS NULL
 	AND "Consumer City" IS NULL
  	AND "Consumer State" = 'Illinois'
	AND "Product Name" IS NOT NULL
	AND "Product Packaging" IS NOT NULL
	AND "Product Category" IS NOT NULL
	AND "Product Line" IS NOT NULL 
	AND "Year" IS NULL
	AND "Quarter" IS NULL
	AND "Month" IS NULL
	AND "Month Name" IS NULL

--3.Quantity of auto sales by each supplier from Wisconsin to each auto consumer in Illinois?
SELECT "Supplier Name", "Consumer Name", "Total Transactions Quantity"
FROM Tb_Transactions_Midterm_Cube
WHERE "Supplier Name" IS NOT NULL
  	AND "Supplier City" IS NOT NULL
  	AND "Supplier State" = 'Wisconsin'
 	AND "Consumer Name" IS NOT NULL
 	AND "Consumer City" IS NOT NULL
  	AND "Consumer State" = 'Illinois'
	AND "Product Name" = 'Auto'
	AND "Product Packaging" IS NOT NULL
	AND "Product Category" IS NOT NULL
	AND "Product Line" IS NOT NULL 
	AND "Year" IS NULL
	AND "Quarter" IS NULL
	AND "Month" IS NULL
	AND "Month Name" IS NULL

--4. Quantity of monthly sales of milk from Wisconsin suppliers during the year 2019 (show month name and order months by calendar)?
SELECT "Month Name", "Total Transactions Quantity"
FROM Tb_Transactions_Midterm_Cube
WHERE "Supplier Name" IS NULL
  	AND "Supplier City" IS NULL
  	AND "Supplier State" = 'Wisconsin'
 	AND "Consumer Name" IS NULL
 	AND "Consumer City" IS NULL
  	AND "Consumer State" IS NULL
	AND "Product Name" = 'Milk'
	AND "Product Packaging" IS NOT NULL
	AND "Product Category" IS NOT NULL
	AND "Product Line" IS NOT NULL 
	AND "Year" = 2019
	AND "Quarter" IS NOT NULL
	AND "Month" IS NOT NULL
	AND "Month Name" IS NOT NULL
Order by "Month"


--5. For each product list total value of sales during January 2019 compared to value of sales during March 2019.
SELECT ISNULL(JS.[Product Name],MS.[Product Name]) as 'Name',ISNULL("Sales During Jan 2019",0) as "Sales During Jan 2019",ISNULL("Sales During March 2019",0) as "Sales During March 2019"
FROM
(SELECT "Product Name", "Total Transactions Value" as "Sales During Jan 2019"
FROM Tb_Transactions_Midterm_Cube
WHERE "Supplier Name" IS  NULL
  	AND "Supplier City" IS NULL
  	AND "Supplier State" IS  NULL
 	AND "Consumer Name" IS NULL
 	AND "Consumer City" IS NULL
  	AND "Consumer State" IS NULL
	AND "Product Name" IS NOT NULL
	AND "Product Packaging" IS  NOT NULL
	AND "Product Category" IS NOT NULL
	AND "Product Line" IS NOT NULL 
	AND "Year" = 2019
	AND "Quarter" IS NOT NULL
	AND "Month" IS NOT NULL
	AND "Month Name" = 'January') JS
FULL JOIN
(SELECT "Product Name", "Total Transactions Value" as "Sales During March 2019"
FROM Tb_Transactions_Midterm_Cube
WHERE "Supplier Name" IS  NULL
  	AND "Supplier City" IS  NULL
  	AND "Supplier State" IS  NULL
 	AND "Consumer Name" IS NULL
 	AND "Consumer City" IS NULL
  	AND "Consumer State" IS NULL
	AND "Product Name" IS NOT NULL
	AND "Product Packaging" IS NOT NULL
	AND "Product Category" IS NOT NULL
	AND "Product Line" IS NOT NULL 
	AND "Year" = 2019
	AND "Quarter" IS NOT NULL
	AND "Month" IS NOT NULL
	AND "Month Name" = 'March') MS
ON JS."Product Name" = MS."Product Name"
