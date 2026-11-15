/*
  Proyecto 2 - WWI - Filtros para Corporativo
  Ejecutar exclusivamente en WWI_Corporativo.
  Solo expone catalogos compartidos cuya estructura consta en los scripts
  de fragmentacion. No reune ni duplica registros historicos.
  No crea filtros de Personas: el sinonimo corporativo conocido es
  Gen_PersonasPrivadas, que NO equivale al catalogo publico Gen_Personas.
  Tampoco incorpora clientes: su origen general corporativo requiere
  verificar el esquema fragmentado antes de definir el procedimiento.
  No modifica tablas ni datos; solo crea o actualiza procedimientos.
*/
SET NOCOUNT ON;
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
