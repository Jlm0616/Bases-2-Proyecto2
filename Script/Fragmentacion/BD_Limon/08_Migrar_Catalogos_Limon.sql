
-- ============================================
-- 08_Migrar_Catalogos_Limon.sql
-- ============================================

USE WWI_Limon;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

-- Categorias de proveedores.
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

-- Categorias de clientes.
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

    COMMIT TRANSACTION;

    PRINT 'Catalogos de Limon migrados correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
