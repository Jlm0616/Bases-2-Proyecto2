USE WWI_SanJose;
GO

-- ============================================================================
-- 00_Sinonimos_SanJose.sql
-- Sinónimos del nodo San José (para Limón: cambiar solo la línea USE)
-- ============================================================================

-- ============================================
-- CLIENTES
-- ============================================
CREATE SYNONYM dbo.Cli_Clientes
    FOR Sales.Customers;

CREATE SYNONYM dbo.Cli_CategoriasCliente
    FOR Sales.CustomerCategories;

CREATE SYNONYM dbo.Cli_GruposCompra
    FOR Sales.BuyingGroups;

-- ============================================
-- PROVEEDORES
-- ============================================
CREATE SYNONYM dbo.Prov_Proveedores
    FOR Purchasing.Suppliers;

CREATE SYNONYM dbo.Prov_CategoriasProveedor
    FOR Purchasing.SupplierCategories;

-- ============================================
-- INVENTARIO / PRODUCTOS
-- ============================================
CREATE SYNONYM dbo.Inv_Articulos
    FOR Warehouse.StockItems;

CREATE SYNONYM dbo.Inv_GruposArticulo
    FOR Warehouse.StockGroups;

CREATE SYNONYM dbo.Inv_ArticuloGrupo
    FOR Warehouse.StockItemStockGroups;

CREATE SYNONYM dbo.Inv_ExistenciasArticulo
    FOR Warehouse.StockItemHoldings;

CREATE SYNONYM dbo.Inv_Colores
    FOR Warehouse.Colors;

CREATE SYNONYM dbo.Inv_TiposEmpaque
    FOR Warehouse.PackageTypes;

-- ============================================
-- VENTAS
-- ============================================
CREATE SYNONYM dbo.Vta_Facturas
    FOR Sales.Invoices;

CREATE SYNONYM dbo.Vta_LineasFactura
    FOR Sales.InvoiceLines;

-- ============================================
-- COMPRAS
-- ============================================
CREATE SYNONYM dbo.Cmp_OrdenesCompra
    FOR Purchasing.PurchaseOrders;

CREATE SYNONYM dbo.Cmp_LineasOrdenCompra
    FOR Purchasing.PurchaseOrderLines;

-- ============================================
-- TABLAS COMUNES
-- ============================================
CREATE SYNONYM dbo.Gen_Personas
    FOR Application.People;

CREATE SYNONYM dbo.Gen_MetodosEntrega
    FOR Application.DeliveryMethods;

CREATE SYNONYM dbo.Gen_Ciudades
    FOR Application.Cities;

CREATE SYNONYM dbo.Gen_Provincias
    FOR Application.StateProvinces;

CREATE SYNONYM dbo.Gen_Paises
    FOR Application.Countries;
GO