-- ============================================
-- 15_Crear_Tablas_Receptoras_Corporativo.sql
-- ============================================

USE WWI_Corporativo;
GO

-- ============================================
-- SAN JOSE
-- ============================================

-- 1. Sales.OrdersSanJose
CREATE TABLE Sales.OrdersSanJose (
    OrderID INT NOT NULL,
    SucursalID INT NOT NULL DEFAULT (1),
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

    CONSTRAINT PK_OrdersSanJose
        PRIMARY KEY (OrderID)
);
GO

-- 2. Sales.OrderLinesSanJose
CREATE TABLE Sales.OrderLinesSanJose (
    OrderLineID INT NOT NULL,
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
    SucursalID INT NOT NULL DEFAULT (1),

    CONSTRAINT PK_OrderLinesSanJose
        PRIMARY KEY (OrderLineID),

    CONSTRAINT FK_OrderLinesSanJose_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Sales.OrdersSanJose(OrderID)
);
GO

-- 3. Sales.InvoicesSanJose
CREATE TABLE Sales.InvoicesSanJose (
    InvoiceID INT NOT NULL,
    SucursalID INT NOT NULL DEFAULT (1),
    CustomerID INT NOT NULL,
    BillToCustomerID INT NOT NULL,
    OrderID INT NULL,
    DeliveryMethodID INT NOT NULL,
    ContactPersonID INT NOT NULL,
    AccountsPersonID INT NOT NULL,
    SalespersonPersonID INT NOT NULL,
    PackedByPersonID INT NOT NULL,
    InvoiceDate DATE NOT NULL,
    CustomerPurchaseOrderNumber NVARCHAR(20) NULL,
    IsCreditNote BIT NOT NULL,
    CreditNoteReason NVARCHAR(MAX) NULL,
    Comments NVARCHAR(MAX) NULL,
    DeliveryInstructions NVARCHAR(MAX) NULL,
    InternalComments NVARCHAR(MAX) NULL,
    TotalDryItems INT NOT NULL,
    TotalChillerItems INT NOT NULL,
    DeliveryRun NVARCHAR(5) NULL,
    RunPosition NVARCHAR(5) NULL,
    ReturnedDeliveryData NVARCHAR(MAX) NULL,

    ConfirmedDeliveryTime AS TRY_CONVERT(
        DATETIME2(7),
        JSON_VALUE(ReturnedDeliveryData, N'$.DeliveredWhen'),
        126
    ),

    ConfirmedReceivedBy AS JSON_VALUE(
        ReturnedDeliveryData,
        N'$.ReceivedBy'
    ),

    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,

    CONSTRAINT PK_InvoicesSanJose
        PRIMARY KEY (InvoiceID)
);
GO

-- 4. Sales.InvoiceLinesSanJose
CREATE TABLE Sales.InvoiceLinesSanJose (
    InvoiceLineID INT NOT NULL,
    InvoiceID INT NOT NULL,
    StockItemID INT NOT NULL,
    Description NVARCHAR(100) NOT NULL,
    PackageTypeID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NULL,
    TaxRate DECIMAL(18,3) NOT NULL,
    TaxAmount DECIMAL(18,2) NOT NULL,
    LineProfit DECIMAL(18,2) NOT NULL,
    ExtendedPrice DECIMAL(18,2) NOT NULL,
    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,
    SucursalID INT NOT NULL DEFAULT (1),

    CONSTRAINT PK_InvoiceLinesSanJose
        PRIMARY KEY (InvoiceLineID),

    CONSTRAINT FK_InvoiceLinesSanJose_Invoices
        FOREIGN KEY (InvoiceID)
        REFERENCES Sales.InvoicesSanJose(InvoiceID)
);
GO

-- 5. Purchasing.PurchaseOrdersSanJose
CREATE TABLE Purchasing.PurchaseOrdersSanJose (
    PurchaseOrderID INT NOT NULL,
    SupplierID INT NOT NULL,
    OrderDate DATE NOT NULL,
    DeliveryMethodID INT NOT NULL,
    ContactPersonID INT NOT NULL,
    ExpectedDeliveryDate DATE NULL,
    SupplierReference NVARCHAR(20) NULL,
    IsOrderFinalized BIT NOT NULL,
    Comments NVARCHAR(MAX) NULL,
    InternalComments NVARCHAR(MAX) NULL,
    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,
    SucursalID INT NOT NULL DEFAULT (1),

    CONSTRAINT PK_PurchaseOrdersSanJose
        PRIMARY KEY (PurchaseOrderID)
);
GO

-- 6. Purchasing.PurchaseOrderLinesSanJose
CREATE TABLE Purchasing.PurchaseOrderLinesSanJose (
    PurchaseOrderLineID INT NOT NULL,
    PurchaseOrderID INT NOT NULL,
    StockItemID INT NOT NULL,
    OrderedOuters INT NOT NULL,
    Description NVARCHAR(100) NOT NULL,
    ReceivedOuters INT NOT NULL,
    PackageTypeID INT NOT NULL,
    ExpectedUnitPricePerOuter DECIMAL(18,2) NULL,
    LastReceiptDate DATE NULL,
    IsOrderLineFinalized BIT NOT NULL,
    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,
    SucursalID INT NOT NULL DEFAULT (1),

    CONSTRAINT PK_PurchaseOrderLinesSanJose
        PRIMARY KEY (PurchaseOrderLineID),

    CONSTRAINT FK_PurchaseOrderLinesSanJose_PurchaseOrders
        FOREIGN KEY (PurchaseOrderID)
        REFERENCES Purchasing.PurchaseOrdersSanJose(PurchaseOrderID)
);
GO

-- ============================================
-- LIMON
-- ============================================

-- 7. Sales.OrdersLimon
CREATE TABLE Sales.OrdersLimon (
    OrderID INT NOT NULL,
    SucursalID INT NOT NULL DEFAULT (2),
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

    CONSTRAINT PK_OrdersLimon
        PRIMARY KEY (OrderID)
);
GO

-- 8. Sales.OrderLinesLimon
CREATE TABLE Sales.OrderLinesLimon (
    OrderLineID INT NOT NULL,
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
    SucursalID INT NOT NULL DEFAULT (2),

    CONSTRAINT PK_OrderLinesLimon
        PRIMARY KEY (OrderLineID),

    CONSTRAINT FK_OrderLinesLimon_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Sales.OrdersLimon(OrderID)
);
GO

-- 9. Sales.InvoicesLimon
CREATE TABLE Sales.InvoicesLimon (
    InvoiceID INT NOT NULL,
    SucursalID INT NOT NULL DEFAULT (2),
    CustomerID INT NOT NULL,
    BillToCustomerID INT NOT NULL,
    OrderID INT NULL,
    DeliveryMethodID INT NOT NULL,
    ContactPersonID INT NOT NULL,
    AccountsPersonID INT NOT NULL,
    SalespersonPersonID INT NOT NULL,
    PackedByPersonID INT NOT NULL,
    InvoiceDate DATE NOT NULL,
    CustomerPurchaseOrderNumber NVARCHAR(20) NULL,
    IsCreditNote BIT NOT NULL,
    CreditNoteReason NVARCHAR(MAX) NULL,
    Comments NVARCHAR(MAX) NULL,
    DeliveryInstructions NVARCHAR(MAX) NULL,
    InternalComments NVARCHAR(MAX) NULL,
    TotalDryItems INT NOT NULL,
    TotalChillerItems INT NOT NULL,
    DeliveryRun NVARCHAR(5) NULL,
    RunPosition NVARCHAR(5) NULL,
    ReturnedDeliveryData NVARCHAR(MAX) NULL,

    ConfirmedDeliveryTime AS TRY_CONVERT(
        DATETIME2(7),
        JSON_VALUE(ReturnedDeliveryData, N'$.DeliveredWhen'),
        126
    ),

    ConfirmedReceivedBy AS JSON_VALUE(
        ReturnedDeliveryData,
        N'$.ReceivedBy'
    ),

    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,

    CONSTRAINT PK_InvoicesLimon
        PRIMARY KEY (InvoiceID)
);
GO

-- 10. Sales.InvoiceLinesLimon
CREATE TABLE Sales.InvoiceLinesLimon (
    InvoiceLineID INT NOT NULL,
    InvoiceID INT NOT NULL,
    StockItemID INT NOT NULL,
    Description NVARCHAR(100) NOT NULL,
    PackageTypeID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NULL,
    TaxRate DECIMAL(18,3) NOT NULL,
    TaxAmount DECIMAL(18,2) NOT NULL,
    LineProfit DECIMAL(18,2) NOT NULL,
    ExtendedPrice DECIMAL(18,2) NOT NULL,
    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,
    SucursalID INT NOT NULL DEFAULT (2),

    CONSTRAINT PK_InvoiceLinesLimon
        PRIMARY KEY (InvoiceLineID),

    CONSTRAINT FK_InvoiceLinesLimon_Invoices
        FOREIGN KEY (InvoiceID)
        REFERENCES Sales.InvoicesLimon(InvoiceID)
);
GO

-- 11. Purchasing.PurchaseOrdersLimon
CREATE TABLE Purchasing.PurchaseOrdersLimon (
    PurchaseOrderID INT NOT NULL,
    SupplierID INT NOT NULL,
    OrderDate DATE NOT NULL,
    DeliveryMethodID INT NOT NULL,
    ContactPersonID INT NOT NULL,
    ExpectedDeliveryDate DATE NULL,
    SupplierReference NVARCHAR(20) NULL,
    IsOrderFinalized BIT NOT NULL,
    Comments NVARCHAR(MAX) NULL,
    InternalComments NVARCHAR(MAX) NULL,
    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,
    SucursalID INT NOT NULL DEFAULT (2),

    CONSTRAINT PK_PurchaseOrdersLimon
        PRIMARY KEY (PurchaseOrderID)
);
GO

-- 12. Purchasing.PurchaseOrderLinesLimon
CREATE TABLE Purchasing.PurchaseOrderLinesLimon (
    PurchaseOrderLineID INT NOT NULL,
    PurchaseOrderID INT NOT NULL,
    StockItemID INT NOT NULL,
    OrderedOuters INT NOT NULL,
    Description NVARCHAR(100) NOT NULL,
    ReceivedOuters INT NOT NULL,
    PackageTypeID INT NOT NULL,
    ExpectedUnitPricePerOuter DECIMAL(18,2) NULL,
    LastReceiptDate DATE NULL,
    IsOrderLineFinalized BIT NOT NULL,
    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,
    SucursalID INT NOT NULL DEFAULT (2),

    CONSTRAINT PK_PurchaseOrderLinesLimon
        PRIMARY KEY (PurchaseOrderLineID),

    CONSTRAINT FK_PurchaseOrderLinesLimon_PurchaseOrders
        FOREIGN KEY (PurchaseOrderID)
        REFERENCES Purchasing.PurchaseOrdersLimon(PurchaseOrderID)
);
GO

-- ============================================
-- VERIFICACION DE LAS 12 TABLAS
-- ============================================

SELECT
    s.name + '.' + t.name AS Tabla,
    COUNT(c.column_id) AS CantidadColumnas
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
INNER JOIN sys.columns AS c
    ON c.object_id = t.object_id
WHERE t.name IN (
    'OrdersSanJose',
    'OrderLinesSanJose',
    'InvoicesSanJose',
    'InvoiceLinesSanJose',
    'PurchaseOrdersSanJose',
    'PurchaseOrderLinesSanJose',
    'OrdersLimon',
    'OrderLinesLimon',
    'InvoicesLimon',
    'InvoiceLinesLimon',
    'PurchaseOrdersLimon',
    'PurchaseOrderLinesLimon'
)
GROUP BY s.name, t.name
ORDER BY s.name, t.name;
GO
