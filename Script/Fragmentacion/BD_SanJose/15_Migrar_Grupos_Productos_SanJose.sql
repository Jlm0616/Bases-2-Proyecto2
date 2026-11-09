USE WWI_SanJose;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- ========================================================
    -- MIGRAR STOCKGROUPS
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
    -- MIGRAR STOCKITEMSTOCKGROUPS
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

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO