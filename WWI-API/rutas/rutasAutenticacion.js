const express = require('express');

/**
 * Enrutador para endpoints de autenticación
 * @type {express.Router}
 */
const enrutador = express.Router();

const {
  iniciarSesion,
  obtenerSesion,
  cerrarSesion
} = require('../controladores/controladorAutenticacion');

// POST /api/autenticacion/iniciar-sesion - Iniciar sesión
enrutador.post('/iniciar-sesion', iniciarSesion);

// GET /api/autenticacion/sesion - Consultar sesión actual
enrutador.get('/sesion', obtenerSesion);

// POST /api/autenticacion/cerrar-sesion - Cerrar sesión
enrutador.post('/cerrar-sesion', cerrarSesion);

module.exports = enrutador;
