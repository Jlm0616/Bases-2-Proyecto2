
-- ============================================
-- 01_Crear_Esquemas_SanJose.sql
-- ============================================

USE WWI_SanJose;
GO

-- Esquema para clientes, pedidos y facturas.
IF SCHEMA_ID('Sales') IS NULL
    EXEC('CREATE SCHEMA Sales');
GO

-- Esquema para proveedores.
IF SCHEMA_ID('Purchasing') IS NULL
    EXEC('CREATE SCHEMA Purchasing');
GO

-- Esquema para productos e inventario.
IF SCHEMA_ID('Warehouse') IS NULL
    EXEC('CREATE SCHEMA Warehouse');
GO

-- Esquema para catalogos auxiliares.
IF SCHEMA_ID('Application') IS NULL
    EXEC('CREATE SCHEMA Application');
GO
