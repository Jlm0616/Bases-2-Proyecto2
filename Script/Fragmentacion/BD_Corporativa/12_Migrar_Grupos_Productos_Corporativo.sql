-- ============================================
-- 12_Migrar_Grupos_Productos_Corporativo.sql
-- ============================================

USE WWI_Corporativo;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- ============================================
    -- 1. MIGRAR RELACIONES PRODUCTO-GRUPO
    -- ============================================

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

    -- ============================================
    -- 2. VALIDAR CANTIDAD
    -- ============================================

    IF (
        SELECT COUNT(*)
        FROM Warehouse.StockItemStockGroups
    ) <> (
        SELECT COUNT(*)
        FROM WideWorldImporters.Warehouse.StockItemStockGroups
    )
    BEGIN
        THROW 50002,
            'La cantidad de relaciones no coincide.',
            1;
    END;

    COMMIT TRANSACTION;

    PRINT 'Migracion de relaciones producto-grupo completada.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
