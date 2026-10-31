
-- ============================================
-- 09_Migrar_Clientes_Proveedores_Limon.sql
-- ============================================

USE WWI_Limon;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Migrar proveedores generales.
    INSERT INTO Purchasing.Suppliers (
        SupplierID,
        SupplierName,
        SupplierCategoryID,
        SupplierReference,
        PaymentDays,
        LastEditedBy,
        ValidFrom,
        ValidTo
    )
    SELECT
        SupplierID,
        SupplierName,
        SupplierCategoryID,
        SupplierReference,
        PaymentDays,
        LastEditedBy,
        ValidFrom,
        ValidTo
    FROM WideWorldImporters.Purchasing.Suppliers;

    -- Desactivar temporalmente la relacion entre clientes.
    ALTER TABLE Sales.Customers
    NOCHECK CONSTRAINT FK_Customers_BillToCustomer;

    -- Migrar clientes generales.
    INSERT INTO Sales.Customers (
        CustomerID,
        CustomerName,
        BillToCustomerID,
        CustomerCategoryID,
        BuyingGroupID,
        AccountOpenedDate,
        StandardDiscountPercentage,
        IsStatementSent,
        IsOnCreditHold,
        PaymentDays,
        LastEditedBy,
        ValidFrom,
        ValidTo
    )
    SELECT
        CustomerID,
        CustomerName,
        BillToCustomerID,
        CustomerCategoryID,
        BuyingGroupID,
        AccountOpenedDate,
        StandardDiscountPercentage,
        IsStatementSent,
        IsOnCreditHold,
        PaymentDays,
        LastEditedBy,
        ValidFrom,
        ValidTo
    FROM WideWorldImporters.Sales.Customers;

    -- Reactivar y validar la clave foranea.
    ALTER TABLE Sales.Customers
    WITH CHECK CHECK CONSTRAINT FK_Customers_BillToCustomer;

    COMMIT TRANSACTION;

    PRINT 'Clientes y proveedores migrados correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
