const express = require('express');
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

router.get('/', verificarSesion, listarProveedores);

router.get('/:id', verificarSesion, obtenerDetalleProveedor);

router.post(
  '/',
  verificarSesion,
  verificarAdministrador,
  crearProveedor
);

router.put(
  '/:id',
  verificarSesion,
  verificarAdministrador,
  actualizarProveedor
);

router.delete(
  '/:id',
  verificarSesion,
  verificarAdministrador,
  eliminarProveedor
);

module.exports = router;
