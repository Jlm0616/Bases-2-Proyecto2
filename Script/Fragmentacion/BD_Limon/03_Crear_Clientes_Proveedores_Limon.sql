
-- ============================================
-- 03_Crear_Clientes_Proveedores_Limon.sql
-- ============================================

USE WWI_Limon;
GO

-- 1. CLIENTES
CREATE TABLE Sales.Customers (
    CustomerID INT NOT NULL PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    BillToCustomerID INT NOT NULL,
    CustomerCategoryID INT NOT NULL,
    BuyingGroupID INT NULL,
    AccountOpenedDate DATE NOT NULL,
    StandardDiscountPercentage DECIMAL(18,3) NOT NULL,
    IsStatementSent BIT NOT NULL,
    IsOnCreditHold BIT NOT NULL,
    PaymentDays INT NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL,

    CONSTRAINT FK_Customers_CustomerCategories
        FOREIGN KEY (CustomerCategoryID)
        REFERENCES Sales.CustomerCategories(CustomerCategoryID),

    CONSTRAINT FK_Customers_BuyingGroups
        FOREIGN KEY (BuyingGroupID)
        REFERENCES Sales.BuyingGroups(BuyingGroupID),

    CONSTRAINT FK_Customers_BillToCustomer
        FOREIGN KEY (BillToCustomerID)
        REFERENCES Sales.Customers(CustomerID)
);
GO

-- 2. PROVEEDORES
CREATE TABLE Purchasing.Suppliers (
    SupplierID INT NOT NULL PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    SupplierCategoryID INT NOT NULL,
    SupplierReference NVARCHAR(20) NULL,
    PaymentDays INT NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL,

    CONSTRAINT FK_Suppliers_SupplierCategories
        FOREIGN KEY (SupplierCategoryID)
        REFERENCES Purchasing.SupplierCategories(SupplierCategoryID)
);
GO
