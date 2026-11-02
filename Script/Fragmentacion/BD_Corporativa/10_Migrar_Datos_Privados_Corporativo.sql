
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
    -- 1. VERIFICAR TABLAS VACIAS
    -- ============================================

    IF EXISTS (SELECT 1 FROM Application.PeoplePrivate)
       OR EXISTS (SELECT 1 FROM Sales.CustomersPrivate)
       OR EXISTS (SELECT 1 FROM Purchasing.SuppliersPrivate)
    BEGIN
        THROW 50001,
            'Las tablas de destino deben estar vacias.',
            1;
    END;

    -- ============================================
    -- 2. MIGRAR PERSONAS
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
    -- 3. MIGRAR CLIENTES
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
    -- 4. MIGRAR PROVEEDORES
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
    -- 5. VALIDAR CANTIDADES
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

-- ============================================
-- 6. VERIFICAR RESULTADOS
-- ============================================

SELECT
    'PeoplePrivate' AS Tabla,
    COUNT(*) AS Registros
FROM Application.PeoplePrivate

UNION ALL

SELECT
    'CustomersPrivate',
    COUNT(*)
FROM Sales.CustomersPrivate

UNION ALL

SELECT
    'SuppliersPrivate',
    COUNT(*)
FROM Purchasing.SuppliersPrivate;
GO
