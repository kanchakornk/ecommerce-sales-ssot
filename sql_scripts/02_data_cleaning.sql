-- =================================================================================
-- Part 2: Data Cleaning & Transformation
-- เป้าหมาย: แปลงข้อมูลจาก Raw ให้เป็น Single Source of Truth (SSOT)
-- =================================================================================

-- 2.1 Standardization: แก้ไขชื่อประเทศให้เป็นมาตรฐาน (Proper Case)
UPDATE dbo.ecommerce_sales_raw
SET Country = UPPER(LEFT(Country,1)) + LOWER(SUBSTRING(Country,2,LEN(Country)))
WHERE Country IS NOT NULL;

-- 2.2 สร้างตารางหลัก FactSales
IF OBJECT_ID('dbo.FactSales', 'U') IS NOT NULL DROP TABLE dbo.FactSales;
GO

SELECT 
    ISNULL(OrderID, 'N/A') AS OrderID,
    ISNULL(CAST(OrderDate AS DATE), '1900-01-01') AS OrderDate, 
    ISNULL(CustomerID, 'N/A') AS CustomerID,
    
    -- Business Logic: Age Segmentation
    CASE 
        WHEN CustomerAge < 25 THEN '18-24'
        WHEN CustomerAge BETWEEN 25 AND 34 THEN '25-34'
        WHEN CustomerAge BETWEEN 35 AND 44 THEN '35-44'
        WHEN CustomerAge BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS AgeGroup,
    
    ISNULL(CustomerGender, 'Unknown') AS CustomerGender,
    ISNULL(Country, 'Unknown') AS Country,
    ISNULL(ProductCategory, 'Other') AS ProductCategory,
    ISNULL(ProductName, 'N/A') AS ProductName,
    ISNULL(Quantity, 0) AS Quantity,
    ISNULL(TotalAmount, 0) AS TotalAmount,
    ISNULL(OrderStatus, 'N/A') AS OrderStatus,
    
    -- Date Features (Helper columns สำหรับการทำ Star Schema)
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    DATENAME(MONTH, OrderDate) AS MonthName,
    DATEPART(QUARTER, OrderDate) AS OrderQuarter

INTO dbo.FactSales
FROM dbo.ecommerce_sales_raw
WHERE OrderStatus IN ('Completed', 'Pending')
  AND TotalAmount > 0; 

GO





