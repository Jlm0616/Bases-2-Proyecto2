-- ============================================
-- 08b_Cifrado_Usuarios_Corporativo.sql
-- ============================================

USE WWI_Corporativo;
GO

-- 1. COLUMNA DE SUCURSAL (aislamiento de negocios)
IF COL_LENGTH('Application.Users', 'Sucursal') IS NULL
    ALTER TABLE Application.Users ADD Sucursal NVARCHAR(20) NULL;
GO

IF OBJECT_ID('Application.CK_Users_Sucursal') IS NULL
    ALTER TABLE Application.Users ADD CONSTRAINT CK_Users_Sucursal
        CHECK (Sucursal IN ('SanJose', 'Limon', 'Corporativo'));
GO

-- 2. JERARQUIA DE CIFRADO
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'CambiarEstaClave#2026!';
GO

IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'CertUsuariosWWI')
    CREATE CERTIFICATE CertUsuariosWWI
        WITH SUBJECT = 'Cifrado de contrasenas de usuarios WWI';
GO

IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = 'KeyUsuariosWWI')
    CREATE SYMMETRIC KEY KeyUsuariosWWI
        WITH ALGORITHM = AES_256
        ENCRYPTION BY CERTIFICATE CertUsuariosWWI;
GO

-- 3. CREAR USUARIO (cifra la contrasena)
CREATE OR ALTER PROCEDURE Application.Usr_sp_CrearUsuario
    @Username  NVARCHAR(50),
    @Password  NVARCHAR(100),
    @FullName  NVARCHAR(100),
    @Role      NVARCHAR(20),
    @Email     NVARCHAR(256),
    @HireDate  DATE,
    @Sucursal  NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        OPEN SYMMETRIC KEY KeyUsuariosWWI DECRYPTION BY CERTIFICATE CertUsuariosWWI;

        INSERT INTO Application.Users
            (Username, PasswordEncrypted, FullName, Role, Email, HireDate, Sucursal)
        OUTPUT INSERTED.UserID
        VALUES
            (@Username, ENCRYPTBYKEY(KEY_GUID('KeyUsuariosWWI'), @Password),
             @FullName, @Role, @Email, @HireDate, @Sucursal);

        CLOSE SYMMETRIC KEY KeyUsuariosWWI;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        BEGIN TRY CLOSE SYMMETRIC KEY KeyUsuariosWWI; END TRY BEGIN CATCH END CATCH;
        THROW;
    END CATCH
END;
GO

-- 4. LOGIN (descifra y compara, sensible a mayusculas)
CREATE OR ALTER PROCEDURE Application.Usr_sp_Login
    @Username NVARCHAR(50),
    @Password NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY KeyUsuariosWWI DECRYPTION BY CERTIFICATE CertUsuariosWWI;

    SELECT UserID, Username, FullName, Role, Email, Sucursal
    FROM Application.Users
    WHERE Username = @Username
      AND Active = 1
      AND CONVERT(NVARCHAR(100), DECRYPTBYKEY(PasswordEncrypted))
          COLLATE Latin1_General_CS_AS = @Password COLLATE Latin1_General_CS_AS;

    CLOSE SYMMETRIC KEY KeyUsuariosWWI;
END;
GO

-- 5. USUARIOS DE PRUEBA
--EXEC Application.Usr_sp_CrearUsuario 'admin_sj',  'Admin123!', 'Administrador San Jose', 'Administrador', 'admin.sj@wwi.com',  '2025-01-15', 'SanJose';
--EXEC Application.Usr_sp_CrearUsuario 'admin_lim', 'Admin123!', 'Administrador Limon',    'Administrador', 'admin.lim@wwi.com', '2025-01-15', 'Limon';
--EXEC Application.Usr_sp_CrearUsuario 'corp',      'Corp123!',  'Gerente Corporativo',    'Corporativo',   'corp@wwi.com',      '2024-06-01', 'Corporativo';
--GO

-- 6. VERIFICACION
--SELECT UserID, Username, PasswordEncrypted, Role, Sucursal FROM Application.Users;
--EXEC Application.Usr_sp_Login 'admin_sj', 'Admin123!';   -- debe devolver 1 fila
--EXEC Application.Usr_sp_Login 'admin_sj', 'incorrecta';  -- debe devolver 0 filas
--GO