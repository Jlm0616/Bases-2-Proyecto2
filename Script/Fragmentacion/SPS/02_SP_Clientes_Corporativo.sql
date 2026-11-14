-- ============================================================================
-- 02_SP_Clientes_Corporativo.sql
-- Stored Procedures de Clientes - Corporativo
-- Proyecto 2 Bases de Datos II
--
-- Descripcion:
--   Consulta los datos privados de clientes.
--   Genera identificadores unicos para nuevos clientes.
--   Los datos generales se almacenan en las sucursales.
--   Los datos privados se almacenan en Corporativo.
-- ============================================================================

USE WWI_Corporativo;
GO

-- ============================================
-- 00. GENERACION DE IDENTIFICADORES DE CLIENTES
-- ============================================

-- Crear la secuencia solamente si no existe.
-- El identificador inicial se calcula a partir
-- del mayor CustomerID registrado en Corporativo.
-- Antes de una instalacion nueva, verificar que
-- las sucursales no tengan identificadores mayores.

IF NOT EXISTS (
    SELECT 1
    FROM sys.sequences
    WHERE name = 'Seq_CustomerID'
      AND schema_id = SCHEMA_ID('Sales')
)
BEGIN
    DECLARE @SiguienteID INT;

    SELECT
        @SiguienteID = ISNULL(MAX(CustomerID), 0) + 1
    FROM Sales.CustomersPrivate;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        CREATE SEQUENCE Sales.Seq_CustomerID
        AS INT
        START WITH ' + CAST(@SiguienteID AS NVARCHAR(20)) + N'
        INCREMENT BY 1
        NO CYCLE
        NO CACHE;
    ';

    EXEC sys.sp_executesql @SQL;
END;
GO

-- ============================================
-- 01. PROCEDIMIENTO PARA GENERAR CUSTOMERID
-- ============================================

CREATE OR ALTER PROCEDURE dbo.Cli_sp_GenerarCustomerID
    @NuevoCustomerID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @NuevoCustomerID =
        NEXT VALUE FOR Sales.Seq_CustomerID;
END;
GO

-- ============================================
-- 02. DETALLE PRIVADO DEL CLIENTE
-- ============================================

CREATE OR ALTER PROCEDURE dbo.Cli_sp_DetalleClientePrivado
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CP.CustomerID                  AS IdCliente,
        CP.PrimaryContactPersonID      AS IdContactoPrimario,
        CP.AlternateContactPersonID    AS IdContactoAlternativo,
        CP.DeliveryMethodID            AS IdMetodoEntrega,
        DM.DeliveryMethodName          AS MetodoEntrega,
        CP.DeliveryCityID              AS IdCiudadEntrega,
        CIU.CityName                   AS CiudadEntrega,
        CP.DeliveryPostalCode          AS CodigoPostalEntrega,
        CP.PhoneNumber                 AS Telefono,
        CP.FaxNumber                   AS Fax,
        CP.WebsiteURL                  AS SitioWeb,
        CP.DeliveryAddressLine1        AS DireccionEntregaLinea1,
        CP.DeliveryAddressLine2        AS DireccionEntregaLinea2,
        CP.PostalAddressLine1          AS DireccionPostalLinea1,
        CP.PostalAddressLine2          AS DireccionPostalLinea2,
        CP.PostalPostalCode            AS CodigoPostalPostal,
        CP.DeliveryLocation.STAsText() AS UbicacionEntregaMapa
    FROM dbo.Cli_ClientesPrivados AS CP
    LEFT JOIN dbo.Gen_MetodosEntrega AS DM
        ON DM.DeliveryMethodID = CP.DeliveryMethodID
    LEFT JOIN dbo.Gen_Ciudades AS CIU
        ON CIU.CityID = CP.DeliveryCityID
    WHERE CP.CustomerID = @CustomerID;
END;
GO

-- ============================================
-- PRUEBA: CONSULTAR DATOS PRIVADOS
-- ============================================

DECLARE @CustomerID INT;

SELECT TOP (1)
    @CustomerID = CustomerID
FROM dbo.Cli_ClientesPrivados
ORDER BY CustomerID;

EXEC dbo.Cli_sp_DetalleClientePrivado
    @CustomerID = @CustomerID;
GO