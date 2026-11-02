
-- ============================================
-- 04_Crear_Productos_SanJose.sql
-- ============================================


USE WWI_SanJose;
GO

-- 1. PRODUCTOS
CREATE TABLE Warehouse.StockItems (
    StockItemID INT NOT NULL PRIMARY KEY,
    StockItemName NVARCHAR(100) NOT NULL,
    SupplierID INT NOT NULL,
    ColorID INT NULL,
    UnitPackageID INT NOT NULL,
    OuterPackageID INT NOT NULL,
    Brand NVARCHAR(50) NULL,
    Size NVARCHAR(20) NULL,
    LeadTimeDays INT NOT NULL,
    QuantityPerOuter INT NOT NULL,
    IsChillerStock BIT NOT NULL,
    Barcode NVARCHAR(50) NULL,
    TaxRate DECIMAL(18,3) NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    RecommendedRetailPrice DECIMAL(18,2) NULL,
    TypicalWeightPerUnit DECIMAL(18,3) NOT NULL,
    MarketingComments NVARCHAR(MAX) NULL,
    InternalComments NVARCHAR(MAX) NULL,
    Photo VARBINARY(MAX) NULL,
    CustomFields NVARCHAR(MAX) NULL,
    -- Columnas calculadas
    Tags AS JSON_QUERY(CustomFields, N'$.Tags'),
    SearchDetails AS CONCAT(
        StockItemName, N' ', MarketingComments
    ),

    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL,
    -- Relaciones
    CONSTRAINT FK_StockItems_Suppliers
        FOREIGN KEY (SupplierID)
        REFERENCES Purchasing.Suppliers(SupplierID),

    CONSTRAINT FK_StockItems_Colors
        FOREIGN KEY (ColorID)
        REFERENCES Warehouse.Colors(ColorID),

    CONSTRAINT FK_StockItems_UnitPackage
        FOREIGN KEY (UnitPackageID)
        REFERENCES Warehouse.PackageTypes(PackageTypeID),

    CONSTRAINT FK_StockItems_OuterPackage
        FOREIGN KEY (OuterPackageID)
        REFERENCES Warehouse.PackageTypes(PackageTypeID)
);
GO
