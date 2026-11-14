const express = require('express');

const {
  listarClientes
} = require('../controladores/controladorClientes');

const {
  verificarAdministrador
} = require('../middleware/middlewareAutorizacion');

const enrutador = express.Router();

enrutador.get('/', verificarAdministrador, listarClientes);

module.exports = enrutador;
