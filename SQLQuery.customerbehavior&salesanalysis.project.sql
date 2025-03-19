-- CUSTOMER BEHAVIOR & SALES ANALYSIS. 

--1. List all the states in which we have customers who have bought cellphones from 2005 till today.

SELECT
DISTINCT dl.state
FROM DIM_LOCATION dl
JOIN FACT_TRANSACTIONS ft ON dl.IDLocation = ft.IDLocation
WHERE YEAR(ft.Date) >= 2005



--2. What state in the US is buying the most 'Samsung' cell phones?

SELECT TOP 1
dl.state,
SUM(ft.quantity) AS total_quantity
FROM fact_transactions ft
JOIN dim_model do ON ft.idmodel = do.idmodel
JOIN dim_manufacturer dm ON do.idmanufacturer = dm.idmanufacturer
JOIN dim_location dl ON ft.idlocation = dl.idlocation
WHERE dm.manufacturer_name = 'Samsung' AND dl.country = 'US'
GROUP BY dl.state
ORDER BY total_quantity DESC



--3. Show the number of transactions for each model per zip code per state.

SELECT 
dl.state, 
dl.zipcode,
do.idmodel,
do.model_name, 
COUNT(ft.idmodel) AS transaction_count
FROM fact_transactions ft
JOIN dim_location dl ON ft.idlocation = dl.idlocation
JOIN dim_model do ON ft.idmodel = do.idmodel
GROUP BY dl.state, dl.zipcode, do.idmodel, do.model_name
ORDER BY dl.state, dl.zipcode, transaction_count DESC



--4. Show the cheapest cellphone (Output should contain the price also).

SELECT
do.model_name, 
do.unit_price
FROM dim_model do
ORDER BY do.unit_price ASC



--5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price. 

SELECT TOP 5
do.idmodel,
do.idmanufacturer,
dm.manufacturer_name,
AVG(do.unit_price) AS avg_price,
SUM(ft.quantity) AS sales_quantity
FROM dim_model do
JOIN fact_transactions ft ON do.idmodel = ft.idmodel
JOIN dim_manufacturer dm ON do.idmanufacturer = dm.idmanufacturer
GROUP BY do.idmodel,do.idmanufacturer, dm.manufacturer_name
ORDER BY avg_price DESC



--6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500.

SELECT
dc.idcustomer,
dc.customer_name,
AVG(ft.totalprice) AS avg_spendings
FROM dim_customer dc
JOIN fact_transactions ft ON dc.idcustomer = ft.idcustomer
WHERE YEAR(ft.date) = '2009'
GROUP BY dc.idcustomer, dc.customer_name
HAVING AVG(ft.totalprice) > 500
ORDER BY avg_spendings DESC



--7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010.

SELECT
ft.idmodel,
do.model_name,
SUM(ft.quantity) AS total_quantity
FROM fact_transactions ft
JOIN dim_model do ON ft.idmodel = do.idmodel
WHERE YEAR(ft.date) IN ('2008', '2009', '2010')
GROUP BY ft.idmodel, do.model_name
HAVING COUNT(DISTINCT YEAR(ft.date)) = 3
ORDER BY total_quantity DESC



--8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.

WITH Top2_2009 AS 
(
SELECT
dm.manufacturer_name,
SUM(ft.totalprice) AS total_sales_2009
FROM fact_transactions ft
JOIN dim_model do ON ft.idmodel = do.idmodel
JOIN dim_manufacturer dm ON do.idmanufacturer = dm.idmanufacturer
WHERE YEAR(ft.date) = 2009
GROUP BY dm.manufacturer_name
ORDER BY total_sales_2009 DESC
OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY
),

Top2_2010 AS 
(
SELECT
dm.manufacturer_name,
SUM(ft.totalprice) AS total_sales_2010
FROM fact_transactions ft
JOIN dim_model do ON ft.idmodel = do.idmodel
JOIN dim_manufacturer dm ON do.idmanufacturer = dm.idmanufacturer
WHERE YEAR(ft.date) = 2010
GROUP BY dm.manufacturer_name
ORDER BY total_sales_2010 DESC
OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY
)

SELECT 
'2009' AS year,
t2.manufacturer_name AS manufacturer_2009,
t2.total_sales_2009 AS sales_2009,
'2010' AS year,
t3.manufacturer_name AS manufacturer_2010,
t3.total_sales_2010 AS sales_2010
FROM Top2_2009 t2
JOIN Top2_2010 t3 ON 1=1



--9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.

WITH Sales2010 AS 
(
SELECT 
dm.idmanufacturer
FROM fact_transactions ft
JOIN dim_model do ON ft.idmodel = do.idmodel
JOIN dim_manufacturer dm ON do.idmanufacturer = dm.idmanufacturer
WHERE YEAR(ft.date) = 2010
),

Sales2009 AS 
(
SELECT 
dm.idmanufacturer
FROM fact_transactions ft
JOIN dim_model do ON ft.idmodel = do.idmodel
JOIN dim_manufacturer dm ON do.idmanufacturer = dm.idmanufacturer
WHERE YEAR(ft.date) = 2009
)

SELECT 
dm.manufacturer_name
FROM dim_manufacturer dm
WHERE dm.idmanufacturer IN (SELECT idmanufacturer FROM Sales2010)
AND dm.idmanufacturer NOT IN (SELECT idmanufacturer FROM Sales2009)



--10. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.

SELECT 
dc.idcustomer,
dc.customer_name,
MAX(YEAR(ft.date)) AS max_year,
MIN(YEAR(ft.date)) AS min_year,
MAX(AVG(ft.totalprice)) AS max_avg_spend,
MIN(AVG(ft.totalprice)) AS min_avg_spend,
(MAX(AVG(ft.totalprice)) - MIN(AVG(ft.totalprice))) AS spend_change,
LAG(MAX(AVG(ft.totalprice))) OVER (PARTITION BY dc.idcustomer ORDER BY MAX(YEAR(ft.date))) AS prev_year_avg_spend,
((MAX(AVG(ft.totalprice)) - LAG(MAX(AVG(ft.totalprice))) OVER (PARTITION BY dc.idcustomer ORDER BY MAX(YEAR(ft.date)))) / 
LAG(MAX(AVG(ft.totalprice))) OVER (PARTITION BY dc.idcustomer ORDER BY MAX(YEAR(ft.date)))) * 100 AS percent_change
FROM dim_customer dc
JOIN fact_transactions ft ON dc.idcustomer = ft.idcustomer
GROUP BY dc.idcustomer, dc.customer_name
ORDER BY max_year DESC










