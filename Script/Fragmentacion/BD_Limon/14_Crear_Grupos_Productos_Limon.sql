
USE WWI_Limon;
GO

-- ============================================================
-- CREAR GRUPOS DE PRODUCTOS
-- ============================================================

CREATE TABLE Warehouse.StockGroups (
    StockGroupID INT NOT NULL,
    StockGroupName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL,

    CONSTRAINT PK_StockGroups
        PRIMARY KEY (StockGroupID),

    CONSTRAINT FK_StockGroups_People
        FOREIGN KEY (LastEditedBy)
        REFERENCES Application.People(PersonID)
);
GO

-- ============================================================
-- CREAR RELACION PRODUCTO - GRUPO
-- ============================================================

CREATE TABLE Warehouse.StockItemStockGroups (
    StockItemStockGroupID INT NOT NULL,
    StockItemID INT NOT NULL,
    StockGroupID INT NOT NULL,
    LastEditedBy INT NOT NULL,
    LastEditedWhen DATETIME2(7) NOT NULL,

    CONSTRAINT PK_StockItemStockGroups
        PRIMARY KEY (StockItemStockGroupID),

    CONSTRAINT FK_StockItemStockGroups_StockItems
        FOREIGN KEY (StockItemID)
        REFERENCES Warehouse.StockItems(StockItemID),

    CONSTRAINT FK_StockItemStockGroups_StockGroups
        FOREIGN KEY (StockGroupID)
        REFERENCES Warehouse.StockGroups(StockGroupID),

    CONSTRAINT FK_StockItemStockGroups_People
        FOREIGN KEY (LastEditedBy)
        REFERENCES Application.People(PersonID)
);
GO
