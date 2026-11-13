
-- ============================================================================
-- 03_SP_Proveedores_Sucursal.sql
-- Stored Procedures de Proveedores - Sucursales
-- Proyecto 2 Bases de Datos II
--
-- Descripcion:
--   Consultas de datos generales de proveedores.
--   Los datos privados se consultan desde Corporativo.
--   Las operaciones CRUD se implementan por separado.
-- ============================================================================

USE WWI_SanJose;
GO

-- ============================================
-- 01. LISTAR PROVEEDORES PAGINADO
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Prov_sp_ListarProveedoresPaginado
    @Nombre       NVARCHAR(100) = NULL,
    @CategoriaID  INT = NULL,
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
        P.SupplierID             AS IdProveedor,
        P.SupplierReference      AS CodigoProveedor,
        P.SupplierName           AS NombreProveedor,
        P.SupplierCategoryID     AS IdCategoria,
        PC.SupplierCategoryName  AS CategoriaProveedor,
        P.PaymentDays            AS DiasGraciaPago
    FROM dbo.Prov_Proveedores AS P
    LEFT JOIN dbo.Prov_CategoriasProveedor AS PC
        ON PC.SupplierCategoryID = P.SupplierCategoryID
    WHERE
        (@Nombre IS NULL
         OR P.SupplierName LIKE N'%' + @Nombre + N'%')
        AND
        (@CategoriaID IS NULL
         OR P.SupplierCategoryID = @CategoriaID)
    ORDER BY
        P.SupplierName ASC,
        P.SupplierID ASC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ============================================
-- 02. CONTAR PROVEEDORES CON FILTROS
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Prov_sp_ContarProveedores
    @Nombre NVARCHAR(100) = NULL,
    @CategoriaID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS Total
    FROM dbo.Prov_Proveedores AS P
    WHERE
        (@Nombre IS NULL
         OR P.SupplierName LIKE N'%' + @Nombre + N'%')
        AND
        (@CategoriaID IS NULL
         OR P.SupplierCategoryID = @CategoriaID);
END;
GO

-- ============================================
-- 03. DETALLE GENERAL DEL PROVEEDOR
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Prov_sp_DetalleProveedor
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.SupplierID             AS IdProveedor,
        P.SupplierReference      AS CodigoProveedor,
        P.SupplierName           AS NombreProveedor,
        P.SupplierCategoryID     AS IdCategoria,
        PC.SupplierCategoryName  AS CategoriaProveedor,
        P.PaymentDays            AS DiasGraciaPago
    FROM dbo.Prov_Proveedores AS P
    LEFT JOIN dbo.Prov_CategoriasProveedor AS PC
        ON PC.SupplierCategoryID = P.SupplierCategoryID
    WHERE P.SupplierID = @SupplierID;
END;
GO
