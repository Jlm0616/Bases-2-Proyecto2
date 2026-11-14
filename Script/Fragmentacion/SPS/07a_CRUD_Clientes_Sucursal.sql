
-- ============================================================================
-- 07a_CRUD_Clientes_Sucursal.sql
-- CRUD de Clientes - Sucursales
-- Proyecto 2 Bases de Datos II
--
-- Descripcion:
--   Gestiona los datos generales de clientes.
--   Se ejecuta en WWI_Limon y WWI_SanJose.
--
--   Los datos privados se almacenan en WWI_Corporativo.
--   El CustomerID es generado previamente por Corporativo.
--
-- Operaciones:
--   01. Insertar cliente general
--   02. Actualizar cliente general
--   03. Eliminar cliente general
-- ============================================================================

-- IMPORTANTE:
-- Seleccionar WWI_Limon o WWI_SanJose en SSMS
-- antes de ejecutar este archivo.
-- No incluir USE para permitir reutilizarlo en ambas bases.

-- ============================================================================
-- 01. INSERTAR CLIENTE GENERAL
-- ============================================================================
-- Descripcion:
--   Inserta los datos generales de un cliente.
--   El CustomerID debe ser el mismo en ambas sucursales.
--   La API coordina la generacion del identificador.
-- ============================================================================

CREATE OR ALTER PROCEDURE dbo.Cli_sp_InsertarClienteGeneral
    @CustomerID         INT,
    @NombreCliente      NVARCHAR(100),
    @CategoriaID        INT,
    @LastEditedBy       INT,
    @BuyingGroupID      INT = NULL,
    @BillToCustomerID   INT = NULL,
    @AccountOpenedDate  DATE = NULL,
    @PaymentDays        INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        IF @CustomerID IS NULL OR @CustomerID <= 0
            THROW 50101, 'El CustomerID debe ser positivo.', 1;

        IF NULLIF(LTRIM(RTRIM(@NombreCliente)), N'') IS NULL
            THROW 50102, 'El nombre del cliente es obligatorio.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Cli_CategoriasCliente
            WHERE CustomerCategoryID = @CategoriaID
        )
            THROW 50103, 'La categoria del cliente no existe.', 1;

        IF @BuyingGroupID IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM dbo.Cli_GruposCompra
               WHERE BuyingGroupID = @BuyingGroupID
           )
            THROW 50104, 'El grupo de compra no existe.', 1;

        IF @PaymentDays IS NULL OR @PaymentDays < 0
            THROW 50105, 'Los dias de pago no son validos.', 1;

        SET @AccountOpenedDate =
            COALESCE(@AccountOpenedDate, CAST(GETDATE() AS DATE));

        -- Por defecto, el cliente se factura a si mismo.
        SET @BillToCustomerID =
            COALESCE(@BillToCustomerID, @CustomerID);

        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1
            FROM Sales.Customers WITH (UPDLOCK, HOLDLOCK)
            WHERE CustomerID = @CustomerID
        )
            THROW 50106, 'El cliente ya existe en la sucursal.', 1;

        -- Si factura a otro cliente, este debe existir.
        IF @BillToCustomerID <> @CustomerID
           AND NOT EXISTS (
               SELECT 1
               FROM Sales.Customers
               WHERE CustomerID = @BillToCustomerID
           )
            THROW 50107, 'El cliente de facturacion no existe.', 1;

        -- Se usa inicialmente un cliente existente
        -- para respetar la FK de BillToCustomerID.
        -- Luego se configura la autofacturacion.
        DECLARE @ClienteFacturacionInicial INT;

        IF @BillToCustomerID = @CustomerID
        BEGIN
            SELECT TOP (1)
                @ClienteFacturacionInicial = CustomerID
            FROM Sales.Customers
            ORDER BY CustomerID;

            IF @ClienteFacturacionInicial IS NULL
                THROW 50108,
                    'No existe un cliente inicial para facturacion.',
                    1;
        END
        ELSE
        BEGIN
            SET @ClienteFacturacionInicial = @BillToCustomerID;
        END;

        INSERT INTO Sales.Customers (
            CustomerID,
            CustomerName,
            BillToCustomerID,
            CustomerCategoryID,
            BuyingGroupID,
            AccountOpenedDate,
            StandardDiscountPercentage,
            IsStatementSent,
            IsOnCreditHold,
            PaymentDays,
            LastEditedBy,
            ValidFrom,
            ValidTo
        )
        VALUES (
            @CustomerID,
            @NombreCliente,
            @ClienteFacturacionInicial,
            @CategoriaID,
            @BuyingGroupID,
            @AccountOpenedDate,
            0,
            0,
            0,
            @PaymentDays,
            @LastEditedBy,
            SYSUTCDATETIME(),
            CONVERT(DATETIME2(7), '9999-12-31 23:59:59.9999999')
        );

        IF @BillToCustomerID = @CustomerID
        BEGIN
            UPDATE Sales.Customers
            SET BillToCustomerID = @CustomerID
            WHERE CustomerID = @CustomerID;
        END;

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
-- 02. ACTUALIZAR CLIENTE GENERAL
-- ============================================================================
-- Descripcion:
--   Actualiza los datos generales de un cliente.
--   Los parametros NULL conservan los valores existentes.
-- ============================================================================

CREATE OR ALTER PROCEDURE dbo.Cli_sp_ActualizarClienteGeneral
    @CustomerID         INT,
    @LastEditedBy       INT,
    @NombreCliente      NVARCHAR(100) = NULL,
    @CategoriaID        INT = NULL,
    @BuyingGroupID      INT = NULL,
    @BillToCustomerID   INT = NULL,
    @PaymentDays        INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        IF NOT EXISTS (
            SELECT 1
            FROM Sales.Customers
            WHERE CustomerID = @CustomerID
        )
            THROW 50111, 'El cliente no existe en la sucursal.', 1;

        IF @NombreCliente IS NOT NULL
           AND NULLIF(LTRIM(RTRIM(@NombreCliente)), N'') IS NULL
            THROW 50112, 'El nombre del cliente no puede estar vacio.', 1;

        IF @CategoriaID IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM dbo.Cli_CategoriasCliente
               WHERE CustomerCategoryID = @CategoriaID
           )
            THROW 50113, 'La categoria del cliente no existe.', 1;

        IF @BuyingGroupID IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM dbo.Cli_GruposCompra
               WHERE BuyingGroupID = @BuyingGroupID
           )
            THROW 50114, 'El grupo de compra no existe.', 1;

        IF @BillToCustomerID IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM Sales.Customers
               WHERE CustomerID = @BillToCustomerID
           )
            THROW 50115, 'El cliente de facturacion no existe.', 1;

        IF @PaymentDays IS NOT NULL AND @PaymentDays < 0
            THROW 50116, 'Los dias de pago no son validos.', 1;

        BEGIN TRANSACTION;

        UPDATE Sales.Customers
        SET
            CustomerName =
                COALESCE(@NombreCliente, CustomerName),
            CustomerCategoryID =
                COALESCE(@CategoriaID, CustomerCategoryID),
            BuyingGroupID =
                COALESCE(@BuyingGroupID, BuyingGroupID),
            BillToCustomerID =
                COALESCE(@BillToCustomerID, BillToCustomerID),
            PaymentDays =
                COALESCE(@PaymentDays, PaymentDays),
            LastEditedBy = @LastEditedBy
        WHERE CustomerID = @CustomerID;

        DECLARE @FilasAfectadas INT = @@ROWCOUNT;

        IF @FilasAfectadas <> 1
            THROW 50117, 'No se pudo actualizar el cliente.', 1;

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
-- 03. ELIMINAR CLIENTE GENERAL
-- ============================================================================
-- Descripcion:
--   Elimina los datos generales de un cliente.
--   Verifica que no tenga facturas ni otros clientes
--   que dependan de el para facturacion.
--
-- Importante:
--   La API debe coordinar la eliminacion entre
--   ambas sucursales y Corporativo.
-- ============================================================================

CREATE OR ALTER PROCEDURE dbo.Cli_sp_EliminarClienteGeneral
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        IF @CustomerID IS NULL OR @CustomerID <= 0
            THROW 50120, 'El CustomerID debe ser positivo.', 1;

        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM Sales.Customers WITH (UPDLOCK, HOLDLOCK)
            WHERE CustomerID = @CustomerID
        )
            THROW 50121, 'El cliente no existe en la sucursal.', 1;

        -- Verificar facturas.
        IF EXISTS (
            SELECT 1
            FROM Sales.Invoices
            WHERE CustomerID = @CustomerID
        )
            THROW 50122,
                'No se puede eliminar: el cliente tiene facturas.',
                1;

        -- Verificar dependencias de facturacion.
        IF EXISTS (
            SELECT 1
            FROM Sales.Customers
            WHERE BillToCustomerID = @CustomerID
              AND CustomerID <> @CustomerID
        )
            THROW 50123,
                'No se puede eliminar: otros clientes dependen de el.',
                1;

        DELETE FROM Sales.Customers
        WHERE CustomerID = @CustomerID;

        DECLARE @FilasAfectadas INT = @@ROWCOUNT;

        IF @FilasAfectadas <> 1
            THROW 50124, 'No se pudo eliminar el cliente.', 1;

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
