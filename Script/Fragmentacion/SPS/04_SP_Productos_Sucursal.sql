
-- ============================================================================
-- 04_SP_Productos_Sucursal.sql
-- Stored Procedures de Productos - Sucursales
-- Proyecto 2 Bases de Datos II
--
-- Descripcion:
--   Consulta el catalogo de productos y las existencias locales.
--   Se ejecuta en San Jose y Limon cambiando la instruccion USE.
--   Las operaciones CRUD se implementan por separado.
-- ============================================================================

USE WWI_Limon;
GO

-- ============================================
-- 01. LISTAR PRODUCTOS PAGINADO
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Inv_sp_ListarProductosPaginado
    @Nombre       NVARCHAR(100) = NULL,
    @GrupoID      INT = NULL,
    @PageNumber   INT = 1,
    @PageSize     INT = 25
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
        ) AS GrupoProducto,
        MAX(H.QuantityOnHand) AS CantidadEnInventario
    FROM dbo.Inv_Articulos AS SI
    LEFT JOIN dbo.Inv_ArticuloGrupo AS AG
        ON AG.StockItemID = SI.StockItemID
    LEFT JOIN dbo.Inv_GruposArticulo AS SG
        ON SG.StockGroupID = AG.StockGroupID
    LEFT JOIN dbo.Inv_ExistenciasArticulo AS H
        ON H.StockItemID = SI.StockItemID
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
        SI.StockItemID             AS IdProducto,
        SI.StockItemName           AS NombreProducto,
        SI.SupplierID              AS IdProveedor,
        PR.SupplierName            AS NombreProveedor,
        SI.ColorID                 AS IdColor,
        COL.ColorName              AS Color,
        SI.UnitPackageID           AS IdUnidadEmpaquetamiento,
        UP.PackageTypeName         AS UnidadEmpaquetamiento,
        SI.OuterPackageID          AS IdEmpaquetamiento,
        OP.PackageTypeName         AS Empaquetamiento,
        SI.QuantityPerOuter        AS CantidadEmpaquetamiento,
        SI.Brand                   AS Marca,
        SI.Size                    AS TallaTamano,
        SI.TaxRate                 AS Impuesto,
        SI.UnitPrice               AS PrecioUnitario,
        SI.RecommendedRetailPrice  AS PrecioVenta,
        SI.TypicalWeightPerUnit    AS Peso,
        SI.SearchDetails           AS PalabrasClave,
        H.QuantityOnHand           AS CantidadDisponible,
        H.BinLocation              AS Ubicacion
    FROM dbo.Inv_Articulos AS SI
    LEFT JOIN dbo.Prov_Proveedores AS PR
        ON PR.SupplierID = SI.SupplierID
    LEFT JOIN dbo.Inv_Colores AS COL
        ON COL.ColorID = SI.ColorID
    LEFT JOIN dbo.Inv_TiposEmpaque AS UP
        ON UP.PackageTypeID = SI.UnitPackageID
    LEFT JOIN dbo.Inv_TiposEmpaque AS OP
        ON OP.PackageTypeID = SI.OuterPackageID
    LEFT JOIN dbo.Inv_ExistenciasArticulo AS H
        ON H.StockItemID = SI.StockItemID
    WHERE SI.StockItemID = @StockItemID;
END;
GO