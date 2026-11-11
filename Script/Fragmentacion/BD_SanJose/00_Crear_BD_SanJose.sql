-- ============================================
-- 00_Crear_BD_SanJose.sql
-- ============================================

USE master;
GO

IF DB_ID(N'WWI_SanJose') IS NULL
BEGIN
    CREATE DATABASE WWI_SanJose;
END;
GO
