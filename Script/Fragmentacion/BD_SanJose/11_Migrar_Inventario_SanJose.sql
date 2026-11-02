
-- ============================================
-- 11_Migrar_Inventario_SanJose.sql
-- ============================================

USE WWI_SanJose;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Migrar la mitad del inventario a San Jose.
    INSERT INTO Warehouse.StockItemHoldings (
        StockItemID,
        QuantityOnHand,
        BinLocation,
        LastStocktakeQuantity,
        LastCostPrice,
        ReorderLevel,
        TargetStockLevel,
        LastEditedBy,
        LastEditedWhen
    )
    SELECT
        StockItemID,
        QuantityOnHand / 2,
        BinLocation,
        LastStocktakeQuantity / 2,
        LastCostPrice,
        ReorderLevel,
        TargetStockLevel,
        LastEditedBy,
        LastEditedWhen
    FROM WideWorldImporters.Warehouse.StockItemHoldings;

    COMMIT TRANSACTION;

    PRINT 'Inventario de San Jose migrado correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
