const express = require('express');
const router = express.Router();

const {
  verificarSesion
} = require('../middleware/middlewareAutorizacion');

const {
  listarProveedores,
  obtenerDetalleProveedor
} = require('../controladores/controladorProveedores');

router.get('/', verificarSesion, listarProveedores);

router.get('/:id', verificarSesion, obtenerDetalleProveedor);

module.exports = router;
