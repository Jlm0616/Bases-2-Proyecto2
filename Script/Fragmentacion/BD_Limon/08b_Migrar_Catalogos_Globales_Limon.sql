-- ============================================
-- 08b_Migrar_Catalogos_Globales_Limon.sql
-- ============================================
USE WWI_Limon;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Application.Countries (CountryID, CountryName, FormalName, IsoAlpha3Code, IsoNumericCode, CountryType, LatestRecordedPopulation, Continent, Region, Subregion, Border, LastEditedBy, ValidFrom, ValidTo)
    SELECT CountryID, CountryName, FormalName, IsoAlpha3Code, IsoNumericCode, CountryType, LatestRecordedPopulation, Continent, Region, Subregion, Border, LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.Countries;

    INSERT INTO Application.StateProvinces (StateProvinceID, StateProvinceCode, StateProvinceName, CountryID, SalesTerritory, Border, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo)
    SELECT StateProvinceID, StateProvinceCode, StateProvinceName, CountryID, SalesTerritory, Border, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.StateProvinces;

    INSERT INTO Application.Cities (CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo)
    SELECT CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.Cities;

    INSERT INTO Application.DeliveryMethods (DeliveryMethodID, DeliveryMethodName, LastEditedBy, ValidFrom, ValidTo)
    SELECT DeliveryMethodID, DeliveryMethodName, LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.DeliveryMethods;

    INSERT INTO Application.People (PersonID, FullName, PreferredName, SearchName, IsPermittedToLogon, LogonName, IsExternalLogonProvider, HashedPassword, IsSystemUser, IsEmployee, IsSalesperson, UserPreferences, PhoneNumber, FaxNumber, EmailAddress, Photo, CustomFields, OtherLanguages, LastEditedBy, ValidFrom, ValidTo)
    SELECT PersonID, FullName, PreferredName, CONCAT(PreferredName, ' ', FullName), IsPermittedToLogon, LogonName, IsExternalLogonProvider, HashedPassword, IsSystemUser, IsEmployee, IsSalesperson, UserPreferences, PhoneNumber, FaxNumber, EmailAddress, Photo, CustomFields, OtherLanguages, LastEditedBy, ValidFrom, ValidTo
    FROM WideWorldImporters.Application.People;

    COMMIT TRANSACTION;
    PRINT 'Catalogos globales migrados correctamente a WWI_Limon.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO