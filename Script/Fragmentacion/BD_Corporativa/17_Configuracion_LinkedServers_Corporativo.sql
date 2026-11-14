USE master;
GO

-- LINKED SERVER SAN JOSE
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

-- LINKED SERVER LIMON
IF NOT EXISTS (
    SELECT 1
    FROM sys.servers
    WHERE name = N'LINK_LIMON'
)
BEGIN
    EXEC master.dbo.sp_addlinkedserver
        @server = N'LINK_LIMON',
        @srvproduct = N'',
        @provider = N'MSOLEDBSQL',
        @datasrc = N'SQLSERVER-LIMON',
        @provstr = N'Encrypt=Mandatory;TrustServerCertificate=Yes;';
END;
GO