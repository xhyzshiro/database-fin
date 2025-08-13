IF DB_ID('StoreXDB') IS NOT NULL
BEGIN
    ALTER DATABASE StoreXDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE StoreXDB;
END
CREATE DATABASE StoreXDB;
GO

USE StoreXDB;
GO

-- =========================
-- 1) Employees
-- =========================
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeCode VARCHAR(20) NOT NULL UNIQUE,
    FullName NVARCHAR(150) NOT NULL,
    Position NVARCHAR(100) NULL,
    PhoneNumber VARCHAR(20) NULL,
    Email VARCHAR(150) NULL UNIQUE
);
GO

-- =========================
-- 2) UserAccounts
-- =========================
CREATE TABLE UserAccounts (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARBINARY(256) NOT NULL,
    PasswordSalt VARBINARY(128) NOT NULL,
    IsFirstLogin BIT NOT NULL DEFAULT 1,
    EmployeeID INT NOT NULL UNIQUE,
    CONSTRAINT FK_UserAccounts_Employees FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmployeeID)
);
GO

-- =========================
-- 3) Customers
-- =========================
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerCode VARCHAR(20) NULL UNIQUE,
    FullName NVARCHAR(150) NOT NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(150) NULL,
    Address NVARCHAR(255) NULL,
    DateRegistered DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- =========================
-- 4) Products
-- =========================
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductCode VARCHAR(20) NOT NULL UNIQUE,
    ProductName NVARCHAR(255) NOT NULL,
    Price DECIMAL(18,2) NOT NULL CONSTRAINT CK_Products_Price CHECK (Price >= 0),
    QuantityInStock INT NOT NULL DEFAULT 0 CONSTRAINT CK_Products_Qty CHECK (QuantityInStock >= 0),
    ImagePath NVARCHAR(255) NULL
);
GO

-- =========================
-- 5) Sales (Orders)
-- =========================
CREATE TABLE Sales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    SaleDate DATETIME NOT NULL DEFAULT GETDATE(),
    CustomerID INT NULL,
    EmployeeID INT NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL CONSTRAINT CK_Sales_Total CHECK (TotalAmount >= 0),
    CONSTRAINT FK_Sales_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Sales_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

-- =========================
-- 6) SaleDetails
-- =========================
CREATE TABLE SaleDetails (
    SaleDetailID INT IDENTITY(1,1) PRIMARY KEY,
    SaleID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CONSTRAINT CK_SaleDetails_Qty CHECK (Quantity > 0),
    UnitPrice DECIMAL(18,2) NOT NULL CONSTRAINT CK_SaleDetails_UnitPrice CHECK (UnitPrice >= 0),
    SubTotal AS (Quantity * UnitPrice) PERSISTED,
    CONSTRAINT FK_SaleDetails_Sales FOREIGN KEY (SaleID) REFERENCES Sales(SaleID) ON DELETE CASCADE,
    CONSTRAINT FK_SaleDetails_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- =========================
-- 7) ProductImports
-- =========================
CREATE TABLE ProductImports (
    ImportID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ImportDate DATETIME NOT NULL DEFAULT GETDATE(),
    Quantity INT NOT NULL CONSTRAINT CK_ProductImports_Qty CHECK (Quantity > 0),
    ImportPrice DECIMAL(18,2) NOT NULL CONSTRAINT CK_ProductImports_Price CHECK (ImportPrice >= 0),
    CONSTRAINT FK_ProductImports_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- =========================
-- SAMPLE DATA
-- =========================
INSERT INTO Employees (EmployeeCode, FullName, Position, PhoneNumber, Email)
VALUES ('EMP001', N'Nguyễn Văn A', N'Quản lý', '0901000111', 'a@storex.vn'),
       ('EMP002', N'Lê Thị B', N'Nhân viên bán hàng', '0901000222', 'b@storex.vn');

DECLARE @salt VARBINARY(128) = CRYPT_GEN_RANDOM(32);
INSERT INTO UserAccounts (Username, PasswordHash, PasswordSalt, EmployeeID)
VALUES ('admin', HASHBYTES('SHA2_256', @salt + CONVERT(VARBINARY(100), 'Admin@123')), @salt, 1);

INSERT INTO Customers (CustomerCode, FullName, Phone, Email, Address)
VALUES ('C001', N'Nguyễn Văn C', '0903000333', 'c@storex.vn', N'Hà Nội');

INSERT INTO Products (ProductCode, ProductName, Price, QuantityInStock, ImagePath)
VALUES ('P001', N'iPhone 13', 13000.00, 20, N'/images/iphone13.jpg'),
       ('P002', N'Samsung Galaxy A52', 4200.00, 30, N'/images/a52.jpg');

INSERT INTO ProductImports (ProductID, Quantity, ImportPrice)
VALUES (1, 10, 10000.00), (2, 15, 3000.00);

INSERT INTO Sales (CustomerID, EmployeeID, TotalAmount)
VALUES (1, 2, 17200.00);

INSERT INTO SaleDetails (SaleID, ProductID, Quantity, UnitPrice)
VALUES (1, 1, 1, 13000.00), (1, 2, 1, 4200.00);
GO

-- =========================
-- VIEW: Monthly Revenue
-- =========================
CREATE VIEW vw_MonthlyRevenue AS
SELECT
    YEAR(SaleDate) AS SaleYear,
    MONTH(SaleDate) AS SaleMonth,
    SUM(TotalAmount) AS TotalRevenue,
    COUNT(SaleID) AS TotalOrders
FROM Sales
GROUP BY YEAR(SaleDate), MONTH(SaleDate);
GO

-- =========================
-- PROCEDURE: Get Top Products
-- =========================
CREATE PROCEDURE usp_GetTopProducts
    @TopN INT = 5
AS
BEGIN
    SELECT TOP(@TopN)
        p.ProductID, p.ProductName,
        SUM(sd.Quantity) AS TotalSold,
        SUM(sd.SubTotal) AS TotalRevenue
    FROM SaleDetails sd
    JOIN Products p ON sd.ProductID = p.ProductID
    GROUP BY p.ProductID, p.ProductName
    ORDER BY TotalSold DESC;
END
GO
