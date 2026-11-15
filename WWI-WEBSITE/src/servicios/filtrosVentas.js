
import { solicitarAPI } from './api';

/**
 * Consulta un catálogo auxiliar para el formulario
 * de ventas de San José o Limón.
 *
 * La API determina la sucursal mediante la sesión
 * del usuario autenticado.
 *
 * @param {string} tipo - Identificador del catálogo.
 * @returns {Promise<object>} Respuesta del servidor.
 */
async function consultarFiltroVenta(tipo) {
  return solicitarAPI(
    `/ventas/filtros/${encodeURIComponent(tipo)}`
  );
}

/**
 * Obtiene los clientes disponibles para ventas.
 */
export async function listarClientesVenta() {
  return consultarFiltroVenta('clientes');
}

/**
 * Obtiene las personas disponibles para seleccionar
 * contactos, responsables de cuentas y empaquetadores.
 */
export async function listarPersonasVenta() {
  return consultarFiltroVenta('personas');
}

/**
 * Obtiene únicamente las personas registradas
 * como vendedores.
 */
export async function listarVendedoresVenta() {
  return consultarFiltroVenta('vendedores');
}

/**
 * Obtiene los métodos de entrega disponibles.
 */
export async function listarMetodosEntregaVenta() {
  return consultarFiltroVenta('metodos-entrega');
}

/**
 * Obtiene los productos disponibles para ventas,
 * incluyendo sus precios unitarios.
 */
export async function listarProductosVenta() {
  return consultarFiltroVenta('productos');
}

/**
 * Obtiene los tipos de empaque disponibles.
 */
export async function listarTiposEmpaqueVenta() {
  return consultarFiltroVenta('tipos-empaque');
}
