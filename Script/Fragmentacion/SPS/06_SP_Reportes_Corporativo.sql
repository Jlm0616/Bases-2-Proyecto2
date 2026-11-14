USE WWI_Corporativo;
GO

-- ============================================================
-- REPORTE 01: MONTOS DE PROVEEDORES
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Rpt_sp_MontosProveedores
    @NombreProveedor NVARCHAR(100) = NULL,
    @Categoria NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Proveedores AS (
        SELECT
            SupplierID,
            SupplierName,
            SupplierCategoryID
        FROM [LINK_SANJOSE].[WWI_SanJose].[Purchasing].[Suppliers]

        UNION ALL

        SELECT
            L.SupplierID,
            L.SupplierName,
            L.SupplierCategoryID
        FROM [LINK_LIMON].[WWI_Limon].[Purchasing].[Suppliers] AS L
        WHERE NOT EXISTS (
            SELECT 1
            FROM [LINK_SANJOSE].[WWI_SanJose].[Purchasing].[Suppliers] AS SJ
            WHERE SJ.SupplierID = L.SupplierID
        )
    ),
    MontosOrdenes AS (
        SELECT
            O.SucursalID,
            O.PurchaseOrderID,
            O.SupplierID,
            SUM(
                L.OrderedOuters *
                L.ExpectedUnitPricePerOuter
            ) AS MontoTotal
        FROM dbo.Cmp_OrdenesCompraUnificadas AS O
        INNER JOIN dbo.Cmp_LineasOrdenCompraUnificadas AS L
            ON L.PurchaseOrderID = O.PurchaseOrderID
           AND L.SucursalID = O.SucursalID
        GROUP BY
            O.SucursalID,
            O.PurchaseOrderID,
            O.SupplierID
    )
    SELECT
        CASE
            WHEN GROUPING(C.SupplierCategoryName) = 1
                THEN N'TOTAL GENERAL'
            ELSE C.SupplierCategoryName
        END AS CategoriaProveedor,

        CASE
            WHEN GROUPING(C.SupplierCategoryName) = 1
                THEN N'TOTAL GENERAL'
            WHEN GROUPING(P.SupplierName) = 1
                THEN N'SUBTOTAL'
            ELSE P.SupplierName
        END AS Proveedor,

        MAX(M.MontoTotal) AS MontoMaximo,
        MIN(M.MontoTotal) AS MontoMinimo,
        AVG(M.MontoTotal) AS MontoPromedio

    FROM MontosOrdenes AS M

    INNER JOIN Proveedores AS P
        ON P.SupplierID = M.SupplierID

    INNER JOIN dbo.Prov_CategoriasProveedor AS C
        ON C.SupplierCategoryID = P.SupplierCategoryID

    WHERE
        (
            @NombreProveedor IS NULL
            OR P.SupplierName LIKE N'%' + @NombreProveedor + N'%'
        )
        AND
        (
            @Categoria IS NULL
            OR C.SupplierCategoryName LIKE N'%' + @Categoria + N'%'
        )

    GROUP BY ROLLUP (
        C.SupplierCategoryName,
        P.SupplierName
    )

    ORDER BY
        GROUPING(C.SupplierCategoryName),
        C.SupplierCategoryName,
        GROUPING(P.SupplierName),
        P.SupplierName;
END;
GO

-- ============================================================
-- REPORTE 02: MONTOS DE CLIENTES
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Rpt_sp_MontosClientes
    @NombreCliente NVARCHAR(100) = NULL,
    @Categoria NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Clientes AS (
        SELECT
            CustomerID,
            CustomerName,
            CustomerCategoryID
        FROM [LINK_SANJOSE].[WWI_SanJose].[Sales].[Customers]

        UNION ALL

        SELECT
            L.CustomerID,
            L.CustomerName,
            L.CustomerCategoryID
        FROM [LINK_LIMON].[WWI_Limon].[Sales].[Customers] AS L
        WHERE NOT EXISTS (
            SELECT 1
            FROM [LINK_SANJOSE].[WWI_SanJose].[Sales].[Customers] AS SJ
            WHERE SJ.CustomerID = L.CustomerID
        )
    ),
    MontosFacturas AS (
        SELECT
            F.SucursalID,
            F.InvoiceID,
            F.CustomerID,
            SUM(L.ExtendedPrice) AS MontoTotal
        FROM dbo.Vta_FacturasUnificadas AS F
        INNER JOIN dbo.Vta_LineasFacturaUnificadas AS L
            ON L.InvoiceID = F.InvoiceID
           AND L.SucursalID = F.SucursalID
        GROUP BY
            F.SucursalID,
            F.InvoiceID,
            F.CustomerID
    )
    SELECT
        CASE
            WHEN GROUPING(C.CustomerCategoryName) = 1
                THEN N'TOTAL GENERAL'
            ELSE C.CustomerCategoryName
        END AS CategoriaCliente,

        CASE
            WHEN GROUPING(CL.CustomerName) = 1
                 AND GROUPING(C.CustomerCategoryName) = 1
                THEN N'TOTAL GENERAL'
            WHEN GROUPING(CL.CustomerName) = 1
                THEN N'SUBTOTAL'
            ELSE CL.CustomerName
        END AS Cliente,

        MAX(M.MontoTotal) AS MontoMaximo,
        MIN(M.MontoTotal) AS MontoMinimo,
        AVG(M.MontoTotal) AS MontoPromedio

    FROM MontosFacturas AS M

    INNER JOIN Clientes AS CL
        ON CL.CustomerID = M.CustomerID

    INNER JOIN dbo.Cli_CategoriasCliente AS C
        ON C.CustomerCategoryID = CL.CustomerCategoryID

    WHERE
        (
            @NombreCliente IS NULL
            OR CL.CustomerName LIKE N'%' + @NombreCliente + N'%'
        )
        AND
        (
            @Categoria IS NULL
            OR C.CustomerCategoryName LIKE N'%' + @Categoria + N'%'
        )

    GROUP BY ROLLUP (
        C.CustomerCategoryName,
        CL.CustomerName
    )

    ORDER BY
        GROUPING(C.CustomerCategoryName),
        C.CustomerCategoryName,
        GROUPING(CL.CustomerName),
        CL.CustomerName;
END;
GO

-- ============================================================
-- REPORTE 03: TOP 5 PRODUCTOS POR GANANCIA
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Rpt_sp_Top5ProductosPorGanancia
    @Anio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH GananciasProductos AS (
        SELECT
            YEAR(F.InvoiceDate) AS Anio,
            L.StockItemID,
            SUM(L.LineProfit) AS GananciaTotal
        FROM dbo.Vta_FacturasUnificadas AS F
        INNER JOIN dbo.Vta_LineasFacturaUnificadas AS L
            ON L.InvoiceID = F.InvoiceID
           AND L.SucursalID = F.SucursalID
        WHERE
            @Anio IS NULL
            OR YEAR(F.InvoiceDate) = @Anio
        GROUP BY
            YEAR(F.InvoiceDate),
            L.StockItemID
    ),
    Productos AS (
        SELECT
            StockItemID,
            StockItemName
        FROM [LINK_SANJOSE].[WWI_SanJose].[Warehouse].[StockItems]

        UNION ALL

        SELECT
            L.StockItemID,
            L.StockItemName
        FROM [LINK_LIMON].[WWI_Limon].[Warehouse].[StockItems] AS L
        WHERE NOT EXISTS (
            SELECT 1
            FROM [LINK_SANJOSE].[WWI_SanJose].[Warehouse].[StockItems] AS SJ
            WHERE SJ.StockItemID = L.StockItemID
        )
    ),
    Ranking AS (
        SELECT
            G.Anio,
            G.StockItemID,
            P.StockItemName AS Producto,
            G.GananciaTotal,
            DENSE_RANK() OVER (
                PARTITION BY G.Anio
                ORDER BY G.GananciaTotal DESC
            ) AS Posicion
        FROM GananciasProductos AS G
        INNER JOIN Productos AS P
            ON P.StockItemID = G.StockItemID
    )
    SELECT
        Anio,
        Posicion,
        StockItemID,
        Producto,
        GananciaTotal
    FROM Ranking
    WHERE Posicion <= 5
    ORDER BY
        Anio,
        Posicion,
        Producto;
END;
GO

-- ============================================================
-- REPORTE 04: TOP 5 CLIENTES POR FACTURAS
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Rpt_sp_Top5ClientesPorFacturas
    @AnioInicio INT = NULL,
    @AnioFin INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Clientes AS (
        SELECT
            CustomerID,
            CustomerName
        FROM [LINK_SANJOSE].[WWI_SanJose].[Sales].[Customers]

        UNION ALL

        SELECT
            L.CustomerID,
            L.CustomerName
        FROM [LINK_LIMON].[WWI_Limon].[Sales].[Customers] AS L
        WHERE NOT EXISTS (
            SELECT 1
            FROM [LINK_SANJOSE].[WWI_SanJose].[Sales].[Customers] AS SJ
            WHERE SJ.CustomerID = L.CustomerID
        )
    ),
    MontosFacturas AS (
        SELECT
            F.SucursalID,
            F.InvoiceID,
            F.CustomerID,
            YEAR(F.InvoiceDate) AS Anio,
            SUM(L.ExtendedPrice) AS MontoFactura
        FROM dbo.Vta_FacturasUnificadas AS F
        INNER JOIN dbo.Vta_LineasFacturaUnificadas AS L
            ON L.InvoiceID = F.InvoiceID
           AND L.SucursalID = F.SucursalID
        WHERE
            (@AnioInicio IS NULL OR YEAR(F.InvoiceDate) >= @AnioInicio)
            AND
            (@AnioFin IS NULL OR YEAR(F.InvoiceDate) <= @AnioFin)
        GROUP BY
            F.SucursalID,
            F.InvoiceID,
            F.CustomerID,
            YEAR(F.InvoiceDate)
    ),
    TotalesClientes AS (
        SELECT
            M.Anio,
            M.CustomerID,
            COUNT(*) AS CantidadFacturas,
            SUM(M.MontoFactura) AS MontoTotal
        FROM MontosFacturas AS M
        GROUP BY
            M.Anio,
            M.CustomerID
    ),
    Ranking AS (
        SELECT
            T.Anio,
            T.CustomerID,
            C.CustomerName AS Cliente,
            T.CantidadFacturas,
            T.MontoTotal,
            DENSE_RANK() OVER (
                PARTITION BY T.Anio
                ORDER BY T.CantidadFacturas DESC
            ) AS Posicion
        FROM TotalesClientes AS T
        INNER JOIN Clientes AS C
            ON C.CustomerID = T.CustomerID
    )
    SELECT
        Anio,
        Posicion,
        CustomerID,
        Cliente,
        CantidadFacturas,
        MontoTotal
    FROM Ranking
    WHERE Posicion <= 5
    ORDER BY
        Anio,
        Posicion,
        MontoTotal DESC,
        Cliente;
END;
GO

-- ============================================================
-- REPORTE 05: TOP 5 PROVEEDORES POR ÓRDENES DE COMPRA
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Rpt_sp_Top5ProveedoresPorOrdenes
    @AnioInicio INT = NULL,
    @AnioFin INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Proveedores AS (
        SELECT
            SupplierID,
            SupplierName
        FROM [LINK_SANJOSE].[WWI_SanJose].[Purchasing].[Suppliers]

        UNION ALL

        SELECT
            L.SupplierID,
            L.SupplierName
        FROM [LINK_LIMON].[WWI_Limon].[Purchasing].[Suppliers] AS L
        WHERE NOT EXISTS (
            SELECT 1
            FROM [LINK_SANJOSE].[WWI_SanJose].[Purchasing].[Suppliers] AS SJ
            WHERE SJ.SupplierID = L.SupplierID
        )
    ),
    MontosOrdenes AS (
        SELECT
            O.SucursalID,
            O.PurchaseOrderID,
            O.SupplierID,
            YEAR(O.OrderDate) AS Anio,
            SUM(
                L.OrderedOuters * L.ExpectedUnitPricePerOuter
            ) AS MontoOrden
        FROM dbo.Cmp_OrdenesCompraUnificadas AS O
        INNER JOIN dbo.Cmp_LineasOrdenCompraUnificadas AS L
            ON L.PurchaseOrderID = O.PurchaseOrderID
           AND L.SucursalID = O.SucursalID
        WHERE
            (@AnioInicio IS NULL OR YEAR(O.OrderDate) >= @AnioInicio)
            AND
            (@AnioFin IS NULL OR YEAR(O.OrderDate) <= @AnioFin)
        GROUP BY
            O.SucursalID,
            O.PurchaseOrderID,
            O.SupplierID,
            YEAR(O.OrderDate)
    ),
    TotalesProveedores AS (
        SELECT
            M.Anio,
            M.SupplierID,
            COUNT(*) AS CantidadOrdenes,
            SUM(M.MontoOrden) AS MontoTotal
        FROM MontosOrdenes AS M
        GROUP BY
            M.Anio,
            M.SupplierID
    ),
    Ranking AS (
        SELECT
            T.Anio,
            T.SupplierID,
            P.SupplierName AS Proveedor,
            T.CantidadOrdenes,
            T.MontoTotal,
            DENSE_RANK() OVER (
                PARTITION BY T.Anio
                ORDER BY T.CantidadOrdenes DESC
            ) AS Posicion
        FROM TotalesProveedores AS T
        INNER JOIN Proveedores AS P
            ON P.SupplierID = T.SupplierID
    )
    SELECT
        Anio,
        Posicion,
        SupplierID,
        Proveedor,
        CantidadOrdenes,
        MontoTotal
    FROM Ranking
    WHERE Posicion <= 5
    ORDER BY
        Anio,
        Posicion,
        MontoTotal DESC,
        Proveedor;
END;
GO

-- ============================================================
-- REPORTE 06: MATRIZ DE VENTAS POR CATEGORÍA (PIVOT)
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Rpt_sp_MatrizVentasPorCategoria
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH VentasPorCategoria AS (
        SELECT
            SG.StockGroupName AS Categoria,
            YEAR(F.InvoiceDate) AS Anio,
            L.ExtendedPrice AS MontoVenta
        FROM dbo.Vta_FacturasUnificadas AS F
        INNER JOIN dbo.Vta_LineasFacturaUnificadas AS L
            ON L.InvoiceID = F.InvoiceID
           AND L.SucursalID = F.SucursalID
        INNER JOIN [Warehouse].[StockItemStockGroups] AS SISG
            ON SISG.StockItemID = L.StockItemID
        INNER JOIN [Warehouse].[StockGroups] AS SG
            ON SG.StockGroupID = SISG.StockGroupID
        WHERE YEAR(F.InvoiceDate) BETWEEN 2013 AND 2016
    )
    SELECT
        Categoria,
        ISNULL([2013], 0) AS [2013],
        ISNULL([2014], 0) AS [2014],
        ISNULL([2015], 0) AS [2015],
        ISNULL([2016], 0) AS [2016],
        ISNULL([2013], 0)
        + ISNULL([2014], 0)
        + ISNULL([2015], 0)
        + ISNULL([2016], 0) AS TotalVentas
    FROM VentasPorCategoria
    PIVOT (
        SUM(MontoVenta)
        FOR Anio IN ([2013], [2014], [2015], [2016])
    ) AS P
    ORDER BY TotalVentas DESC;
END;
GO

-- ============================================================
-- REPORTE 07: SEGUIMIENTO DE COMPRAS POR CLIENTE
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Rpt_sp_SeguimientoComprasCliente
    @Anio INT = NULL,
    @Mes INT = NULL,
    @Categoria NVARCHAR(100) = NULL,
    @Subcategoria NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Clientes AS (
        SELECT
            CustomerID,
            CustomerName
        FROM [LINK_SANJOSE].[WWI_SanJose].[Sales].[Customers]

        UNION ALL

        SELECT
            L.CustomerID,
            L.CustomerName
        FROM [LINK_LIMON].[WWI_Limon].[Sales].[Customers] AS L
        WHERE NOT EXISTS (
            SELECT 1
            FROM [LINK_SANJOSE].[WWI_SanJose].[Sales].[Customers] AS SJ
            WHERE SJ.CustomerID = L.CustomerID
        )
    ),
    Compras AS (
        SELECT
            YEAR(F.InvoiceDate) AS Anio,
            MONTH(F.InvoiceDate) AS Mes,
            F.InvoiceDate,
            F.CustomerID,
            F.SucursalID,
            F.InvoiceID,
            L.StockItemID,
            L.Quantity,
            L.ExtendedPrice
        FROM dbo.Vta_FacturasUnificadas AS F
        INNER JOIN dbo.Vta_LineasFacturaUnificadas AS L
            ON L.InvoiceID = F.InvoiceID
           AND L.SucursalID = F.SucursalID
        WHERE
            (@Anio IS NULL OR YEAR(F.InvoiceDate) = @Anio)
            AND (@Mes IS NULL OR MONTH(F.InvoiceDate) = @Mes)
            AND (
                @Categoria IS NULL
                OR EXISTS (
                    SELECT 1
                    FROM Warehouse.StockItemStockGroups AS SISG
                    INNER JOIN Warehouse.StockGroups AS SG
                        ON SG.StockGroupID = SISG.StockGroupID
                    WHERE SISG.StockItemID = L.StockItemID
                      AND SG.StockGroupName
                          LIKE N'%' + @Categoria + N'%'
                )
            )
            AND (
                @Subcategoria IS NULL
                OR EXISTS (
                    SELECT 1
                    FROM Warehouse.StockItemStockGroups AS SISG
                    INNER JOIN Warehouse.StockGroups AS SG
                        ON SG.StockGroupID = SISG.StockGroupID
                    WHERE SISG.StockItemID = L.StockItemID
                      AND SG.StockGroupName
                          LIKE N'%' + @Subcategoria + N'%'
                )
            )
    )
    SELECT
        C.CustomerID AS IdCliente,
        CL.CustomerName AS NombreCliente,
        C.Anio,
        C.Mes,

        MIN(C.InvoiceDate) AS PrimeraFacturaDelMes,
        MAX(C.InvoiceDate) AS UltimaFacturaDelMes,

        COUNT(DISTINCT CONCAT(
            C.SucursalID, ':', C.InvoiceID
        )) AS CantidadFacturas,

        SUM(C.ExtendedPrice) AS MontoTotalComprado,
        SUM(C.Quantity) AS CantidadTotalComprada,

        MIN(C.Quantity) AS CantidadMinimaPorLinea,
        MAX(C.Quantity) AS CantidadMaximaPorLinea

    FROM Compras AS C
    INNER JOIN Clientes AS CL
        ON CL.CustomerID = C.CustomerID
    GROUP BY
        C.CustomerID,
        CL.CustomerName,
        C.Anio,
        C.Mes
    ORDER BY
        CL.CustomerName,
        C.Anio,
        C.Mes;
END;
GO

-- ============================================================
-- REPORTE 08: SEGUIMIENTO DE COMPRAS POR PROVEEDOR
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Rpt_sp_SeguimientoComprasProveedor
    @Anio INT = NULL,
    @Mes INT = NULL,
    @Categoria NVARCHAR(100) = NULL,
    @Subcategoria NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Proveedores AS (
        SELECT
            SupplierID,
            SupplierName
        FROM [LINK_SANJOSE].[WWI_SanJose].[Purchasing].[Suppliers]

        UNION ALL

        SELECT
            L.SupplierID,
            L.SupplierName
        FROM [LINK_LIMON].[WWI_Limon].[Purchasing].[Suppliers] AS L
        WHERE NOT EXISTS (
            SELECT 1
            FROM [LINK_SANJOSE].[WWI_SanJose].[Purchasing].[Suppliers] AS SJ
            WHERE SJ.SupplierID = L.SupplierID
        )
    ),
    Compras AS (
        SELECT
            YEAR(O.OrderDate) AS Anio,
            MONTH(O.OrderDate) AS Mes,
            O.OrderDate,
            O.SupplierID,
            O.SucursalID,
            O.PurchaseOrderID,
            L.StockItemID,
            L.OrderedOuters,
            L.ExpectedUnitPricePerOuter,
            L.OrderedOuters * L.ExpectedUnitPricePerOuter
                AS MontoCompra
        FROM dbo.Cmp_OrdenesCompraUnificadas AS O
        INNER JOIN dbo.Cmp_LineasOrdenCompraUnificadas AS L
            ON L.PurchaseOrderID = O.PurchaseOrderID
           AND L.SucursalID = O.SucursalID
        WHERE
            (@Anio IS NULL OR YEAR(O.OrderDate) = @Anio)
            AND (@Mes IS NULL OR MONTH(O.OrderDate) = @Mes)
            AND (
                @Categoria IS NULL
                OR EXISTS (
                    SELECT 1
                    FROM Warehouse.StockItemStockGroups AS SISG
                    INNER JOIN Warehouse.StockGroups AS SG
                        ON SG.StockGroupID = SISG.StockGroupID
                    WHERE SISG.StockItemID = L.StockItemID
                      AND SG.StockGroupName
                          LIKE N'%' + @Categoria + N'%'
                )
            )
            AND (
                @Subcategoria IS NULL
                OR EXISTS (
                    SELECT 1
                    FROM Warehouse.StockItemStockGroups AS SISG
                    INNER JOIN Warehouse.StockGroups AS SG
                        ON SG.StockGroupID = SISG.StockGroupID
                    WHERE SISG.StockItemID = L.StockItemID
                      AND SG.StockGroupName
                          LIKE N'%' + @Subcategoria + N'%'
                )
            )
    )
    SELECT
        C.SupplierID AS IdProveedor,
        P.SupplierName AS NombreProveedor,
        C.Anio,
        C.Mes,

        MIN(C.OrderDate) AS PrimeraOrdenDelMes,
        MAX(C.OrderDate) AS UltimaOrdenDelMes,

        COUNT(DISTINCT CONCAT(
            C.SucursalID, ':', C.PurchaseOrderID
        )) AS CantidadOrdenes,

        SUM(C.MontoCompra) AS MontoTotalComprado,
        SUM(C.OrderedOuters) AS CantidadTotalComprada,

        MIN(C.OrderedOuters) AS CantidadMinimaPorLinea,
        MAX(C.OrderedOuters) AS CantidadMaximaPorLinea

    FROM Compras AS C
    INNER JOIN Proveedores AS P
        ON P.SupplierID = C.SupplierID
    GROUP BY
        C.SupplierID,
        P.SupplierName,
        C.Anio,
        C.Mes
    ORDER BY
        P.SupplierName,
        C.Anio,
        C.Mes;
END;
GO

-- ============================================================
-- REPORTE 09: ROTACIÓN DE INVENTARIO POR PRODUCTO
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Rpt_sp_RotacionInventario
    @Categoria NVARCHAR(100) = NULL,
    @Anio INT = NULL,
    @Proveedor NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Productos AS (
        SELECT
            StockItemID,
            StockItemName,
            SupplierID
        FROM [LINK_SANJOSE].[WWI_SanJose].[Warehouse].[StockItems]

        UNION ALL

        SELECT
            L.StockItemID,
            L.StockItemName,
            L.SupplierID
        FROM [LINK_LIMON].[WWI_Limon].[Warehouse].[StockItems] AS L
        WHERE NOT EXISTS (
            SELECT 1
            FROM [LINK_SANJOSE].[WWI_SanJose].[Warehouse].[StockItems] AS SJ
            WHERE SJ.StockItemID = L.StockItemID
        )
    ),
    Proveedores AS (
        SELECT
            SupplierID,
            SupplierName
        FROM [LINK_SANJOSE].[WWI_SanJose].[Purchasing].[Suppliers]

        UNION ALL

        SELECT
            L.SupplierID,
            L.SupplierName
        FROM [LINK_LIMON].[WWI_Limon].[Purchasing].[Suppliers] AS L
        WHERE NOT EXISTS (
            SELECT 1
            FROM [LINK_SANJOSE].[WWI_SanJose].[Purchasing].[Suppliers] AS SJ
            WHERE SJ.SupplierID = L.SupplierID
        )
    ),
    VentasPorDia AS (
        SELECT DISTINCT
            L.StockItemID,
            F.InvoiceDate AS FechaVenta
        FROM dbo.Vta_FacturasUnificadas AS F
        INNER JOIN dbo.Vta_LineasFacturaUnificadas AS L
            ON L.InvoiceID = F.InvoiceID
           AND L.SucursalID = F.SucursalID
    ),
    VentasConAnterior AS (
        SELECT
            StockItemID,
            FechaVenta,
            LAG(FechaVenta) OVER (
                PARTITION BY StockItemID
                ORDER BY FechaVenta
            ) AS FechaVentaAnterior
        FROM VentasPorDia
    )
    SELECT
        P.StockItemID AS IdProducto,
        P.StockItemName AS Producto,
        PR.SupplierName AS Proveedor,
        @Anio AS AnioFiltrado,

        COUNT(*) AS CantidadDiasConVentas,

        MIN(V.FechaVenta) AS PrimeraFechaVenta,
        MAX(V.FechaVenta) AS UltimaFechaVenta,

        CAST(
            AVG(
                CAST(
                    DATEDIFF(
                        DAY,
                        V.FechaVentaAnterior,
                        V.FechaVenta
                    ) AS DECIMAL(18, 2)
                )
            ) AS DECIMAL(18, 2)
        ) AS PromedioDiasRotacion

    FROM VentasConAnterior AS V
    INNER JOIN Productos AS P
        ON P.StockItemID = V.StockItemID
    INNER JOIN Proveedores AS PR
        ON PR.SupplierID = P.SupplierID

    WHERE
        (@Anio IS NULL OR YEAR(V.FechaVenta) = @Anio)

        AND (
            @Proveedor IS NULL
            OR PR.SupplierName LIKE N'%' + @Proveedor + N'%'
        )

        AND (
            @Categoria IS NULL
            OR EXISTS (
                SELECT 1
                FROM Warehouse.StockItemStockGroups AS SISG
                INNER JOIN Warehouse.StockGroups AS SG
                    ON SG.StockGroupID = SISG.StockGroupID
                WHERE SISG.StockItemID = P.StockItemID
                  AND SG.StockGroupName
                      LIKE N'%' + @Categoria + N'%'
            )
        )

    GROUP BY
        P.StockItemID,
        P.StockItemName,
        PR.SupplierName

    ORDER BY
        PromedioDiasRotacion ASC,
        Producto;
END;
GO

-- ============================================================
-- REPORTE 10: MÉTODO DE ENVÍO FAVORITO POR ZONA
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Rpt_sp_MetodoEnvioFavoritoPorZona
    @Anio INT = NULL,
    @Mes INT = NULL,
    @CategoriaCliente NVARCHAR(100) = NULL,
    @CategoriaProducto NVARCHAR(100) = NULL,
    @Producto NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Clientes AS (
        SELECT
            CustomerID,
            CustomerName,
            CustomerCategoryID
        FROM [LINK_SANJOSE].[WWI_SanJose].[Sales].[Customers]

        UNION ALL

        SELECT
            L.CustomerID,
            L.CustomerName,
            L.CustomerCategoryID
        FROM [LINK_LIMON].[WWI_Limon].[Sales].[Customers] AS L
        WHERE NOT EXISTS (
            SELECT 1
            FROM [LINK_SANJOSE].[WWI_SanJose].[Sales].[Customers] AS SJ
            WHERE SJ.CustomerID = L.CustomerID
        )
    ),
    Productos AS (
        SELECT
            StockItemID,
            StockItemName
        FROM [LINK_SANJOSE].[WWI_SanJose].[Warehouse].[StockItems]

        UNION ALL

        SELECT
            L.StockItemID,
            L.StockItemName
        FROM [LINK_LIMON].[WWI_Limon].[Warehouse].[StockItems] AS L
        WHERE NOT EXISTS (
            SELECT 1
            FROM [LINK_SANJOSE].[WWI_SanJose].[Warehouse].[StockItems] AS SJ
            WHERE SJ.StockItemID = L.StockItemID
        )
    ),
    VentasPorZonaMetodo AS (
        SELECT
            CIU.CityID,
            CIU.CityName AS Zona,
            DM.DeliveryMethodID,
            DM.DeliveryMethodName AS MetodoEnvio,
            COUNT(*) AS CantidadVentas

        FROM dbo.Vta_FacturasUnificadas AS F

        INNER JOIN Clientes AS C
            ON C.CustomerID = F.CustomerID

        INNER JOIN Sales.CustomersPrivate AS CP
            ON CP.CustomerID = C.CustomerID

        INNER JOIN Application.Cities AS CIU
            ON CIU.CityID = CP.DeliveryCityID

        INNER JOIN Application.DeliveryMethods AS DM
            ON DM.DeliveryMethodID = F.DeliveryMethodID

        INNER JOIN Sales.CustomerCategories AS CC
            ON CC.CustomerCategoryID = C.CustomerCategoryID

        WHERE
            F.IsCreditNote = 0

            AND (
                @Anio IS NULL
                OR YEAR(F.InvoiceDate) = @Anio
            )

            AND (
                @Mes IS NULL
                OR MONTH(F.InvoiceDate) = @Mes
            )

            AND (
                @CategoriaCliente IS NULL
                OR CC.CustomerCategoryName
                    LIKE N'%' + @CategoriaCliente + N'%'
            )

            AND (
                (@CategoriaProducto IS NULL AND @Producto IS NULL)
                OR EXISTS (
                    SELECT 1
                    FROM dbo.Vta_LineasFacturaUnificadas AS L

                    INNER JOIN Productos AS P
                        ON P.StockItemID = L.StockItemID

                    WHERE
                        L.InvoiceID = F.InvoiceID
                        AND L.SucursalID = F.SucursalID

                        AND (
                            @Producto IS NULL
                            OR P.StockItemName
                                LIKE N'%' + @Producto + N'%'
                        )

                        AND (
                            @CategoriaProducto IS NULL
                            OR EXISTS (
                                SELECT 1
                                FROM Warehouse.StockItemStockGroups AS SISG

                                INNER JOIN Warehouse.StockGroups AS SG
                                    ON SG.StockGroupID = SISG.StockGroupID

                                WHERE
                                    SISG.StockItemID = L.StockItemID
                                    AND SG.StockGroupName
                                        LIKE N'%' + @CategoriaProducto + N'%'
                            )
                        )
                )
            )

        GROUP BY
            CIU.CityID,
            CIU.CityName,
            DM.DeliveryMethodID,
            DM.DeliveryMethodName
    ),
    Ranking AS (
        SELECT
            Zona,
            MetodoEnvio,
            CantidadVentas,

            ROW_NUMBER() OVER (
                PARTITION BY CityID
                ORDER BY
                    CantidadVentas DESC,
                    DeliveryMethodID
            ) AS Posicion

        FROM VentasPorZonaMetodo
    )

    SELECT
        Zona,
        MetodoEnvio AS MetodoEnvioFavorito,
        CantidadVentas

    FROM Ranking

    WHERE Posicion = 1

    ORDER BY
        CantidadVentas DESC,
        Zona;
END;
GO
