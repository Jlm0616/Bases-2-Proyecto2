
require('dotenv').config();

const sql = require('mssql');

/**
 * Configuración de conexión para la base de datos de San José
 */
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

/**
 * Configuración de conexión para la base de datos de Limón
 */
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

/**
 * Configuración de conexión para la base de datos Corporativo
 */
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

/**
 * Pools de conexión para las tres bases de datos
 */
const poolSanJose = new sql.ConnectionPool(configuracionSanJose);
const poolLimon = new sql.ConnectionPool(configuracionLimon);
const poolCorporativo = new sql.ConnectionPool(configuracionCorporativo);

/**
 * Conecta a la base de datos de San José
 * @returns {Promise<sql.ConnectionPool>} Pool de conexión a San José
 */
async function conectarSanJose() {
  if (!poolSanJose.connected) {
    await poolSanJose.connect();
  }

  return poolSanJose;
}

/**
 * Conecta a la base de datos de Limón
 * @returns {Promise<sql.ConnectionPool>} Pool de conexión a Limón
 */
async function conectarLimon() {
  if (!poolLimon.connected) {
    await poolLimon.connect();
  }

  return poolLimon;
}

/**
 * Conecta a la base de datos Corporativo
 * @returns {Promise<sql.ConnectionPool>} Pool de conexión a Corporativo
 */
async function conectarCorporativo() {
  if (!poolCorporativo.connected) {
    await poolCorporativo.connect();
  }

  return poolCorporativo;
}

/**
 * Cierra todas las conexiones a las bases de datos
 * @returns {Promise<void>}
 */
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
