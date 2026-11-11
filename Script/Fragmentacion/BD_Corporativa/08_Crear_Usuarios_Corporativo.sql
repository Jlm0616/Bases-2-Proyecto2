-- ============================================
-- 08_Crear_Usuarios_Corporativo.sql
-- ============================================

USE WWI_Corporativo;
GO

-- ============================================
-- 1. CREAR TABLA DE USUARIOS
-- ============================================

CREATE TABLE Application.Users (
    UserID INT IDENTITY(1,1) NOT NULL,
    Username NVARCHAR(50) NOT NULL,
    PasswordEncrypted VARBINARY(8000) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Active BIT NOT NULL DEFAULT (1),
    Role NVARCHAR(20) NOT NULL,
    Email NVARCHAR(256) NOT NULL,
    HireDate DATE NOT NULL,

    CONSTRAINT PK_Users
        PRIMARY KEY (UserID),

    CONSTRAINT UQ_Users_Username
        UNIQUE (Username),

    CONSTRAINT CK_Users_Role
        CHECK (Role IN ('Administrador', 'Corporativo'))
);
GO
