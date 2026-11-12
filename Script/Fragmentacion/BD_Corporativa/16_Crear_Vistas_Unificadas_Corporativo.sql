-- ============================================
-- 16_Crear_Vistas_Unificadas_Corporativo.sql
-- ============================================

USE WWI_Corporativo;
GO

-- ============================================
-- 1. VISTA UNIFICADA DE PEDIDOS
-- ============================================

CREATE OR ALTER VIEW Sales.vw_OrdersUnificados
AS
    SELECT *
    FROM Sales.OrdersSanJose

    UNION ALL

    SELECT *
    FROM Sales.OrdersLimon
    WHERE SucursalID = 2;
GO

-- ============================================
-- 2. VISTA UNIFICADA DE DETALLES DE PEDIDOS
-- ============================================

CREATE OR ALTER VIEW Sales.vw_OrderLinesUnificados
AS
    SELECT *
    FROM Sales.OrderLinesSanJose

    UNION ALL

    SELECT *
    FROM Sales.OrderLinesLimon
    WHERE SucursalID = 2;
GO

-- ============================================
-- 3. VISTA UNIFICADA DE FACTURAS
-- ============================================

CREATE OR ALTER VIEW Sales.vw_InvoicesUnificados
AS
    SELECT *
    FROM Sales.InvoicesSanJose

    UNION ALL

    SELECT *
    FROM Sales.InvoicesLimon
    WHERE SucursalID = 2;
GO

-- ============================================
-- 4. VISTA UNIFICADA DE DETALLES DE FACTURAS
-- ============================================

CREATE OR ALTER VIEW Sales.vw_InvoiceLinesUnificados
AS
    SELECT *
    FROM Sales.InvoiceLinesSanJose

    UNION ALL

    SELECT *
    FROM Sales.InvoiceLinesLimon
    WHERE SucursalID = 2;
GO

-- ============================================
-- 5. VISTA UNIFICADA DE ORDENES DE COMPRA
-- ============================================

CREATE OR ALTER VIEW Purchasing.vw_PurchaseOrdersUnificados
AS
    SELECT *
    FROM Purchasing.PurchaseOrdersSanJose

    UNION ALL

    SELECT *
    FROM Purchasing.PurchaseOrdersLimon
    WHERE SucursalID = 2;
GO

-- ============================================
-- 6. VISTA UNIFICADA DE DETALLES DE ORDENES
-- ============================================

CREATE OR ALTER VIEW Purchasing.vw_PurchaseOrderLinesUnificados
AS
    SELECT *
    FROM Purchasing.PurchaseOrderLinesSanJose

    UNION ALL

    SELECT *
    FROM Purchasing.PurchaseOrderLinesLimon
    WHERE SucursalID = 2;
GO
