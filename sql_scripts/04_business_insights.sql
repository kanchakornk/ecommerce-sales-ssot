-- Part 4: Data Validation & Advanced SQL Insights 
-- -- 4.1 Data Validation
SELECT 
    'Rows before cleaning' AS Stage, COUNT(*) AS RowsBeforeCleaning FROM dbo.ecommerce_sales_raw
UNION ALL
SELECT 
    'Rows remaining in FactSales', COUNT(*) FROM dbo.FactSales;
SELECT COUNT(*) AS 'Rows deleted (invalid status)'
FROM ecommerce_sales_raw
WHERE OrderStatus NOT IN ('Completed', 'Pending');

/*Result:  
- Rows before cleaning: 5,000
- Rows remaining in FactSales: 4,226
- Rows deleted (invalid status): 774
*/

-- 4.2 Overview KPI
SELECT 
    ROUND(SUM(TotalAmount), 2) AS TotalRevenue,
    COUNT(*) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    ROUND(AVG(TotalAmount), 2) AS AvgOrderValue
FROM dbo.FactSales;

-- 4.3 Monthly Peak Insight
WITH MonthlyStats AS (
    SELECT OrderMonth, MonthName, SUM(TotalAmount) AS MonthlyRevenue
    FROM FactSales
    GROUP BY OrderMonth, MonthName
),
AvgStats AS (
    SELECT AVG(MonthlyRevenue) AS AvgMonthlyRevenue FROM MonthlyStats
)
SELECT m.MonthName, m.MonthlyRevenue, a.AvgMonthlyRevenue,
    FORMAT((m.MonthlyRevenue - a.AvgMonthlyRevenue) * 100.0 / a.AvgMonthlyRevenue, 'N2') + '%' AS DiffFromAvg
FROM MonthlyStats m, AvgStats a
ORDER BY m.MonthlyRevenue DESC; 

-- 4.4 Month-over-Month Growth
WITH MonthlySales AS (
    SELECT OrderYear, OrderMonth, MonthName,
        CAST(SUM(TotalAmount) AS DECIMAL(18,2)) AS MonthlyRevenue
    FROM FactSales
    GROUP BY OrderYear, OrderMonth, MonthName
)
SELECT MonthName, FORMAT(MonthlyRevenue, 'N2') AS MonthlyRevenue,
    FORMAT(LAG(MonthlyRevenue, 1) OVER (ORDER BY OrderYear, OrderMonth), 'N2') AS PrevMonthRevenue,
    FORMAT((MonthlyRevenue - LAG(MonthlyRevenue, 1) OVER (ORDER BY OrderYear, OrderMonth)) * 100.0 / NULLIF(LAG(MonthlyRevenue, 1) OVER (ORDER BY OrderYear, OrderMonth), 0), 'N2') + '%' AS GrowthRate
FROM MonthlySales;

-- 4.5 Customer Segmentation Insight
SELECT 
    Segment,
    COUNT(*) AS CustomerCount,
    FORMAT(SUM(MonetaryValue), 'N2') AS TotalRevenue,
    CAST(SUM(MonetaryValue) * 100.0 / (SELECT SUM(TotalAmount) FROM FactSales) AS DECIMAL(5,2)) AS RevenueShare
FROM CustomerSegment
GROUP BY Segment

ORDER BY SUM(MonetaryValue) DESC;

-- 4.6 Category Revenue Share (Top Categories Concentration)
WITH CategoryRevenue AS (
    SELECT
        ProductCategory,
        SUM(TotalAmount) AS CategoryRevenue
    FROM FactSales
    GROUP BY ProductCategory
),
RankedCategories AS (
    SELECT
        ProductCategory,
        CategoryRevenue,
        DENSE_RANK() OVER (ORDER BY CategoryRevenue DESC) AS RevenueRank
    FROM CategoryRevenue
),
TotalRevenue AS (
    SELECT SUM(CategoryRevenue) AS TotalRevenue
    FROM CategoryRevenue
)
SELECT
    ProductCategory,
    FORMAT(CategoryRevenue, 'N2') AS CategoryRevenue,
    CAST(CategoryRevenue * 100.0 / (SELECT TotalRevenue FROM TotalRevenue) AS DECIMAL(5,2)) AS RevenueShare
FROM RankedCategories
ORDER BY CategoryRevenue DESC;

-- 4.7 Top 3 Categories Revenue Share Summary
WITH CategoryRevenue AS (
    SELECT
        ProductCategory,
        SUM(TotalAmount) AS CategoryRevenue
    FROM FactSales
    GROUP BY ProductCategory
),
RankedCategories AS (
    SELECT
        ProductCategory,
        CategoryRevenue,
        DENSE_RANK() OVER (ORDER BY CategoryRevenue DESC) AS RevenueRank
    FROM CategoryRevenue
),
TotalRevenue AS (
    SELECT SUM(CategoryRevenue) AS TotalRevenue
    FROM CategoryRevenue
),
Top3Revenue AS (
    SELECT SUM(CategoryRevenue) AS Top3Revenue
    FROM RankedCategories
    WHERE RevenueRank <= 3
)
SELECT
    FORMAT(Top3Revenue, 'N2') AS Top3Revenue,
    CAST(Top3Revenue * 100.0 / (SELECT TotalRevenue FROM TotalRevenue) AS DECIMAL(5,2)) AS Top3RevenueShare
FROM Top3Revenue;

-- 4.8 Age Group Revenue Share 
SELECT
    AgeGroup,
    COUNT(*) AS OrderCount,
    FORMAT(SUM(TotalAmount), 'N2') AS TotalRevenue,
    CAST(SUM(TotalAmount) * 100.0 / (SELECT SUM(TotalAmount) FROM FactSales) AS DECIMAL(5,2)) AS RevenueShare
FROM FactSales
GROUP BY AgeGroup
ORDER BY SUM(TotalAmount) DESC;




