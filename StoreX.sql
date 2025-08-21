CREATE DATABASE StoreXDB;
GO
USE StoreXDB;
GO

-- Products
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100),
    Price DECIMAL(10,2),
    Quantity INT
);

-- Employees
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeName NVARCHAR(100),
    Role NVARCHAR(20)
);

-- UserAccounts
CREATE TABLE UserAccounts (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    Username NVARCHAR(50),
    Password NVARCHAR(100),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Customers
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(100),
    Phone NVARCHAR(20),
    Address NVARCHAR(255)
);

-- SalesInvoices
CREATE TABLE SalesInvoices (
    InvoiceID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    CustomerID INT,
    InvoiceDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- SalesDetails
CREATE TABLE SalesDetails (
    SalesDetailID INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    FOREIGN KEY (InvoiceID) REFERENCES SalesInvoices(InvoiceID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- ProductImports
CREATE TABLE ProductImports (
    ImportID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    ImportDate DATETIME DEFAULT GETDATE(),
    Quantity INT,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Sample Data
INSERT INTO Products (ProductName, Price, Quantity) VALUES
('Laptop', 1200.00, 10),
('Phone', 800.00, 20);

INSERT INTO Employees (EmployeeName, Role) VALUES
('Admin User', 'Admin'),
('John Smith', 'Sales'),
('Shiro', 'Warehouse');

INSERT INTO UserAccounts (EmployeeID, Username, Password) VALUES
(1, 'admin', 'admin123'),
(2, 'john', 'john123'),
(3, 'shiro', '123');

INSERT INTO Customers (CustomerName, Phone, Address) VALUES
('Alice', '0123456789', 'Hanoi'),
('Bob', '0987654321', 'HCM');

INSERT INTO SalesInvoices (EmployeeID, CustomerID) VALUES
(2, 1),
(2, 2);

INSERT INTO SalesDetails (InvoiceID, ProductID, Quantity, UnitPrice) VALUES
(1, 1, 1, 1200.00),
(2, 2, 2, 800.00);

INSERT INTO ProductImports (ProductID, Quantity) VALUES
(1, 5),
(2, 10);

-- Test
SELECT * FROM Products;
SELECT * FROM Employees;
SELECT * FROM Customers;
SELECT * FROM SalesInvoices;
SELECT * FROM SalesDetails;
SELECT * FROM ProductImports;
SELECT * FROM UserAccounts
UPDATE UserAccounts
SET EmployeeID = 3
WHERE Username = 'shiro';