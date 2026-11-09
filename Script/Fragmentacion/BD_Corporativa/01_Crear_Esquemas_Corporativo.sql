
USE WWI_Corporativo;
GO

-- ============================================
-- 01_Crear_Esquemas_Corporativo.sql
-- ============================================

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas
    WHERE name = 'Application'
)
    EXEC('CREATE SCHEMA Application');
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas
    WHERE name = 'Sales'
)
    EXEC('CREATE SCHEMA Sales');
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas
    WHERE name = 'Purchasing'
)
    EXEC('CREATE SCHEMA Purchasing');
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas
    WHERE name = 'Warehouse'
)
    EXEC('CREATE SCHEMA Warehouse');
GO
