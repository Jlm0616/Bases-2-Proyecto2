-- ============================================
-- 00_Crear_BD_Corporativo.sql
-- ============================================

USE master;
GO

IF DB_ID(N'WWI_Corporativo') IS NULL
BEGIN
    CREATE DATABASE WWI_Corporativo;

    PRINT 'Base de datos WWI_Corporativo creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La base de datos WWI_Corporativo ya existe.';
END;
GO
