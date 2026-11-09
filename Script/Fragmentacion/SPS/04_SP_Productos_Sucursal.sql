-- ============================================================================
-- 04_SP_Productos_Sucursal.sql
-- SPs de Productos para San Jose y Limon.
-- Catalogo replicado + existencias locales de la sucursal.
-- Para San Jose: cambiar solo la linea USE.
-- ============================================================================

USE WWI_Limon;
GO

CREATE OR ALTER PROCEDURE Inv_sp_ListarProductosPaginado
    @Nombre     NVARCHAR(100) = NULL,
    @GrupoID    INT           = NULL,
    @PageNumber INT           = 1,
    @PageSize   INT           = 25
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 25;
    IF @PageSize > 1000 SET @PageSize = 1000;

    SELECT
        SI.StockItemID                                  AS IdProducto,
        SI.StockItemName                                AS NombreProducto,
        STRING_AGG(SG.StockGroupName, ', ')
            WITHIN GROUP (ORDER BY SG.StockGroupName)   AS GrupoProducto,
        MAX(H.QuantityOnHand)                           AS CantidadEnInventario
    FROM Inv_Articulos AS SI
    LEFT JOIN Inv_ArticuloGrupo       AS AG ON AG.StockItemID  = SI.StockItemID
    LEFT JOIN Inv_GruposArticulo      AS SG ON SG.StockGroupID = AG.StockGroupID
    LEFT JOIN Inv_ExistenciasArticulo AS H  ON H.StockItemID   = SI.StockItemID
    WHERE (@Nombre  IS NULL OR SI.StockItemName LIKE '%' + @Nombre + '%')
      AND (@GrupoID IS NULL OR EXISTS (
              SELECT 1
              FROM Inv_ArticuloGrupo AS AG2
              WHERE AG2.StockItemID = SI.StockItemID
                AND AG2.StockGroupID = @GrupoID
          ))
    GROUP BY SI.StockItemID, SI.StockItemName
    ORDER BY SI.StockItemName ASC, SI.StockItemID ASC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE Inv_sp_ContarProductos
    @Nombre  NVARCHAR(100) = NULL,
    @GrupoID INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS Total
    FROM Inv_Articulos AS SI
    WHERE (@Nombre  IS NULL OR SI.StockItemName LIKE '%' + @Nombre + '%')
      AND (@GrupoID IS NULL OR EXISTS (
              SELECT 1
              FROM Inv_ArticuloGrupo AS AG2
              WHERE AG2.StockItemID = SI.StockItemID
                AND AG2.StockGroupID = @GrupoID
          ));
END
GO

CREATE OR ALTER PROCEDURE Inv_sp_DetalleProducto
    @StockItemID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SI.StockItemID                AS IdProducto,
        SI.StockItemName              AS NombreProducto,
        SI.SupplierID                 AS IdProveedor,
        PR.SupplierName               AS NombreProveedor,
        SI.ColorID                    AS IdColor,
        COL.ColorName                 AS Color,
        SI.UnitPackageID              AS IdUnidadEmpaquetamiento,
        UP.PackageTypeName            AS UnidadEmpaquetamiento,
        SI.OuterPackageID             AS IdEmpaquetamiento,
        OP.PackageTypeName            AS Empaquetamiento,
        SI.QuantityPerOuter           AS CantidadEmpaquetamiento,
        SI.Brand                      AS Marca,
        SI.Size                       AS TallaTamano,
        SI.TaxRate                    AS Impuesto,
        SI.UnitPrice                  AS PrecioUnitario,
        SI.RecommendedRetailPrice     AS PrecioVenta,
        SI.TypicalWeightPerUnit       AS Peso,
        SI.SearchDetails              AS PalabrasClave,
        H.QuantityOnHand              AS CantidadDisponible,
        H.BinLocation                 AS Ubicacion
    FROM Inv_Articulos AS SI
    LEFT JOIN Prov_Proveedores        AS PR  ON PR.SupplierID    = SI.SupplierID
    LEFT JOIN Inv_Colores             AS COL ON COL.ColorID      = SI.ColorID
    LEFT JOIN Inv_TiposEmpaque        AS UP  ON UP.PackageTypeID = SI.UnitPackageID
    LEFT JOIN Inv_TiposEmpaque        AS OP  ON OP.PackageTypeID = SI.OuterPackageID
    LEFT JOIN Inv_ExistenciasArticulo AS H   ON H.StockItemID    = SI.StockItemID
    WHERE SI.StockItemID = @StockItemID;
END
GO

-- Pruebas
EXEC Inv_sp_ListarProductosPaginado @PageNumber = 1, @PageSize = 5;
EXEC Inv_sp_ContarProductos;
SELECT COUNT(*) AS ProductosReales FROM Inv_Articulos;
EXEC Inv_sp_DetalleProducto 1;
GO