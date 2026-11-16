# Wide World Importers - Sistema de Gestión Fragmentado

**Aplicación web full-stack con arquitectura de base de datos fragmentada, autenticación basada en sesiones y control de acceso por roles.**

---

## Integrantes

| Nombre | Carné |
|---|---|
| Julian Lizano Monge | 2024188887 |
| Maikel Flores Navarro | 2024148346 |

**Curso:** Bases de Datos 2  
**Fecha de entrega:** 4 de octubre de 2026, 10:00 PM

---

## Descripción del proyecto

Sistema de gestión empresarial para Wide World Importers con arquitectura de base de datos fragmentada en tres nodos:
- **SanJosé**: Base de datos de la sucursal de San José
- **Limón**: Base de datos de la sucursal de Limón  
- **Corporativo**: Base de datos consolidada con datos privados de clientes/proveedores y reportes estadísticos

La aplicación incluye:
- Autenticación y gestión de sesiones con cookies HTTP-only
- Control de acceso basado en roles (Administrador de sucursal, Corporativo)
- Módulos de gestión: Clientes, Proveedores, Productos, Ventas, Reportes
- Operaciones CRUD completas con validaciones
- Paginación y filtros acumulativos
- Inventario consolidado y reportes estadísticos
- Consultas con respaldo automático para Corporativo (SanJosé → Limón en caso de fallo)

---

## Arquitectura del Sistema

### 1. Nodos de Base de Datos

El sistema utiliza una arquitectura de fragmentación horizontal con tres bases de datos SQL Server:

#### **Nodo SanJosé (Sucursal)**
- Datos públicos: clientes, proveedores, productos, ventas, inventario
- Solo administradores de SanJosé pueden modificar datos
- Puerto: 1433 (host: 1433)

#### **Nodo Limón (Sucursal)**
- Datos públicos: clientes, proveedores, productos, ventas, inventario
- Solo administradores de Limón pueden modificar datos
- Puerto: 1434 (host: 1434)

#### **Nodo Corporativo (Consolidado)**
- Datos privados: información confidencial de clientes y proveedores
- Reportes estadísticos consolidados
- Inventario consolidado de todas las sucursales
- Tablas receptoras para sincronización de compras
- Solo usuarios Corporativo pueden acceder
- Puerto: 1435 (host: 1435)

### 2. API Backend (Node.js + Express)

**Ubicación:** `WWI-API/`  
**Puerto:** 3000  
**Tecnologías:**
- Express.js 5.3.0
- mssql 12.7.14 (driver SQL Server)
- express-session 1.19.0 (gestión de sesiones)
- cors 2.8.6 (CORS para frontend)
- dotenv 18.0.10 (variables de entorno)

**Funcionalidades:**
- Autenticación con procedimiento almacenado `Application.Usr_sp_Login`
- Sesiones con cookies HTTP-only, sameSite 'lax', duración 2 horas
- Middleware de autorización: `verificarSesion`, `verificarAdministrador`, `verificarCorporativo`
- Controladores por módulo: clientes, proveedores, productos, ventas, reportes
- Consultas con respaldo automático para Corporativo (intenta SanJosé, si falla → Limón)
- Manejo de errores en español con códigos HTTP apropiados

### 3. Frontend (React + Vite)

**Ubicación:** `WWI-WEBSITE/`  
**Puerto:** 5173  
**Tecnologías:**
- React 19.3.1
- Vite 8.3.6
- Context API para autenticación global
- Express sessions para persistencia de sesión

**Funcionalidades:**
- Panel de autenticación (login/logout)
- Panel de Corporativo: clientes, proveedores, productos, ventas (con filtros por sucursal), reportes
- Panel de Sucursales: clientes, proveedores, productos, ventas
- Componentes reutilizables: BarraLateral, BarraSuperior, modales CRUD
- Servicios para llamadas a la API con credenciales
- Filtros acumulativos con botón "Limpiar"
- Paginación con selección de tamaño (25, 50, 100)

---

## Estructura del Proyecto

```
Bases-2-Proyecto2/
├── README.md
├── docker-compose.yml              # Docker Compose para base de datos
├── docker-compose.db.yml          # Docker Compose específico para SQL Server
├── .gitignore
│
├── Script/                        # Scripts SQL para configuración
│   ├── 01_CrearBaseDeDatos.sql
│   ├── 02_SP_Clientes.sql         # Procedimientos de clientes
│   ├── 03_SP_Proveedores.sql      # Procedimientos de proveedores
│   ├── 04_SP_Productos.sql        # Procedimientos de productos
│   ├── 05_SP_Ventas.sql           # Procedimientos de ventas
│   ├── 06_SP_Reportes.sql         # Procedimientos de reportes
│   ├── 07_Aplicacion.sql         # Datos de aplicación
│   ├── 08_Autenticacion.sql      # Usuarios y autenticación
│   └── Fragmentacion/             # Scripts de fragmentación
│       ├── BD_SanJose/
│       ├── BD_Limon/
│       └── BD_Corporativa/
│           ├── 15_Crear_Tablas_Receptoras_Corporativo.sql
│
├── WWI-API/                       # Backend (Node.js + Express)
│   ├── package.json
│   ├── server.js                  # Punto de entrada del servidor
│   ├── .env                       # Variables de entorno (NO subir a Git)
│   ├── config/
│   │   └── db.js                  # Configuración de conexiones a las 3 bases de datos
│   ├── middleware/
│   │   └── middlewareAutorizacion.js  # Verificación de sesiones y roles
│   ├── controladores/             # Lógica de negocio por módulo
│   │   ├── controladorAutenticacion.js
│   │   ├── controladorClientes.js
│   │   ├── controladorProveedores.js
│   │   ├── controladorProductos.js
│   │   ├── controladorVentas.js
│   │   └── controladorReportes.js
│   └── rutas/                     # Definición de endpoints REST
│       ├── rutasAutenticacion.js
│       ├── rutasClientes.js
│       ├── rutasProveedores.js
│       rutasProductos.js
│       ├── rutasVentas.js
│       └── rutasReportes.js
│
└── WWI-WEBSITE/                   # Frontend (React + Vite)
    ├── package.json
    ├── vite.config.js
    ├── index.html
    ├── src/
    │   ├── main.jsx
    │   ├── App.jsx                 # Enrutador principal por rol
    │   ├── contextos/
    │   │   └── ContextoAutenticacion.jsx  # Contexto global de autenticación
    │   ├── componentes/
    │   │   ├── BarraLateral.jsx      # Menú lateral con opciones por rol
    │   │   ├── BarraSuperior.jsx     # Barra superior con logout
    │   │   ├── clientes/             # Componentes CRUD de clientes
    │   │   ├── productos/            # Componentes CRUD de productos
    │   │   ├── proveedores/          # Componentes CRUD de proveedores
    │   │   ├── ventas/               # Componentes CRUD de ventas
    │   │   └── reportes/             # Componentes de visualización de reportes
    │   ├── paginas/
    │   │   ├── Login.jsx             # Página de inicio de sesión
    │   │   ├── sucursal/             # Paneles de administradores de sucursal
    │   │   │   ├── InicioSucursal.jsx
    │   │   │   ├── Clientes.jsx
    │   │   │   ├── Productos.jsx
    │   │   │   ├── Proveedores.jsx
    │   │   │   └── Ventas.jsx
    │   │   └── corporativo/          # Panel de Corporativo
    │   │       ├── InicioCorporativo.jsx
    │   │       ├── ClientesCorporativo.jsx    # Vista de solo lectura
    │   │       ├── ProductosCorporativo.jsx   # Vista con inventario
    │   │       ├── ProveedoresCorporativo.jsx # Vista de solo lectura
    │   │       └── Reportes.jsx
    │   ├── servicios/
    │   │   ├── api.js                # Cliente HTTP con credenciales
    │   │   ├── autenticacion.js     # Servicios de login/logout
    │   │   ├── clientes.js
    │   │   ├── productos.js
    │   │   ├── proveedores.js
    │   │   ├── ventas.js
    │   │   └── reportes.js
    │   └── estilos/
    │       ├── estructuraPanel.css
    │       ├── clientes.css
    │       ├── productos.css
    │       ├── proveedores.css
    │       ├── ventas.css
    │       └── reportes.css
```

---

## Cómo Ejecutar el Proyecto

### Requisitos Previos

- Docker Desktop instalado y corriendo
- Node.js v18 o superior
- SQL Server Management Studio (SSMS) u otro cliente SQL

### 1. Levantar las Bases de Datos (Docker)

```powershell
cd C:\Users\Usuario\Documents\GitHub\Bases-2-Proyecto2
docker-compose -f docker-compose.db.yml up -d
```

Esto iniciará tres contenedores de SQL Server:
- `sqlserver-sanjose` (puerto 1433)
- `sqlserver-limon` (puerto 1434)
- `sqlserver-corporativo` (puerto 1435)

**Credenciales de conexión:**
- Usuario: `sa`
- Contraseña: `<TU_PASSWORD>`

### 2. Ejecutar los Scripts SQL

En SSMS, conectarse a cada base de datos y ejecutar los scripts correspondientes:

#### **Base de datos SanJosé (localhost,1433)**
```
Script/Fragmentacion/BD_SanJose/01_CrearBaseDatos.sql
Script/Fragmentacion/BD_SanJose/02_SP_Clientes.sql
Script/Fragmentacion/BD_SanJose/03_SP_Proveedores.sql
Script/Fragmentacion/BD_SanJose/04_SP_Productos.sql
Script/Fragmentacion/BD_SanJose/05_SP_Ventas.sql
Script/08_Autenticacion.sql
```

#### **Base de datos Limón (localhost,1434)**
```
Script/Fragmentacion/BD_Limon/01_CrearBaseDatos.sql
Script/Fragmentacion/BD_Limon/02_SP_Clientes.sql
Script/Fragmentacion/BD_Limon/03_SP_Proveedores.sql
Script/Fragmentacion/BD_Limon/04_SP_Productos.sql
Script/Fragmentacion/BD_Limon/05_SP_Ventas.sql
Script/08_Autenticacion.sql
```

#### **Base de datos Corporativo (localhost,1435)**
```
Script/Fragmentacion/BD_Corporativa/01_CrearBaseDatos.sql
Script/Fragmentacion/BD_Corporativa/02_SP_Clientes.sql
Script/Fragmentacion/BD_Corporativa/03_SP_Proveedores.sql
Script/Fragmentacion/BD_Corporativa/04_SP_Productos.sql
Script/Fragmentacion/BD_Corporativa/05_SP_Ventas.sql
Script/Fragmentacion/BD_Corporativa/06_SP_Reportes.sql
Script/Fragmentacion/BD_Corporativa/15_Crear_Tablas_Receptoras_Corporativo.sql
Script/08_Autenticacion.sql
```

### 3. Configurar el Backend

```powershell
cd WWI-API
npm install
```

Crear el archivo `.env` en `WWI-API/`:

```env
# Conexiones a las 3 bases de datos
DB_SERVER_SANJOSE=localhost
DB_PORT_SANJOSE=1433
DB_USER_SANJOSE=sa
DB_PASSWORD_SANJOSE=<TU_PASSWORD>
DB_NAME_SANJOSE=SanJose

DB_SERVER_LIMON=localhost
DB_PORT_LIMON=1434
DB_USER_LIMON=sa
DB_PASSWORD_LIMON=<TU_PASSWORD>
DB_NAME_LIMON=Limon

DB_SERVER_CORPORATIVO=localhost
DB_PORT_CORPORATIVO=1435
DB_USER_CORPORATIVO=sa
DB_PASSWORD_CORPORATIVO=<TU_PASSWORD>
DB_NAME_CORPORATIVO=WWI_Corporativo

# Sesión
SESSION_SECRET=<TU_SECRETO>
```

Iniciar el servidor:

```powershell
npm run dev
```

El servidor debe estar corriendo en http://localhost:3000

### 4. Configurar el Frontend

```powershell
cd WWI-WEBSITE
npm install
```

Iniciar el servidor de desarrollo:

```powershell
npm run dev
```

La aplicación estará disponible en http://localhost:5173

---

## Cómo Funciona la API

### Arquitectura de la API

La API sigue una arquitectura en capas:

1. **Rutas (`rutas/*.js`)**: Definen los endpoints HTTP y asignan middleware
2. **Middleware (`middlewareAutorizacion.js`)**: Verifica autenticación y roles
3. **Controladores (`controladores/*.js`)**: Contienen la lógica de negocio
4. **Configuración (`config/db.js`)**: Gestiona las conexiones a las 3 bases de datos

### Endpoints Principales

#### **Autenticación**
- `POST /api/autenticacion/login` - Inicia sesión
- `GET /api/autenticacion/sesion` - Consulta sesión actual
- `POST /api/autenticacion/logout` - Cierra sesión

#### **Clientes**
- `GET /api/clientes` - Listar clientes (requiere sesión)
- `GET /api/clientes/:id` - Obtener detalle (requiere sesión)
- `POST /api/clientes` - Crear cliente (requiere Administrador)
- `PUT /api/clientes/:id` - Actualizar cliente (requiere Administrador)
- `DELETE /api/clientes/:id` - Eliminar cliente (requiere Administrador)

#### **Proveedores**
- `GET /api/proveedores` - Listar proveedores (requiere sesión)
- `GET /api/proveedores/:id` - Obtener detalle (requiere sesión)
- `POST /api/proveedores` - Crear proveedor (requiere Administrador)
- `PUT /api/proveedores/:id` - Actualizar proveedor (requiere Administrador)
- `DELETE /api/proveedores/:id` - Eliminar proveedor (requiere Administrador)

#### **Productos**
- `GET /api/productos` - Listar productos (requiere sesión)
- `GET /api/productos/:id` - Obtener detalle (requiere sesión)
- `GET /api/productos/inventario/sucursal` - Inventario por sucursal (requiere sesión)
- `GET /api/productos/inventario/consolidado` - Inventario consolidado (requiere Corporativo)
- `POST /api/productos` - Crear producto (requiere Administrador)
- `PUT /api/productos/:id` - Actualizar producto (requiere Administrador)
- `DELETE /api/productos/:id` - Eliminar producto (requiere Administrador)

#### **Ventas**
- `GET /api/ventas` - Listar ventas (requiere sesión)
- `GET /api/ventas/:id` - Obtener detalle (requiere sesión)
- `POST /api/ventas` - Crear venta (requiere Administrador)
- `PUT /api/ventas/:id` - Actualizar venta (requiere Administrador)
- `DELETE /api/ventas/:id` - Eliminar venta (requiere Administrador)

#### **Reportes**
- `GET /api/reportes` - Listar reportes disponibles (requiere sesión)
- `GET /api/reportes/:nombre` - Ejecutar reporte específico (requiere Corporativo)

### Funcionalidades Especiales

#### **Consultas con Respaldo Automático**
Para Corporativo, las consultas de clientes y proveedores usan la función `consultarConRespaldo`:
1. Intenta conectar a SanJosé
2. Si falla, automáticamente intenta con Limón
3. Retorna el resultado con la sucursal que funcionó

#### **Transacciones con TVP**
La creación de ventas usa Table-Valued Parameters (`dbo.TipoLineasFactura`) para insertar múltiples líneas en una sola transacción.

#### **Manejo de Errores**
Todos los errores se devuelven en español con códigos HTTP apropiados:
- 401: No hay sesión
- 403: Rol no autorizado
- 404: Recurso no encontrado
- 400: Parámetros inválidos
- 500: Error del servidor

---

## Cómo se Conecta el Frontend

### Cliente HTTP (`servicios/api.js`)

El frontend usa `fetch` con credenciales incluidas para comunicarse con la API:

```javascript
export async function solicitarAPI(ruta, opciones = {}) {
  const respuesta = await fetch(`http://localhost:3000${ruta}`, {
    credentials: 'include',  // Incluye cookies de sesión
    headers: {
      'Content-Type': 'application/json',
      ...opciones.headers
    },
    ...opciones
  });

  if (!respuesta.ok) {
    const error = await respuesta.json();
    throw new Error(error.mensaje || 'Error en la petición');
  }

  return respuesta.json();
}
```

### Contexto de Autenticación

El contexto global (`ContextoAutenticacion.jsx`) mantiene:
- Estado del usuario autenticado
- Estado de carga
- Funciones para login/logout

### Flujo de Autenticación

1. Usuario ingresa credenciales en `/login`
2. Frontend llama a `POST /api/autenticacion/login`
3. Backend valida con `Application.Usr_sp_Login`
4. Backend crea sesión HTTP-only con datos del usuario:
   ```javascript
   {
     id: datosUsuario.UserID,
     nombreUsuario: datosUsuario.Username,
     nombreCompleto: datosUsuario.FullName,
     rol: datosUsuario.Role,
     sucursal: datosUsuario.Sucursal
   }
   ```
5. Frontend redirige al panel correspondiente según rol/sucursal

### Enrutamiento por Rol

**App.jsx** determina qué panel mostrar:

```javascript
if (usuario.rol === 'Corporativo' && usuario.sucursal === 'Corporativo') {
  return <InicioCorporativo />;
}

if (usuario.rol === 'Administrador' && ['SanJose', 'Limon'].includes(usuario.sucursal)) {
  return <InicioSucursal />;
}
```

---

## Módulos Implementados

### 1. Módulo de Clientes

**Funcionalidades por rol:**

**Administrador de Sucursal:**
- Listar clientes de su sucursal con paginación
- Ver detalle completo (datos públicos + privados de Corporativo)
- Crear clientes (datos públicos en sucursal, privados en Corporativo)
- Actualizar clientes
- Eliminar clientes

**Corporativo:**
- Listar clientes de cualquier sucursal (con respaldo automático SanJosé → Limón)
- Ver detalle completo
- Solo lectura (no puede crear, editar ni eliminar)

**Endpoints:**
- `GET /api/clientes` - Listar con filtros (nombre, categoríaID, pagina, tamanoPagina)
- `GET /api/clientes/:id` - Detalle (combina datos públicos y privados)
- `POST /api/clientes` - Crear (recibe datosPublicos y datosPrivados)
- `PUT /api/clientes/:id` - Actualizar
- `DELETE /api/clientes/:id` - Eliminar

### 2. Módulo de Proveedores

**Funcionalidades por rol:**

**Administrador de Sucursal:**
- Listar proveedores de su sucursal
- Ver detalle completo
- Crear proveedores (datos públicos en sucursal, privados en Corporativo)
- Actualizar proveedores
- Eliminar proveedores

**Corporativo:**
- Listar proveedores de cualquier sucursal (con respaldo automático)
- Ver detalle completo
- Solo lectura

**Endpoints:**
- `GET /api/proveedores` - Listar con filtros
- `GET /api/proveedores/:id` - Detalle
- `POST /api/proveedores` - Crear
- `PUT /api/proveedores/:id` - Actualizar
- `DELETE /api/proveedores/:id` - Eliminar

### 3. Módulo de Productos

**Funcionalidades por rol:**

**Administrador de Sucursal:**
- Listar productos de su sucursal
- Ver detalle de producto
- Consultar inventario de su sucursal
- Crear productos
- Actualizar productos
- Eliminar productos

**Corporativo:**
- Listar productos (consulta desde SanJosé por defecto)
- Ver detalle de producto
- Inventario por sucursal (SanJosé, Limón)
- Inventario consolidado (todas las sucursales)
- Solo lectura

**Endpoints:**
- `GET /api/productos` - Listar catálogo (nombre, grupoID, pagina, limite)
- `GET /api/productos/:id` - Detalle
- `GET /api/productos/inventario/sucursal` - Inventario por sucursal (nombre, pagina, limite)
- `GET /api/productos/inventario/consolidado` - Inventario consolidado (pagina, limite)
- `POST /api/productos` - Crear
- `PUT /api/productos/:id` - Actualizar
- `DELETE /api/productos/:id` - Eliminar

### 4. Módulo de Ventas (Facturas en la interfaz)

**Nota:** Internamente el módulo se llama "Ventas" (controladorVentas.js, /api/ventas), pero en la interfaz se muestra como "Facturas".

**Funcionalidades por rol:**

**Administrador de Sucursal:**
- Listar ventas de su sucursal con filtros
- Ver detalle de factura (encabezado + líneas)
- Crear ventas con TVP para líneas
- Actualizar ventas
- Eliminar ventas (reintegra inventario)

**Corporativo:**
- Listar ventas de todas las sucursales (selector: Todas, Histórico, SanJosé, Limón)
- Ver detalle de factura
- Solo lectura (no puede crear, editar ni eliminar)

**Endpoints:**
- `GET /api/ventas` - Listar (nombreCliente, fechaInicio, fechaFin, montoMinimo, montoMaximo, pagina, limite, sucursalID)
  - `sucursalID`: 0=Histórico, 1=SanJosé, 2=Limón, sin parámetro=Todas (solo Corporativo)
- `GET /api/ventas/:id` - Detalle
- `POST /api/ventas` - Crear (usa TVP dbo.TipoLineasFactura)
- `PUT /api/ventas/:id` - Actualizar
- `DELETE /api/ventas/:id` - Eliminar

### 5. Módulo de Reportes

**Funcionalidades:**

Solo Corporativo puede acceder a los reportes.

**10 Reportes disponibles:**
1. `Rpt_sp_MontosProveedores` - Montos por proveedor
2. `Rpt_sp_MontosClientes` - Montos por cliente
3. `Rpt_sp_Top5ProductosPorGanancia` - Top 5 productos por ganancia
4. `Rpt_sp_Top5ClientesPorFacturas` - Top 5 clientes por facturas
5. `Rpt_sp_Top5ProveedoresPorOrdenes` - Top 5 proveedores por órdenes
6. `Rpt_sp_MatrizVentasPorCategoria` - Matriz de ventas por categoría
7. `Rpt_sp_SeguimientoComprasCliente` - Seguimiento de compras de clientes
8. `Rpt_sp_SeguimientoComprasProveedor` - Seguimiento de compras de proveedores
9. `Rpt_sp_RotacionInventario` - Rotación de inventario
10. `Rpt_sp_MetodoEnvioFavoritoPorZona` - Método de envío favorito por zona

**Endpoints:**
- `GET /api/reportes` - Listar reportes disponibles
- `GET /api/reportes/:nombre` - Ejecutar reporte con filtros opcionales

---

## Control de Acceso por Rol

### Roles Disponibles

1. **Administrador**
   - Asignado a sucursales SanJosé o Limón
   - Puede: Listar, Ver, Crear, Editar, Eliminar en su sucursal
   - No puede: Acceder a datos de otras sucursales, ver reportes

2. **Corporativo**
   - Asignado a Corporativo
   - Puede: Listar clientes/proveedores de todas las sucursales (con respaldo), Ver inventario consolidado, Ver reportes
   - No puede: Crear, Editar, Eliminar datos

### Middleware de Autorización

**`verificarSesion`**
- Verifica que exista una sesión activa
- Se usa en todos los endpoints protegidos

**`verificarAdministrador`**
- Verifica que el usuario sea Administrador
- Se usa en endpoints de escritura (POST, PUT, DELETE)

**`verificarCorporativo`**
- Verifica que el usuario sea Corporativo
- Se usa en endpoints de reportes e inventario consolidado

---

## Fragmentación de la Base de Datos

### Estrategia de Fragmentación

**Fragmentación Horizontal:** Las mismas tablas se replican en las bases de datos de sucursales con datos específicos de cada ubicación.

**Tablas Públicas (en SanJosé y Limón):**
- Sales.Customers (clientes)
- Purchasing.Suppliers (proveedores)
- Warehouse.StockItems (productos)
- Sales.Invoices (ventas)
- Warehouse.StockItemHoldings (inventario)

**Tablas Privadas (en Corporativo):**
- Datos financieros de clientes
- Datos bancarios de proveedores
- Reportes consolidados
- Tablas receptoras para sincronización de compras

### Tablas Receptoras Corporativo

Para la sincronización de órdenes de compra desde las sucursales hacia Corporativo:

```sql
-- En WWI_Corporativo
Purchasing.PurchaseOrdersSanJose
Purchasing.PurchaseOrderLinesSanJose
Purchasing.PurchaseOrdersLimon
Purchasing.PurchaseOrderLinesLimon
```

Cada tabla tiene FK de líneas hacia su tabla de órdenes correspondiente.

---

## Procedimientos Almacenados

### Clientes
- `Cli_sp_ListarClientesPaginado` - Listar con paginación
- `Cli_sp_ContarClientes` - Contar total
- `Cli_sp_DetalleCliente` - Detalle público
- `Cli_sp_DetalleClientePrivado` - Detalle privado (Corporativo)
- `Cli_sp_InsertarCliente` - Crear
- `Cli_sp_ActualizarCliente` - Actualizar
- `Cli_sp_EliminarCliente` - Eliminar

### Proveedores
- `Prov_sp_ListarProveedoresPaginado` - Listar con paginación
- `Prov_sp_ContarProveedores` - Contar total
- `Prov_sp_DetalleProveedor` - Detalle público
- `Prov_sp_DetalleProveedorPrivado` - Detalle privado (Corporativo)
- `Prov_sp_InsertarProveedor` - Crear
- `Prov_sp_ActualizarProveedor` - Actualizar
- `Prov_sp_EliminarProveedor` - Eliminar

### Productos
- `Inv_sp_ListarProductosPaginado` - Listar catálogo
- `Inv_sp_ContarProductos` - Contar catálogo
- `Inv_sp_DetalleProducto` - Detalle
- `Inv_sp_ListarInventarioSucursal` - Inventario por sucursal
- `Inv_sp_ListarInventarioConsolidado` - Inventario consolidado
- `Inv_sp_InsertarProducto` - Crear
- `Inv_sp_ActualizarProducto` - Actualizar
- `Inv_sp_EliminarProducto` - Eliminar

### Ventas
- `Vta_sp_ListarVentas` - Listar con filtros
- `Vta_sp_ContarVentas` - Contar total
- `Vta_sp_DetalleVenta` - Detalle (encabezado + líneas)
- `Vta_sp_InsertarVenta` - Crear (usa TVP)
- `Vta_sp_ActualizarVenta` - Actualizar
- `Vta_sp_EliminarVenta` - Eliminar (reintegra inventario)

### Reportes
- `Rpt_sp_MontosProveedores`
- `Rpt_sp_MontosClientes`
- `Rpt_sp_Top5ProductosPorGanancia`
- `Rpt_sp_Top5ClientesPorFacturas`
- `Rpt_sp_Top5ProveedoresPorOrdenes`
- `Rpt_sp_MatrizVentasPorCategoria`
- `Rpt_sp_SeguimientoComprasCliente`
- `Rpt_sp_SeguimientoComprasProveedor`
- `Rpt_sp_RotacionInventario`
- `Rpt_sp_MetodoEnvioFavoritoPorZona`

### Autenticación
- `Application.Usp_LogIn` - Login (en WideWorldImporters)
- `Application.Usr_sp_Login` - Login personalizado

---

## Variables de Entorno

### Backend (.env en WWI-API/)

```env
# SanJosé
DB_SERVER_SANJOSE=localhost
DB_PORT_SANJOSE=1433
DB_USER_SANJOSE=sa
DB_PASSWORD_SANJOSE=<TU_PASSWORD>
DB_NAME_SANJOSE=SanJose

# Limón
DB_SERVER_LIMON=localhost
DB_PORT_LIMON=1434
DB_USER_LIMON=sa
DB_PASSWORD_LIMON=<TU_PASSWORD>
DB_NAME_LIMON=Limon

# Corporativo
DB_SERVER_CORPORATIVO=localhost
DB_PORT_CORPORATIVO=1435
DB_USER_CORPORATIVO=sa
DB_PASSWORD_CORPORATIVO=<TU_PASSWORD>
DB_NAME_CORPORATIVO=WWI_Corporativo

# Sesión
SESSION_SECRET=<TU_SECRETO>
```

---

## Configuración CORS

El servidor Express está configurado para aceptar peticiones desde el frontend:

```javascript
app.use(cors({
  origin: 'http://localhost:5173',
  credentials: true  // Permite cookies
}));
```

---

## Sesiones

Configuración de sesiones en Express:

```javascript
app.use(session({
  name: 'wwi.sid',
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,      // No accesible desde JavaScript
    secure: false,       // false para HTTP en desarrollo
    sameSite: 'lax',     // Protección CSRF
    maxAge: 2 * 60 * 60 * 1000  // 2 horas
  }
}));
```

---

## Validaciones

### Lado del Servidor

- IDs: deben ser enteros positivos <= 2147483647
- Paginación: página mayor o igual a 1
- El límite máximo de registros depende del módulo:
  - En Ventas, el parámetro `limite` admite valores entre 1 y 500
  - En los demás módulos se aplican los límites definidos en sus controladores
- Categorías: IDs válidos
- Ventas: al menos una línea, IDs de productos duplicados prohibidos
- TVP: Validación de campos obligatorios en líneas de factura

### Lado del Cliente

- Formularios con campos obligatorios marcados
- Mensajes de error en español
- Confirmación antes de eliminar
- Botones deshabilitados durante carga

---

## Objetivos Alcanzados

✅ Arquitectura de base de datos fragmentada con 3 nodos (SanJosé, Limón, Corporativo)  
✅ Autenticación basada en sesiones con cookies HTTP-only  
✅ Control de acceso por roles (Administrador, Corporativo)  
✅ CRUD completo para clientes, proveedores, productos, ventas  
✅ Paginación en todos los listados  
✅ Filtros acumulativos con botón "Limpiar"  
✅ Inventario consolidado para Corporativo  
✅ 10 reportes estadísticos para Corporativo  
✅ Consultas con respaldo automático para Corporativo (SanJosé → Limón)  
✅ Tablas receptoras para sincronización de compras  
✅ Manejo de errores en español con códigos HTTP apropiados  
✅ Frontend React con gestión de estado global  
✅ Paneles diferenciados por rol y sucursal  
✅ API REST con middleware de autorización  
✅ Uso de TVP para inserción de líneas de venta  
✅ Transacciones ACID en operaciones de escritura  

---

## Objetivos No Alcanzados

Ninguno. Todos los objetivos planteados fueron alcanzados.

---

## Referencias

- WideWorldImporters database catalog: https://docs.microsoft.com/en-us/sql/samples/wide-world-importers-oltp-database-catalog
- Express.js: https://expressjs.com/
- React: https://react.dev/
- Vite: https://vitejs.dev/
- mssql (Node.js driver): https://github.com/tediousjs/node-mssql
- SQL Server Table-Valued Parameters: https://docs.microsoft.com/en-us/sql/relational-databases/tables/use-table-valued-parameters

---

## Notas Adicionales

- El archivo `.env` con credenciales no se sube al repositorio (está en `.gitignore`)
- Los scripts SQL son idempotentes (se pueden ejecutar múltiples veces)
- El servidor de desarrollo usa `nodemon` para reinicio automático
- Las cookies de sesión se configuran como `httpOnly` y `secure: false` para desarrollo local
- En producción, cambiar `secure: true` y usar HTTPS
- La API responde con mensajes en español para una mejor experiencia de usuario
- Corporativo usa SanJosé como conexión por defecto para productos (procedimientos solo existen en sucursales)
