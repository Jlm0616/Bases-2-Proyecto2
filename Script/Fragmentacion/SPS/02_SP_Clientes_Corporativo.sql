
-- ============================================================================
-- 02_SP_Clientes_Corporativo.sql
-- Stored Procedures de Clientes - Corporativo
-- Proyecto 2 Bases de Datos II
--
-- Descripcion:
--   Consulta los datos privados de un cliente.
--   Los datos generales se consultan desde las sucursales.
--   No realiza operaciones CRUD.
-- ============================================================================

USE WWI_Corporativo;
GO

-- ============================================
-- 01. DETALLE PRIVADO DEL CLIENTE
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
-- PRUEBA
-- ============================================
DECLARE @CustomerID INT;

SELECT TOP (1)
    @CustomerID = CustomerID
FROM dbo.Cli_ClientesPrivados
ORDER BY CustomerID;

EXEC dbo.Cli_sp_DetalleClientePrivado
    @CustomerID = @CustomerID;
GO
