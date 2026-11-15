-- ============================================
-- 17_Migrar_Ordenes_Compra_SanJose.sql
-- ============================================

USE WWI_SanJose;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Purchasing.PurchaseOrders (
        PurchaseOrderID, SupplierID,
        OrderDate, DeliveryMethodID,
        ContactPersonID, ExpectedDeliveryDate,
        SupplierReference, IsOrderFinalized,
        Comments, InternalComments,
        LastEditedBy, LastEditedWhen,
        SucursalID
    )
    SELECT
        PurchaseOrderID, SupplierID,
        OrderDate, DeliveryMethodID,
        ContactPersonID, ExpectedDeliveryDate,
        SupplierReference, IsOrderFinalized,
        Comments, InternalComments,
        LastEditedBy, LastEditedWhen, 0
    FROM WideWorldImporters.Purchasing.PurchaseOrders;

    INSERT INTO Purchasing.PurchaseOrderLines (
        PurchaseOrderLineID, PurchaseOrderID,
        StockItemID, OrderedOuters,
        Description, ReceivedOuters,
        PackageTypeID, ExpectedUnitPricePerOuter,
        LastReceiptDate, IsOrderLineFinalized,
        LastEditedBy, LastEditedWhen,
        SucursalID
    )
    SELECT
        PurchaseOrderLineID, PurchaseOrderID,
        StockItemID, OrderedOuters,
        Description, ReceivedOuters,
        PackageTypeID, ExpectedUnitPricePerOuter,
        LastReceiptDate, IsOrderLineFinalized,
        LastEditedBy, LastEditedWhen, 0
    FROM WideWorldImporters.Purchasing.PurchaseOrderLines;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
