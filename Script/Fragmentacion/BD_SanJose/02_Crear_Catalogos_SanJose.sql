-- ============================================
-- 02_Crear_Catalogos_SanJose.sql
-- ============================================

USE WWI_SanJose;
GO

-- ============================================
-- Catálogos auxiliares
-- ============================================

-- Categorías de proveedores.
CREATE TABLE Purchasing.SupplierCategories (
    SupplierCategoryID INT NOT NULL PRIMARY KEY,
    SupplierCategoryName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- Grupos de compra.
CREATE TABLE Sales.BuyingGroups (
    BuyingGroupID INT NOT NULL PRIMARY KEY,
    BuyingGroupName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- Categorías de clientes.
CREATE TABLE Sales.CustomerCategories (
    CustomerCategoryID INT NOT NULL PRIMARY KEY,
    CustomerCategoryName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- Colores de productos.
CREATE TABLE Warehouse.Colors (
    ColorID INT NOT NULL PRIMARY KEY,
    ColorName NVARCHAR(20) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- Tipos de empaque.
CREATE TABLE Warehouse.PackageTypes (
    PackageTypeID INT NOT NULL PRIMARY KEY,
    PackageTypeName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- ============================================
-- Catálogos globales de Application
-- ============================================

-- ============================================
-- 1. Application.Countries
-- Catálogo de países. Raíz de la jerarquía geográfica.
-- ============================================
CREATE TABLE Application.Countries (
    CountryID                 INT           NOT NULL PRIMARY KEY,
    CountryName               NVARCHAR(60)  NOT NULL,
    FormalName                NVARCHAR(60)  NOT NULL,
    IsoAlpha3Code             NVARCHAR(3)   NULL,
    IsoNumericCode            INT           NULL,
    CountryType               NVARCHAR(20)  NULL,
    LatestRecordedPopulation  BIGINT        NULL,
    Continent                 NVARCHAR(30)  NOT NULL,
    Region                    NVARCHAR(30)  NOT NULL,
    Subregion                 NVARCHAR(30)  NOT NULL,
    Border                    GEOGRAPHY     NULL,
    LastEditedBy              INT           NOT NULL,
    ValidFrom                 DATETIME2(7)  NOT NULL,
    ValidTo                   DATETIME2(7)  NOT NULL
);
GO

-- ============================================
-- 2. Application.StateProvinces
-- Catálogo de provincias/estados. Depende de Countries.
-- ============================================
CREATE TABLE Application.StateProvinces (
    StateProvinceID           INT           NOT NULL PRIMARY KEY,
    StateProvinceCode         NVARCHAR(5)   NOT NULL,
    StateProvinceName         NVARCHAR(50)  NOT NULL,
    CountryID                 INT           NOT NULL,
    SalesTerritory            NVARCHAR(50)  NOT NULL,
    Border                    GEOGRAPHY     NULL,
    LatestRecordedPopulation  BIGINT        NULL,
    LastEditedBy              INT           NOT NULL,
    ValidFrom                 DATETIME2(7)  NOT NULL,
    ValidTo                   DATETIME2(7)  NOT NULL,

    CONSTRAINT FK_StateProvinces_Countries
        FOREIGN KEY (CountryID)
        REFERENCES Application.Countries(CountryID)
);
GO

-- ============================================
-- 3. Application.Cities
-- Catálogo de ciudades. Depende de StateProvinces.
-- La usan clientes, proveedores y reportes.
-- ============================================
CREATE TABLE Application.Cities (
    CityID                    INT           NOT NULL PRIMARY KEY,
    CityName                  NVARCHAR(50)  NOT NULL,
    StateProvinceID           INT           NOT NULL,
    Location                  GEOGRAPHY     NULL,
    LatestRecordedPopulation  BIGINT        NULL,
    LastEditedBy              INT           NOT NULL,
    ValidFrom                 DATETIME2(7)  NOT NULL,
    ValidTo                   DATETIME2(7)  NOT NULL,

    CONSTRAINT FK_Cities_StateProvinces
        FOREIGN KEY (StateProvinceID)
        REFERENCES Application.StateProvinces(StateProvinceID)
);
GO

-- ============================================
-- 4. Application.DeliveryMethods
-- Catálogo de métodos de entrega.
-- La usan clientes, proveedores, facturas y filtros.
-- ============================================
CREATE TABLE Application.DeliveryMethods (
    DeliveryMethodID          INT           NOT NULL PRIMARY KEY,
    DeliveryMethodName        NVARCHAR(50)  NOT NULL,
    LastEditedBy              INT           NOT NULL,
    ValidFrom                 DATETIME2(7)  NOT NULL,
    ValidTo                   DATETIME2(7)  NOT NULL
);
GO

-- ============================================
-- 5. Application.People
-- Identificadores, nombres y roles básicos de personas.
-- Los datos de contacto, credenciales y preferencias quedan en Corporativo.
-- No se almacenan atributos privados en la sucursal.
-- ============================================
CREATE TABLE Application.People (
    PersonID                  INT            NOT NULL PRIMARY KEY,
    FullName                  NVARCHAR(50)   NOT NULL,
    PreferredName             NVARCHAR(50)   NOT NULL,
    SearchName                NVARCHAR(101)  NOT NULL,
    IsSystemUser              BIT            NOT NULL,
    IsEmployee                BIT            NOT NULL,
    IsSalesperson             BIT            NOT NULL,
    LastEditedBy              INT            NOT NULL,
    ValidFrom                 DATETIME2(7)   NOT NULL,
    ValidTo                   DATETIME2(7)   NOT NULL,

    CONSTRAINT FK_People_LastEditedBy
        FOREIGN KEY (LastEditedBy)
        REFERENCES Application.People(PersonID)
);
GO

-- ============================================
-- Índices principales
-- ============================================

-- Búsqueda de personas por nombre
CREATE INDEX IX_People_FullName
    ON Application.People(FullName);
GO

-- Búsqueda de ciudades por nombre
CREATE INDEX IX_Cities_CityName
    ON Application.Cities(CityName);
GO

-- Búsqueda de ciudades por provincia
CREATE INDEX IX_Cities_StateProvinceID
    ON Application.Cities(StateProvinceID);
GO

-- Búsqueda de provincias por país
CREATE INDEX IX_StateProvinces_CountryID
    ON Application.StateProvinces(CountryID);
GO

