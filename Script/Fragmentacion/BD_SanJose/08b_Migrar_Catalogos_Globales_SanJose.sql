-- ============================================
-- 08b_Migrar_Catalogos_Globales_SanJose.sql
-- Proyecto 2 - Bases de Datos II
-- Migra People, Cities, StateProvinces, Countries y DeliveryMethods
-- ============================================

USE WWI_SanJose;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Migrar Países
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

    -- 2. Migrar Provincias / Estados
    INSERT INTO Application.StateProvinces (
        StateProvinceID, StateProvinceCode, StateProvinceName, CountryID,
        SalesTerritory, Border, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo
    )
    SELECT 
        StateProvinceID, StateProvinceCode, StateProvinceName, CountryID,
        SalesTerritory, Border, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.StateProvinces;

    -- 3. Migrar Ciudades
    INSERT INTO Application.Cities (
        CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation,
        LastEditedBy, ValidFrom, ValidTo
    )
    SELECT 
        CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation,
        LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.Cities;

    -- 4. Migrar Métodos de Entrega
    INSERT INTO Application.DeliveryMethods (
        DeliveryMethodID, DeliveryMethodName, LastEditedBy, ValidFrom, ValidTo
    )
    SELECT 
        DeliveryMethodID, DeliveryMethodName, LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.DeliveryMethods;

    -- 5. Migrar Personas (People)
    -- Nota: Calculamos el SearchName porque en nuestra tabla es una columna normal
    INSERT INTO Application.People (
        PersonID, FullName, PreferredName, SearchName, IsPermittedToLogon,
        LogonName, IsExternalLogonProvider, HashedPassword, IsSystemUser,
        IsEmployee, IsSalesperson, UserPreferences, PhoneNumber, FaxNumber,
        EmailAddress, Photo, CustomFields, OtherLanguages, LastEditedBy, ValidFrom, ValidTo
    )
    SELECT 
        PersonID, FullName, PreferredName, 
        CONCAT(PreferredName, ' ', FullName), -- Calculamos el SearchName
        IsPermittedToLogon, LogonName, IsExternalLogonProvider, HashedPassword, IsSystemUser,
        IsEmployee, IsSalesperson, UserPreferences, PhoneNumber, FaxNumber,
        EmailAddress, Photo, CustomFields, OtherLanguages, LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.People;

    COMMIT TRANSACTION;

    PRINT 'Catalogos globales migrados correctamente a WWI_SanJose.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO