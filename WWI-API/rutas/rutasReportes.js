const express = require('express');
const router = express.Router();

const {
  listarReportes,
  ejecutarReporte
} = require('../controladores/controladorReportes');

router.get('/', listarReportes);
router.get('/:reporte', ejecutarReporte);

module.exports = router;
