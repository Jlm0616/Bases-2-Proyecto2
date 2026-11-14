USE WWI_Limon;
GO

CREATE OR ALTER PROCEDURE dbo.Inv_sp_CrearProducto
    @StockItemID INT,
    @Nombre NVARCHAR(100),
    @ProveedorID INT,
    @ColorID INT = NULL,
    @UnidadEmpaqueID INT,
    @EmpaqueExteriorID INT,
    @Marca NVARCHAR(50) = NULL,
    @Tamano NVARCHAR(20) = NULL,
    @DiasEntrega INT,
    @CantidadPorEmpaque INT,
    @RequiereRefrigeracion BIT,
    @CodigoBarras NVARCHAR(50) = NULL,
    @Impuesto DECIMAL(18, 3),
    @PrecioUnitario DECIMAL(18, 2),
    @PrecioVenta DECIMAL(18, 2) = NULL,
    @Peso DECIMAL(18, 3),
    @UsuarioEditor INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Validar ID
    IF @StockItemID IS NULL OR @StockItemID <= 0
        THROW 50001, 'ID de producto no valido.', 1;

    -- Validar nombre
    IF NULLIF(LTRIM(RTRIM(@Nombre)), N'') IS NULL
        THROW 50002, 'El nombre del producto es obligatorio.', 1;

    -- Verificar que el producto no exista
    IF EXISTS (
        SELECT 1
        FROM Warehouse.StockItems
        WHERE StockItemID = @StockItemID
    )
        THROW 50003, 'El ID del producto ya existe.', 1;

    -- Validar proveedor
    IF NOT EXISTS (
        SELECT 1
        FROM Purchasing.Suppliers
        WHERE SupplierID = @ProveedorID
    )
        THROW 50004, 'El proveedor no existe.', 1;

    -- Validar unidad de empaque
    IF NOT EXISTS (
        SELECT 1
        FROM Warehouse.PackageTypes
        WHERE PackageTypeID = @UnidadEmpaqueID
    )
        THROW 50005, 'La unidad de empaque no existe.', 1;

    -- Validar empaque exterior
    IF NOT EXISTS (
        SELECT 1
        FROM Warehouse.PackageTypes
        WHERE PackageTypeID = @EmpaqueExteriorID
    )
        THROW 50006, 'El empaque exterior no existe.', 1;

    -- Validar color
    IF @ColorID IS NOT NULL
       AND NOT EXISTS (
           SELECT 1
           FROM Warehouse.Colors
           WHERE ColorID = @ColorID
       )
        THROW 50007, 'El color no existe.', 1;

    -- Crear producto
    INSERT INTO Warehouse.StockItems (
        StockItemID,
        StockItemName,
        SupplierID,
        ColorID,
        UnitPackageID,
        OuterPackageID,
        Brand,
        Size,
        LeadTimeDays,
        QuantityPerOuter,
        IsChillerStock,
        Barcode,
        TaxRate,
        UnitPrice,
        RecommendedRetailPrice,
        TypicalWeightPerUnit,
        LastEditedBy,
        ValidFrom,
        ValidTo
    )
    VALUES (
        @StockItemID,
        @Nombre,
        @ProveedorID,
        @ColorID,
        @UnidadEmpaqueID,
        @EmpaqueExteriorID,
        @Marca,
        @Tamano,
        @DiasEntrega,
        @CantidadPorEmpaque,
        @RequiereRefrigeracion,
        @CodigoBarras,
        @Impuesto,
        @PrecioUnitario,
        @PrecioVenta,
        @Peso,
        @UsuarioEditor,
        SYSDATETIME(),
        CONVERT(DATETIME2(7), '9999-12-31 23:59:59.9999999')
    );

    -- Devolver producto creado
    SELECT
        StockItemID AS IdProducto,
        StockItemName AS NombreProducto
    FROM Warehouse.StockItems
    WHERE StockItemID = @StockItemID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Inv_sp_ActualizarProducto
    @StockItemID INT,
    @Nombre NVARCHAR(100),
    @ProveedorID INT,
    @ColorID INT = NULL,
    @UnidadEmpaqueID INT,
    @EmpaqueExteriorID INT,
    @Marca NVARCHAR(50) = NULL,
    @Tamano NVARCHAR(20) = NULL,
    @DiasEntrega INT,
    @CantidadPorEmpaque INT,
    @RequiereRefrigeracion BIT,
    @CodigoBarras NVARCHAR(50) = NULL,
    @Impuesto DECIMAL(18, 3),
    @PrecioUnitario DECIMAL(18, 2),
    @PrecioVenta DECIMAL(18, 2) = NULL,
    @Peso DECIMAL(18, 3),
    @UsuarioEditor INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Validar producto
    IF NOT EXISTS (
        SELECT 1
        FROM Warehouse.StockItems
        WHERE StockItemID = @StockItemID
    )
        THROW 50001, 'El producto no existe.', 1;

    -- Validar nombre
    IF NULLIF(LTRIM(RTRIM(@Nombre)), N'') IS NULL
        THROW 50002, 'El nombre es obligatorio.', 1;

    -- Validar proveedor
    IF NOT EXISTS (
        SELECT 1
        FROM Purchasing.Suppliers
        WHERE SupplierID = @ProveedorID
    )
        THROW 50003, 'El proveedor no existe.', 1;

    -- Validar empaques
    IF NOT EXISTS (
        SELECT 1
        FROM Warehouse.PackageTypes
        WHERE PackageTypeID = @UnidadEmpaqueID
    )
        THROW 50004, 'La unidad de empaque no existe.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Warehouse.PackageTypes
        WHERE PackageTypeID = @EmpaqueExteriorID
    )
        THROW 50005, 'El empaque exterior no existe.', 1;

    -- Validar color
    IF @ColorID IS NOT NULL
       AND NOT EXISTS (
           SELECT 1
           FROM Warehouse.Colors
           WHERE ColorID = @ColorID
       )
        THROW 50006, 'El color no existe.', 1;

    -- Actualizar producto
    UPDATE Warehouse.StockItems
    SET
        StockItemName = @Nombre,
        SupplierID = @ProveedorID,
        ColorID = @ColorID,
        UnitPackageID = @UnidadEmpaqueID,
        OuterPackageID = @EmpaqueExteriorID,
        Brand = @Marca,
        Size = @Tamano,
        LeadTimeDays = @DiasEntrega,
        QuantityPerOuter = @CantidadPorEmpaque,
        IsChillerStock = @RequiereRefrigeracion,
        Barcode = @CodigoBarras,
        TaxRate = @Impuesto,
        UnitPrice = @PrecioUnitario,
        RecommendedRetailPrice = @PrecioVenta,
        TypicalWeightPerUnit = @Peso,
        LastEditedBy = @UsuarioEditor
    WHERE StockItemID = @StockItemID;

    -- Devolver producto actualizado
    SELECT
        StockItemID AS IdProducto,
        StockItemName AS NombreProducto,
        UnitPrice AS PrecioUnitario
    FROM Warehouse.StockItems
    WHERE StockItemID = @StockItemID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Inv_sp_EliminarProducto
    @StockItemID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Verificar existencia
    IF NOT EXISTS (
        SELECT 1
        FROM Warehouse.StockItems
        WHERE StockItemID = @StockItemID
    )
        THROW 50001, 'El producto no existe.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Eliminar asociaciones con grupos
        DELETE FROM Warehouse.StockItemStockGroups
        WHERE StockItemID = @StockItemID;

        -- Eliminar producto
        DELETE FROM Warehouse.StockItems
        WHERE StockItemID = @StockItemID;

        COMMIT TRANSACTION;

        SELECT
            @StockItemID AS IdProducto,
            'Producto eliminado correctamente' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        IF ERROR_NUMBER() = 547
            THROW 50002,
                'No se puede eliminar el producto porque tiene registros relacionados.',
                1;

        THROW;
    END CATCH;
END;
GO