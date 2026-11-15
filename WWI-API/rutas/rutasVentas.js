const express = require('express');
const router = express.Router();

const {
  verificarSesion
} = require('../middleware/middlewareAutorizacion');

const {
  listarVentas,
  detalleVenta,
  crearVenta,
  actualizarVenta,
  eliminarVenta
} = require('../controladores/controladorVentas');

router.get('/', verificarSesion, listarVentas);
router.get('/:id', verificarSesion, detalleVenta);

router.post('/', verificarSesion, crearVenta);
router.put('/:id', verificarSesion, actualizarVenta);
router.delete('/:id', verificarSesion, eliminarVenta);

module.exports = router;
