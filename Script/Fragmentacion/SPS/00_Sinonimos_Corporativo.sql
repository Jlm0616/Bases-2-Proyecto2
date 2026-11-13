
USE WWI_Corporativo;
GO

-- ============================================================================
-- 00_Sinonimos_Corporativo.sql
-- Sinónimos del nodo Corporativo (datos privados + catálogos replicados
-- + vistas unificadas de ventas y compras)
-- ============================================================================

-- ============================================
-- CLIENTES - DATOS PRIVADOS
-- ============================================
CREATE SYNONYM dbo.Cli_ClientesPrivados
    FOR Sales.CustomersPrivate;

CREATE SYNONYM dbo.Cli_CategoriasCliente
    FOR Sales.CustomerCategories;

CREATE SYNONYM dbo.Cli_GruposCompra
    FOR Sales.BuyingGroups;

-- ============================================
-- PROVEEDORES
-- ============================================
CREATE SYNONYM dbo.Prov_ProveedoresPrivados
    FOR Purchasing.SuppliersPrivate;

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

CREATE SYNONYM dbo.Inv_Colores
    FOR Warehouse.Colors;

CREATE SYNONYM dbo.Inv_TiposEmpaque
    FOR Warehouse.PackageTypes;

-- ============================================
-- VENTAS - VISTAS UNIFICADAS
-- ============================================
CREATE SYNONYM dbo.Vta_OrdenesUnificadas
    FOR Sales.vw_OrdersUnificados;

CREATE SYNONYM dbo.Vta_LineasOrdenUnificadas
    FOR Sales.vw_OrderLinesUnificados;

CREATE SYNONYM dbo.Vta_FacturasUnificadas
    FOR Sales.vw_InvoicesUnificados;

CREATE SYNONYM dbo.Vta_LineasFacturaUnificadas
    FOR Sales.vw_InvoiceLinesUnificados;

-- ============================================
-- COMPRAS - VISTAS UNIFICADAS
-- ============================================
CREATE SYNONYM dbo.Cmp_OrdenesCompraUnificadas
    FOR Purchasing.vw_PurchaseOrdersUnificados;

CREATE SYNONYM dbo.Cmp_LineasOrdenCompraUnificadas
    FOR Purchasing.vw_PurchaseOrderLinesUnificados;

-- ============================================
-- TABLAS COMUNES
-- ============================================
CREATE SYNONYM dbo.Gen_PersonasPrivadas
    FOR Application.PeoplePrivate;

CREATE SYNONYM dbo.Gen_MetodosEntrega
    FOR Application.DeliveryMethods;

CREATE SYNONYM dbo.Gen_Ciudades
    FOR Application.Cities;

CREATE SYNONYM dbo.Gen_Provincias
    FOR Application.StateProvinces;

CREATE SYNONYM dbo.Gen_Paises
    FOR Application.Countries;
GO
