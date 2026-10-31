
-- ============================================
-- 02_Crear_Catalogos_Auxiliares_SanJose.sql
-- ============================================

USE WWI_SanJose;
GO

-- Categorias de proveedores.
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

-- Categorias de clientes.
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
