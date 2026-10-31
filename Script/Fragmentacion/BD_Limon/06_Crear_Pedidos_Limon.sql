
-- ============================================
-- 06_Crear_Pedidos_Limon.sql
-- ============================================

USE WWI_Limon;
GO

CREATE TABLE Sales.Orders (
    OrderID INT NOT NULL PRIMARY KEY,
    SucursalID INT NOT NULL
        CONSTRAINT DF_Orders_SucursalID DEFAULT (2),
    CustomerID INT NOT NULL,
    SalespersonPersonID INT NOT NULL,
    PickedByPersonID INT NULL,
    ContactPersonID INT NOT NULL,
    BackorderOrderID INT NULL,
    OrderDate DATE NOT NULL,
    ExpectedDeliveryDate DATE NOT NULL,
    CustomerPurchaseOrderNumber NVARCHAR(20) NULL,
    IsUndersupplyBackordered BIT NOT NULL,
    Comments NVARCHAR(MAX) NULL,
    DeliveryInstructions NVARCHAR(MAX) NULL,
    InternalComments NVARCHAR(MAX) NULL,
    PickingCompletedWhen DATETIME2(7) NULL,
    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,

    CONSTRAINT CK_Orders_SucursalID
        CHECK (SucursalID IN (0, 2)),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID),

    CONSTRAINT FK_Orders_Backorder
        FOREIGN KEY (BackorderOrderID)
        REFERENCES Sales.Orders(OrderID)
);
GO

CREATE TABLE Sales.OrderLines (
    OrderLineID INT NOT NULL PRIMARY KEY,
    OrderID INT NOT NULL,
    StockItemID INT NOT NULL,
    Description NVARCHAR(100) NOT NULL,
    PackageTypeID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NULL,
    TaxRate DECIMAL(18,3) NOT NULL,
    PickedQuantity INT NOT NULL,
    PickingCompletedWhen DATETIME2(7) NULL,
    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,

    CONSTRAINT FK_OrderLines_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Sales.Orders(OrderID),

    CONSTRAINT FK_OrderLines_StockItems
        FOREIGN KEY (StockItemID)
        REFERENCES Warehouse.StockItems(StockItemID),

    CONSTRAINT FK_OrderLines_PackageTypes
        FOREIGN KEY (PackageTypeID)
        REFERENCES Warehouse.PackageTypes(PackageTypeID)
);
GO
