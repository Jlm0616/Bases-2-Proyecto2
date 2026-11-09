
-- ============================================
-- 00_Crear_BD_SanJose.sql
-- Proyecto 2 - Bases de Datos II
-- Crear base de datos de San Jose
-- ============================================

USE master;
GO

IF DB_ID(N'WWI_SanJose') IS NULL
BEGIN
    CREATE DATABASE WWI_SanJose;
END;
GO
