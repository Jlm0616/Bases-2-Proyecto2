-- ============================================
-- 13_Crear_Tablas_Inventario_Corporativo.sql
-- ============================================

-- 1. Seleccionar la base de datos corporativa
USE WWI_Corporativo;
GO

-- 2. Crear la tabla receptora del inventario de San José
IF OBJECT_ID(N'Warehouse.InventarioSanJose', N'U') IS NULL
BEGIN
    CREATE TABLE Warehouse.InventarioSanJose
    (
        StockItemID int NOT NULL,
        QuantityOnHand int NOT NULL,
        BinLocation nvarchar(20) NOT NULL,
        LastStocktakeQuantity int NOT NULL,
        LastCostPrice decimal(18,2) NOT NULL,
        ReorderLevel int NOT NULL,
        TargetStockLevel int NOT NULL,
        LastEditedBy int NOT NULL,
        LastEditedWhen datetime2(7) NOT NULL,

        CONSTRAINT PK_InventarioSanJose
            PRIMARY KEY (StockItemID)
    );
END;
GO

-- 3. Crear la tabla receptora del inventario de Limón
IF OBJECT_ID(N'Warehouse.InventarioLimon', N'U') IS NULL
BEGIN
    CREATE TABLE Warehouse.InventarioLimon
    (
        StockItemID int NOT NULL,
        QuantityOnHand int NOT NULL,
        BinLocation nvarchar(20) NOT NULL,
        LastStocktakeQuantity int NOT NULL,
        LastCostPrice decimal(18,2) NOT NULL,
        ReorderLevel int NOT NULL,
        TargetStockLevel int NOT NULL,
        LastEditedBy int NOT NULL,
        LastEditedWhen datetime2(7) NOT NULL,

        CONSTRAINT PK_InventarioLimon
            PRIMARY KEY (StockItemID)
    );
END;
GO
