-- ============================================================================
-- 17_Configuracion_LinkedServers_Corporativo.sql
-- Configuracion de Linked Servers para Corporativo.
-- SQL Server 2025 - Docker
-- Ejecutar en SQLSERVER-CORPORATIVO.
-- ============================================================================

USE master;
GO

-- ============================================================================
-- 1. LINKED SERVER SAN JOSE
-- ============================================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.servers
    WHERE name = N'LINK_SANJOSE'
)
BEGIN
    EXEC master.dbo.sp_addlinkedserver
        @server = N'LINK_SANJOSE',
        @srvproduct = N'',
        @provider = N'MSOLEDBSQL',
        @datasrc = N'SQLSERVER-SANJOSE',
        @provstr = N'Encrypt=Mandatory;TrustServerCertificate=Yes;';
END;
GO

-- ============================================================================
-- 2. LINKED SERVER LIMON
-- ============================================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.servers
    WHERE name = N'LINK_LIMON'
)
BEGIN
    EXEC master.dbo.sp_addlinkedserver
        @server = N'LINK_LIMON',
        @srvproduct = N'MSOLEDBSQL',
        @datasrc = N'SQLSERVER-LIMON',
        @provstr = N'Encrypt=Mandatory;TrustServerCertificate=Yes;';
END;
GO