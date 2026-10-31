
-- ============================================
-- 00_Crear_BD_Limon.sql
-- Proyecto 2 - Bases de Datos II
-- Crear base de datos de Limon
-- ============================================

USE master;
GO

-- Verificar si la base de datos ya existe.
IF DB_ID(N'WWI_Limon') IS NULL
BEGIN
    CREATE DATABASE WWI_Limon;

    PRINT 'Base de datos WWI_Limon creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La base de datos WWI_Limon ya existe.';
END;
GO
