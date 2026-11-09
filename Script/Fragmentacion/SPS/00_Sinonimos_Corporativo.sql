USE WWI_Corporativo;
GO

-- ============================================================================
-- 00_Sinonimos_Corporativo.sql
-- Sinónimos del nodo Corporativo (datos privados + catálogos replicados)
-- ============================================================================

-- Clientes
DROP SYNONYM IF EXISTS Cli_ClientesPrivados;
DROP SYNONYM IF EXISTS Cli_CategoriasCliente;
DROP SYNONYM IF EXISTS Cli_GruposCompra;
CREATE SYNONYM Cli_ClientesPrivados   FOR Sales.CustomersPrivate;
CREATE SYNONYM Cli_CategoriasCliente  FOR Sales.CustomerCategories;
CREATE SYNONYM Cli_GruposCompra       FOR Sales.BuyingGroups;

-- Proveedores
DROP SYNONYM IF EXISTS Prov_ProveedoresPrivados;
DROP SYNONYM IF EXISTS Prov_CategoriasProveedor;
CREATE SYNONYM Prov_ProveedoresPrivados FOR Purchasing.SuppliersPrivate;
CREATE SYNONYM Prov_CategoriasProveedor FOR Purchasing.SupplierCategories;

-- Inventario / Productos
DROP SYNONYM IF EXISTS Inv_Articulos;
DROP SYNONYM IF EXISTS Inv_GruposArticulo;
DROP SYNONYM IF EXISTS Inv_ArticuloGrupo;
DROP SYNONYM IF EXISTS Inv_Colores;
DROP SYNONYM IF EXISTS Inv_TiposEmpaque;
CREATE SYNONYM Inv_Articulos      FOR Warehouse.StockItems;
CREATE SYNONYM Inv_GruposArticulo FOR Warehouse.StockGroups;
CREATE SYNONYM Inv_ArticuloGrupo  FOR Warehouse.StockItemStockGroups;
CREATE SYNONYM Inv_Colores        FOR Warehouse.Colors;
CREATE SYNONYM Inv_TiposEmpaque   FOR Warehouse.PackageTypes;

-- Comunes
DROP SYNONYM IF EXISTS Gen_PersonasPrivadas;
DROP SYNONYM IF EXISTS Gen_MetodosEntrega;
DROP SYNONYM IF EXISTS Gen_Ciudades;
DROP SYNONYM IF EXISTS Gen_Provincias;
DROP SYNONYM IF EXISTS Gen_Paises;
CREATE SYNONYM Gen_PersonasPrivadas FOR Application.PeoplePrivate;
CREATE SYNONYM Gen_MetodosEntrega   FOR Application.DeliveryMethods;
CREATE SYNONYM Gen_Ciudades         FOR Application.Cities;
CREATE SYNONYM Gen_Provincias       FOR Application.StateProvinces;
CREATE SYNONYM Gen_Paises           FOR Application.Countries;
GO

-- Verificación
SELECT name AS Sinonimo, base_object_name AS Apunta_A
FROM sys.synonyms
ORDER BY name;
GO