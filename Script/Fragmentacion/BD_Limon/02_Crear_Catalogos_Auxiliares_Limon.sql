
-- ============================================
-- 02_Crear_Catalogos_Auxiliares_Limon.sql
-- ============================================

USE WWI_Limon;
GO

-- 1. CATEGORIAS DE PROVEEDORES
CREATE TABLE Purchasing.SupplierCategories (
    SupplierCategoryID INT NOT NULL PRIMARY KEY,
    SupplierCategoryName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- 2. GRUPOS DE COMPRA
CREATE TABLE Sales.BuyingGroups (
    BuyingGroupID INT NOT NULL PRIMARY KEY,
    BuyingGroupName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- 3. CATEGORIAS DE CLIENTES
CREATE TABLE Sales.CustomerCategories (
    CustomerCategoryID INT NOT NULL PRIMARY KEY,
    CustomerCategoryName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- 4. COLORES
CREATE TABLE Warehouse.Colors (
    ColorID INT NOT NULL PRIMARY KEY,
    ColorName NVARCHAR(20) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO

-- 5. TIPOS DE EMPAQUE
CREATE TABLE Warehouse.PackageTypes (
    PackageTypeID INT NOT NULL PRIMARY KEY,
    PackageTypeName NVARCHAR(50) NOT NULL,
    LastEditedBy INT NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
GO
