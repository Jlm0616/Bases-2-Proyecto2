
USE WWI_Corporativo;
GO

-- ============================================
-- 02_Crear_Personas_Privadas_Corporativo.sql
-- ============================================

CREATE TABLE Application.PeoplePrivate (
    PersonID INT NOT NULL PRIMARY KEY,

    -- Datos de contacto
    PhoneNumber NVARCHAR(20) NULL,
    FaxNumber NVARCHAR(20) NULL,
    EmailAddress NVARCHAR(256) NULL,

    -- Autenticacion
    LogonName NVARCHAR(50) NULL,
    IsPermittedToLogon BIT NOT NULL,
    IsExternalLogonProvider BIT NOT NULL,
    HashedPassword VARBINARY(MAX) NULL,

    -- Preferencias y datos adicionales
    UserPreferences NVARCHAR(MAX) NULL,
    OtherLanguages NVARCHAR(MAX) NULL,
    Photo VARBINARY(MAX) NULL,
    CustomFields NVARCHAR(MAX) NULL
);
GO