USE SalesDB;
GO

-- 2. สร้างตารางเก็บข้อมูลสินค้า (Products)
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY, -- ไอดีรันอัตโนมัติ เริ่มจาก 1 เพิ่มทีละ 1
    ProductName NVARCHAR(100) NOT NULL,       -- ชื่อสินค้า (รองรับภาษาไทย)
    Price DECIMAL(10,2) NOT NULL,             -- ราคาสินค้า ทศนิยม 2 ตำแหน่ง
    StockQuantity INT DEFAULT 0               -- จำนวนสินค้าในคลัง ค่าเริ่มต้นเป็น 0
);
GO

-- 3. สร้างตารางเก็บข้อมูลการสั่งซื้อ (Orders)
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,   -- ไอดีออเดอร์รันอัตโนมัติ
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID), -- เชื่อมโยงไปตาราง Products
    Quantity INT NOT NULL,                    -- จำนวนที่ซื้อ
    OrderDate DATETIME DEFAULT GETDATE()     -- บันทึกวันเวลาที่ซื้อให้อัตโนมัติ
);
GO
 
