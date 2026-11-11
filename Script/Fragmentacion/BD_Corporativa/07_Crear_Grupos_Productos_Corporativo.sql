-- ============================================
-- 07_Crear_Grupos_Productos_Corporativo.sql
-- ============================================

USE WWI_Corporativo;
GO

-- ============================================
-- 1. RELACION PRODUCTOS Y GRUPOS
-- ============================================

CREATE TABLE Warehouse.StockItemStockGroups (
    StockItemStockGroupID INT NOT NULL PRIMARY KEY,
    StockItemID INT NOT NULL,
    StockGroupID INT NOT NULL,
    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,

    -- Relaciones
    CONSTRAINT FK_StockItemStockGroups_StockItems
        FOREIGN KEY (StockItemID)
        REFERENCES Warehouse.StockItems(StockItemID),

    CONSTRAINT FK_StockItemStockGroups_StockGroups
        FOREIGN KEY (StockGroupID)
        REFERENCES Warehouse.StockGroups(StockGroupID)
);
GO
