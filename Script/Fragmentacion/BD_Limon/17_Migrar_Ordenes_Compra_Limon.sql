
USE WWI_Limon;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- ========================================================
    -- MIGRAR ORDENES DE COMPRA HISTORICAS
    -- ========================================================

    INSERT INTO Purchasing.PurchaseOrders (
        PurchaseOrderID,
        SupplierID,
        OrderDate,
        DeliveryMethodID,
        ContactPersonID,
        ExpectedDeliveryDate,
        SupplierReference,
        IsOrderFinalized,
        Comments,
        InternalComments,
        LastEditedBy,
        LastEditedWhen,
        SucursalID
    )
    SELECT
        PurchaseOrderID,
        SupplierID,
        OrderDate,
        DeliveryMethodID,
        ContactPersonID,
        ExpectedDeliveryDate,
        SupplierReference,
        IsOrderFinalized,
        Comments,
        InternalComments,
        LastEditedBy,
        LastEditedWhen,
        0
    FROM WideWorldImporters.Purchasing.PurchaseOrders;

    -- ========================================================
    -- MIGRAR LINEAS DE ORDENES DE COMPRA
    -- ========================================================

    INSERT INTO Purchasing.PurchaseOrderLines (
        PurchaseOrderLineID,
        PurchaseOrderID,
        StockItemID,
        OrderedOuters,
        Description,
        ReceivedOuters,
        PackageTypeID,
        ExpectedUnitPricePerOuter,
        LastReceiptDate,
        IsOrderLineFinalized,
        LastEditedBy,
        LastEditedWhen
    )
    SELECT
        PurchaseOrderLineID,
        PurchaseOrderID,
        StockItemID,
        OrderedOuters,
        Description,
        ReceivedOuters,
        PackageTypeID,
        ExpectedUnitPricePerOuter,
        LastReceiptDate,
        IsOrderLineFinalized,
        LastEditedBy,
        LastEditedWhen
    FROM WideWorldImporters.Purchasing.PurchaseOrderLines;

    COMMIT TRANSACTION;

    PRINT 'Migracion de ordenes de compra completada.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

-- ============================================================
-- VERIFICAR CANTIDADES
-- ============================================================

SELECT
    'PurchaseOrders' AS Tabla,
    (SELECT COUNT(*)
     FROM WideWorldImporters.Purchasing.PurchaseOrders) AS Origen,
    (SELECT COUNT(*)
     FROM Purchasing.PurchaseOrders) AS Destino

UNION ALL

SELECT
    'PurchaseOrderLines',
    (SELECT COUNT(*)
     FROM WideWorldImporters.Purchasing.PurchaseOrderLines),
    (SELECT COUNT(*)
     FROM Purchasing.PurchaseOrderLines);
GO

-- ============================================================
-- VERIFICAR SUCURSAL HISTORICA
-- ============================================================

SELECT
    SucursalID,
    COUNT(*) AS Total
FROM Purchasing.PurchaseOrders
GROUP BY SucursalID;
GO

-- ============================================================
-- VERIFICAR LINEAS HUERFANAS
-- ============================================================

SELECT
    COUNT(*) AS LineasHuerfanas
FROM Purchasing.PurchaseOrderLines pol
LEFT JOIN Purchasing.PurchaseOrders po
    ON pol.PurchaseOrderID = po.PurchaseOrderID
WHERE po.PurchaseOrderID IS NULL;
GO
