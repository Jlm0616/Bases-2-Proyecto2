-- ============================================================================
-- 03_SP_Proveedores_Sucursal.sql
-- SPs de Proveedores para San Jose y Limon (datos generales).
-- Para San Jose: cambiar solo la linea USE.
-- Los datos privados (contacto, direcciones, banco, metodo de entrega)
-- los devuelve Corporativo con Prov_sp_DetalleProveedorPrivado.
-- ============================================================================

USE WWI_Limon;
GO

CREATE OR ALTER PROCEDURE Prov_sp_ListarProveedoresPaginado
    @Nombre       NVARCHAR(100) = NULL,
    @CategoriaID  INT           = NULL,
    @PageNumber   INT           = 1,
    @PageSize     INT           = 25
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 25;
    IF @PageSize > 1000 SET @PageSize = 1000;

    SELECT
        P.SupplierID              AS IdProveedor,
        P.SupplierName            AS NombreProveedor,
        PC.SupplierCategoryName   AS CategoriaProveedor
    FROM Prov_Proveedores AS P
    LEFT JOIN Prov_CategoriasProveedor AS PC ON PC.SupplierCategoryID = P.SupplierCategoryID
    WHERE (@Nombre      IS NULL OR P.SupplierName LIKE '%' + @Nombre + '%')
      AND (@CategoriaID IS NULL OR P.SupplierCategoryID = @CategoriaID)
    ORDER BY P.SupplierName ASC, P.SupplierID ASC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE Prov_sp_ContarProveedores
    @Nombre       NVARCHAR(100) = NULL,
    @CategoriaID  INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS Total
    FROM Prov_Proveedores AS P
    WHERE (@Nombre      IS NULL OR P.SupplierName LIKE '%' + @Nombre + '%')
      AND (@CategoriaID IS NULL OR P.SupplierCategoryID = @CategoriaID);
END
GO

CREATE OR ALTER PROCEDURE Prov_sp_DetalleProveedor
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.SupplierID              AS IdProveedor,
        P.SupplierReference       AS CodigoProveedor,
        P.SupplierName            AS NombreProveedor,
        P.SupplierCategoryID      AS IdCategoria,
        PC.SupplierCategoryName   AS CategoriaProveedor,
        P.PaymentDays             AS DiasGraciaPago
    FROM Prov_Proveedores AS P
    LEFT JOIN Prov_CategoriasProveedor AS PC ON PC.SupplierCategoryID = P.SupplierCategoryID
    WHERE P.SupplierID = @SupplierID;
END
GO

-- Pruebas
EXEC Prov_sp_ListarProveedoresPaginado @PageNumber = 1, @PageSize = 5;
EXEC Prov_sp_ContarProveedores;
EXEC Prov_sp_DetalleProveedor 1;
GO