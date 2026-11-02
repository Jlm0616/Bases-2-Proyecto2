
-- ============================================
-- 10_Migrar_Productos_SanJose.sql
-- ============================================

USE WWI_SanJose;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Migrar el catalogo de productos.
    INSERT INTO Warehouse.StockItems (
        StockItemID,
        StockItemName,
        SupplierID,
        ColorID,
        UnitPackageID,
        OuterPackageID,
        Brand,
        Size,
        LeadTimeDays,
        QuantityPerOuter,
        IsChillerStock,
        Barcode,
        TaxRate,
        UnitPrice,
        RecommendedRetailPrice,
        TypicalWeightPerUnit,
        MarketingComments,
        InternalComments,
        Photo,
        CustomFields,
        LastEditedBy,
        ValidFrom,
        ValidTo
    )
    SELECT
        StockItemID,
        StockItemName,
        SupplierID,
        ColorID,
        UnitPackageID,
        OuterPackageID,
        Brand,
        Size,
        LeadTimeDays,
        QuantityPerOuter,
        IsChillerStock,
        Barcode,
        TaxRate,
        UnitPrice,
        RecommendedRetailPrice,
        TypicalWeightPerUnit,
        MarketingComments,
        InternalComments,
        Photo,
        CustomFields,
        LastEditedBy,
        ValidFrom,
        ValidTo
    FROM WideWorldImporters.Warehouse.StockItems;

    COMMIT TRANSACTION;

    PRINT 'Productos migrados correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
