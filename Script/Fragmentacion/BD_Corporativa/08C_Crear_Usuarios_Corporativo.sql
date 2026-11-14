USE WWI_Corporativo;
GO

-- ============================================
-- 1. ADMINISTRADOR SAN JOSE
-- ============================================

IF NOT EXISTS (
    SELECT 1
    FROM Application.Users
    WHERE Username = 'admin_sj'
)
BEGIN
    EXEC Application.Usr_sp_CrearUsuario
        @Username = N'admin_sj',
        @Password = N'1234',
        @FullName = N'Administrador San Jose',
        @Role = N'Administrador',
        @Email = N'admin.sj@wwi.com',
        @HireDate = '2025-01-15',
        @Sucursal = N'SanJose';
END;
GO

-- ============================================
-- 2. ADMINISTRADOR LIMON
-- ============================================

IF NOT EXISTS (
    SELECT 1
    FROM Application.Users
    WHERE Username = 'admin_lim'
)
BEGIN
    EXEC Application.Usr_sp_CrearUsuario
        @Username = N'admin_lim',
        @Password = N'1234',
        @FullName = N'Administrador Limon',
        @Role = N'Administrador',
        @Email = N'admin.lim@wwi.com',
        @HireDate = '2025-01-15',
        @Sucursal = N'Limon';
END;
GO

-- ============================================
-- 3. USUARIO CORPORATIVO
-- ============================================

IF NOT EXISTS (
    SELECT 1
    FROM Application.Users
    WHERE Username = 'corp'
)
BEGIN
    EXEC Application.Usr_sp_CrearUsuario
        @Username = N'corp',
        @Password = N'1234',
        @FullName = N'Gerente Corporativo',
        @Role = N'Corporativo',
        @Email = N'corp@wwi.com',
        @HireDate = '2024-06-01',
        @Sucursal = N'Corporativo';
END;
GO

-- ============================================
-- 4. VERIFICAR USUARIOS CREADOS
-- ============================================

SELECT
    UserID,
    Username,
    FullName,
    Role,
    Sucursal,
    Active,
    Email
FROM Application.Users
WHERE Username IN ('admin_sj', 'admin_lim', 'corp')
ORDER BY UserID;
GO