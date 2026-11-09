-- ============================================================================
-- 03_SP_Proveedores_Corporativo.sql
-- Detalle PRIVADO de un proveedor (contacto, direcciones, datos bancarios).
-- Los datos generales (codigo, nombre, categoria, dias de pago) los devuelve
-- la sucursal.
-- ============================================================================

USE WWI_Corporativo;
GO

CREATE OR ALTER PROCEDURE Prov_sp_DetalleProveedorPrivado
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SP.SupplierID                    AS IdProveedor,
        SP.PrimaryContactPersonID        AS IdContactoPrimario,
        SP.AlternateContactPersonID      AS IdContactoAlternativo,
        SP.DeliveryMethodID              AS IdMetodoEntrega,
        DM.DeliveryMethodName            AS MetodoEntrega,
        SP.DeliveryCityID                AS IdCiudadEntrega,
        CIU.CityName                     AS CiudadEntrega,
        SP.DeliveryPostalCode            AS CodigoPostalEntrega,
        SP.PhoneNumber                   AS Telefono,
        SP.FaxNumber                     AS Fax,
        SP.WebsiteURL                    AS SitioWeb,
        SP.DeliveryAddressLine1          AS DireccionEntregaLinea1,
        SP.DeliveryAddressLine2          AS DireccionEntregaLinea2,
        SP.PostalAddressLine1            AS DireccionPostalLine1,
        SP.PostalAddressLine2            AS DireccionPostalLine2,
        SP.PostalPostalCode              AS CodigoPostalPostal,
        SP.DeliveryLocation.STAsText()   AS UbicacionEntregaMapa,
        SP.BankAccountName               AS NombreBanco,
        SP.BankAccountNumber             AS NumeroCuentaCorriente
    FROM Prov_ProveedoresPrivados AS SP
    LEFT JOIN Gen_MetodosEntrega AS DM  ON DM.DeliveryMethodID = SP.DeliveryMethodID
    LEFT JOIN Gen_Ciudades       AS CIU ON CIU.CityID          = SP.DeliveryCityID
    WHERE SP.SupplierID = @SupplierID;
END
GO

-- Prueba (usa un proveedor que exista)
DECLARE @id INT = (SELECT TOP 1 SupplierID FROM Prov_ProveedoresPrivados ORDER BY SupplierID);
EXEC Prov_sp_DetalleProveedorPrivado @id;
GO