/*
  Proyecto 2 - WWI - Filtros para sucursales
  Ejecutar este archivo por separado en WWI_SanJose y WWI_Limon.
  No modifica tablas ni datos; solo crea o actualiza procedimientos.
  Requiere los sinonimos 00_Sinonimos_SanJose / 00_Sinonimos_Limon.
  Las respuestas conservan los alias usados en el Proyecto 1.
*/
SET NOCOUNT ON;
GO

CREATE OR ALTER PROCEDURE dbo.Flt_sp_ListarClientes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CustomerID AS IdCliente,
           CustomerName AS NombreCliente
    FROM dbo.Cli_Clientes
    ORDER BY CustomerName, CustomerID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Flt_sp_ListarPersonas
AS
BEGIN
    SET NOCOUNT ON;
    -- Solo datos generales; no consultar datos privados corporativos.
    SELECT PersonID AS IdPersona,
           FullName AS NombrePersona
    FROM dbo.Gen_Personas
    ORDER BY FullName, PersonID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Flt_sp_ListarVendedores
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PersonID AS IdPersona,
           FullName AS NombrePersona
    FROM dbo.Gen_Personas
    WHERE IsSalesperson = 1
    ORDER BY FullName, PersonID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Flt_sp_ListarMetodosEntrega
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DeliveryMethodID AS IdMetodoEntrega,
           DeliveryMethodName AS NombreMetodoEntrega
    FROM dbo.Gen_MetodosEntrega
    ORDER BY DeliveryMethodName, DeliveryMethodID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Flt_sp_ListarProductos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT StockItemID AS IdProducto,
           StockItemName AS NombreProducto,
           UnitPrice AS PrecioUnitario
    FROM dbo.Inv_Articulos
    ORDER BY StockItemName, StockItemID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Flt_sp_ListarTiposEmpaque
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PackageTypeID AS IdTipoEmpaque,
           PackageTypeName AS NombreTipoEmpaque
    FROM dbo.Inv_TiposEmpaque
    ORDER BY PackageTypeName, PackageTypeID;
END;
GO
