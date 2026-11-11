-- ============================================
-- 00_Crear_BD_Limon.sql
-- ============================================

USE master;
GO

IF DB_ID(N'WWI_Limon') IS NULL
BEGIN
    CREATE DATABASE WWI_Limon;
END;
GO
