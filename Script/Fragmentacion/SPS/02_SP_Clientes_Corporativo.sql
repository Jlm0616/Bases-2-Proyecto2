-- ============================================================================
-- 02_SP_Clientes_Corporativo.sql
-- Detalle PRIVADO de un cliente (contacto y direcciones). Los datos generales
-- (nombre, categoria, grupo de compra, etc.) los devuelve la sucursal.
-- ============================================================================

USE WWI_Corporativo;
GO

DROP PROCEDURE IF EXISTS Cli_sp_DetalleCliente;
GO

CREATE OR ALTER PROCEDURE Cli_sp_DetalleClientePrivado
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CP.CustomerID                   AS IdCliente,
        CP.PrimaryContactPersonID       AS IdContactoPrimario,
        CP.AlternateContactPersonID     AS IdContactoAlternativo,
        CP.DeliveryMethodID             AS IdMetodoEntrega,
        DM.DeliveryMethodName           AS MetodoEntrega,
        CP.DeliveryCityID               AS IdCiudadEntrega,
        CIU.CityName                    AS CiudadEntrega,
        CP.DeliveryPostalCode           AS CodigoPostalEntrega,
        CP.PhoneNumber                  AS Telefono,
        CP.FaxNumber                    AS Fax,
        CP.WebsiteURL                   AS SitioWeb,
        CP.DeliveryAddressLine1         AS DireccionEntregaLinea1,
        CP.DeliveryAddressLine2         AS DireccionEntregaLinea2,
        CP.PostalAddressLine1           AS DireccionPostalLinea1,
        CP.PostalAddressLine2           AS DireccionPostalLine2,
        CP.PostalPostalCode             AS CodigoPostalPostal,
        CP.DeliveryLocation.STAsText()  AS UbicacionEntregaMapa
    FROM Cli_ClientesPrivados AS CP
    LEFT JOIN Gen_MetodosEntrega AS DM  ON DM.DeliveryMethodID = CP.DeliveryMethodID
    LEFT JOIN Gen_Ciudades       AS CIU ON CIU.CityID          = CP.DeliveryCityID
    WHERE CP.CustomerID = @CustomerID;
END
GO

-- Prueba (usa un cliente que exista)
DECLARE @id INT = (SELECT TOP 1 CustomerID FROM Cli_ClientesPrivados ORDER BY CustomerID);
EXEC Cli_sp_DetalleClientePrivado @id;
GO