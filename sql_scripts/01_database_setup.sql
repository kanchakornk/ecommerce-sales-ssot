/* DATA SOURCE: ecommerce_sales_raw.csv (5,000 rows)
METHOD: Imported via SQL Server Import Wizard
*/
-- Part 1: Database Setup & Data Discovery
-- 1.1 สร้าง Database และใช้งาน
CREATE DATABASE EcommerceSalesDB;
GO
USE EcommerceSalesDB;
GO

-- 1.2 Data Quality Check: ตรวจสอบจำนวนข้อมูลทั้งหมดและสถานะออเดอร์ที่ไม่ถูกต้อง (Invalid Status)
SELECT COUNT(*) AS 'Rows before cleaning' from ecommerce_sales_raw
SELECT COUNT(*) AS 'Invalid orders detected'
FROM ecommerce_sales_raw
WHERE OrderStatus NOT IN ('Completed', 'Pending');

/*
Result:
- Rows before cleaning: 5,000
- Invalid orders detected: 774
*/








