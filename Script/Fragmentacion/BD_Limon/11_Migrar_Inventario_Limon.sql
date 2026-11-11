-- ============================================
-- 11_Migrar_Inventario_Limon.sql
-- ============================================

USE WWI_Limon;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Migrar el inventario restante a Limon.

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
        QuantityOnHand - (QuantityOnHand / 2),
        BinLocation,
        LastStocktakeQuantity - (LastStocktakeQuantity / 2),
        LastCostPrice,
        ReorderLevel,
        TargetStockLevel,
        LastEditedBy,
        LastEditedWhen
    FROM WideWorldImporters.Warehouse.StockItemHoldings;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
