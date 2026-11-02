-- ============================================
-- 02b_Crear_Catalogos_Globales_Limon.sql
-- ============================================
USE WWI_Limon;
GO

CREATE TABLE Application.Countries (
    CountryID INT NOT NULL PRIMARY KEY,
    CountryName NVARCHAR(60) NOT NULL,
    FormalName NVARCHAR(60) NOT NULL,
    IsoAlpha3Code NVARCHAR(3) NULL,
    IsoNumericCode INT NULL,
    CountryType NVARCHAR(20) NULL,
    LatestRecordedPopulation BIGINT NULL,
    Continent NVARCHAR(30) NOT NULL,
    Region NVARCHAR(30) NOT NULL,
    Subregion NVARCHAR(30) NULL,
    Border GEOGRAPHY NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

CREATE TABLE Application.StateProvinces (
    StateProvinceID INT NOT NULL PRIMARY KEY,
    StateProvinceCode NVARCHAR(5) NULL,
    StateProvinceName NVARCHAR(50) NOT NULL,
    CountryID INT NOT NULL,
    SalesTerritory NVARCHAR(50) NOT NULL,
    Border GEOGRAPHY NULL,
    LatestRecordedPopulation BIGINT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL,
    CONSTRAINT FK_StateProvinces_Countries FOREIGN KEY (CountryID) REFERENCES Application.Countries(CountryID)
);
GO

CREATE TABLE Application.Cities (
    CityID INT NOT NULL PRIMARY KEY,
    CityName NVARCHAR(50) NOT NULL,
    StateProvinceID INT NOT NULL,
    Location GEOGRAPHY NULL,
    LatestRecordedPopulation BIGINT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL,
    CONSTRAINT FK_Cities_StateProvinces FOREIGN KEY (StateProvinceID) REFERENCES Application.StateProvinces(StateProvinceID)
);
GO

CREATE TABLE Application.DeliveryMethods (
    DeliveryMethodID INT NOT NULL PRIMARY KEY,
    DeliveryMethodName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

CREATE TABLE Application.People (
    PersonID INT NOT NULL PRIMARY KEY,
    FullName NVARCHAR(50) NOT NULL,
    PreferredName NVARCHAR(50) NOT NULL,
    SearchName NVARCHAR(101) NOT NULL,
    IsPermittedToLogon BIT NOT NULL,
    LogonName NVARCHAR(50) NULL,
    IsExternalLogonProvider BIT NOT NULL,
    HashedPassword VARBINARY(256) NULL,
    IsSystemUser BIT NOT NULL,
    IsEmployee BIT NOT NULL,
    IsSalesperson BIT NOT NULL,
    UserPreferences NVARCHAR(MAX) NULL,
    PhoneNumber NVARCHAR(20) NULL,
    FaxNumber NVARCHAR(20) NULL,
    EmailAddress NVARCHAR(256) NULL,
    Photo VARBINARY(MAX) NULL,
    CustomFields NVARCHAR(MAX) NULL,
    OtherLanguages NVARCHAR(MAX) NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL,
    CONSTRAINT FK_People_LastEditedBy FOREIGN KEY (LastEditedBy) REFERENCES Application.People(PersonID)
);
GO

CREATE INDEX IX_People_FullName ON Application.People(FullName);
CREATE INDEX IX_Cities_CityName ON Application.Cities(CityName);
CREATE INDEX IX_Cities_StateProvinceID ON Application.Cities(StateProvinceID);
CREATE INDEX IX_StateProvinces_CountryID ON Application.StateProvinces(CountryID);
GO