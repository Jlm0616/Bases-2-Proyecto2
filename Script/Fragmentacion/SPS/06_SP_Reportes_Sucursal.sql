-- ============================================================================
-- 06_SP_Reportes_Sucursal.sql
-- Reportes 1 a 9 para San Jose y Limon (datos de cada sucursal).
-- El reporte 10 (metodo de envio por zona) se construye en Corporativo,
-- porque la ciudad de entrega del cliente vive alli.
-- Para Limon: cambiar solo la linea USE.
-- ============================================================================

USE WWI_SanJose;
GO

-- ============================================================================
-- Reporte 1: montos de ordenes de compra por categoria y proveedor (ROLLUP)
-- Las filas de subtotal y total llevan etiqueta en lugar de NULL.
-- ============================================================================
CREATE OR ALTER PROCEDURE Rpt_sp_MontosProveedores
    @NombreProveedor NVARCHAR(100) = NULL,
    @Categoria       NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CASE WHEN GROUPING(PC.SupplierCategoryName) = 1
             THEN 'TOTAL GENERAL'
             ELSE PC.SupplierCategoryName END          AS CategoriaProveedor,
        CASE WHEN GROUPING(PC.SupplierCategoryName) = 1
             THEN 'Todos los proveedores'
             WHEN GROUPING(P.SupplierName) = 1
             THEN 'SUBTOTAL ' + PC.SupplierCategoryName
             ELSE P.SupplierName END                   AS NombreProveedor,
        MAX(COALESCE(M.MontoTotal, 0))                 AS MontoMasAlto,
        MIN(COALESCE(M.MontoTotal, 0))                 AS MontoMasBajo,
        AVG(COALESCE(M.MontoTotal, 0))                 AS MontoPromedio
    FROM Cmp_OrdenesCompra AS PO
    JOIN Prov_Proveedores AS P ON P.SupplierID = PO.SupplierID
    JOIN Prov_CategoriasProveedor AS PC ON PC.SupplierCategoryID = P.SupplierCategoryID
    LEFT JOIN (
        SELECT POL.PurchaseOrderID,
               SUM(POL.OrderedOuters * POL.ExpectedUnitPricePerOuter) AS MontoTotal
        FROM Cmp_LineasOrdenCompra AS POL
        GROUP BY POL.PurchaseOrderID
    ) AS M ON M.PurchaseOrderID = PO.PurchaseOrderID
    WHERE (@NombreProveedor IS NULL OR P.SupplierName LIKE '%' + @NombreProveedor + '%')
      AND (@Categoria IS NULL OR PC.SupplierCategoryName LIKE '%' + @Categoria + '%')
    GROUP BY ROLLUP (PC.SupplierCategoryName, P.SupplierName)
    ORDER BY
        GROUPING(PC.SupplierCategoryName),
        PC.SupplierCategoryName,
        GROUPING(P.SupplierName),
        P.SupplierName;
END
GO

-- ============================================================================
-- Reporte 2: montos de facturas por categoria y cliente (ROLLUP)
-- Las filas de subtotal y total llevan etiqueta en lugar de NULL.
-- ============================================================================
CREATE OR ALTER PROCEDURE Rpt_sp_MontosClientes
    @NombreCliente NVARCHAR(100) = NULL,
    @Categoria     NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CASE WHEN GROUPING(CC.CustomerCategoryName) = 1
             THEN 'TOTAL GENERAL'
             ELSE CC.CustomerCategoryName END          AS CategoriaCliente,
        CASE WHEN GROUPING(CC.CustomerCategoryName) = 1
             THEN 'Todos los clientes'
             WHEN GROUPING(C.CustomerName) = 1
             THEN 'SUBTOTAL ' + CC.CustomerCategoryName
             ELSE C.CustomerName END                   AS NombreCliente,
        MAX(COALESCE(M.MontoTotal, 0))                 AS MontoMasAlto,
        MIN(COALESCE(M.MontoTotal, 0))                 AS MontoMasBajo,
        AVG(COALESCE(M.MontoTotal, 0))                 AS MontoPromedio
    FROM Vta_Facturas AS I
    JOIN Cli_Clientes AS C ON C.CustomerID = I.CustomerID
    JOIN Cli_CategoriasCliente AS CC ON CC.CustomerCategoryID = C.CustomerCategoryID
    LEFT JOIN (
        SELECT IL.InvoiceID, SUM(IL.ExtendedPrice) AS MontoTotal
        FROM Vta_LineasFactura AS IL
        GROUP BY IL.InvoiceID
    ) AS M ON M.InvoiceID = I.InvoiceID
    WHERE I.IsCreditNote = 0
      AND (@NombreCliente IS NULL OR C.CustomerName LIKE '%' + @NombreCliente + '%')
      AND (@Categoria IS NULL OR CC.CustomerCategoryName LIKE '%' + @Categoria + '%')
    GROUP BY ROLLUP (CC.CustomerCategoryName, C.CustomerName)
    ORDER BY
        GROUPING(CC.CustomerCategoryName),
        CC.CustomerCategoryName,
        GROUPING(C.CustomerName),
        C.CustomerName;
END
GO

-- ============================================================================
-- Reporte 3: top 5 productos por ganancia, por anio (DENSE_RANK)
-- ============================================================================
CREATE OR ALTER PROCEDURE Rpt_sp_Top5ProductosPorGanancia
    @Anio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH GananciaPorProducto AS (
        SELECT
            YEAR(I.InvoiceDate)      AS Anio,
            SI.StockItemID,
            SI.StockItemName         AS NombreProducto,
            SUM(IL.LineProfit)       AS GananciaTotal
        FROM Vta_LineasFactura AS IL
        JOIN Vta_Facturas AS I    ON I.InvoiceID = IL.InvoiceID
        JOIN Inv_Articulos AS SI  ON SI.StockItemID = IL.StockItemID
        WHERE I.IsCreditNote = 0
          AND (@Anio IS NULL OR YEAR(I.InvoiceDate) = @Anio)
        GROUP BY YEAR(I.InvoiceDate), SI.StockItemID, SI.StockItemName
    ),
    Ranking AS (
        SELECT
            Anio,
            NombreProducto,
            GananciaTotal,
            DENSE_RANK() OVER (PARTITION BY Anio ORDER BY GananciaTotal DESC) AS Posicion
        FROM GananciaPorProducto
    )
    SELECT Anio, Posicion, NombreProducto, GananciaTotal
    FROM Ranking
    WHERE Posicion <= 5
    ORDER BY Anio, Posicion;
END
GO

-- ============================================================================
-- Reporte 4: top 5 clientes por cantidad de facturas, por anio (DENSE_RANK)
-- ============================================================================
CREATE OR ALTER PROCEDURE Rpt_sp_Top5ClientesPorFacturas
    @AnioInicio INT = NULL,
    @AnioFin    INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH FacturasPorCliente AS (
        SELECT
            YEAR(I.InvoiceDate)                 AS Anio,
            C.CustomerID,
            C.CustomerName                      AS NombreCliente,
            COUNT(*)                            AS CantidadFacturas,
            SUM(COALESCE(M.MontoTotal, 0))      AS MontoTotalFacturado
        FROM Vta_Facturas AS I
        JOIN Cli_Clientes AS C ON C.CustomerID = I.CustomerID
        LEFT JOIN (
            SELECT IL.InvoiceID, SUM(IL.ExtendedPrice) AS MontoTotal
            FROM Vta_LineasFactura AS IL
            GROUP BY IL.InvoiceID
        ) AS M ON M.InvoiceID = I.InvoiceID
        WHERE I.IsCreditNote = 0
          AND (@AnioInicio IS NULL OR YEAR(I.InvoiceDate) >= @AnioInicio)
          AND (@AnioFin    IS NULL OR YEAR(I.InvoiceDate) <= @AnioFin)
        GROUP BY YEAR(I.InvoiceDate), C.CustomerID, C.CustomerName
    ),
    Ranking AS (
        SELECT
            Anio,
            NombreCliente,
            CantidadFacturas,
            MontoTotalFacturado,
            DENSE_RANK() OVER (PARTITION BY Anio ORDER BY CantidadFacturas DESC) AS Posicion
        FROM FacturasPorCliente
    )
    SELECT Anio, Posicion, NombreCliente, CantidadFacturas, MontoTotalFacturado
    FROM Ranking
    WHERE Posicion <= 5
    ORDER BY Anio, Posicion;
END
GO

-- ============================================================================
-- Reporte 5: top 5 proveedores por cantidad de ordenes, por anio (DENSE_RANK)
-- ============================================================================
CREATE OR ALTER PROCEDURE Rpt_sp_Top5ProveedoresPorOrdenes
    @AnioInicio INT = NULL,
    @AnioFin    INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH OrdenesPorProveedor AS (
        SELECT
            YEAR(PO.OrderDate)                  AS Anio,
            P.SupplierID,
            P.SupplierName                      AS NombreProveedor,
            COUNT(*)                            AS CantidadOrdenes,
            SUM(COALESCE(M.MontoTotal, 0))      AS MontoTotalComprado
        FROM Cmp_OrdenesCompra AS PO
        JOIN Prov_Proveedores AS P ON P.SupplierID = PO.SupplierID
        LEFT JOIN (
            SELECT POL.PurchaseOrderID,
                   SUM(POL.OrderedOuters * POL.ExpectedUnitPricePerOuter) AS MontoTotal
            FROM Cmp_LineasOrdenCompra AS POL
            GROUP BY POL.PurchaseOrderID
        ) AS M ON M.PurchaseOrderID = PO.PurchaseOrderID
        WHERE (@AnioInicio IS NULL OR YEAR(PO.OrderDate) >= @AnioInicio)
          AND (@AnioFin IS NULL OR YEAR(PO.OrderDate) <= @AnioFin)
        GROUP BY YEAR(PO.OrderDate), P.SupplierID, P.SupplierName
    ),
    Ranking AS (
        SELECT
            Anio,
            NombreProveedor,
            CantidadOrdenes,
            MontoTotalComprado,
            DENSE_RANK() OVER (PARTITION BY Anio ORDER BY CantidadOrdenes DESC) AS Posicion
        FROM OrdenesPorProveedor
    )
    SELECT Anio, Posicion, NombreProveedor, CantidadOrdenes, MontoTotalComprado
    FROM Ranking
    WHERE Posicion <= 5
    ORDER BY Anio, Posicion;
END
GO

-- ============================================================================
-- Reporte 6: matriz de ventas por categoria de producto y anio (PIVOT)
-- ============================================================================
CREATE OR ALTER PROCEDURE Rpt_sp_MatrizVentasPorCategoria
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CategoriaProducto,
        ISNULL([2013], 0) AS Anio2013,
        ISNULL([2014], 0) AS Anio2014,
        ISNULL([2015], 0) AS Anio2015,
        ISNULL([2016], 0) AS Anio2016
    FROM (
        SELECT
            SG.StockGroupName    AS CategoriaProducto,
            YEAR(I.InvoiceDate)  AS Anio,
            IL.ExtendedPrice     AS Monto
        FROM Vta_LineasFactura AS IL
        JOIN Vta_Facturas AS I ON I.InvoiceID = IL.InvoiceID
        LEFT JOIN (
            SELECT AG.StockItemID, GA.StockGroupName,
                   ROW_NUMBER() OVER (PARTITION BY AG.StockItemID ORDER BY GA.StockGroupName) AS rn
            FROM Inv_ArticuloGrupo AS AG
            JOIN Inv_GruposArticulo AS GA ON GA.StockGroupID = AG.StockGroupID
        ) AS SG ON SG.StockItemID = IL.StockItemID AND SG.rn = 1
        WHERE I.IsCreditNote = 0
    ) AS Origen
    PIVOT (
        SUM(Monto) FOR Anio IN ([2013], [2014], [2015], [2016])
    ) AS Matriz
    ORDER BY CategoriaProducto;
END
GO

-- ============================================================================
-- Reporte 7: seguimiento mensual de compras por cliente
-- ============================================================================
CREATE OR ALTER PROCEDURE Rpt_sp_SeguimientoComprasCliente
    @Anio         INT           = NULL,
    @Mes          INT           = NULL,
    @Categoria    NVARCHAR(100) = NULL,
    @Subcategoria NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.CustomerID                       AS IdCliente,
        C.CustomerName                     AS NombreCliente,
        YEAR(I.InvoiceDate)                AS Anio,
        MONTH(I.InvoiceDate)               AS Mes,
        MIN(I.InvoiceDate)                 AS PrimeraFacturaDelMes,
        MAX(I.InvoiceDate)                 AS UltimaFacturaDelMes,
        SUM(IL.ExtendedPrice)              AS MontoTotalComprado,
        SUM(IL.Quantity)                   AS CantidadTotalComprada,
        MIN(IL.Quantity)                   AS CantidadMinimaPorLinea,
        MAX(IL.Quantity)                   AS CantidadMaximaPorLinea
    FROM Vta_LineasFactura AS IL
    JOIN Vta_Facturas AS I  ON I.InvoiceID = IL.InvoiceID
    JOIN Cli_Clientes AS C  ON C.CustomerID = I.CustomerID
    WHERE I.IsCreditNote = 0
      AND (@Anio IS NULL OR YEAR(I.InvoiceDate) = @Anio)
      AND (@Mes  IS NULL OR MONTH(I.InvoiceDate) = @Mes)
      AND (@Categoria IS NULL OR EXISTS (
              SELECT 1
              FROM Inv_ArticuloGrupo AS AG
              JOIN Inv_GruposArticulo AS SG ON SG.StockGroupID = AG.StockGroupID
              WHERE AG.StockItemID = IL.StockItemID
                AND SG.StockGroupName = @Categoria
          ))
      AND (@Subcategoria IS NULL OR EXISTS (
              SELECT 1
              FROM Inv_ArticuloGrupo AS AG
              JOIN Inv_GruposArticulo AS SG ON SG.StockGroupID = AG.StockGroupID
              WHERE AG.StockItemID = IL.StockItemID
                AND SG.StockGroupName = @Subcategoria
          ))
    GROUP BY C.CustomerID, C.CustomerName, YEAR(I.InvoiceDate), MONTH(I.InvoiceDate)
    ORDER BY C.CustomerName, Anio, Mes;
END
GO

-- ============================================================================
-- Reporte 8: seguimiento mensual de compras por proveedor
-- ============================================================================
CREATE OR ALTER PROCEDURE Rpt_sp_SeguimientoComprasProveedor
    @Anio         INT           = NULL,
    @Mes          INT           = NULL,
    @Categoria    NVARCHAR(100) = NULL,
    @Subcategoria NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.SupplierID                        AS IdProveedor,
        P.SupplierName                      AS NombreProveedor,
        YEAR(PO.OrderDate)                  AS Anio,
        MONTH(PO.OrderDate)                 AS Mes,
        MIN(PO.OrderDate)                   AS PrimeraOrdenDelMes,
        MAX(PO.OrderDate)                   AS UltimaOrdenDelMes,
        SUM(POL.OrderedOuters * POL.ExpectedUnitPricePerOuter) AS MontoTotalComprado,
        SUM(POL.OrderedOuters)              AS CantidadTotalComprada,
        MIN(POL.OrderedOuters)              AS CantidadMinimaPorLinea,
        MAX(POL.OrderedOuters)              AS CantidadMaximaPorLinea
    FROM Cmp_LineasOrdenCompra AS POL
    JOIN Cmp_OrdenesCompra AS PO ON PO.PurchaseOrderID = POL.PurchaseOrderID
    JOIN Prov_Proveedores AS P   ON P.SupplierID = PO.SupplierID
    WHERE (@Anio IS NULL OR YEAR(PO.OrderDate) = @Anio)
      AND (@Mes  IS NULL OR MONTH(PO.OrderDate) = @Mes)
      AND (@Categoria IS NULL OR EXISTS (
              SELECT 1
              FROM Inv_ArticuloGrupo AS AG
              JOIN Inv_GruposArticulo AS SG ON SG.StockGroupID = AG.StockGroupID
              WHERE AG.StockItemID = POL.StockItemID
                AND SG.StockGroupName = @Categoria
          ))
      AND (@Subcategoria IS NULL OR EXISTS (
              SELECT 1
              FROM Inv_ArticuloGrupo AS AG
              JOIN Inv_GruposArticulo AS SG ON SG.StockGroupID = AG.StockGroupID
              WHERE AG.StockItemID = POL.StockItemID
                AND SG.StockGroupName = @Subcategoria
          ))
    GROUP BY P.SupplierID, P.SupplierName, YEAR(PO.OrderDate), MONTH(PO.OrderDate)
    ORDER BY P.SupplierName, Anio, Mes;
END
GO

-- ============================================================================
-- Reporte 9: rotacion de inventario (LAG)
-- ============================================================================
CREATE OR ALTER PROCEDURE Rpt_sp_RotacionInventario
    @Categoria  NVARCHAR(100) = NULL,
    @Anio       INT           = NULL,
    @Proveedor  NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH VentasProducto AS (
        SELECT
            SI.StockItemID,
            SI.StockItemName    AS NombreProducto,
            SG.StockGroupName   AS Categoria,
            PR.SupplierName     AS Proveedor,
            I.InvoiceDate,
            LAG(I.InvoiceDate) OVER (PARTITION BY SI.StockItemID ORDER BY I.InvoiceDate) AS FechaVentaAnterior
        FROM Vta_LineasFactura AS IL
        JOIN Vta_Facturas AS I       ON I.InvoiceID = IL.InvoiceID
        JOIN Inv_Articulos AS SI     ON SI.StockItemID = IL.StockItemID
        JOIN Prov_Proveedores AS PR  ON PR.SupplierID = SI.SupplierID
        LEFT JOIN (
            SELECT AG.StockItemID, GA.StockGroupName,
                   ROW_NUMBER() OVER (PARTITION BY AG.StockItemID ORDER BY GA.StockGroupName) AS rn
            FROM Inv_ArticuloGrupo AS AG
            JOIN Inv_GruposArticulo AS GA ON GA.StockGroupID = AG.StockGroupID
        ) AS SG ON SG.StockItemID = SI.StockItemID AND SG.rn = 1
        WHERE (@Anio      IS NULL OR YEAR(I.InvoiceDate) = @Anio)
          AND (@Categoria IS NULL OR SG.StockGroupName LIKE '%' + @Categoria + '%')
          AND (@Proveedor IS NULL OR PR.SupplierName LIKE '%' + @Proveedor + '%')
    )
    SELECT
        StockItemID       AS IdProducto,
        NombreProducto,
        Categoria,
        Proveedor,
        AVG(DATEDIFF(DAY, FechaVentaAnterior, InvoiceDate) * 1.0) AS DiasPromedioRotacion
    FROM VentasProducto
    WHERE FechaVentaAnterior IS NOT NULL
    GROUP BY StockItemID, NombreProducto, Categoria, Proveedor
    ORDER BY DiasPromedioRotacion ASC;
END
GO

-- ============================================================================
-- Pruebas: una por reporte
-- ============================================================================
EXEC Rpt_sp_MontosProveedores;
EXEC Rpt_sp_MontosClientes @Categoria = 'Novelty';
EXEC Rpt_sp_Top5ProductosPorGanancia @Anio = 2013;
EXEC Rpt_sp_Top5ClientesPorFacturas @AnioInicio = 2013, @AnioFin = 2013;
EXEC Rpt_sp_Top5ProveedoresPorOrdenes @AnioInicio = 2013, @AnioFin = 2013;
EXEC Rpt_sp_MatrizVentasPorCategoria;
EXEC Rpt_sp_SeguimientoComprasCliente @Anio = 2013, @Mes = 1;
EXEC Rpt_sp_SeguimientoComprasProveedor @Anio = 2013, @Mes = 1;
EXEC Rpt_sp_RotacionInventario @Anio = 2013;
GO
