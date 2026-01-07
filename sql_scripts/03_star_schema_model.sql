-- Part 3: Dimensional Modeling (การสร้าง Star Schema)
-- 3.1 สร้าง Dimension: CustomerSegment (RFM-Lite)
IF OBJECT_ID('dbo.CustomerSegment', 'U') IS NOT NULL DROP TABLE dbo.CustomerSegment;
GO

WITH CustomerMetrics AS (
    SELECT 
        CustomerID,
        MAX(OrderDate) AS LastPurchaseDate,
        COUNT(*) AS Frequency,
        SUM(TotalAmount) AS MonetaryValue
    FROM FactSales
    GROUP BY CustomerID
)
SELECT 
    CustomerID, 
    DATEDIFF(DAY, LastPurchaseDate, GETDATE()) AS Recency,
    Frequency, 
    MonetaryValue,
    CASE 
        WHEN MonetaryValue >= 10000 THEN 'VIP'
        WHEN MonetaryValue >= 5000 THEN 'Premium'
        WHEN MonetaryValue >= 1000 THEN 'Regular'
        ELSE 'New'
    END AS Segment
INTO dbo.CustomerSegment
FROM CustomerMetrics;
GO

-- 3.2 สร้าง Dimension: DimProduct
IF OBJECT_ID('dbo.DimProduct', 'U') IS NOT NULL DROP TABLE dbo.DimProduct;
GO

SELECT DISTINCT ProductName, ProductCategory INTO dbo.DimProduct FROM FactSales;
GO

-- 3.3 สร้าง Dimension: DimDate
IF OBJECT_ID('dbo.DimDate','U') IS NOT NULL DROP TABLE dbo.DimDate;
GO

SELECT DISTINCT 
    OrderDate, YEAR(OrderDate) AS [Year], MONTH(OrderDate) AS [Month],
    FORMAT(OrderDate, 'yyyy-MM') AS YearMonth,
    DATENAME(MONTH, OrderDate) AS MonthName, DATEPART(QUARTER, OrderDate) AS [Quarter],
    DATENAME(WEEKDAY, OrderDate) AS DayOfWeek
INTO dbo.DimDate FROM FactSales;

GO

