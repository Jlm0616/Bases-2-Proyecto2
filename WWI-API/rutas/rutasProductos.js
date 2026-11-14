const express = require('express');
const router = express.Router();

const controladorProductos = require('../controladores/controladorProductos');

const {
  verificarSesion,
  verificarCorporativo
} = require('../middleware/middlewareAutorizacion');

router.get(
  '/',
  verificarSesion,
  controladorProductos.listarProductos
);

router.get(
  '/inventario/sucursal',
  verificarSesion,
  controladorProductos.inventarioPorSucursal
);

router.get(
  '/inventario/consolidado',
  verificarSesion,
  verificarCorporativo,
  controladorProductos.inventarioConsolidado
);

router.get(
  '/:id',
  verificarSesion,
  controladorProductos.detalleProducto
);

module.exports = router;
