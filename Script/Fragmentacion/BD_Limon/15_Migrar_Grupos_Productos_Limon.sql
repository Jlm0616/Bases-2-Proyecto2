
USE WWI_Limon;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- ========================================================
    -- MIGRAR GRUPOS DE PRODUCTOS
    -- ========================================================

    INSERT INTO Warehouse.StockGroups (
        StockGroupID,
        StockGroupName,
        LastEditedBy,
        ValidFrom,
        ValidTo
    )
    SELECT
        StockGroupID,
        StockGroupName,
        LastEditedBy,
        ValidFrom,
        ValidTo
    FROM WideWorldImporters.Warehouse.StockGroups;

    -- ========================================================
    -- MIGRAR RELACIONES PRODUCTO - GRUPO
    -- ========================================================

    INSERT INTO Warehouse.StockItemStockGroups (
        StockItemStockGroupID,
        StockItemID,
        StockGroupID,
        LastEditedBy,
        LastEditedWhen
    )
    SELECT
        StockItemStockGroupID,
        StockItemID,
        StockGroupID,
        LastEditedBy,
        LastEditedWhen
    FROM WideWorldImporters.Warehouse.StockItemStockGroups;

    COMMIT TRANSACTION;

    PRINT 'Migracion de grupos de productos completada.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

-- ============================================================
-- VERIFICAR MIGRACION
-- ============================================================

SELECT
    'StockGroups' AS Tabla,
    (SELECT COUNT(*)
     FROM WideWorldImporters.Warehouse.StockGroups) AS Origen,
    (SELECT COUNT(*)
     FROM Warehouse.StockGroups) AS Destino

UNION ALL

SELECT
    'StockItemStockGroups',
    (SELECT COUNT(*)
     FROM WideWorldImporters.Warehouse.StockItemStockGroups),
    (SELECT COUNT(*)
     FROM Warehouse.StockItemStockGroups);
GO
