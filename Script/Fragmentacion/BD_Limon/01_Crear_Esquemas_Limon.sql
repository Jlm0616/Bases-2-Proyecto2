
-- ============================================
-- 01_Crear_Esquemas_Limon.sql
-- Proyecto 2 - Bases de Datos II
-- Crear esquemas de la sucursal Limon
-- ============================================

USE WWI_Limon;
GO

-- Crear esquema Sales.
IF SCHEMA_ID(N'Sales') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA Sales');
END;
GO

-- Crear esquema Purchasing.
IF SCHEMA_ID(N'Purchasing') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA Purchasing');
END;
GO

-- Crear esquema Warehouse.
IF SCHEMA_ID(N'Warehouse') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA Warehouse');
END;
GO

-- Crear esquema Application.
IF SCHEMA_ID(N'Application') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA Application');
END;
GO
