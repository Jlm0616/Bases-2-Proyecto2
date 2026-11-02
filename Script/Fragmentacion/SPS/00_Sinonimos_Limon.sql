USE WWI_Limon;
GO

CREATE OR ALTER PROCEDURE Cli_sp_ListarClientes
    @Nombre          NVARCHAR(100) = NULL,
    @CategoriaID     INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.CustomerID              AS IdCliente,
        C.CustomerName            AS NombreCliente,
        CC.CustomerCategoryName   AS CategoriaCliente
    FROM Cli_Clientes AS C
    LEFT JOIN Cli_CategoriasCliente AS CC ON CC.CustomerCategoryID = C.CustomerCategoryID
    WHERE (@Nombre IS NULL OR C.CustomerName LIKE '%' + @Nombre + '%')
      AND (@CategoriaID IS NULL OR C.CustomerCategoryID = @CategoriaID)
    ORDER BY C.CustomerName ASC;
END
GO