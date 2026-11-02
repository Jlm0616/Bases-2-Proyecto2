
-- ============================================
-- 09_Migrar_Catalogos_Corporativo.sql
-- ============================================

USE WWI_Corporativo;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- ============================================
    -- 1. COUNTRIES
    -- ============================================

    INSERT INTO Application.Countries (
        CountryID, CountryName, FormalName,
        IsoAlpha3Code, IsoNumericCode, CountryType,
        LatestRecordedPopulation, Continent,
        Region, Subregion, Border,
        LastEditedBy, ValidFrom, ValidTo
    )
    SELECT
        CountryID, CountryName, FormalName,
        IsoAlpha3Code, IsoNumericCode, CountryType,
        LatestRecordedPopulation, Continent,
        Region, Subregion, Border,
        LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.Countries;

    -- ============================================
    -- 2. STATE PROVINCES
    -- ============================================

    INSERT INTO Application.StateProvinces (
        StateProvinceID, StateProvinceCode,
        StateProvinceName, CountryID,
        SalesTerritory, Border,
        LatestRecordedPopulation,
        LastEditedBy, ValidFrom, ValidTo
    )
    SELECT
        StateProvinceID, StateProvinceCode,
        StateProvinceName, CountryID,
        SalesTerritory, Border,
        LatestRecordedPopulation,
        LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.StateProvinces;

    -- ============================================
    -- 3. CITIES
    -- ============================================

    INSERT INTO Application.Cities (
        CityID, CityName, StateProvinceID,
        Location, LatestRecordedPopulation,
        LastEditedBy, ValidFrom, ValidTo
    )
    SELECT
        CityID, CityName, StateProvinceID,
        Location, LatestRecordedPopulation,
        LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.Cities;

    -- ============================================
    -- 4. DELIVERY METHODS
    -- ============================================

    INSERT INTO Application.DeliveryMethods (
        DeliveryMethodID, DeliveryMethodName,
        LastEditedBy, ValidFrom, ValidTo
    )
    SELECT
        DeliveryMethodID, DeliveryMethodName,
        LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.DeliveryMethods;

    -- ============================================
    -- 5. SUPPLIER CATEGORIES
    -- ============================================

    INSERT INTO Purchasing.SupplierCategories (
        SupplierCategoryID, SupplierCategoryName,
        LastEditedBy, ValidFrom, ValidTo
    )
    SELECT
        SupplierCategoryID, SupplierCategoryName,
        LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Purchasing.SupplierCategories;

    -- ============================================
    -- 6. BUYING GROUPS
    -- ============================================

    INSERT INTO Sales.BuyingGroups (
        BuyingGroupID, BuyingGroupName,
        LastEditedBy, ValidFrom, ValidTo
    )
    SELECT
        BuyingGroupID, BuyingGroupName,
        LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Sales.BuyingGroups;

    -- ============================================
    -- 7. CUSTOMER CATEGORIES
    -- ============================================

    INSERT INTO Sales.CustomerCategories (
        CustomerCategoryID, CustomerCategoryName,
        LastEditedBy, ValidFrom, ValidTo
    )
    SELECT
        CustomerCategoryID, CustomerCategoryName,
        LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Sales.CustomerCategories;

    -- ============================================
    -- 8. COLORS
    -- ============================================

    INSERT INTO Warehouse.Colors (
        ColorID, ColorName,
        LastEditedBy, ValidFrom, ValidTo
    )
    SELECT
        ColorID, ColorName,
        LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Warehouse.Colors;

    -- ============================================
    -- 9. PACKAGE TYPES
    -- ============================================

    INSERT INTO Warehouse.PackageTypes (
        PackageTypeID, PackageTypeName,
        LastEditedBy, ValidFrom, ValidTo
    )
    SELECT
        PackageTypeID, PackageTypeName,
        LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Warehouse.PackageTypes;

    -- ============================================
    -- 10. STOCK GROUPS
    -- ============================================

    INSERT INTO Warehouse.StockGroups (
        StockGroupID, StockGroupName,
        LastEditedBy, ValidFrom, ValidTo
    )
    SELECT
        StockGroupID, StockGroupName,
        LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Warehouse.StockGroups;

    -- ============================================
    -- 11. VALIDAR CANTIDADES
    -- ============================================

    IF
        (SELECT COUNT(*) FROM Application.Countries) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Application.Countries)
        OR
        (SELECT COUNT(*) FROM Application.StateProvinces) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Application.StateProvinces)
        OR
        (SELECT COUNT(*) FROM Application.Cities) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Application.Cities)
        OR
        (SELECT COUNT(*) FROM Application.DeliveryMethods) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Application.DeliveryMethods)
        OR
        (SELECT COUNT(*) FROM Purchasing.SupplierCategories) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Purchasing.SupplierCategories)
        OR
        (SELECT COUNT(*) FROM Sales.BuyingGroups) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Sales.BuyingGroups)
        OR
        (SELECT COUNT(*) FROM Sales.CustomerCategories) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Sales.CustomerCategories)
        OR
        (SELECT COUNT(*) FROM Warehouse.Colors) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Warehouse.Colors)
        OR
        (SELECT COUNT(*) FROM Warehouse.PackageTypes) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Warehouse.PackageTypes)
        OR
        (SELECT COUNT(*) FROM Warehouse.StockGroups) <>
        (SELECT COUNT(*) FROM WideWorldImporters.Warehouse.StockGroups)
    BEGIN
        THROW 50001, 'Error: las cantidades no coinciden.', 1;
    END;

    COMMIT TRANSACTION;

    PRINT 'Migracion de catalogos completada correctamente.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

-- ============================================
-- 12. VERIFICAR RESULTADOS
-- ============================================

SELECT 'Countries' AS Tabla, COUNT(*) AS Registros
FROM Application.Countries
UNION ALL
SELECT 'StateProvinces', COUNT(*)
FROM Application.StateProvinces
UNION ALL
SELECT 'Cities', COUNT(*)
FROM Application.Cities
UNION ALL
SELECT 'DeliveryMethods', COUNT(*)
FROM Application.DeliveryMethods
UNION ALL
SELECT 'SupplierCategories', COUNT(*)
FROM Purchasing.SupplierCategories
UNION ALL
SELECT 'BuyingGroups', COUNT(*)
FROM Sales.BuyingGroups
UNION ALL
SELECT 'CustomerCategories', COUNT(*)
FROM Sales.CustomerCategories
UNION ALL
SELECT 'Colors', COUNT(*)
FROM Warehouse.Colors
UNION ALL
SELECT 'PackageTypes', COUNT(*)
FROM Warehouse.PackageTypes
UNION ALL
SELECT 'StockGroups', COUNT(*)
FROM Warehouse.StockGroups;
GO
