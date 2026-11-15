require('dotenv').config();

const express = require('express');
const cors = require('cors');
const sesiones = require('express-session');

const rutasAutenticacion = require('./rutas/rutasAutenticacion');
const rutasClientes = require('./rutas/rutasClientes');
const rutasProveedores = require('./rutas/rutasProveedores');
const rutasProductos = require('./rutas/rutasProductos');
const rutasVentas = require('./rutas/rutasVentas');
const rutasReportes = require('./rutas/rutasReportes');

/**
 * Aplicación Express para la API de WideWorldImporters
 * @type {express.Application}
 */
const aplicacion = express();
const puerto = process.env.PORT || 3000;

if (!process.env.SESSION_SECRET) {
  throw new Error('Falta SESSION_SECRET en el archivo .env');
}

// Configuración de CORS para permitir requests desde el frontend
aplicacion.use(cors({
  origin: 'http://localhost:5173',
  credentials: true
}));

// Middleware para parsear JSON en el cuerpo de las solicitudes
aplicacion.use(express.json());

// Configuración de sesiones con Express Session
aplicacion.use(sesiones({
  name: 'wwi.sid',
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: false,
    sameSite: 'lax',
    maxAge: 2 * 60 * 60 * 1000 // 2 horas
  }
}));

/**
 * Endpoint de health check
 * @route GET /api/health
 */
aplicacion.get('/api/health', (solicitud, respuesta) => {
  respuesta.json({
    estado: 'OK',
    mensaje: 'API WideWorldImporters funcionando'
  });
});

// Registro de rutas de la API
aplicacion.use('/api/autenticacion', rutasAutenticacion);
aplicacion.use('/api/clientes', rutasClientes);
aplicacion.use('/api/proveedores', rutasProveedores);
aplicacion.use('/api/productos', rutasProductos);
aplicacion.use('/api/ventas', rutasVentas);
aplicacion.use('/api/reportes', rutasReportes);

// Iniciar el servidor
aplicacion.listen(puerto, () => {
  console.log(`API ejecutándose en http://localhost:${puerto}`);
});
