USE WWI_SanJose;
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
-- 4. VERIFICACION
-- ============================================================

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