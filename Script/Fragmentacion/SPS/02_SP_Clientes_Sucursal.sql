
-- ============================================================================
-- 02_SP_Clientes_Sucursal.sql
-- SPs de consulta de clientes para San Jose y Limon (datos generales).
-- Para San Jose: cambiar solo la linea USE.
-- Los datos privados se consultan en Corporativo mediante
-- Cli_sp_DetalleClientePrivado.
-- Las operaciones CRUD se implementan en un archivo separado.
-- ============================================================================

USE WWI_Limon;
GO

-- ============================================
-- 01. LISTAR CLIENTES PAGINADO
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Cli_sp_ListarClientesPaginado
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
        C.CustomerID                  AS IdCliente,
        C.CustomerName                AS NombreCliente,
        C.CustomerCategoryID          AS IdCategoria,
        CC.CustomerCategoryName       AS CategoriaCliente,
        C.BuyingGroupID               AS IdGrupoCompra,
        BG.BuyingGroupName            AS GrupoCompra,
        C.AccountOpenedDate           AS FechaApertura,
        C.StandardDiscountPercentage  AS DescuentoEstandar,
        C.IsStatementSent             AS EnviaEstadoCuenta,
        C.IsOnCreditHold              AS CreditoSuspendido,
        C.PaymentDays                 AS DiasGraciaPago
    FROM dbo.Cli_Clientes AS C
    LEFT JOIN dbo.Cli_CategoriasCliente AS CC
        ON CC.CustomerCategoryID = C.CustomerCategoryID
    LEFT JOIN dbo.Cli_GruposCompra AS BG
        ON BG.BuyingGroupID = C.BuyingGroupID
    WHERE
        (@Nombre IS NULL
         OR C.CustomerName LIKE N'%' + @Nombre + N'%')
        AND
        (@CategoriaID IS NULL
         OR C.CustomerCategoryID = @CategoriaID)
    ORDER BY
        C.CustomerName ASC,
        C.CustomerID ASC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ============================================
-- 02. CONTAR CLIENTES CON FILTROS
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Cli_sp_ContarClientes
    @Nombre       NVARCHAR(100) = NULL,
    @CategoriaID  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS Total
    FROM dbo.Cli_Clientes AS C
    WHERE
        (@Nombre IS NULL
         OR C.CustomerName LIKE N'%' + @Nombre + N'%')
        AND
        (@CategoriaID IS NULL
         OR C.CustomerCategoryID = @CategoriaID);
END;
GO

-- ============================================
-- 03. DETALLE GENERAL DEL CLIENTE
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Cli_sp_DetalleCliente
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.CustomerID                  AS IdCliente,
        C.CustomerName                AS NombreCliente,
        C.CustomerCategoryID          AS IdCategoria,
        CC.CustomerCategoryName       AS CategoriaCliente,
        C.BuyingGroupID               AS IdGrupoCompra,
        BG.BuyingGroupName            AS GrupoCompra,
        C.BillToCustomerID            AS IdClienteFacturar,
        C.AccountOpenedDate           AS FechaApertura,
        C.StandardDiscountPercentage  AS DescuentoEstandar,
        C.IsStatementSent             AS EnviaEstadoCuenta,
        C.IsOnCreditHold              AS CreditoSuspendido,
        C.PaymentDays                 AS DiasGraciaPago
    FROM dbo.Cli_Clientes AS C
    LEFT JOIN dbo.Cli_CategoriasCliente AS CC
        ON CC.CustomerCategoryID = C.CustomerCategoryID
    LEFT JOIN dbo.Cli_GruposCompra AS BG
        ON BG.BuyingGroupID = C.BuyingGroupID
    WHERE C.CustomerID = @CustomerID;
END;
GO