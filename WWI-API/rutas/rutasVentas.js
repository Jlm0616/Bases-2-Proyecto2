
const express = require('express');

/**
 * Enrutador para endpoints de ventas
 * @type {express.Router}
 */
const router = express.Router();

const {
  verificarSesion
} = require('../middleware/middlewareAutorizacion');

const {
  listarVentas,
  detalleVenta,
  crearVenta,
  actualizarVenta,
  eliminarVenta,
  listarFiltrosVenta
} = require('../controladores/controladorVentas');

// GET /api/ventas - Listar ventas (todos los roles)
router.get('/', verificarSesion, listarVentas);

// GET /api/ventas/filtros/:tipo - Catálogos auxiliares para ventas
// Tipos disponibles:
// clientes, personas, vendedores, metodos-entrega,
// productos, tipos-empaque
// El controlador restringe el acceso a SanJosé y Limón.
router.get(
  '/filtros/:tipo',
  verificarSesion,
  listarFiltrosVenta
);

// GET /api/ventas/:id - Detalle de factura (todos los roles)
router.get('/:id', verificarSesion, detalleVenta);

// POST /api/ventas - Crear venta (solo sucursales SanJosé/Limón)
router.post('/', verificarSesion, crearVenta);

// PUT /api/ventas/:id - Actualizar venta (solo sucursales SanJosé/Limón)
router.put('/:id', verificarSesion, actualizarVenta);

// DELETE /api/ventas/:id - Eliminar venta (solo sucursales SanJosé/Limón)
router.delete('/:id', verificarSesion, eliminarVenta);

module.exports = router;
