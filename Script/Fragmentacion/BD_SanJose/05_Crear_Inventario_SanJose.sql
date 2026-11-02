
-- ============================================
-- 05_Crear_Inventario_SanJose.sql
-- ============================================

USE WWI_SanJose;
GO

-- 1. INVENTARIO
CREATE TABLE Warehouse.StockItemHoldings (
    StockItemID INT NOT NULL PRIMARY KEY,
    QuantityOnHand INT NOT NULL,
    BinLocation NVARCHAR(20) NOT NULL,
    LastStocktakeQuantity INT NOT NULL,
    LastCostPrice DECIMAL(18,2) NOT NULL,
    ReorderLevel INT NOT NULL,
    TargetStockLevel INT NOT NULL,
    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,

    CONSTRAINT FK_StockItemHoldings_StockItems
        FOREIGN KEY (StockItemID)
        REFERENCES Warehouse.StockItems(StockItemID)
);
GO
