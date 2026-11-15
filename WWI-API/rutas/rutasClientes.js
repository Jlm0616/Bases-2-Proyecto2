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

/**
 * Enrutador para endpoints de clientes
 * @type {express.Router}
 */
const enrutador = express.Router();

// GET /api/clientes - Listar clientes (solo Administradores)
enrutador.get('/', verificarAdministrador, listarClientes);

// GET /api/clientes/:id - Obtener detalle de un cliente (solo Administradores)
enrutador.get('/:id', verificarAdministrador, obtenerDetalleCliente);

// POST /api/clientes - Crear un cliente (solo Administradores)
enrutador.post('/', verificarAdministrador, crearCliente);

// PUT /api/clientes/:id - Actualizar un cliente (solo Administradores)
enrutador.put('/:id', verificarAdministrador, actualizarCliente);

// DELETE /api/clientes/:id - Eliminar un cliente (solo Administradores)
enrutador.delete('/:id', verificarAdministrador, eliminarCliente);

module.exports = enrutador;
