-- ============================================================================
-- 05_SP_Ventas_Sucursal.sql
-- SPs de Ventas para San Jose y Limon (facturacion propia de cada sucursal).
-- Para Limon: cambiar solo la linea USE.
-- ============================================================================

USE WWI_Limon;
GO

CREATE OR ALTER PROCEDURE Vta_sp_ListarVentas
    @NombreCliente   NVARCHAR(100)  = NULL,
    @FechaInicio     DATE           = NULL,
    @FechaFin        DATE           = NULL,
    @MontoMinimo     DECIMAL(18,2)  = NULL,
    @MontoMaximo     DECIMAL(18,2)  = NULL,
    @PageNumber      INT            = 1,
    @PageSize        INT            = 50
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 50;
    IF @PageSize > 500 SET @PageSize = 500;

    SELECT
        I.InvoiceID                 AS NumeroFactura,
        I.InvoiceDate               AS FechaFactura,
        C.CustomerName              AS NombreCliente,
        DM.DeliveryMethodName       AS MetodoEntrega,
        COALESCE(M.MontoTotal, 0)   AS MontoFactura
    FROM Vta_Facturas AS I
    LEFT JOIN Cli_Clientes       AS C  ON C.CustomerID        = I.CustomerID
    LEFT JOIN Gen_MetodosEntrega AS DM ON DM.DeliveryMethodID = I.DeliveryMethodID
    LEFT JOIN (
        SELECT IL.InvoiceID, SUM(IL.ExtendedPrice) AS MontoTotal
        FROM Vta_LineasFactura AS IL
        GROUP BY IL.InvoiceID
    ) AS M ON M.InvoiceID = I.InvoiceID
    WHERE (@NombreCliente IS NULL OR C.CustomerName LIKE '%' + @NombreCliente + '%')
      AND (@FechaInicio   IS NULL OR I.InvoiceDate >= @FechaInicio)
      AND (@FechaFin      IS NULL OR I.InvoiceDate <= @FechaFin)
      AND (@MontoMinimo   IS NULL OR COALESCE(M.MontoTotal, 0) >= @MontoMinimo)
      AND (@MontoMaximo   IS NULL OR COALESCE(M.MontoTotal, 0) <= @MontoMaximo)
    ORDER BY C.CustomerName ASC, I.InvoiceID ASC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE Vta_sp_ContarVentas
    @NombreCliente   NVARCHAR(100)  = NULL,
    @FechaInicio     DATE           = NULL,
    @FechaFin        DATE           = NULL,
    @MontoMinimo     DECIMAL(18,2)  = NULL,
    @MontoMaximo     DECIMAL(18,2)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS Total
    FROM Vta_Facturas AS I
    LEFT JOIN Cli_Clientes AS C ON C.CustomerID = I.CustomerID
    LEFT JOIN (
        SELECT IL.InvoiceID, SUM(IL.ExtendedPrice) AS MontoTotal
        FROM Vta_LineasFactura AS IL
        GROUP BY IL.InvoiceID
    ) AS M ON M.InvoiceID = I.InvoiceID
    WHERE (@NombreCliente IS NULL OR C.CustomerName LIKE '%' + @NombreCliente + '%')
      AND (@FechaInicio   IS NULL OR I.InvoiceDate >= @FechaInicio)
      AND (@FechaFin      IS NULL OR I.InvoiceDate <= @FechaFin)
      AND (@MontoMinimo   IS NULL OR COALESCE(M.MontoTotal, 0) >= @MontoMinimo)
      AND (@MontoMaximo   IS NULL OR COALESCE(M.MontoTotal, 0) <= @MontoMaximo);
END
GO

CREATE OR ALTER PROCEDURE Vta_sp_DetalleVenta
    @InvoiceID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Encabezado
    SELECT
        I.InvoiceID                       AS NumeroFactura,
        C.CustomerName                    AS NombreCliente,
        DM.DeliveryMethodName             AS MetodoEntrega,
        I.CustomerPurchaseOrderNumber     AS NumeroOrdenCompra,
        Contacto.FullName                 AS PersonaContacto,
        Vendedor.FullName                 AS NombreVendedor,
        I.InvoiceDate                     AS FechaFactura,
        I.DeliveryInstructions            AS InstruccionesEntrega
    FROM Vta_Facturas AS I
    LEFT JOIN Cli_Clientes       AS C        ON C.CustomerID        = I.CustomerID
    LEFT JOIN Gen_MetodosEntrega AS DM       ON DM.DeliveryMethodID = I.DeliveryMethodID
    LEFT JOIN Gen_Personas       AS Contacto ON Contacto.PersonID   = I.ContactPersonID
    LEFT JOIN Gen_Personas       AS Vendedor ON Vendedor.PersonID   = I.SalespersonPersonID
    WHERE I.InvoiceID = @InvoiceID;

    -- Lineas
    SELECT
        SI.StockItemName        AS NombreProducto,
        IL.Quantity             AS Cantidad,
        IL.UnitPrice            AS PrecioUnitario,
        IL.TaxRate              AS ImpuestoAplicado,
        IL.TaxAmount            AS MontoImpuesto,
        IL.ExtendedPrice        AS TotalPorLinea
    FROM Vta_LineasFactura AS IL
    LEFT JOIN Inv_Articulos AS SI ON SI.StockItemID = IL.StockItemID
    WHERE IL.InvoiceID = @InvoiceID;
END
GO

-- Pruebas
EXEC Vta_sp_ListarVentas @PageNumber = 1, @PageSize = 5;
EXEC Vta_sp_ContarVentas;
SELECT COUNT(*) AS FacturasReales FROM Vta_Facturas;

DECLARE @id INT = (SELECT TOP 1 InvoiceID FROM Vta_Facturas ORDER BY InvoiceID);
EXEC Vta_sp_DetalleVenta @id;
GO