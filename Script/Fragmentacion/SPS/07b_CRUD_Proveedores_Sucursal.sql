-- ============================================================================
-- 07b_CRUD_Proveedores_Sucursal.sql
-- Datos generales: Purchasing.Suppliers
-- Ejecutar en WWI_Limon y en WWI_SanJose (cambiar USE).
-- Lecturas existentes (archivo 03):
--   dbo.Prov_sp_ListarProveedoresPaginado
--   dbo.Prov_sp_ContarProveedores
--   dbo.Prov_sp_DetalleProveedor
-- SupplierID debe generarse en Corporativo, no localmente.
-- ADVERTENCIA: ambas sucursales publican estas tablas. Probar la replicacion
-- y el manejo de conflictos antes de realizar escrituras concurrentes.
-- ============================================================================
USE WWI_Limon; -- Cambiar a WWI_SanJose al ejecutar en San Jose.
GO

-- INSERT de datos generales.
CREATE OR ALTER PROCEDURE dbo.Prov_sp_InsertarProveedorGeneral
    @SupplierID INT,
    @SupplierName NVARCHAR(100),
    @SupplierCategoryID INT,
    @PaymentDays INT,
    @LastEditedBy INT,
    @SupplierReference NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @SupplierID IS NULL OR @SupplierID <= 0
        THROW 51101, 'SupplierID debe ser un entero positivo.', 1;
    IF EXISTS (SELECT 1 FROM Purchasing.Suppliers WHERE SupplierID = @SupplierID)
        THROW 51102, 'El proveedor general ya existe.', 1;

    INSERT INTO Purchasing.Suppliers (
        SupplierID, SupplierName, SupplierCategoryID, SupplierReference,
        PaymentDays, LastEditedBy, ValidFrom, ValidTo
    )
    VALUES (
        @SupplierID, @SupplierName, @SupplierCategoryID, @SupplierReference,
        @PaymentDays, @LastEditedBy,
        SYSUTCDATETIME(), CONVERT(DATETIME2(7), '9999-12-31 23:59:59.9999999')
    );

    SELECT @SupplierID AS SupplierID;
END;
GO

-- UPDATE de datos generales.
CREATE OR ALTER PROCEDURE dbo.Prov_sp_ActualizarProveedorGeneral
    @SupplierID INT,
    @SupplierName NVARCHAR(100),
    @SupplierCategoryID INT,
    @PaymentDays INT,
    @LastEditedBy INT,
    @SupplierReference NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    UPDATE Purchasing.Suppliers
    SET SupplierName = @SupplierName,
        SupplierCategoryID = @SupplierCategoryID,
        SupplierReference = @SupplierReference,
        PaymentDays = @PaymentDays,
        LastEditedBy = @LastEditedBy
    WHERE SupplierID = @SupplierID;

    IF @@ROWCOUNT = 0
        THROW 51103, 'No existe el proveedor general indicado.', 1;

    SELECT @SupplierID AS SupplierID;
END;
GO

-- DELETE de datos generales; las claves foraneas pueden impedirlo.
CREATE OR ALTER PROCEDURE dbo.Prov_sp_EliminarProveedorGeneral
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DELETE FROM Purchasing.Suppliers
    WHERE SupplierID = @SupplierID;

    IF @@ROWCOUNT = 0
        THROW 51104, 'No existe el proveedor general indicado.', 1;

    SELECT @SupplierID AS SupplierID;
END;
GO

-- Verificacion de creacion (no modifica datos).
SELECT name AS Procedimiento
FROM sys.procedures
WHERE schema_id = SCHEMA_ID('dbo')
  AND name IN (
      'Prov_sp_InsertarProveedorGeneral',
      'Prov_sp_ActualizarProveedorGeneral',
      'Prov_sp_EliminarProveedorGeneral'
  )
ORDER BY name;
GO
