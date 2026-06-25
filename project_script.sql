CREATE TABLE Products (
	ProductID INT IDENTITY(1,1) PRIMARY KEY,
	ProductName NVARCHAR(100) NOT NULL,
	Price DECIMAL(10,2) NOT NULL,
	StockQuantity INT DEFAULT 0
	);


CREATE TABLE Orders (
	OrderID INT IDENTITY(1,1) PRIMARY KEY,
	ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
	Quantity INT NOT NULL,
	OrderDate DATETIME	DEFAULT GETDATE()
	
);

USE SalesDB;
GO

INSERT INTO Products (ProductName, Price, StockQuantity)
VALUES
(N'iPhone 15', 32900.00, 50),
(N'iPad Air', 23900.00, 30),
(N'AirPods Pro', 8990.00, 100);
GO

INSERT INTO Orders (ProductID, Quantity)
VALUES 
(1, 2),
(3, 1),
(2, 3);
GO

SELECT 
	O.OrderID AS [เลขที่ออเดอร์],
	P.ProductName AS [ชื่อสินค้า],
	P.Price AS [ราคาต่อชิ้น],
	O.Quantity AS [จำนวนที่ซื้อ],
	(P.Price * O.Quantity) AS [ยอดรวมสุทธิ์],
	O.OrderDate AS [วันที่สั่งซื้อ]
FROM Orders O WITH (NOLOCK)
INNER JOIN Products p ON O.ProductID = P.ProductID 
ORDER BY [ยอดรวมสุทธิ์] DESC ;
GO


USE SalesDB;
GO

-- เริ่มต้นเปิดระบบ Transaction
BEGIN TRANSACTION;

BEGIN TRY
    -- ขั้นตอนที่ 1: บันทึกประวัติการสั่งซื้อ (ใส่เลข 1 คือ iPhone 15 และเลข 2 คือจำนวนชิ้นตรงๆ ไปเลย)
    INSERT INTO Orders (ProductID, Quantity)
    VALUES (1, 2);

    -- ขั้นตอนที่ 2: ใช้คำสั่ง UPDATE เพื่อตัดสต็อกสินค้า
    UPDATE Products
    SET StockQuantity = StockQuantity - 2 -- หักลบสต็อกออก 2 ชิ้น
    WHERE ProductID = 1;                  -- หักลบเฉพาะสินค้าไอดีเลข 1

    -- บันทึกข้อมูลถาวรเมื่อทำงานสำเร็จทั้งคู่
    COMMIT TRANSACTION;
    PRINT 'บันทึกออเดอร์และตัดสต็อกสำเร็จเรียบร้อย!';
END TRY

BEGIN CATCH
    -- ยกเลิกทั้งหมดหากเกิดข้อผิดพลาด
    ROLLBACK TRANSACTION;
    PRINT 'เกิดข้อผิดพลาด! ระบบทำการ Rollback ข้อมูลกลับสู่สภาพเดิมแล้ว';
END CATCH;
GO

USE SalesDB;
GO

SELECT 
	P.ProductName AS [ชื่อสินค้า],
	COUNT(O.OrderID) AS [จำนวนครั้งที่ออเดอร์เข้า],
	SUM(O.Quantity) AS [จำนวนชิ้นรวมที่ขายได้],
	SUM(P.Price*O.Quantity) AS [รายได้รวมสุทธิ],
	AVG(P.Price*O.Quantity) AS [ยอกซื้แเฉลี่ยนต่อออเดอร์]
FROM Orders O WITH (NOLOCK)
INNER JOIN Products P ON O.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY [รายได้รวมสุทธิ] DESC
GO

CREATE PROCEDURE GetSalesSummary
AS
BEGIN
	SELECT 
		P.ProductName AS [ชื่อสินค้า],
		COUNT(O.OrderID) AS [จำนวนครั้งที่ออเดอร์เข้า],
		SUM(O.Quantity) AS [จำนวนชิ้นรวมที่ขายได้],
		SUM(P.Price*O.Quantity) AS [รายได้รวมสุทธิ],
		AVG(P.Price*O.Quantity) AS [ยอกซื้แเฉลี่ยนต่อออเดอร์]
	FROM Orders O WITH (NOLOCK)
	INNER JOIN Products P ON O.ProductID = P.ProductID
	GROUP BY P.ProductName
	ORDER BY [รายได้รวมสุทธิ] DESC;	
END;
GO

EXEC GetSalesSummary;

USE SalesDB;
GO

CREATE VIEW v_SalesDailyReport
AS
SELECT 
	O.OrderID AS [เลขที่ออเดอร์],
	P.ProductName AS [ชื่อสินค้า],
	P.Price AS [ราคาต่อชิ้น],
	O.Quantity AS [จำนวนที่ซื้อ],
	(P.Price * O.Quantity) AS [ยอดรวมสุทธิ์],
	O.OrderDate AS [วันที่สั่งซื้อ]
FROM  Orders O WITH (NOLOCK)
INNER JOIN Products P ON O.ProductID = P.ProductID;
GO

