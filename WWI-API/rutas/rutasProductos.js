const express = require('express');

/**
 * Enrutador para endpoints de productos
 * @type {express.Router}
 */
const router = express.Router();

const controladorProductos = require('../controladores/controladorProductos');

const {
  verificarSesion,
  verificarCorporativo,
  verificarAdministrador
} = require('../middleware/middlewareAutorizacion');

// GET /api/productos - Listar productos (todos los roles)
router.get(
  '/',
  verificarSesion,
  controladorProductos.listarProductos
);

// GET /api/productos/inventario/sucursal - Inventario por sucursal (todos los roles)
router.get(
  '/inventario/sucursal',
  verificarSesion,
  controladorProductos.inventarioPorSucursal
);

// GET /api/productos/inventario/consolidado - Inventario consolidado (solo Corporativo)
router.get(
  '/inventario/consolidado',
  verificarSesion,
  verificarCorporativo,
  controladorProductos.inventarioConsolidado
);

// GET /api/productos/:id - Detalle de producto (todos los roles)
router.get(
  '/:id',
  verificarSesion,
  controladorProductos.detalleProducto
);

// POST /api/productos - Crear producto (solo Administradores de sucursales)
router.post(
  '/',
  verificarSesion,
  verificarAdministrador,
  controladorProductos.crearProducto
);

// PUT /api/productos/:id - Actualizar producto (solo Administradores de sucursales)
router.put(
  '/:id',
  verificarSesion,
  verificarAdministrador,
  controladorProductos.actualizarProducto
);

// DELETE /api/productos/:id - Eliminar producto (solo Administradores de sucursales)
router.delete(
  '/:id',
  verificarSesion,
  verificarAdministrador,
  controladorProductos.eliminarProducto
);

module.exports = router;
