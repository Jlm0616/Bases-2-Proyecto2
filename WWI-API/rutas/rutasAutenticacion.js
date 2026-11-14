const express = require('express');

const enrutador = express.Router();

const {
  iniciarSesion,
  obtenerSesion,
  cerrarSesion
} = require('../controladores/controladorAutenticacion');

enrutador.post('/iniciar-sesion', iniciarSesion);
enrutador.get('/sesion', obtenerSesion);
enrutador.post('/cerrar-sesion', cerrarSesion);

module.exports = enrutador;
