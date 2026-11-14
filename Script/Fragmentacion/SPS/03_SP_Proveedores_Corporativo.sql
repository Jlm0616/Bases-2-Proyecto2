
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
        SP.SupplierID AS IdProveedor,

        -- Contactos
        SP.PrimaryContactPersonID AS IdContactoPrimario,
        SP.AlternateContactPersonID AS IdContactoAlternativo,

        -- Entrega y ciudades
        SP.DeliveryMethodID AS IdMetodoEntrega,
        DM.DeliveryMethodName AS MetodoEntrega,
        SP.DeliveryCityID AS IdCiudadEntrega,
        CE.CityName AS CiudadEntrega,
        SP.PostalCityID AS IdCiudadPostal,
        CP.CityName AS CiudadPostal,

        -- Información bancaria
        SP.BankAccountName AS NombreBanco,
        SP.BankAccountBranch AS SucursalBancaria,
        SP.BankAccountCode AS CodigoBancario,
        SP.BankAccountNumber AS NumeroCuentaCorriente,
        SP.BankInternationalCode AS CodigoBancarioInternacional,

        -- Información interna
        SP.InternalComments AS ComentariosInternos,

        -- Contacto
        SP.PhoneNumber AS Telefono,
        SP.FaxNumber AS Fax,
        SP.WebsiteURL AS SitioWeb,

        -- Dirección de entrega
        SP.DeliveryAddressLine1 AS DireccionEntregaLinea1,
        SP.DeliveryAddressLine2 AS DireccionEntregaLinea2,
        SP.DeliveryPostalCode AS CodigoPostalEntrega,
        SP.DeliveryLocation.STAsText() AS UbicacionEntregaMapa,

        -- Dirección postal
        SP.PostalAddressLine1 AS DireccionPostalLinea1,
        SP.PostalAddressLine2 AS DireccionPostalLinea2,
        SP.PostalPostalCode AS CodigoPostalPostal

    FROM dbo.Prov_ProveedoresPrivados AS SP

    LEFT JOIN dbo.Gen_MetodosEntrega AS DM
        ON DM.DeliveryMethodID = SP.DeliveryMethodID

    LEFT JOIN dbo.Gen_Ciudades AS CE
        ON CE.CityID = SP.DeliveryCityID

    LEFT JOIN dbo.Gen_Ciudades AS CP
        ON CP.CityID = SP.PostalCityID

    WHERE SP.SupplierID = @SupplierID;
END;
GO
