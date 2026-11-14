
-- ============================================================================
-- 07a_CRUD_Clientes_Corporativo.sql
-- CRUD de Clientes - Corporativo
-- Proyecto 2 Bases de Datos II
--
-- Descripcion:
--   Gestiona los datos privados de clientes en WWI_Corporativo.
--   El CustomerID es generado previamente por Corporativo.
--   Los datos generales se almacenan en las sucursales.
-- ============================================================================

USE WWI_Corporativo;
GO

-- ============================================================================
-- 01. INSERTAR CLIENTE PRIVADO
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.Cli_sp_InsertarClientePrivado
    @CustomerID              INT,
    @PrimaryContactID        INT,
    @MetodoEntregaID         INT,
    @DeliveryCityID          INT,
    @AlternateContactID      INT = NULL,
    @CreditLimit             DECIMAL(18,2) = NULL,
    @PostalCityID            INT = NULL,
    @PhoneNumber             NVARCHAR(20) = N'Sin definir',
    @FaxNumber               NVARCHAR(20) = NULL,
    @WebsiteURL              NVARCHAR(256) = N'http://www.AunNoSe.com',
    @DeliveryAddressLine1    NVARCHAR(60) = N'Sin definir',
    @DeliveryAddressLine2    NVARCHAR(60) = NULL,
    @DeliveryPostalCode      NVARCHAR(10) = N'00000',
    @PostalAddressLine1      NVARCHAR(60) = N'Sin definir',
    @PostalAddressLine2      NVARCHAR(60) = NULL,
    @PostalPostalCode        NVARCHAR(10) = N'00000'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- Validaciones
        IF @CustomerID IS NULL OR @CustomerID <= 0
            THROW 50001, 'El CustomerID debe ser positivo.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM Application.PeoplePrivate
            WHERE PersonID = @PrimaryContactID
        )
            THROW 50002, 'El contacto principal no existe.', 1;

        IF @AlternateContactID IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM Application.PeoplePrivate
               WHERE PersonID = @AlternateContactID
           )
            THROW 50003, 'El contacto alternativo no existe.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Gen_MetodosEntrega
            WHERE DeliveryMethodID = @MetodoEntregaID
        )
            THROW 50004, 'El metodo de entrega no existe.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Gen_Ciudades
            WHERE CityID = @DeliveryCityID
        )
            THROW 50005, 'La ciudad de entrega no existe.', 1;

        SET @PostalCityID = ISNULL(@PostalCityID, @DeliveryCityID);

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Gen_Ciudades
            WHERE CityID = @PostalCityID
        )
            THROW 50006, 'La ciudad postal no existe.', 1;

        IF @CreditLimit IS NOT NULL AND @CreditLimit < 0
            THROW 50007, 'El limite de credito no puede ser negativo.', 1;

        IF NULLIF(LTRIM(RTRIM(@PhoneNumber)), N'') IS NULL
            THROW 50008, 'El telefono no puede estar vacio.', 1;

        SET @FaxNumber = COALESCE(@FaxNumber, @PhoneNumber);

        IF NULLIF(LTRIM(RTRIM(@FaxNumber)), N'') IS NULL
            THROW 50009, 'El fax no puede estar vacio.', 1;

        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1
            FROM Sales.CustomersPrivate WITH (UPDLOCK, HOLDLOCK)
            WHERE CustomerID = @CustomerID
        )
            THROW 50010, 'El cliente ya existe en Corporativo.', 1;

        INSERT INTO Sales.CustomersPrivate (
            CustomerID,
            PrimaryContactPersonID,
            AlternateContactPersonID,
            CreditLimit,
            PhoneNumber,
            FaxNumber,
            WebsiteURL,
            DeliveryMethodID,
            DeliveryCityID,
            DeliveryAddressLine1,
            DeliveryAddressLine2,
            DeliveryPostalCode,
            DeliveryLocation,
            DeliveryRun,
            RunPosition,
            PostalCityID,
            PostalAddressLine1,
            PostalAddressLine2,
            PostalPostalCode
        )
        VALUES (
            @CustomerID,
            @PrimaryContactID,
            @AlternateContactID,
            @CreditLimit,
            @PhoneNumber,
            @FaxNumber,
            @WebsiteURL,
            @MetodoEntregaID,
            @DeliveryCityID,
            @DeliveryAddressLine1,
            @DeliveryAddressLine2,
            @DeliveryPostalCode,
            NULL,
            NULL,
            NULL,
            @PostalCityID,
            @PostalAddressLine1,
            @PostalAddressLine2,
            @PostalPostalCode
        );

        COMMIT TRANSACTION;

        SELECT
            @CustomerID AS NuevoClienteID,
            'OK' AS Resultado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO


-- ============================================================================
-- 02. ACTUALIZAR CLIENTE PRIVADO
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.Cli_sp_ActualizarClientePrivado
    @CustomerID              INT,
    @PrimaryContactID        INT = NULL,
    @AlternateContactID      INT = NULL,
    @CreditLimit             DECIMAL(18,2) = NULL,
    @MetodoEntregaID         INT = NULL,
    @DeliveryCityID          INT = NULL,
    @PostalCityID            INT = NULL,
    @PhoneNumber             NVARCHAR(20) = NULL,
    @FaxNumber               NVARCHAR(20) = NULL,
    @WebsiteURL              NVARCHAR(256) = NULL,
    @DeliveryAddressLine1    NVARCHAR(60) = NULL,
    @DeliveryAddressLine2    NVARCHAR(60) = NULL,
    @DeliveryPostalCode      NVARCHAR(10) = NULL,
    @PostalAddressLine1      NVARCHAR(60) = NULL,
    @PostalAddressLine2      NVARCHAR(60) = NULL,
    @PostalPostalCode        NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM Sales.CustomersPrivate
            WHERE CustomerID = @CustomerID
        )
            THROW 50011, 'El cliente no existe en Corporativo.', 1;

        IF @PrimaryContactID IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM Application.PeoplePrivate
               WHERE PersonID = @PrimaryContactID
           )
            THROW 50012, 'El contacto principal no existe.', 1;

        IF @AlternateContactID IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM Application.PeoplePrivate
               WHERE PersonID = @AlternateContactID
           )
            THROW 50013, 'El contacto alternativo no existe.', 1;

        IF @MetodoEntregaID IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM dbo.Gen_MetodosEntrega
               WHERE DeliveryMethodID = @MetodoEntregaID
           )
            THROW 50014, 'El metodo de entrega no existe.', 1;

        IF @DeliveryCityID IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM dbo.Gen_Ciudades
               WHERE CityID = @DeliveryCityID
           )
            THROW 50015, 'La ciudad de entrega no existe.', 1;

        IF @PostalCityID IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM dbo.Gen_Ciudades
               WHERE CityID = @PostalCityID
           )
            THROW 50016, 'La ciudad postal no existe.', 1;

        IF @CreditLimit IS NOT NULL AND @CreditLimit < 0
            THROW 50017, 'El limite de credito no puede ser negativo.', 1;

        IF @PhoneNumber IS NOT NULL
           AND NULLIF(LTRIM(RTRIM(@PhoneNumber)), N'') IS NULL
            THROW 50018, 'El telefono no puede estar vacio.', 1;

        BEGIN TRANSACTION;

        UPDATE Sales.CustomersPrivate
        SET
            PrimaryContactPersonID =
                COALESCE(@PrimaryContactID, PrimaryContactPersonID),
            AlternateContactPersonID =
                COALESCE(@AlternateContactID, AlternateContactPersonID),
            CreditLimit =
                COALESCE(@CreditLimit, CreditLimit),
            DeliveryMethodID =
                COALESCE(@MetodoEntregaID, DeliveryMethodID),
            DeliveryCityID =
                COALESCE(@DeliveryCityID, DeliveryCityID),
            PostalCityID =
                COALESCE(@PostalCityID, PostalCityID),
            PhoneNumber =
                COALESCE(@PhoneNumber, PhoneNumber),
            FaxNumber =
                COALESCE(@FaxNumber, FaxNumber),
            WebsiteURL =
                COALESCE(@WebsiteURL, WebsiteURL),
            DeliveryAddressLine1 =
                COALESCE(@DeliveryAddressLine1, DeliveryAddressLine1),
            DeliveryAddressLine2 =
                COALESCE(@DeliveryAddressLine2, DeliveryAddressLine2),
            DeliveryPostalCode =
                COALESCE(@DeliveryPostalCode, DeliveryPostalCode),
            PostalAddressLine1 =
                COALESCE(@PostalAddressLine1, PostalAddressLine1),
            PostalAddressLine2 =
                COALESCE(@PostalAddressLine2, PostalAddressLine2),
            PostalPostalCode =
                COALESCE(@PostalPostalCode, PostalPostalCode)
        WHERE CustomerID = @CustomerID;

        DECLARE @FilasAfectadas INT = @@ROWCOUNT;

        IF @FilasAfectadas <> 1
            THROW 50019, 'No se pudo actualizar el cliente.', 1;

        COMMIT TRANSACTION;

        SELECT
            @FilasAfectadas AS FilasAfectadas,
            'OK' AS Resultado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 03. ELIMINAR CLIENTE PRIVADO
-- ============================================================================
-- Descripcion:
--   Elimina los datos privados de un cliente en Corporativo.
--   La API debe comprobar previamente que el cliente
--   no tenga facturas ni otras dependencias en las sucursales.
--
-- Importante:
--   Este procedimiento no elimina datos generales.
--   La eliminacion completa debe coordinarse entre nodos.
-- ============================================================================

CREATE OR ALTER PROCEDURE dbo.Cli_sp_EliminarClientePrivado
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        IF @CustomerID IS NULL OR @CustomerID <= 0
            THROW 50020, 'El CustomerID debe ser positivo.', 1;

        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM Sales.CustomersPrivate WITH (UPDLOCK, HOLDLOCK)
            WHERE CustomerID = @CustomerID
        )
            THROW 50021, 'El cliente no existe en Corporativo.', 1;

        DELETE FROM Sales.CustomersPrivate
        WHERE CustomerID = @CustomerID;

        DECLARE @FilasAfectadas INT = @@ROWCOUNT;

        IF @FilasAfectadas <> 1
            THROW 50022, 'No se pudo eliminar el cliente privado.', 1;

        COMMIT TRANSACTION;

        SELECT
            @FilasAfectadas AS FilasAfectadas,
            'OK' AS Resultado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
