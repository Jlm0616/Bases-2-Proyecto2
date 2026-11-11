-- ============================================
-- 12_Migrar_Pedidos_SanJose.sql
-- ============================================

USE WWI_SanJose;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    ALTER TABLE Sales.Orders
        NOCHECK CONSTRAINT FK_Orders_Backorder;

    INSERT INTO Sales.Orders (
        OrderID, SucursalID, CustomerID,
        SalespersonPersonID, PickedByPersonID,
        ContactPersonID, BackorderOrderID,
        OrderDate, ExpectedDeliveryDate,
        CustomerPurchaseOrderNumber,
        IsUndersupplyBackordered, Comments,
        DeliveryInstructions, InternalComments,
        PickingCompletedWhen, LastEditedBy,
        LastEditedWhen
    )
    SELECT
        OrderID, 0, CustomerID,
        SalespersonPersonID, PickedByPersonID,
        ContactPersonID, BackorderOrderID,
        OrderDate, ExpectedDeliveryDate,
        CustomerPurchaseOrderNumber,
        IsUndersupplyBackordered, Comments,
        DeliveryInstructions, InternalComments,
        PickingCompletedWhen, LastEditedBy,
        LastEditedWhen
    FROM WideWorldImporters.Sales.Orders;

    ALTER TABLE Sales.Orders
        WITH CHECK CHECK CONSTRAINT FK_Orders_Backorder;

    INSERT INTO Sales.OrderLines (
        OrderLineID, OrderID, StockItemID,
        Description, PackageTypeID, Quantity,
        UnitPrice, TaxRate, PickedQuantity,
        PickingCompletedWhen, LastEditedBy,
        LastEditedWhen, SucursalID
    )
    SELECT
        OrderLineID, OrderID, StockItemID,
        Description, PackageTypeID, Quantity,
        UnitPrice, TaxRate, PickedQuantity,
        PickingCompletedWhen, LastEditedBy,
        LastEditedWhen, 0
    FROM WideWorldImporters.Sales.OrderLines;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
