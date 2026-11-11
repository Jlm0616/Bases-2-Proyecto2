-- ============================================
-- 16_Crear_Ordenes_Compra_SanJose.sql
-- ============================================

USE WWI_SanJose;
GO

CREATE TABLE Purchasing.PurchaseOrders (
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
    SucursalID INT NOT NULL
        CONSTRAINT DF_PurchaseOrders_SucursalID DEFAULT (1),

    CONSTRAINT PK_Purchasing_PurchaseOrders
        PRIMARY KEY (PurchaseOrderID),
    CONSTRAINT CK_PurchaseOrders_SucursalID
        CHECK (SucursalID IN (0, 1)),
    CONSTRAINT FK_PurchaseOrders_Suppliers
        FOREIGN KEY (SupplierID)
        REFERENCES Purchasing.Suppliers(SupplierID),
    CONSTRAINT FK_PurchaseOrders_DeliveryMethods
        FOREIGN KEY (DeliveryMethodID)
        REFERENCES Application.DeliveryMethods(DeliveryMethodID),
    CONSTRAINT FK_PurchaseOrders_ContactPerson
        FOREIGN KEY (ContactPersonID)
        REFERENCES Application.People(PersonID),
    CONSTRAINT FK_PurchaseOrders_LastEditedBy
        FOREIGN KEY (LastEditedBy)
        REFERENCES Application.People(PersonID)
);
GO

CREATE TABLE Purchasing.PurchaseOrderLines (
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
    SucursalID INT NOT NULL
        CONSTRAINT DF_PurchaseOrderLines_SucursalID DEFAULT (1),

    CONSTRAINT PK_Purchasing_PurchaseOrderLines
        PRIMARY KEY (PurchaseOrderLineID),
    CONSTRAINT CK_PurchaseOrderLines_SucursalID
        CHECK (SucursalID IN (0, 1)),
    CONSTRAINT FK_PurchaseOrderLines_PurchaseOrders
        FOREIGN KEY (PurchaseOrderID)
        REFERENCES Purchasing.PurchaseOrders(PurchaseOrderID),
    CONSTRAINT FK_PurchaseOrderLines_StockItems
        FOREIGN KEY (StockItemID)
        REFERENCES Warehouse.StockItems(StockItemID),
    CONSTRAINT FK_PurchaseOrderLines_PackageTypes
        FOREIGN KEY (PackageTypeID)
        REFERENCES Warehouse.PackageTypes(PackageTypeID),
    CONSTRAINT FK_PurchaseOrderLines_LastEditedBy
        FOREIGN KEY (LastEditedBy)
        REFERENCES Application.People(PersonID)
);
GO
