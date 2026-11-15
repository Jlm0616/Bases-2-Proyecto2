const express = require('express');

/**
 * Enrutador para endpoints de proveedores
 * @type {express.Router}
 */
const router = express.Router();

const {
  verificarSesion,
  verificarAdministrador
} = require('../middleware/middlewareAutorizacion');

const {
  listarProveedores,
  obtenerDetalleProveedor,
  crearProveedor,
  actualizarProveedor,
  eliminarProveedor
} = require('../controladores/controladorProveedores');

// GET /api/proveedores - Listar proveedores (todos los roles)
router.get('/', verificarSesion, listarProveedores);

// GET /api/proveedores/:id - Detalle de proveedor (todos los roles)
router.get('/:id', verificarSesion, obtenerDetalleProveedor);

// POST /api/proveedores - Crear proveedor (solo Administradores de sucursales)
router.post(
  '/',
  verificarSesion,
  verificarAdministrador,
  crearProveedor
);

// PUT /api/proveedores/:id - Actualizar proveedor (solo Administradores de sucursales)
router.put(
  '/:id',
  verificarSesion,
  verificarAdministrador,
  actualizarProveedor
);

// DELETE /api/proveedores/:id - Eliminar proveedor (solo Administradores de sucursales)
router.delete(
  '/:id',
  verificarSesion,
  verificarAdministrador,
  eliminarProveedor
);

module.exports = router;
