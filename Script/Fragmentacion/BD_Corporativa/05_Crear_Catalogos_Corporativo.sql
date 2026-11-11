-- ============================================
-- 05_Crear_Catalogos_Corporativo.sql
-- ============================================

USE WWI_Corporativo;
GO

-- ============================================
-- 1. Catalogos auxiliares
-- ============================================

-- 1. Categorias de proveedores
CREATE TABLE Purchasing.SupplierCategories (
    SupplierCategoryID INT NOT NULL PRIMARY KEY,
    SupplierCategoryName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- 2. Grupos de compra
CREATE TABLE Sales.BuyingGroups (
    BuyingGroupID INT NOT NULL PRIMARY KEY,
    BuyingGroupName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- 3. Categorias de clientes
CREATE TABLE Sales.CustomerCategories (
    CustomerCategoryID INT NOT NULL PRIMARY KEY,
    CustomerCategoryName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- 4. Colores
CREATE TABLE Warehouse.Colors (
    ColorID INT NOT NULL PRIMARY KEY,
    ColorName NVARCHAR(20) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- 5. Tipos de empaque
CREATE TABLE Warehouse.PackageTypes (
    PackageTypeID INT NOT NULL PRIMARY KEY,
    PackageTypeName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- 6. Grupos de productos
CREATE TABLE Warehouse.StockGroups (
    StockGroupID INT NOT NULL PRIMARY KEY,
    StockGroupName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- ============================================
-- 2. Catalogos geograficos
-- ============================================

-- 7. Paises
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
    Subregion NVARCHAR(30) NOT NULL,
    Border GEOGRAPHY NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- 8. Provincias y estados
CREATE TABLE Application.StateProvinces (
    StateProvinceID INT NOT NULL PRIMARY KEY,
    StateProvinceCode NVARCHAR(5) NOT NULL,
    StateProvinceName NVARCHAR(50) NOT NULL,
    CountryID INT NOT NULL,
    SalesTerritory NVARCHAR(50) NOT NULL,
    Border GEOGRAPHY NULL,
    LatestRecordedPopulation BIGINT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL,

    CONSTRAINT FK_StateProvinces_Countries
        FOREIGN KEY (CountryID)
        REFERENCES Application.Countries(CountryID)
);
GO

-- 9. Ciudades
CREATE TABLE Application.Cities (
    CityID INT NOT NULL PRIMARY KEY,
    CityName NVARCHAR(50) NOT NULL,
    StateProvinceID INT NOT NULL,
    Location GEOGRAPHY NULL,
    LatestRecordedPopulation BIGINT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL,

    CONSTRAINT FK_Cities_StateProvinces
        FOREIGN KEY (StateProvinceID)
        REFERENCES Application.StateProvinces(StateProvinceID)
);
GO

-- ============================================
-- 3. Metodos de entrega
-- ============================================

-- 10. Metodos de entrega
CREATE TABLE Application.DeliveryMethods (
    DeliveryMethodID INT NOT NULL PRIMARY KEY,
    DeliveryMethodName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO


GO


-- ============================================
-- 4. Indices principales
-- ============================================

CREATE INDEX IX_Cities_CityName
ON Application.Cities(CityName);
GO

CREATE INDEX IX_Cities_StateProvinceID
ON Application.Cities(StateProvinceID);
GO

CREATE INDEX IX_StateProvinces_CountryID
ON Application.StateProvinces(CountryID);
GO
