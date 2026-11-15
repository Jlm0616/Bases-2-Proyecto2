const express = require('express');

/**
 * Enrutador para endpoints de reportes
 * @type {express.Router}
 */
const router = express.Router();

const {
  listarReportes,
  ejecutarReporte
} = require('../controladores/controladorReportes');

// GET /api/reportes - Listar reportes disponibles (solo Corporativo)
router.get('/', listarReportes);

// GET /api/reportes/:reporte - Ejecutar reporte específico (solo Corporativo)
router.get('/:reporte', ejecutarReporte);

module.exports = router;
