-- ============================================
-- 14_Crear_Inventario_Unificado_Corporativo.sql
-- ============================================

USE WWI_Corporativo;
GO

-- Crear vista de inventario unificado
CREATE VIEW Warehouse.InventarioUnificado
AS
SELECT
    StockItemID,

    SUM(
        CASE
            WHEN Sucursal = 'SanJose'
            THEN CONVERT(BIGINT, QuantityOnHand)
            ELSE CONVERT(BIGINT, 0)
        END
    ) AS InventarioSanJose,

    SUM(
        CASE
            WHEN Sucursal = 'Limon'
            THEN CONVERT(BIGINT, QuantityOnHand)
            ELSE CONVERT(BIGINT, 0)
        END
    ) AS InventarioLimon,

    SUM(CONVERT(BIGINT, QuantityOnHand))
        AS InventarioTotal

FROM
(
    SELECT
        StockItemID,
        QuantityOnHand,
        'SanJose' AS Sucursal
    FROM Warehouse.InventarioSanJose

    UNION ALL

    SELECT
        StockItemID,
        QuantityOnHand,
        'Limon'
    FROM Warehouse.InventarioLimon

) AS Inventarios

GROUP BY StockItemID;
GO

-- Mostrar todos los productos unificados
SELECT
    StockItemID,
    InventarioSanJose,
    InventarioLimon,
    InventarioTotal
FROM Warehouse.InventarioUnificado
ORDER BY StockItemID;
GO
