
USE WWI_Limon;
GO

-- ============================================================
-- 1. TIPO DE TABLA PARA LAS LINEAS DE FACTURA
-- ============================================================

IF TYPE_ID(N'dbo.TipoLineasFactura') IS NULL
BEGIN
    EXEC(N'
        CREATE TYPE dbo.TipoLineasFactura AS TABLE (
            StockItemID INT NOT NULL,
            Quantity INT NOT NULL,
            UnitPrice DECIMAL(18,2) NOT NULL,
            PackageTypeID INT NULL
        );
    ');

    PRINT 'TipoLineasFactura creado correctamente.';
END
ELSE
BEGIN
    PRINT 'TipoLineasFactura ya existe.';
END;
GO

-- ============================================================
-- 2. SECUENCIA PARA LOS IDs DE FACTURAS
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.sequences
    WHERE name = 'Seq_InvoiceID'
      AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    DECLARE @SiguienteID INT;
    DECLARE @SQL NVARCHAR(MAX);

    SELECT @SiguienteID =
        ISNULL(MAX(InvoiceID), 0) + 1
    FROM Sales.Invoices;

    SET @SQL = N'
        CREATE SEQUENCE dbo.Seq_InvoiceID
        AS INT
        START WITH ' + CAST(@SiguienteID AS NVARCHAR(20)) + N'
        INCREMENT BY 1
        NO CYCLE;
    ';

    EXEC sp_executesql @SQL;

    PRINT 'Seq_InvoiceID creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Seq_InvoiceID ya existe.';
END;
GO

-- ============================================================
-- 3. SECUENCIA PARA LOS IDs DE DETALLES
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.sequences
    WHERE name = 'Seq_InvoiceLineID'
      AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    DECLARE @SiguienteID INT;
    DECLARE @SQL NVARCHAR(MAX);

    SELECT @SiguienteID =
        ISNULL(MAX(InvoiceLineID), 0) + 1
    FROM Sales.InvoiceLines;

    SET @SQL = N'
        CREATE SEQUENCE dbo.Seq_InvoiceLineID
        AS INT
        START WITH ' + CAST(@SiguienteID AS NVARCHAR(20)) + N'
        INCREMENT BY 1
        NO CYCLE;
    ';

    EXEC sp_executesql @SQL;

    PRINT 'Seq_InvoiceLineID creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Seq_InvoiceLineID ya existe.';
END;
GO

-- ============================================================
-- 4. INSERTAR VENTA
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Vta_sp_InsertarVenta
    @CustomerID INT,
    @ContactPersonID INT,
    @SalespersonPersonID INT,
    @LastEditedBy INT,
    @DeliveryMethodID INT = 1,
    @AccountsPersonID INT = NULL,
    @PackedByPersonID INT = NULL,
    @CustomerPONumber NVARCHAR(20) = NULL,
    @DeliveryInstructions NVARCHAR(100) = NULL,
    @Lineas dbo.TipoLineasFactura READONLY,
    @NuevoID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @NuevoID = NULL;

    -- Validar cliente
    IF NOT EXISTS (
        SELECT 1
        FROM Cli_Clientes
        WHERE CustomerID = @CustomerID
    )
        THROW 50001, 'El cliente no existe en esta sucursal.', 1;

    -- Validar contacto
    IF NOT EXISTS (
        SELECT 1
        FROM Gen_Personas
        WHERE PersonID = @ContactPersonID
    )
        THROW 50002, 'La persona de contacto no existe.', 1;

    -- Validar vendedor
    IF NOT EXISTS (
        SELECT 1
        FROM Gen_Personas
        WHERE PersonID = @SalespersonPersonID
    )
        THROW 50003, 'El vendedor no existe.', 1;

    -- Validar editor
    IF NOT EXISTS (
        SELECT 1
        FROM Gen_Personas
        WHERE PersonID = @LastEditedBy
    )
        THROW 50004, 'El editor no existe.', 1;

    -- Personas predeterminadas
    SET @AccountsPersonID =
        COALESCE(@AccountsPersonID, @SalespersonPersonID);

    SET @PackedByPersonID =
        COALESCE(@PackedByPersonID, @SalespersonPersonID);

    IF NOT EXISTS (
        SELECT 1
        FROM Gen_Personas
        WHERE PersonID = @AccountsPersonID
    )
        THROW 50005, 'La persona de cuentas no existe.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Gen_Personas
        WHERE PersonID = @PackedByPersonID
    )
        THROW 50006, 'La persona que empaca no existe.', 1;

    -- Validar metodo de entrega
    IF NOT EXISTS (
        SELECT 1
        FROM Gen_MetodosEntrega
        WHERE DeliveryMethodID = @DeliveryMethodID
    )
        THROW 50007, 'El metodo de entrega no existe.', 1;

    -- Validar lineas
    IF NOT EXISTS (SELECT 1 FROM @Lineas)
        THROW 50008, 'La factura requiere al menos una linea.', 1;

    IF EXISTS (
        SELECT 1
        FROM @Lineas
        WHERE Quantity <= 0 OR UnitPrice < 0
    )
        THROW 50009, 'Cantidad o precio invalido.', 1;

    IF EXISTS (
        SELECT StockItemID
        FROM @Lineas
        GROUP BY StockItemID
        HAVING COUNT(*) > 1
    )
        THROW 50010, 'No repita productos; agrupe sus cantidades.', 1;

    -- Validar productos
    IF EXISTS (
        SELECT 1
        FROM @Lineas L
        WHERE NOT EXISTS (
            SELECT 1
            FROM Inv_Articulos SI
            WHERE SI.StockItemID = L.StockItemID
        )
    )
        THROW 50011, 'Hay productos inexistentes.', 1;

    -- Validar empaques
    IF EXISTS (
        SELECT 1
        FROM @Lineas L
        WHERE L.PackageTypeID IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM Warehouse.PackageTypes PT
              WHERE PT.PackageTypeID = L.PackageTypeID
          )
    )
        THROW 50012, 'Hay tipos de empaque inexistentes.', 1;

    -- Validar secuencias
    IF OBJECT_ID(N'dbo.Seq_InvoiceID', N'SO') IS NULL
        THROW 50014, 'No existe la secuencia Seq_InvoiceID.', 1;

    IF OBJECT_ID(N'dbo.Seq_InvoiceLineID', N'SO') IS NULL
        THROW 50015, 'No existe la secuencia Seq_InvoiceLineID.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ====================================================
        -- DESCONTAR INVENTARIO
        -- ====================================================

        UPDATE H WITH (UPDLOCK)
        SET
            H.QuantityOnHand = H.QuantityOnHand - L.Quantity,
            H.LastEditedBy = @LastEditedBy,
            H.LastEditedWhen = SYSDATETIME()
        FROM Inv_ExistenciasArticulo H
        INNER JOIN @Lineas L
            ON L.StockItemID = H.StockItemID
        WHERE H.QuantityOnHand >= L.Quantity;

        DECLARE @FilasDescontadas INT = @@ROWCOUNT;

        IF @FilasDescontadas <> (SELECT COUNT(*) FROM @Lineas)
            THROW 50013,
                'Stock insuficiente o inventario inexistente.',
                1;

        -- ====================================================
        -- INSERTAR ENCABEZADO DE FACTURA
        -- ====================================================

        DECLARE @Ids TABLE (InvoiceID INT);

        INSERT INTO Vta_Facturas (
            InvoiceID,
            CustomerID,
            BillToCustomerID,
            OrderID,
            DeliveryMethodID,
            ContactPersonID,
            AccountsPersonID,
            SalespersonPersonID,
            PackedByPersonID,
            InvoiceDate,
            CustomerPurchaseOrderNumber,
            IsCreditNote,
            DeliveryInstructions,
            TotalDryItems,
            TotalChillerItems,
            LastEditedBy,
            LastEditedWhen
        )
        OUTPUT INSERTED.InvoiceID INTO @Ids
        VALUES (
            NEXT VALUE FOR dbo.Seq_InvoiceID,
            @CustomerID,
            @CustomerID,
            NULL,
            @DeliveryMethodID,
            @ContactPersonID,
            @AccountsPersonID,
            @SalespersonPersonID,
            @PackedByPersonID,
            CAST(GETDATE() AS DATE),
            @CustomerPONumber,
            0,
            @DeliveryInstructions,
            0,
            0,
            @LastEditedBy,
            SYSDATETIME()
        );

        SELECT @NuevoID = InvoiceID
        FROM @Ids;

        -- ====================================================
        -- INSERTAR LINEAS DE FACTURA
        -- ====================================================

        INSERT INTO Vta_LineasFactura (
            InvoiceLineID,
            InvoiceID,
            StockItemID,
            Description,
            PackageTypeID,
            Quantity,
            UnitPrice,
            TaxRate,
            TaxAmount,
            LineProfit,
            ExtendedPrice,
            LastEditedBy,
            LastEditedWhen
        )
        SELECT
            NEXT VALUE FOR dbo.Seq_InvoiceLineID,
            @NuevoID,
            L.StockItemID,
            SI.StockItemName,
            COALESCE(L.PackageTypeID, SI.UnitPackageID),
            L.Quantity,
            L.UnitPrice,
            SI.TaxRate,
            ROUND(
                L.Quantity * L.UnitPrice * SI.TaxRate / 100.0,
                2
            ),
            ROUND(
                L.Quantity *
                (L.UnitPrice - COALESCE(H.LastCostPrice, 0)),
                2
            ),
            ROUND(
                L.Quantity * L.UnitPrice *
                (1 + SI.TaxRate / 100.0),
                2
            ),
            @LastEditedBy,
            SYSDATETIME()
        FROM @Lineas L
        INNER JOIN Inv_Articulos SI
            ON SI.StockItemID = L.StockItemID
        INNER JOIN Inv_ExistenciasArticulo H
            ON H.StockItemID = L.StockItemID;

        -- ====================================================
        -- ACTUALIZAR TOTALES
        -- ====================================================

        UPDATE Vta_Facturas
        SET
            TotalDryItems = (
                SELECT COALESCE(SUM(L.Quantity), 0)
                FROM @Lineas L
                INNER JOIN Inv_Articulos SI
                    ON SI.StockItemID = L.StockItemID
                WHERE SI.IsChillerStock = 0
            ),
            TotalChillerItems = (
                SELECT COALESCE(SUM(L.Quantity), 0)
                FROM @Lineas L
                INNER JOIN Inv_Articulos SI
                    ON SI.StockItemID = L.StockItemID
                WHERE SI.IsChillerStock = 1
            )
        WHERE InvoiceID = @NuevoID;

        COMMIT TRANSACTION;

        SELECT
            @NuevoID AS NuevaVentaID,
            N'OK' AS Resultado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- ============================================================
-- 5. ACTUALIZAR VENTA
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Vta_sp_ActualizarVenta
    @InvoiceID INT,
    @DeliveryInstructions NVARCHAR(100) = NULL,
    @CustomerPONumber NVARCHAR(20) = NULL,
    @LastEditedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM Gen_Personas
        WHERE PersonID = @LastEditedBy
    )
        THROW 50020, 'El editor no existe.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Vta_Facturas
        SET
            DeliveryInstructions = @DeliveryInstructions,
            CustomerPurchaseOrderNumber = @CustomerPONumber,
            LastEditedBy = @LastEditedBy,
            LastEditedWhen = SYSDATETIME()
        WHERE InvoiceID = @InvoiceID;

        IF @@ROWCOUNT <> 1
            THROW 50021,
                'La factura no existe en esta sucursal.',
                1;

        COMMIT TRANSACTION;

        SELECT
            1 AS FilasAfectadas,
            N'OK' AS Resultado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- ============================================================
-- 6. ELIMINAR VENTA
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.Vta_sp_EliminarVenta
    @InvoiceID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Reintegra inventario antes de eliminar la factura.
    -- Usar para ventas registradas con descuento de inventario.

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM Vta_Facturas WITH (UPDLOCK, HOLDLOCK)
            WHERE InvoiceID = @InvoiceID
        )
            THROW 50030,
                'La factura no existe en esta sucursal.',
                1;

        IF EXISTS (
            SELECT 1
            FROM Vta_LineasFactura IL
            WHERE IL.InvoiceID = @InvoiceID
              AND NOT EXISTS (
                  SELECT 1
                  FROM Inv_ExistenciasArticulo H
                  WHERE H.StockItemID = IL.StockItemID
              )
        )
            THROW 50032,
                'Hay productos sin registro de inventario.',
                1;

        ;WITH Cantidades AS (
            SELECT
                StockItemID,
                SUM(Quantity) AS Cantidad
            FROM Vta_LineasFactura
            WHERE InvoiceID = @InvoiceID
            GROUP BY StockItemID
        )
        UPDATE H
        SET
            H.QuantityOnHand = H.QuantityOnHand + C.Cantidad,
            H.LastEditedWhen = SYSDATETIME()
        FROM Inv_ExistenciasArticulo H
        INNER JOIN Cantidades C
            ON C.StockItemID = H.StockItemID;

        DELETE FROM Vta_LineasFactura
        WHERE InvoiceID = @InvoiceID;

        DELETE FROM Vta_Facturas
        WHERE InvoiceID = @InvoiceID;

        COMMIT TRANSACTION;

        SELECT
            1 AS FilasAfectadas,
            N'OK' AS Resultado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- ============================================================
-- 7. VERIFICACION FINAL
-- ============================================================

SELECT
    name AS Procedimiento
FROM sys.procedures
WHERE name IN (
    'Vta_sp_InsertarVenta',
    'Vta_sp_ActualizarVenta',
    'Vta_sp_EliminarVenta'
);

SELECT
    name AS Secuencia,
    current_value AS ValorActual
FROM sys.sequences
WHERE name IN (
    'Seq_InvoiceID',
    'Seq_InvoiceLineID'
);

SELECT
    SCHEMA_NAME(schema_id) AS Esquema,
    name AS Tipo
FROM sys.table_types
WHERE name = 'TipoLineasFactura';
GO
