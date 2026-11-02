
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
    -- 1. VERIFICAR TABLA VACIA
    -- ============================================

    IF EXISTS (
        SELECT 1
        FROM Warehouse.StockItemStockGroups
    )
    BEGIN
        THROW 50001,
            'La tabla de destino debe estar vacia.',
            1;
    END;

    -- ============================================
    -- 2. MIGRAR RELACIONES PRODUCTO-GRUPO
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
    -- 3. VALIDAR CANTIDAD
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

-- ============================================
-- 4. VERIFICAR RESULTADOS
-- ============================================

SELECT
    'Warehouse.StockItemStockGroups' AS Tabla,
    (SELECT COUNT(*)
     FROM WideWorldImporters.Warehouse.StockItemStockGroups) AS Origen,
    (SELECT COUNT(*)
     FROM Warehouse.StockItemStockGroups) AS Destino;
GO
