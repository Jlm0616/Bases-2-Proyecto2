require('dotenv').config();

const express = require('express');
const cors = require('cors');
const sesiones = require('express-session');

const rutasAutenticacion = require('./rutas/rutasAutenticacion');
const rutasClientes = require('./rutas/rutasClientes');

const aplicacion = express();
const puerto = process.env.PORT || 3000;

if (!process.env.SESSION_SECRET) {
  throw new Error('Falta SESSION_SECRET en el archivo .env');
}

aplicacion.use(cors({
  origin: 'http://localhost:5173',
  credentials: true
}));

aplicacion.use(express.json());

aplicacion.use(sesiones({
  name: 'wwi.sid',
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: false,
    sameSite: 'lax',
    maxAge: 2 * 60 * 60 * 1000
  }
}));

aplicacion.get('/api/health', (solicitud, respuesta) => {
  respuesta.json({
    estado: 'OK',
    mensaje: 'API WideWorldImporters funcionando'
  });
});

aplicacion.use('/api/autenticacion', rutasAutenticacion);
aplicacion.use('/api/clientes', rutasClientes);

aplicacion.listen(puerto, () => {
  console.log(`API ejecutándose en http://localhost:${puerto}`);
});
