
-- ============================================================================
-- 03_SP_Proveedores_Corporativo.sql
-- Stored Procedures de Proveedores - Corporativo
-- Proyecto 2 Bases de Datos II
--
-- Descripcion:
--   Consulta los datos privados de un proveedor.
--   Los datos generales se consultan desde las sucursales.
--   No realiza operaciones CRUD.
-- ============================================================================

USE WWI_Corporativo;
GO

-- ============================================
-- 01. DETALLE PRIVADO DEL PROVEEDOR
-- ============================================
CREATE OR ALTER PROCEDURE dbo.Prov_sp_DetalleProveedorPrivado
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SP.SupplierID                  AS IdProveedor,
        SP.PrimaryContactPersonID      AS IdContactoPrimario,
        SP.AlternateContactPersonID    AS IdContactoAlternativo,
        SP.DeliveryMethodID            AS IdMetodoEntrega,
        DM.DeliveryMethodName          AS MetodoEntrega,
        SP.DeliveryCityID              AS IdCiudadEntrega,
        CIU.CityName                   AS CiudadEntrega,
        SP.DeliveryPostalCode          AS CodigoPostalEntrega,
        SP.PhoneNumber                 AS Telefono,
        SP.FaxNumber                   AS Fax,
        SP.WebsiteURL                  AS SitioWeb,
        SP.DeliveryAddressLine1        AS DireccionEntregaLinea1,
        SP.DeliveryAddressLine2        AS DireccionEntregaLinea2,
        SP.PostalAddressLine1          AS DireccionPostalLinea1,
        SP.PostalAddressLine2          AS DireccionPostalLinea2,
        SP.PostalPostalCode            AS CodigoPostalPostal,
        SP.DeliveryLocation.STAsText() AS UbicacionEntregaMapa,
        SP.BankAccountName             AS NombreBanco,
        SP.BankAccountNumber           AS NumeroCuentaCorriente
    FROM dbo.Prov_ProveedoresPrivados AS SP
    LEFT JOIN dbo.Gen_MetodosEntrega AS DM
        ON DM.DeliveryMethodID = SP.DeliveryMethodID
    LEFT JOIN dbo.Gen_Ciudades AS CIU
        ON CIU.CityID = SP.DeliveryCityID
    WHERE SP.SupplierID = @SupplierID;
END;
GO
