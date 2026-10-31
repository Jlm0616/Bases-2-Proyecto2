
-- ============================================
-- 13_Migrar_Facturas_SanJose.sql
-- ============================================

USE WWI_SanJose;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Sales.Invoices (
        InvoiceID,
        SucursalID,
        CustomerID,
        BillToCustomerID,
        OrderID,
        DeliveryMethodID,
        ContactPersonID,
        AccountsPersonID,
        SalespersonPersonID,
        PackedByPersonID,
        InvoiceDate,
        CustomerPurchaseOrderNumber,
        IsCreditNote,
        CreditNoteReason,
        Comments,
        DeliveryInstructions,
        InternalComments,
        TotalDryItems,
        TotalChillerItems,
        DeliveryRun,
        RunPosition,
        ReturnedDeliveryData,
        LastEditedBy,
        LastEditedWhen
    )
    SELECT
        InvoiceID,
        0,
        CustomerID,
        BillToCustomerID,
        OrderID,
        DeliveryMethodID,
        ContactPersonID,
        AccountsPersonID,
        SalespersonPersonID,
        PackedByPersonID,
        InvoiceDate,
        CustomerPurchaseOrderNumber,
        IsCreditNote,
        CreditNoteReason,
        Comments,
        DeliveryInstructions,
        InternalComments,
        TotalDryItems,
        TotalChillerItems,
        DeliveryRun,
        RunPosition,
        ReturnedDeliveryData,
        LastEditedBy,
        LastEditedWhen
    FROM WideWorldImporters.Sales.Invoices;

    INSERT INTO Sales.InvoiceLines (
        InvoiceLineID,
        InvoiceID,
        StockItemID,
        Description,
        PackageTypeID,
        Quantity,
        UnitPrice,
        TaxRate,
        TaxAmount,
        LineProfit,
        ExtendedPrice,
        LastEditedBy,
        LastEditedWhen
    )
    SELECT
        InvoiceLineID,
        InvoiceID,
        StockItemID,
        Description,
        PackageTypeID,
        Quantity,
        UnitPrice,
        TaxRate,
        TaxAmount,
        LineProfit,
        ExtendedPrice,
        LastEditedBy,
        LastEditedWhen
    FROM WideWorldImporters.Sales.InvoiceLines;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
