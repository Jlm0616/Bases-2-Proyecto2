
-- ============================================
-- 11_Migrar_Productos_Corporativo.sql
-- ============================================

USE WWI_Corporativo;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- ============================================
    -- 1. MIGRAR PRODUCTOS
    -- ============================================

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

    -- ============================================
    -- 2. VALIDAR CANTIDAD
    -- ============================================

    IF (
        SELECT COUNT(*)
        FROM Warehouse.StockItems
    ) <> (
        SELECT COUNT(*)
        FROM WideWorldImporters.Warehouse.StockItems
    )
    BEGIN
        THROW 50002,
            'La cantidad de productos no coincide.',
            1;
    END;

    COMMIT TRANSACTION;

    PRINT 'Migracion de productos completada correctamente.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
