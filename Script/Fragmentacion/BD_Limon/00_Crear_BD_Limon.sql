
-- ============================================
-- 00_Crear_BD_Limon.sql
-- Proyecto 2 - Bases de Datos II
-- Crear base de datos de Limon
-- ============================================

USE master;
GO

IF DB_ID(N'WWI_Limon') IS NULL
BEGIN
    CREATE DATABASE WWI_Limon;
END;
GO
