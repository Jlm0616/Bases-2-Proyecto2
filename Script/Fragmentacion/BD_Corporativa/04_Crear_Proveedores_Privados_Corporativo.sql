
USE WWI_Corporativo;
GO

-- ============================================
-- 04_Crear_Proveedores_Privados_Corporativo.sql
-- ============================================

CREATE TABLE Purchasing.SuppliersPrivate (
    SupplierID INT NOT NULL PRIMARY KEY,

    -- Personas de contacto
    PrimaryContactPersonID INT NOT NULL,
    AlternateContactPersonID INT NOT NULL,

    -- Metodos y ubicaciones de entrega
    DeliveryMethodID INT NULL,
    DeliveryCityID INT NOT NULL,
    PostalCityID INT NOT NULL,

    -- Informacion bancaria
    BankAccountName NVARCHAR(50) NULL,
    BankAccountBranch NVARCHAR(50) NULL,
    BankAccountCode NVARCHAR(20) NULL,
    BankAccountNumber NVARCHAR(20) NULL,
    BankInternationalCode NVARCHAR(20) NULL,

    -- Informacion interna
    InternalComments NVARCHAR(MAX) NULL,

    -- Datos de contacto
    PhoneNumber NVARCHAR(20) NOT NULL,
    FaxNumber NVARCHAR(20) NOT NULL,
    WebsiteURL NVARCHAR(256) NOT NULL,

    -- Direccion de entrega
    DeliveryAddressLine1 NVARCHAR(60) NOT NULL,
    DeliveryAddressLine2 NVARCHAR(60) NULL,
    DeliveryPostalCode NVARCHAR(10) NOT NULL,
    DeliveryLocation GEOGRAPHY NULL,

    -- Direccion postal
    PostalAddressLine1 NVARCHAR(60) NOT NULL,
    PostalAddressLine2 NVARCHAR(60) NULL,
    PostalPostalCode NVARCHAR(10) NOT NULL
);
GO
