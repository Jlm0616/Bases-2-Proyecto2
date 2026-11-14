-- ============================================================================
-- 05_SP_Ventas_Corporativo.sql
-- Ventas corporativas con datos generales remotos (Linked Servers).
-- SucursalID 0: historico (referencia de San Jose), 1: San Jose, 2: Limon.
-- Requiere LINK_SANJOSE y LINK_LIMON configurados en esta instancia.
-- IMPORTANTE: se presupone InvoiceID globalmente unico para facturas nuevas.
-- ============================================================================
USE WWI_Corporativo;
GO
-- Validaciones de infraestructura. Ejecutar este bloque antes de los SP.
IF OBJECT_ID(N'Sales.vw_InvoicesUnificados', N'V') IS NULL
    THROW 50001, 'Falta Sales.vw_InvoicesUnificados.', 1;
IF OBJECT_ID(N'Sales.vw_InvoiceLinesUnificados', N'V') IS NULL
    THROW 50002, 'Falta Sales.vw_InvoiceLinesUnificados.', 1;
IF OBJECT_ID(N'Application.DeliveryMethods', N'U') IS NULL
    THROW 50003, 'Falta Application.DeliveryMethods.', 1;
IF OBJECT_ID(N'Warehouse.StockItems', N'U') IS NULL
    THROW 50004, 'Falta Warehouse.StockItems.', 1;
IF NOT EXISTS (SELECT 1 FROM sys.servers WHERE name = N'LINK_SANJOSE')
    THROW 50005, 'Falta LINK_SANJOSE.', 1;
IF NOT EXISTS (SELECT 1 FROM sys.servers WHERE name = N'LINK_LIMON')
    THROW 50006, 'Falta LINK_LIMON.', 1;
GO

-- 1. Listado paginado (parametros originales mas SucursalID opcional).
CREATE OR ALTER PROCEDURE dbo.Vta_sp_ListarVentas
    @NombreCliente NVARCHAR(100) = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @MontoMinimo DECIMAL(18,2) = NULL,
    @MontoMaximo DECIMAL(18,2) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 50,
    @SucursalID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @PageNumber IS NULL OR @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize IS NULL OR @PageSize < 1 SET @PageSize = 50;
    IF @PageSize > 500 SET @PageSize = 500;
    IF @SucursalID IS NOT NULL AND @SucursalID NOT IN (0,1,2)
        THROW 50010, 'SucursalID invalido (0, 1, 2 o NULL).', 1;
    IF @FechaInicio IS NOT NULL AND @FechaFin IS NOT NULL AND @FechaInicio > @FechaFin
        THROW 50011, 'Rango de fechas invalido.', 1;
    IF @MontoMinimo IS NOT NULL AND @MontoMaximo IS NOT NULL AND @MontoMinimo > @MontoMaximo
        THROW 50012, 'Rango de montos invalido.', 1;

    ;WITH Montos AS (
        SELECT InvoiceID, SUM(ExtendedPrice) AS MontoTotal
        FROM dbo.Vta_LineasFacturaUnificadas
        GROUP BY InvoiceID
    )
    SELECT I.InvoiceID AS NumeroFactura,
           I.InvoiceDate AS FechaFactura,
           C.CustomerName AS NombreCliente,
           DM.DeliveryMethodName AS MetodoEntrega,
           COALESCE(M.MontoTotal,0) AS MontoFactura,
           I.SucursalID,
           CASE I.SucursalID WHEN 0 THEN N'Historico' WHEN 1 THEN N'San Jose'
                             WHEN 2 THEN N'Limon' END AS Sucursal
    FROM dbo.Vta_FacturasUnificadas AS I
    LEFT JOIN (
        SELECT CustomerID, CustomerName, 0 AS OrigenSucursal
        FROM [LINK_SANJOSE].[WWI_SanJose].[Sales].[Customers]
        UNION ALL
        SELECT CustomerID, CustomerName, 2 AS OrigenSucursal
        FROM [LINK_LIMON].[WWI_Limon].[Sales].[Customers]
    ) AS C
      ON C.CustomerID = I.CustomerID
     AND C.OrigenSucursal = CASE WHEN I.SucursalID = 2 THEN 2 ELSE 0 END
    LEFT JOIN Montos AS M ON M.InvoiceID = I.InvoiceID
    LEFT JOIN Application.DeliveryMethods AS DM
      ON DM.DeliveryMethodID = I.DeliveryMethodID
    WHERE (@NombreCliente IS NULL OR C.CustomerName LIKE N'%' + @NombreCliente + N'%')
      AND (@FechaInicio IS NULL OR I.InvoiceDate >= @FechaInicio)
      AND (@FechaFin IS NULL OR I.InvoiceDate <= @FechaFin)
      AND (@MontoMinimo IS NULL OR COALESCE(M.MontoTotal,0) >= @MontoMinimo)
      AND (@MontoMaximo IS NULL OR COALESCE(M.MontoTotal,0) <= @MontoMaximo)
      AND (@SucursalID IS NULL OR I.SucursalID = @SucursalID)
    ORDER BY C.CustomerName, I.InvoiceID
    OFFSET (CONVERT(BIGINT,@PageNumber)-1)*@PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- 2. Conteo con los mismos filtros.
CREATE OR ALTER PROCEDURE dbo.Vta_sp_ContarVentas
    @NombreCliente NVARCHAR(100) = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @MontoMinimo DECIMAL(18,2) = NULL,
    @MontoMaximo DECIMAL(18,2) = NULL,
    @SucursalID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @SucursalID IS NOT NULL AND @SucursalID NOT IN (0,1,2)
        THROW 50010, 'SucursalID invalido (0, 1, 2 o NULL).', 1;
    IF @FechaInicio IS NOT NULL AND @FechaFin IS NOT NULL AND @FechaInicio > @FechaFin
        THROW 50011, 'Rango de fechas invalido.', 1;
    IF @MontoMinimo IS NOT NULL AND @MontoMaximo IS NOT NULL AND @MontoMinimo > @MontoMaximo
        THROW 50012, 'Rango de montos invalido.', 1;

    ;WITH Montos AS (
        SELECT InvoiceID, SUM(ExtendedPrice) AS MontoTotal
        FROM dbo.Vta_LineasFacturaUnificadas
        GROUP BY InvoiceID
    )
    SELECT COUNT(*) AS Total
    FROM dbo.Vta_FacturasUnificadas AS I
    LEFT JOIN (
        SELECT CustomerID, CustomerName, 0 AS OrigenSucursal
        FROM [LINK_SANJOSE].[WWI_SanJose].[Sales].[Customers]
        UNION ALL
        SELECT CustomerID, CustomerName, 2 AS OrigenSucursal
        FROM [LINK_LIMON].[WWI_Limon].[Sales].[Customers]
    ) AS C
      ON C.CustomerID = I.CustomerID
     AND C.OrigenSucursal = CASE WHEN I.SucursalID = 2 THEN 2 ELSE 0 END
    LEFT JOIN Montos AS M ON M.InvoiceID = I.InvoiceID
    WHERE (@NombreCliente IS NULL OR C.CustomerName LIKE N'%' + @NombreCliente + N'%')
      AND (@FechaInicio IS NULL OR I.InvoiceDate >= @FechaInicio)
      AND (@FechaFin IS NULL OR I.InvoiceDate <= @FechaFin)
      AND (@MontoMinimo IS NULL OR COALESCE(M.MontoTotal,0) >= @MontoMinimo)
      AND (@MontoMaximo IS NULL OR COALESCE(M.MontoTotal,0) <= @MontoMaximo)
      AND (@SucursalID IS NULL OR I.SucursalID = @SucursalID);
END;
GO

-- 3. Detalle: encabezado y lineas.
CREATE OR ALTER PROCEDURE dbo.Vta_sp_DetalleVenta
    @InvoiceID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF @InvoiceID IS NULL THROW 50014, 'Debe indicar InvoiceID.', 1;

    SELECT I.InvoiceID AS NumeroFactura,
           C.CustomerName AS NombreCliente,
           DM.DeliveryMethodName AS MetodoEntrega,
           I.CustomerPurchaseOrderNumber AS NumeroOrdenCompra,
           Contacto.FullName AS PersonaContacto,
           Vendedor.FullName AS NombreVendedor,
           I.InvoiceDate AS FechaFactura,
           I.DeliveryInstructions AS InstruccionesEntrega,
           I.SucursalID,
           CASE I.SucursalID WHEN 0 THEN N'Historico' WHEN 1 THEN N'San Jose'
                             WHEN 2 THEN N'Limon' END AS Sucursal
    FROM dbo.Vta_FacturasUnificadas AS I
    LEFT JOIN (
        SELECT CustomerID, CustomerName, 0 AS OrigenSucursal
        FROM [LINK_SANJOSE].[WWI_SanJose].[Sales].[Customers]
        UNION ALL
        SELECT CustomerID, CustomerName, 2 AS OrigenSucursal
        FROM [LINK_LIMON].[WWI_Limon].[Sales].[Customers]
    ) AS C
      ON C.CustomerID = I.CustomerID
     AND C.OrigenSucursal = CASE WHEN I.SucursalID = 2 THEN 2 ELSE 0 END
    LEFT JOIN Application.DeliveryMethods AS DM
      ON DM.DeliveryMethodID = I.DeliveryMethodID
    LEFT JOIN (
        SELECT PersonID, FullName, 0 AS OrigenSucursal
        FROM [LINK_SANJOSE].[WWI_SanJose].[Application].[People]
        UNION ALL
        SELECT PersonID, FullName, 2 AS OrigenSucursal
        FROM [LINK_LIMON].[WWI_Limon].[Application].[People]
    ) AS Contacto
      ON Contacto.PersonID = I.ContactPersonID
     AND Contacto.OrigenSucursal = CASE WHEN I.SucursalID = 2 THEN 2 ELSE 0 END
    LEFT JOIN (
        SELECT PersonID, FullName, 0 AS OrigenSucursal
        FROM [LINK_SANJOSE].[WWI_SanJose].[Application].[People]
        UNION ALL
        SELECT PersonID, FullName, 2 AS OrigenSucursal
        FROM [LINK_LIMON].[WWI_Limon].[Application].[People]
    ) AS Vendedor
      ON Vendedor.PersonID = I.SalespersonPersonID
     AND Vendedor.OrigenSucursal = CASE WHEN I.SucursalID = 2 THEN 2 ELSE 0 END
    WHERE I.InvoiceID = @InvoiceID;

    SELECT SI.StockItemName AS NombreProducto,
           IL.Quantity AS Cantidad,
           IL.UnitPrice AS PrecioUnitario,
           IL.TaxRate AS ImpuestoAplicado,
           IL.TaxAmount AS MontoImpuesto,
           IL.ExtendedPrice AS TotalPorLinea
    FROM dbo.Vta_LineasFacturaUnificadas AS IL
    LEFT JOIN Warehouse.StockItems AS SI ON SI.StockItemID = IL.StockItemID
    WHERE IL.InvoiceID = @InvoiceID
    ORDER BY IL.InvoiceLineID;
END;
GO