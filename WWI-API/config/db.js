
require('dotenv').config();

const sql = require('mssql');

// Configuración San José
const configuracionSanJose = {
  server: process.env.DB_SJ_SERVER,
  port: Number(process.env.DB_SJ_PORT),
  database: process.env.DB_SJ_DATABASE,
  user: process.env.DB_SJ_USER,
  password: process.env.DB_SJ_PASSWORD,
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

// Configuración Limón
const configuracionLimon = {
  server: process.env.DB_LIM_SERVER,
  port: Number(process.env.DB_LIM_PORT),
  database: process.env.DB_LIM_DATABASE,
  user: process.env.DB_LIM_USER,
  password: process.env.DB_LIM_PASSWORD,
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

// Configuración Corporativo
const configuracionCorporativo = {
  server: process.env.DB_CORP_SERVER,
  port: Number(process.env.DB_CORP_PORT),
  database: process.env.DB_CORP_DATABASE,
  user: process.env.DB_CORP_USER,
  password: process.env.DB_CORP_PASSWORD,
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

// Pools de conexión
const poolSanJose = new sql.ConnectionPool(configuracionSanJose);
const poolLimon = new sql.ConnectionPool(configuracionLimon);
const poolCorporativo = new sql.ConnectionPool(configuracionCorporativo);

// Conectar San José
async function conectarSanJose() {
  if (!poolSanJose.connected) {
    await poolSanJose.connect();
  }

  return poolSanJose;
}

// Conectar Limón
async function conectarLimon() {
  if (!poolLimon.connected) {
    await poolLimon.connect();
  }

  return poolLimon;
}

// Conectar Corporativo
async function conectarCorporativo() {
  if (!poolCorporativo.connected) {
    await poolCorporativo.connect();
  }

  return poolCorporativo;
}

// Cerrar conexiones
async function cerrarConexiones() {
  await poolSanJose.close();
  await poolLimon.close();
  await poolCorporativo.close();
}

module.exports = {
  sql,
  conectarSanJose,
  conectarLimon,
  conectarCorporativo,
  cerrarConexiones
};
