-- ============================================
-- 08_Migrar_Catalogos_SanJose.sql
-- ============================================

USE WWI_SanJose;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

-- ============================================
-- Catálogos auxiliares
-- ============================================

-- Categorías de proveedores.
INSERT INTO Purchasing.SupplierCategories (
    SupplierCategoryID,
    SupplierCategoryName,
    LastEditedBy,
    ValidFrom,
    ValidTo
)
SELECT
    SupplierCategoryID,
    SupplierCategoryName,
    LastEditedBy,
    ValidFrom,
    ValidTo
FROM WideWorldImporters.Purchasing.SupplierCategories;

-- Grupos de compra.
INSERT INTO Sales.BuyingGroups (
    BuyingGroupID,
    BuyingGroupName,
    LastEditedBy,
    ValidFrom,
    ValidTo
)
SELECT
    BuyingGroupID,
    BuyingGroupName,
    LastEditedBy,
    ValidFrom,
    ValidTo
FROM WideWorldImporters.Sales.BuyingGroups;

-- Categorías de clientes.
INSERT INTO Sales.CustomerCategories (
    CustomerCategoryID,
    CustomerCategoryName,
    LastEditedBy,
    ValidFrom,
    ValidTo
)
SELECT
    CustomerCategoryID,
    CustomerCategoryName,
    LastEditedBy,
    ValidFrom,
    ValidTo
FROM WideWorldImporters.Sales.CustomerCategories;

-- Colores.
INSERT INTO Warehouse.Colors (
    ColorID,
    ColorName,
    LastEditedBy,
    ValidFrom,
    ValidTo
)
SELECT
    ColorID,
    ColorName,
    LastEditedBy,
    ValidFrom,
    ValidTo
FROM WideWorldImporters.Warehouse.Colors;

-- Tipos de empaque.
INSERT INTO Warehouse.PackageTypes (
    PackageTypeID,
    PackageTypeName,
    LastEditedBy,
    ValidFrom,
    ValidTo
)
SELECT
    PackageTypeID,
    PackageTypeName,
    LastEditedBy,
    ValidFrom,
    ValidTo
FROM WideWorldImporters.Warehouse.PackageTypes;

-- ============================================
-- Catálogos globales de Application
-- ============================================

-- Países
INSERT INTO Application.Countries (
    CountryID, CountryName, FormalName, IsoAlpha3Code, IsoNumericCode,
    CountryType, LatestRecordedPopulation, Continent, Region, Subregion,
    Border, LastEditedBy, ValidFrom, ValidTo
)
SELECT
    CountryID, CountryName, FormalName, IsoAlpha3Code, IsoNumericCode,
    CountryType, LatestRecordedPopulation, Continent, Region, Subregion,
    Border, LastEditedBy, ValidFrom, ValidTo
FROM WideWorldImporters.Application.Countries;

-- Provincias y estados
INSERT INTO Application.StateProvinces (
    StateProvinceID, StateProvinceCode, StateProvinceName, CountryID,
    SalesTerritory, Border, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo
)
SELECT
    StateProvinceID, StateProvinceCode, StateProvinceName, CountryID,
    SalesTerritory, Border, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo
FROM WideWorldImporters.Application.StateProvinces;

-- Ciudades
INSERT INTO Application.Cities (
    CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation,
    LastEditedBy, ValidFrom, ValidTo
)
SELECT
    CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation,
    LastEditedBy, ValidFrom, ValidTo
FROM WideWorldImporters.Application.Cities;

-- Métodos de entrega
INSERT INTO Application.DeliveryMethods (
    DeliveryMethodID, DeliveryMethodName, LastEditedBy, ValidFrom, ValidTo
)
SELECT
    DeliveryMethodID, DeliveryMethodName, LastEditedBy, ValidFrom, ValidTo
FROM WideWorldImporters.Application.DeliveryMethods;

-- Personas. SearchName se calcula porque es una columna normal en el destino.
INSERT INTO Application.People (
    PersonID, FullName, PreferredName, SearchName, IsSystemUser,
    IsEmployee, IsSalesperson, LastEditedBy, ValidFrom, ValidTo
)
SELECT
    PersonID, FullName, PreferredName,
    CONCAT(PreferredName, ' ', FullName),
    IsSystemUser, IsEmployee, IsSalesperson, LastEditedBy, ValidFrom, ValidTo
FROM WideWorldImporters.Application.People;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
