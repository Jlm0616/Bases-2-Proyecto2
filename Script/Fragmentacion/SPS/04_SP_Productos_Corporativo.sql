
-- ============================================================================
-- 04_SP_Productos_Corporativo.sql
-- Stored Procedures de Productos - Corporativo
-- Proyecto 2 Bases de Datos II
--
-- Descripcion:
--   Consulta el catalogo compartido de productos.
--   El catalogo no consulta existencias locales directamente.
--   Los SP de inventario consultan Warehouse.InventarioUnificado.
-- ============================================================================

USE WWI_Corporativo;
GO

-- ============================================
-- 01. LISTAR PRODUCTOS PAGINADO
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Inv_sp_ListarProductosPaginado
    @Nombre NVARCHAR(100) = NULL,
    @GrupoID INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 25
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber IS NULL OR @PageNumber < 1
        SET @PageNumber = 1;

    IF @PageSize IS NULL OR @PageSize < 1
        SET @PageSize = 25;

    IF @PageSize > 1000
        SET @PageSize = 1000;

    DECLARE @Offset BIGINT =
        (CAST(@PageNumber AS BIGINT) - 1) * @PageSize;

    SELECT
        SI.StockItemID AS IdProducto,
        SI.StockItemName AS NombreProducto,
        STRING_AGG(
            CONVERT(NVARCHAR(MAX), SG.StockGroupName),
            N', '
        ) WITHIN GROUP (
            ORDER BY SG.StockGroupName
        ) AS GrupoProducto
    FROM dbo.Inv_Articulos AS SI
    LEFT JOIN dbo.Inv_ArticuloGrupo AS AG
        ON AG.StockItemID = SI.StockItemID
    LEFT JOIN dbo.Inv_GruposArticulo AS SG
        ON SG.StockGroupID = AG.StockGroupID
    WHERE
        (@Nombre IS NULL
         OR SI.StockItemName LIKE N'%' + @Nombre + N'%')
        AND
        (@GrupoID IS NULL OR EXISTS (
            SELECT 1
            FROM dbo.Inv_ArticuloGrupo AS AG2
            WHERE AG2.StockItemID = SI.StockItemID
              AND AG2.StockGroupID = @GrupoID
        ))
    GROUP BY
        SI.StockItemID,
        SI.StockItemName
    ORDER BY
        SI.StockItemName ASC,
        SI.StockItemID ASC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ============================================
-- 02. CONTAR PRODUCTOS CON FILTROS
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Inv_sp_ContarProductos
    @Nombre NVARCHAR(100) = NULL,
    @GrupoID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS Total
    FROM dbo.Inv_Articulos AS SI
    WHERE
        (@Nombre IS NULL
         OR SI.StockItemName LIKE N'%' + @Nombre + N'%')
        AND
        (@GrupoID IS NULL OR EXISTS (
            SELECT 1
            FROM dbo.Inv_ArticuloGrupo AS AG
            WHERE AG.StockItemID = SI.StockItemID
              AND AG.StockGroupID = @GrupoID
        ));
END;
GO

-- ============================================
-- 03. DETALLE DEL PRODUCTO
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Inv_sp_DetalleProducto
    @StockItemID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SI.StockItemID AS IdProducto,
        SI.StockItemName AS NombreProducto,
        SI.SupplierID AS IdProveedor,
        SI.ColorID AS IdColor,
        COL.ColorName AS Color,
        SI.UnitPackageID AS IdUnidadEmpaquetamiento,
        UP.PackageTypeName AS UnidadEmpaquetamiento,
        SI.OuterPackageID AS IdEmpaquetamiento,
        OP.PackageTypeName AS Empaquetamiento,
        SI.QuantityPerOuter AS CantidadEmpaquetamiento,
        SI.Brand AS Marca,
        SI.Size AS TallaTamano,
        SI.TaxRate AS Impuesto,
        SI.UnitPrice AS PrecioUnitario,
        SI.RecommendedRetailPrice AS PrecioVenta,
        SI.TypicalWeightPerUnit AS Peso,
        SI.SearchDetails AS PalabrasClave
    FROM dbo.Inv_Articulos AS SI
    LEFT JOIN dbo.Inv_Colores AS COL
        ON COL.ColorID = SI.ColorID
    LEFT JOIN dbo.Inv_TiposEmpaque AS UP
        ON UP.PackageTypeID = SI.UnitPackageID
    LEFT JOIN dbo.Inv_TiposEmpaque AS OP
        ON OP.PackageTypeID = SI.OuterPackageID
    WHERE SI.StockItemID = @StockItemID;
END;
GO


-- ============================================
-- 04. INVENTARIO POR SUCURSAL PAGINADO
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Inv_sp_InventarioPorSucursal
    @Sucursal VARCHAR(20),
    @StockItemID INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 25
AS
BEGIN
    SET NOCOUNT ON;

    IF @Sucursal IS NULL OR @Sucursal NOT IN ('SanJose', 'Limon')
    BEGIN
        RAISERROR('Sucursal no valida', 16, 1);
        RETURN;
    END;

    IF @PageNumber IS NULL OR @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize IS NULL OR @PageSize < 1 SET @PageSize = 25;
    IF @PageSize > 1000 SET @PageSize = 1000;

    DECLARE @Offset BIGINT = (CAST(@PageNumber AS BIGINT) - 1) * @PageSize;

    SELECT
        StockItemID AS IdProducto,
        @Sucursal AS Sucursal,
        CASE
            WHEN @Sucursal = 'SanJose' THEN InventarioSanJose
            WHEN @Sucursal = 'Limon' THEN InventarioLimon
        END AS CantidadInventario
    FROM Warehouse.InventarioUnificado
    WHERE @StockItemID IS NULL OR StockItemID = @StockItemID
    ORDER BY StockItemID
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ============================================
-- 05. INVENTARIO CONSOLIDADO PAGINADO
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Inv_sp_InventarioConsolidado
    @StockItemID INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 25
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber IS NULL OR @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize IS NULL OR @PageSize < 1 SET @PageSize = 25;
    IF @PageSize > 1000 SET @PageSize = 1000;

    DECLARE @Offset BIGINT = (CAST(@PageNumber AS BIGINT) - 1) * @PageSize;

    SELECT
        StockItemID AS IdProducto,
        InventarioSanJose,
        InventarioLimon,
        InventarioTotal
    FROM Warehouse.InventarioUnificado
    WHERE @StockItemID IS NULL OR StockItemID = @StockItemID
    ORDER BY StockItemID
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- =============================================
-- 06. CREAR SECUENCIA PARA IDs DE PRODUCTOS
-- =============================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.sequences
    WHERE name = 'Seq_StockItemID'
      AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    DECLARE @SiguienteID INT;

    -- Obtener el siguiente ID disponible
    SELECT @SiguienteID =
        ISNULL(MAX(StockItemID), 0) + 1
    FROM Warehouse.StockItems;

    -- Crear secuencia dinámicamente
    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        CREATE SEQUENCE dbo.Seq_StockItemID
        AS INT
        START WITH ' + CAST(@SiguienteID AS NVARCHAR(20)) + N'
        INCREMENT BY 1
        NO CYCLE;
    ';

    EXEC sp_executesql @SQL;

    PRINT 'Secuencia Seq_StockItemID creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La secuencia Seq_StockItemID ya existe.';
END;
GO

-- =============================================
-- 07. CREAR PROCEDIMIENTO GENERADOR DE IDs
-- =============================================

CREATE OR ALTER PROCEDURE dbo.Inv_sp_GenerarStockItemID
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StockItemID INT;

    SET @StockItemID = NEXT VALUE FOR dbo.Seq_StockItemID;

    SELECT @StockItemID AS StockItemID;
END;
GO
