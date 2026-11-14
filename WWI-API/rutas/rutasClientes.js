const express = require('express');

const {
  listarClientes,
  obtenerDetalleCliente,
  crearCliente,
  actualizarCliente,
  eliminarCliente
} = require('../controladores/controladorClientes');

const {
  verificarAdministrador
} = require('../middleware/middlewareAutorizacion');

const enrutador = express.Router();

// Listar clientes
enrutador.get('/', verificarAdministrador, listarClientes);

// Obtener detalle de un cliente
enrutador.get('/:id', verificarAdministrador, obtenerDetalleCliente);

// Crear un cliente
enrutador.post('/', verificarAdministrador, crearCliente);

// Actualizar un cliente
enrutador.put('/:id', verificarAdministrador, actualizarCliente);

// Eliminar un cliente
enrutador.delete('/:id', verificarAdministrador, eliminarCliente);

module.exports = enrutador;
