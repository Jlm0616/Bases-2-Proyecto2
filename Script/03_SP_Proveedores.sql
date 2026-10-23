USE WideWorldImporters;
GO

-- ============================================================================
-- 03_SP_Proveedores.sql
-- Stored Procedures de Proveedores - Proyecto 1 Bases de Datos 2
--
-- Descripción:
--   Contiene los procedimientos almacenados para la gestión de proveedores,
--   incluyendo listado con filtros, paginación y detalle completo de un proveedor específico.
-- ============================================================================

-- ============================================================================
-- Stored Procedure: Prov_sp_ListarProveedoresPaginado
-- Descripción: Lista proveedores con filtros acumulativos y paginación
-- Uso: Consulta de proveedores con filtros de búsqueda flexibles y paginación
-- Parámetros:
--   @Nombre: Filtro por nombre del proveedor (búsqueda parcial, LIKE)
--   @CategoriaID: Filtro por categoría de proveedor (exacto)
--   @PageNumber: Número de página a mostrar (por defecto: 1)
--   @PageSize: Cantidad de registros por página (por defecto: 25, máximo: 1000)
-- Ordenamiento: Nombre del proveedor ascendente, ID del proveedor ascendente (tiebreaker)
-- Columnas retornadas:
--   - IdProveedor: Identificador único del proveedor
--   - NombreProveedor: Nombre del proveedor
--   - CategoriaProveedor: Categoría a la que pertenece el proveedor
--   - MetodoEntrega: Método de entrega preferido
-- ============================================================================
CREATE OR ALTER PROCEDURE Prov_sp_ListarProveedoresPaginado
    @Nombre       NVARCHAR(100) = NULL,
    @CategoriaID  INT           = NULL,
    @PageNumber   INT           = 1,
    @PageSize     INT           = 25
AS
BEGIN
    SET NOCOUNT ON;

    -- Sanitizar parámetros
    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 25;
    IF @PageSize > 1000 SET @PageSize = 1000;

    SELECT
        P.SupplierID              AS IdProveedor,
        P.SupplierName            AS NombreProveedor,
        PC.SupplierCategoryName   AS CategoriaProveedor,
        DM.DeliveryMethodName     AS MetodoEntrega
    FROM Prov_Proveedores AS P
    LEFT JOIN Prov_CategoriasProveedor AS PC ON PC.SupplierCategoryID = P.SupplierCategoryID
    LEFT JOIN Gen_MetodosEntrega       AS DM ON DM.DeliveryMethodID   = P.DeliveryMethodID
    WHERE (@Nombre      IS NULL OR P.SupplierName LIKE '%' + @Nombre + '%')
      AND (@CategoriaID IS NULL OR P.SupplierCategoryID = @CategoriaID)
    ORDER BY P.SupplierName ASC, P.SupplierID ASC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO


-- ============================================================================
-- Stored Procedure: Prov_sp_ContarProveedores
-- Descripción: Cuenta el total de proveedores que cumplen con los filtros
-- Uso: Calcula el total de registros para implementar paginación
-- Parámetros:
--   @Nombre: Filtro por nombre del proveedor (búsqueda parcial, LIKE)
--   @CategoriaID: Filtro por categoría de proveedor (exacto)
-- Columnas retornadas:
--   - Total: Cantidad total de registros que cumplen los filtros
-- ============================================================================
CREATE OR ALTER PROCEDURE Prov_sp_ContarProveedores
    @Nombre       NVARCHAR(100) = NULL,
    @CategoriaID  INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS Total
    FROM Prov_Proveedores AS P
    LEFT JOIN Prov_CategoriasProveedor AS PC ON PC.SupplierCategoryID = P.SupplierCategoryID
    LEFT JOIN Gen_MetodosEntrega       AS DM ON DM.DeliveryMethodID   = P.DeliveryMethodID
    WHERE (@Nombre      IS NULL OR P.SupplierName LIKE '%' + @Nombre + '%')
      AND (@CategoriaID IS NULL OR P.SupplierCategoryID = @CategoriaID);
END
GO


-- ============================================================================
-- Stored Procedure: Prov_sp_DetalleProveedor
-- Descripción: Obtiene el detalle completo de un proveedor específico
-- Uso: Cargar datos de un proveedor para visualización o edición
-- Parámetros:
--   @SupplierID: Identificador único del proveedor a consultar
-- Columnas retornadas:
--   - IdProveedor: Identificador único del proveedor
--   - CodigoProveedor: Código de referencia del proveedor
--   - NombreProveedor: Nombre del proveedor
--   - IdCategoria: Identificador de la categoría del proveedor
--   - CategoriaProveedor: Nombre de la categoría del proveedor
--   - IdContactoPrimario: Identificador del contacto principal
--   - ContactoPrimario: Nombre del contacto principal
--   - IdContactoAlternativo: Identificador del contacto alternativo
--   - ContactoAlternativo: Nombre del contacto alternativo
--   - IdMetodoEntrega: Identificador del método de entrega
--   - MetodoEntrega: Nombre del método de entrega
--   - IdCiudadEntrega: Identificador de la ciudad de entrega
--   - CiudadEntrega: Nombre de la ciudad de entrega
--   - CodigoPostalEntrega: Código postal de entrega
--   - Telefono: Número de teléfono
--   - Fax: Número de fax
--   - SitioWeb: URL del sitio web
--   - DireccionEntregaLinea1: Primera línea de dirección de entrega
--   - DireccionEntregaLinea2: Segunda línea de dirección de entrega
--   - DireccionPostalLinea1: Primera línea de dirección postal
--   - DireccionPostalLinea2: Segunda línea de dirección postal
--   - CodigoPostalPostal: Código postal postal
--   - UbicacionEntregaMapa: Coordenadas geográficas para mapa
--   - NombreBanco: Nombre del banco
--   - NumeroCuentaCorriente: Número de cuenta corriente
--   - DiasGraciaPago: Días de gracia para pago
-- ============================================================================
CREATE OR ALTER PROCEDURE Prov_sp_DetalleProveedor
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.SupplierID                     AS IdProveedor,
        P.SupplierReference              AS CodigoProveedor,
        P.SupplierName                   AS NombreProveedor,
        P.SupplierCategoryID             AS IdCategoria,
        PC.SupplierCategoryName          AS CategoriaProveedor,
        P.PrimaryContactPersonID         AS IdContactoPrimario,
        pContacto.FullName               AS ContactoPrimario,
        P.AlternateContactPersonID       AS IdContactoAlternativo,
        aContacto.FullName               AS ContactoAlternativo,
        P.DeliveryMethodID               AS IdMetodoEntrega,
        DM.DeliveryMethodName            AS MetodoEntrega,
        P.DeliveryCityID                 AS IdCiudadEntrega,
        CIU.CityName                     AS CiudadEntrega,
        P.DeliveryPostalCode             AS CodigoPostalEntrega,
        P.PhoneNumber                    AS Telefono,
        P.FaxNumber                      AS Fax,
        P.WebsiteURL                     AS SitioWeb,
        P.DeliveryAddressLine1           AS DireccionEntregaLinea1,
        P.DeliveryAddressLine2           AS DireccionEntregaLinea2,
        P.PostalAddressLine1             AS DireccionPostalLine1,
        P.PostalAddressLine2             AS DireccionPostalLine2,
        P.PostalPostalCode               AS CodigoPostalPostal,
        P.DeliveryLocation.STAsText()    AS UbicacionEntregaMapa,
        P.BankAccountName                AS NombreBanco,
        P.BankAccountNumber              AS NumeroCuentaCorriente,
        P.PaymentDays                    AS DiasGraciaPago
    FROM Prov_Proveedores AS P
    LEFT JOIN Prov_CategoriasProveedor AS PC        ON PC.SupplierCategoryID = P.SupplierCategoryID
    LEFT JOIN Gen_MetodosEntrega       AS DM        ON DM.DeliveryMethodID   = P.DeliveryMethodID
    LEFT JOIN Gen_Ciudades             AS CIU       ON CIU.CityID            = P.DeliveryCityID
    LEFT JOIN Gen_Personas             AS pContacto ON pContacto.PersonID    = P.PrimaryContactPersonID
    LEFT JOIN Gen_Personas             AS aContacto ON aContacto.PersonID    = P.AlternateContactPersonID
    WHERE P.SupplierID = @SupplierID;
END
GO
