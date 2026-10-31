
-- ============================================
-- 00_Crear_BD_SanJose.sql
-- Proyecto 2 - Bases de Datos II
-- Crear base de datos de San Jose
-- ============================================

USE master;
GO

-- Verificar si la base de datos ya existe.
IF DB_ID(N'WWI_SanJose') IS NULL
BEGIN
    CREATE DATABASE WWI_SanJose;

    PRINT 'Base de datos WWI_SanJose creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La base de datos WWI_SanJose ya existe.';
END;
GO
