USE WWI_Corporativo;
GO

CREATE OR ALTER PROCEDURE Cli_sp_DetalleCliente
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.CustomerID              AS IdCliente,
        C.CustomerName            AS NombreCliente,
        -- Datos privados:
        CP.PhoneNumber            AS Telefono,
        CP.DeliveryAddressLine1   AS DireccionEntrega,
        -- Datos de catálogo geográfico:
        CIU.CityName              AS CiudadEntrega
    FROM Sales.Customers C -- OJO: AQUÍ DEBES TENER LA TABLA CUSTOMERS EN CORP (La creaste?)
    INNER JOIN Cli_ClientesPrivados CP ON CP.CustomerID = C.CustomerID
    LEFT JOIN Gen_Ciudades CIU ON CIU.CityID = CP.DeliveryCityID
    WHERE C.CustomerID = @CustomerID;
END
GO