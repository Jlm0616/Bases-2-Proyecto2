-- ============================================================================
-- 02_SP_Clientes_Sucursal.sql
-- SPs de Clientes para San Jose y Limon (datos generales).
-- Para San Jose: cambiar solo la linea USE.
-- Los datos privados (telefono, direcciones, contactos, metodo de entrega)
-- los devuelve Corporativo con Cli_sp_DetalleClientePrivado.
-- ============================================================================

USE WWI_Limon;
GO

CREATE OR ALTER PROCEDURE Cli_sp_ListarClientesPaginado
    @Nombre       NVARCHAR(100) = NULL,
    @CategoriaID  INT = NULL,
    @PageNumber   INT = 1,
    @PageSize     INT = 25
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 25;
    IF @PageSize > 1000 SET @PageSize = 1000;

    SELECT
        C.CustomerID              AS IdCliente,
        C.CustomerName            AS NombreCliente,
        CC.CustomerCategoryName   AS CategoriaCliente
    FROM Cli_Clientes AS C
    LEFT JOIN Cli_CategoriasCliente AS CC ON CC.CustomerCategoryID = C.CustomerCategoryID
    WHERE (@Nombre IS NULL OR C.CustomerName LIKE '%' + @Nombre + '%')
      AND (@CategoriaID IS NULL OR C.CustomerCategoryID = @CategoriaID)
    ORDER BY C.CustomerName ASC, C.CustomerID ASC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE Cli_sp_ContarClientes
    @Nombre       NVARCHAR(100) = NULL,
    @CategoriaID  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS Total
    FROM Cli_Clientes AS C
    WHERE (@Nombre IS NULL OR C.CustomerName LIKE '%' + @Nombre + '%')
      AND (@CategoriaID IS NULL OR C.CustomerCategoryID = @CategoriaID);
END
GO

CREATE OR ALTER PROCEDURE Cli_sp_DetalleCliente
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.CustomerID              AS IdCliente,
        C.CustomerName            AS NombreCliente,
        C.CustomerCategoryID      AS IdCategoria,
        CC.CustomerCategoryName   AS CategoriaCliente,
        C.BuyingGroupID           AS IdGrupoCompra,
        BG.BuyingGroupName        AS GrupoCompra,
        C.BillToCustomerID        AS IdClienteFacturar,
        C.PaymentDays             AS DiasGraciaPago
    FROM Cli_Clientes AS C
    LEFT JOIN Cli_CategoriasCliente AS CC ON CC.CustomerCategoryID = C.CustomerCategoryID
    LEFT JOIN Cli_GruposCompra      AS BG ON BG.BuyingGroupID      = C.BuyingGroupID
    WHERE C.CustomerID = @CustomerID;
END
GO

-- Pruebas
EXEC Cli_sp_ListarClientesPaginado @PageNumber = 1, @PageSize = 5;
EXEC Cli_sp_ContarClientes;
EXEC Cli_sp_DetalleCliente 1;
GO