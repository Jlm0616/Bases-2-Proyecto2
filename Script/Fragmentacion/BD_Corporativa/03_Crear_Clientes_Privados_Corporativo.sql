
USE WWI_Corporativo;
GO

-- ============================================
-- 03_Crear_Clientes_Privados_Corporativo.sql
-- ============================================

CREATE TABLE Sales.CustomersPrivate (
    CustomerID INT NOT NULL PRIMARY KEY,

    -- Personas de contacto
    PrimaryContactPersonID INT NOT NULL,
    AlternateContactPersonID INT NULL,

    -- Informacion comercial privada
    CreditLimit DECIMAL(18, 2) NULL,

    -- Datos de contacto
    PhoneNumber NVARCHAR(20) NOT NULL,
    FaxNumber NVARCHAR(20) NOT NULL,
    WebsiteURL NVARCHAR(256) NOT NULL,

    -- Informacion de entrega
    DeliveryMethodID INT NOT NULL,
    DeliveryCityID INT NOT NULL,
    DeliveryAddressLine1 NVARCHAR(60) NOT NULL,
    DeliveryAddressLine2 NVARCHAR(60) NULL,
    DeliveryPostalCode NVARCHAR(10) NOT NULL,
    DeliveryLocation GEOGRAPHY NULL,
    DeliveryRun NVARCHAR(5) NULL,
    RunPosition NVARCHAR(5) NULL,

    -- Direccion postal
    PostalCityID INT NOT NULL,
    PostalAddressLine1 NVARCHAR(60) NOT NULL,
    PostalAddressLine2 NVARCHAR(60) NULL,
    PostalPostalCode NVARCHAR(10) NOT NULL
);
GO

-- ============================================
-- Verificar estructura
-- ============================================

SELECT
    c.name AS Columna,
    TYPE_NAME(c.user_type_id) AS Tipo,
    c.max_length AS LongitudBytes,
    c.is_nullable AS PermiteNull
FROM sys.columns c
WHERE c.object_id = OBJECT_ID('Sales.CustomersPrivate')
ORDER BY c.column_id;
GO
