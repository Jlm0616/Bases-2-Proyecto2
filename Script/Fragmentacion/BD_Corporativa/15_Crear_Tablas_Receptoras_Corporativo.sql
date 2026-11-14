-- ============================================
-- 15_Crear_Tablas_Receptoras_Corporativo.sql
-- ============================================

USE WWI_Corporativo;
GO

-- ============================================
-- SAN JOSE
-- ============================================

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

-- ============================================
-- LIMON
-- ============================================

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

-- ============================================
-- VERIFICACION DE LAS 4 TABLAS DE FACTURAS
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
    'InvoicesSanJose',
    'InvoiceLinesSanJose',
    'InvoicesLimon',
    'InvoiceLinesLimon'
)
GROUP BY s.name, t.name
ORDER BY s.name, t.name;
GO
