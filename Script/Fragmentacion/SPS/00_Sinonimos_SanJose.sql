USE WWI_SanJose;
GO

-- ============================================================================
-- 00_Sinonimos_SanJose.sql
-- Sinónimos del nodo San José (para Limón: cambiar solo la línea USE)
-- ============================================================================

-- Clientes
DROP SYNONYM IF EXISTS Cli_Clientes;
DROP SYNONYM IF EXISTS Cli_CategoriasCliente;
DROP SYNONYM IF EXISTS Cli_GruposCompra;
CREATE SYNONYM Cli_Clientes          FOR Sales.Customers;
CREATE SYNONYM Cli_CategoriasCliente FOR Sales.CustomerCategories;
CREATE SYNONYM Cli_GruposCompra      FOR Sales.BuyingGroups;

-- Proveedores
DROP SYNONYM IF EXISTS Prov_Proveedores;
DROP SYNONYM IF EXISTS Prov_CategoriasProveedor;
CREATE SYNONYM Prov_Proveedores         FOR Purchasing.Suppliers;
CREATE SYNONYM Prov_CategoriasProveedor FOR Purchasing.SupplierCategories;

-- Inventario / Productos
DROP SYNONYM IF EXISTS Inv_Articulos;
DROP SYNONYM IF EXISTS Inv_GruposArticulo;
DROP SYNONYM IF EXISTS Inv_ArticuloGrupo;
DROP SYNONYM IF EXISTS Inv_ExistenciasArticulo;
DROP SYNONYM IF EXISTS Inv_Colores;
DROP SYNONYM IF EXISTS Inv_TiposEmpaque;
CREATE SYNONYM Inv_Articulos           FOR Warehouse.StockItems;
CREATE SYNONYM Inv_GruposArticulo      FOR Warehouse.StockGroups;
CREATE SYNONYM Inv_ArticuloGrupo       FOR Warehouse.StockItemStockGroups;
CREATE SYNONYM Inv_ExistenciasArticulo FOR Warehouse.StockItemHoldings;
CREATE SYNONYM Inv_Colores             FOR Warehouse.Colors;
CREATE SYNONYM Inv_TiposEmpaque        FOR Warehouse.PackageTypes;

-- Ventas
DROP SYNONYM IF EXISTS Vta_Facturas;
DROP SYNONYM IF EXISTS Vta_LineasFactura;
CREATE SYNONYM Vta_Facturas      FOR Sales.Invoices;
CREATE SYNONYM Vta_LineasFactura FOR Sales.InvoiceLines;

-- Compras
DROP SYNONYM IF EXISTS Cmp_OrdenesCompra;
DROP SYNONYM IF EXISTS Cmp_LineasOrdenCompra;
CREATE SYNONYM Cmp_OrdenesCompra     FOR Purchasing.PurchaseOrders;
CREATE SYNONYM Cmp_LineasOrdenCompra FOR Purchasing.PurchaseOrderLines;

-- Comunes
DROP SYNONYM IF EXISTS Gen_Personas;
DROP SYNONYM IF EXISTS Gen_MetodosEntrega;
DROP SYNONYM IF EXISTS Gen_Ciudades;
DROP SYNONYM IF EXISTS Gen_Provincias;
DROP SYNONYM IF EXISTS Gen_Paises;
CREATE SYNONYM Gen_Personas       FOR Application.People;
CREATE SYNONYM Gen_MetodosEntrega FOR Application.DeliveryMethods;
CREATE SYNONYM Gen_Ciudades       FOR Application.Cities;
CREATE SYNONYM Gen_Provincias     FOR Application.StateProvinces;
CREATE SYNONYM Gen_Paises         FOR Application.Countries;
GO

-- Verificación
SELECT name AS Sinonimo, base_object_name AS Apunta_A
FROM sys.synonyms
ORDER BY name;
GO