const express = require('express');
const router = express.Router();

const {
  verificarSesion
} = require('../middleware/middlewareAutorizacion');

const {
  listarVentas,
  detalleVenta
} = require('../controladores/controladorVentas');

router.get('/', verificarSesion, listarVentas);
router.get('/:id', verificarSesion, detalleVenta);

module.exports = router;
