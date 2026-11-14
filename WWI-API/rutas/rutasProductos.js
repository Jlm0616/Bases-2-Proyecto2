const express = require('express');
const router = express.Router();

const controladorProductos = require('../controladores/controladorProductos');

const {
  verificarSesion,
  verificarCorporativo,
  verificarAdministrador
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

router.post(
  '/',
  verificarSesion,
  verificarAdministrador,
  controladorProductos.crearProducto
);

router.put(
  '/:id',
  verificarSesion,
  verificarAdministrador,
  controladorProductos.actualizarProducto
);

router.delete(
  '/:id',
  verificarSesion,
  verificarAdministrador,
  controladorProductos.eliminarProducto
);

module.exports = router;
