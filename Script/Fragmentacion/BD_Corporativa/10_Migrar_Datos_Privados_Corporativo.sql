-- ============================================
-- 10_Migrar_Datos_Privados_Corporativo.sql
-- ============================================

USE WWI_Corporativo;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- ============================================
    -- 1. MIGRAR PERSONAS
    -- ============================================

    INSERT INTO Application.PeoplePrivate (
        PersonID,
        PhoneNumber,
        FaxNumber,
        EmailAddress,
        LogonName,
        IsPermittedToLogon,
        IsExternalLogonProvider,
        HashedPassword,
        UserPreferences,
        OtherLanguages,
        Photo,
        CustomFields
    )
    SELECT
        PersonID,
        PhoneNumber,
        FaxNumber,
        EmailAddress,
        LogonName,
        IsPermittedToLogon,
        IsExternalLogonProvider,
        HashedPassword,
        UserPreferences,
        OtherLanguages,
        Photo,
        CustomFields
    FROM WideWorldImporters.Application.People;

    -- ============================================
    -- 2. MIGRAR CLIENTES
    -- ============================================

    INSERT INTO Sales.CustomersPrivate (
        CustomerID,
        PrimaryContactPersonID,
        AlternateContactPersonID,
        CreditLimit,
        PhoneNumber,
        FaxNumber,
        WebsiteURL,
        DeliveryMethodID,
        DeliveryCityID,
        DeliveryAddressLine1,
        DeliveryAddressLine2,
        DeliveryPostalCode,
        DeliveryLocation,
        DeliveryRun,
        RunPosition,
        PostalCityID,
        PostalAddressLine1,
        PostalAddressLine2,
        PostalPostalCode
    )
    SELECT
        CustomerID,
        PrimaryContactPersonID,
        AlternateContactPersonID,
        CreditLimit,
        PhoneNumber,
        FaxNumber,
        WebsiteURL,
        DeliveryMethodID,
        DeliveryCityID,
        DeliveryAddressLine1,
        DeliveryAddressLine2,
        DeliveryPostalCode,
        DeliveryLocation,
        DeliveryRun,
        RunPosition,
        PostalCityID,
        PostalAddressLine1,
        PostalAddressLine2,
        PostalPostalCode
    FROM WideWorldImporters.Sales.Customers;

    -- ============================================
    -- 3. MIGRAR PROVEEDORES
    -- ============================================

    INSERT INTO Purchasing.SuppliersPrivate (
        SupplierID,
        PrimaryContactPersonID,
        AlternateContactPersonID,
        DeliveryMethodID,
        DeliveryCityID,
        PostalCityID,
        BankAccountName,
        BankAccountBranch,
        BankAccountCode,
        BankAccountNumber,
        BankInternationalCode,
        InternalComments,
        PhoneNumber,
        FaxNumber,
        WebsiteURL,
        DeliveryAddressLine1,
        DeliveryAddressLine2,
        DeliveryPostalCode,
        DeliveryLocation,
        PostalAddressLine1,
        PostalAddressLine2,
        PostalPostalCode
    )
    SELECT
        SupplierID,
        PrimaryContactPersonID,
        AlternateContactPersonID,
        DeliveryMethodID,
        DeliveryCityID,
        PostalCityID,
        BankAccountName,
        BankAccountBranch,
        BankAccountCode,
        BankAccountNumber,
        BankInternationalCode,
        InternalComments,
        PhoneNumber,
        FaxNumber,
        WebsiteURL,
        DeliveryAddressLine1,
        DeliveryAddressLine2,
        DeliveryPostalCode,
        DeliveryLocation,
        PostalAddressLine1,
        PostalAddressLine2,
        PostalPostalCode
    FROM WideWorldImporters.Purchasing.Suppliers;

    -- ============================================
    -- 4. VALIDAR CANTIDADES
    -- ============================================

    IF
        (SELECT COUNT(*) FROM Application.PeoplePrivate) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Application.People)
        OR
        (SELECT COUNT(*) FROM Sales.CustomersPrivate) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Sales.Customers)
        OR
        (SELECT COUNT(*) FROM Purchasing.SuppliersPrivate) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Purchasing.Suppliers)
    BEGIN
        THROW 50002,
            'Las cantidades de origen y destino no coinciden.',
            1;
    END;

    COMMIT TRANSACTION;

    PRINT 'Migracion de datos privados completada correctamente.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
