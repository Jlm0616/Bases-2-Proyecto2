-- ============================================
-- 07_Crear_Facturas_Limon.sql
-- ============================================

USE WWI_Limon;
GO

CREATE TABLE Sales.Invoices (
    InvoiceID INT NOT NULL PRIMARY KEY,
    SucursalID INT NOT NULL
        CONSTRAINT DF_Invoices_SucursalID DEFAULT (2),
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

    CONSTRAINT CK_Invoices_SucursalID
        CHECK (SucursalID IN (0, 2)),

    CONSTRAINT FK_Invoices_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID),

    CONSTRAINT FK_Invoices_BillToCustomer
        FOREIGN KEY (BillToCustomerID)
        REFERENCES Sales.Customers(CustomerID),

    CONSTRAINT FK_Invoices_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Sales.Orders(OrderID)
);
GO

CREATE TABLE Sales.InvoiceLines (
    InvoiceLineID INT NOT NULL PRIMARY KEY,
    InvoiceID INT NOT NULL,
    SucursalID INT NOT NULL
        CONSTRAINT DF_InvoiceLines_SucursalID_Limon DEFAULT (2), -- NUEVA COLUMNA
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

    CONSTRAINT CK_InvoiceLines_SucursalID_Limon
        CHECK (SucursalID IN (0, 2)), -- NUEVA RESTRICCIÓN

    CONSTRAINT FK_InvoiceLines_Invoices
        FOREIGN KEY (InvoiceID)
        REFERENCES Sales.Invoices(InvoiceID),

    CONSTRAINT FK_InvoiceLines_StockItems
        FOREIGN KEY (StockItemID)
        REFERENCES Warehouse.StockItems(StockItemID),

    CONSTRAINT FK_InvoiceLines_PackageTypes
        FOREIGN KEY (PackageTypeID)
        REFERENCES Warehouse.PackageTypes(PackageTypeID)
);
GO