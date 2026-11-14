-- ============================================================================
-- 07b_CRUD_Proveedores_Corporativo.sql
-- Datos privados: Purchasing.SuppliersPrivate
-- Ejecutar SOLO en WWI_Corporativo.
-- Lectura existente: dbo.Prov_sp_DetalleProveedorPrivado (archivo 03).
-- ID nuevo: dbo.Prov_sp_GenerarSupplierID (secuencia Purchasing.Seq_SupplierID).
-- No ejecutar inserciones de prueba en datos reales sin verificar el ID.
-- ============================================================================
USE WWI_Corporativo;
GO

-- INSERT: SupplierID se obtiene previamente desde Corporativo.
CREATE OR ALTER PROCEDURE dbo.Prov_sp_InsertarProveedorPrivado
    @SupplierID INT,
    @PrimaryContactPersonID INT,
    @AlternateContactPersonID INT,
    @DeliveryCityID INT,
    @PostalCityID INT,
    @PhoneNumber NVARCHAR(20),
    @FaxNumber NVARCHAR(20),
    @WebsiteURL NVARCHAR(256),
    @DeliveryAddressLine1 NVARCHAR(60),
    @DeliveryPostalCode NVARCHAR(10),
    @PostalAddressLine1 NVARCHAR(60),
    @PostalPostalCode NVARCHAR(10),
    @DeliveryMethodID INT = NULL,
    @BankAccountName NVARCHAR(50) = NULL,
    @BankAccountBranch NVARCHAR(50) = NULL,
    @BankAccountCode NVARCHAR(20) = NULL,
    @BankAccountNumber NVARCHAR(20) = NULL,
    @BankInternationalCode NVARCHAR(20) = NULL,
    @InternalComments NVARCHAR(MAX) = NULL,
    @DeliveryAddressLine2 NVARCHAR(60) = NULL,
    @DeliveryLocation GEOGRAPHY = NULL,
    @PostalAddressLine2 NVARCHAR(60) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @SupplierID IS NULL OR @SupplierID <= 0
        THROW 51001, 'SupplierID debe ser un entero positivo.', 1;
    IF EXISTS (SELECT 1 FROM Purchasing.SuppliersPrivate WHERE SupplierID = @SupplierID)
        THROW 51002, 'El proveedor privado ya existe.', 1;

    INSERT INTO Purchasing.SuppliersPrivate (
        SupplierID, PrimaryContactPersonID, AlternateContactPersonID,
        DeliveryMethodID, DeliveryCityID, PostalCityID,
        BankAccountName, BankAccountBranch, BankAccountCode,
        BankAccountNumber, BankInternationalCode, InternalComments,
        PhoneNumber, FaxNumber, WebsiteURL,
        DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode,
        DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode
    )
    VALUES (
        @SupplierID, @PrimaryContactPersonID, @AlternateContactPersonID,
        @DeliveryMethodID, @DeliveryCityID, @PostalCityID,
        @BankAccountName, @BankAccountBranch, @BankAccountCode,
        @BankAccountNumber, @BankInternationalCode, @InternalComments,
        @PhoneNumber, @FaxNumber, @WebsiteURL,
        @DeliveryAddressLine1, @DeliveryAddressLine2, @DeliveryPostalCode,
        @DeliveryLocation, @PostalAddressLine1, @PostalAddressLine2, @PostalPostalCode
    );

    SELECT @SupplierID AS SupplierID;
END;
GO

-- UPDATE: modifica solo los campos privados, sin alterar SupplierID.
CREATE OR ALTER PROCEDURE dbo.Prov_sp_ActualizarProveedorPrivado
    @SupplierID INT,
    @PrimaryContactPersonID INT,
    @AlternateContactPersonID INT,
    @DeliveryCityID INT,
    @PostalCityID INT,
    @PhoneNumber NVARCHAR(20),
    @FaxNumber NVARCHAR(20),
    @WebsiteURL NVARCHAR(256),
    @DeliveryAddressLine1 NVARCHAR(60),
    @DeliveryPostalCode NVARCHAR(10),
    @PostalAddressLine1 NVARCHAR(60),
    @PostalPostalCode NVARCHAR(10),
    @DeliveryMethodID INT = NULL,
    @BankAccountName NVARCHAR(50) = NULL,
    @BankAccountBranch NVARCHAR(50) = NULL,
    @BankAccountCode NVARCHAR(20) = NULL,
    @BankAccountNumber NVARCHAR(20) = NULL,
    @BankInternationalCode NVARCHAR(20) = NULL,
    @InternalComments NVARCHAR(MAX) = NULL,
    @DeliveryAddressLine2 NVARCHAR(60) = NULL,
    @DeliveryLocation GEOGRAPHY = NULL,
    @PostalAddressLine2 NVARCHAR(60) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    UPDATE Purchasing.SuppliersPrivate
    SET PrimaryContactPersonID = @PrimaryContactPersonID,
        AlternateContactPersonID = @AlternateContactPersonID,
        DeliveryMethodID = @DeliveryMethodID,
        DeliveryCityID = @DeliveryCityID,
        PostalCityID = @PostalCityID,
        BankAccountName = @BankAccountName,
        BankAccountBranch = @BankAccountBranch,
        BankAccountCode = @BankAccountCode,
        BankAccountNumber = @BankAccountNumber,
        BankInternationalCode = @BankInternationalCode,
        InternalComments = @InternalComments,
        PhoneNumber = @PhoneNumber,
        FaxNumber = @FaxNumber,
        WebsiteURL = @WebsiteURL,
        DeliveryAddressLine1 = @DeliveryAddressLine1,
        DeliveryAddressLine2 = @DeliveryAddressLine2,
        DeliveryPostalCode = @DeliveryPostalCode,
        DeliveryLocation = @DeliveryLocation,
        PostalAddressLine1 = @PostalAddressLine1,
        PostalAddressLine2 = @PostalAddressLine2,
        PostalPostalCode = @PostalPostalCode
    WHERE SupplierID = @SupplierID;

    IF @@ROWCOUNT = 0
        THROW 51003, 'No existe el proveedor privado indicado.', 1;

    SELECT @SupplierID AS SupplierID;
END;
GO

-- DELETE: las claves foraneas impedirán borrar proveedores en uso.
CREATE OR ALTER PROCEDURE dbo.Prov_sp_EliminarProveedorPrivado
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DELETE FROM Purchasing.SuppliersPrivate
    WHERE SupplierID = @SupplierID;

    IF @@ROWCOUNT = 0
        THROW 51004, 'No existe el proveedor privado indicado.', 1;

    SELECT @SupplierID AS SupplierID;
END;
GO

-- Verificacion de creacion (no modifica datos).
SELECT name AS Procedimiento
FROM sys.procedures
WHERE schema_id = SCHEMA_ID('dbo')
  AND name IN (
      'Prov_sp_InsertarProveedorPrivado',
      'Prov_sp_ActualizarProveedorPrivado',
      'Prov_sp_EliminarProveedorPrivado'
  )
ORDER BY name;
GO
