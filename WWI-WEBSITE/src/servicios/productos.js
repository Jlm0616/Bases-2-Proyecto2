
import { solicitarAPI } from './api';

/**
 * Lista productos con filtros y paginación.
 */
export async function listarProductos({
  nombre = '',
  grupoID = '',
  pagina = 1,
  limite = 25
} = {}) {
  const parametros = new URLSearchParams();

  parametros.set('pagina', String(pagina));
  parametros.set('limite', String(limite));

  if (nombre.trim()) {
    parametros.set('nombre', nombre.trim());
  }

  if (grupoID !== '' && grupoID !== null && grupoID !== undefined) {
    parametros.set('grupoID', String(grupoID));
  }

  return solicitarAPI(`/productos?${parametros.toString()}`);
}

/**
 * Consulta el detalle de un producto.
 */
export async function obtenerDetalleProducto(idProducto) {
  return solicitarAPI(`/productos/${encodeURIComponent(idProducto)}`);
}

/**
 * Crea un producto en la sucursal del administrador.
 */
export async function crearProducto(datosProducto) {
  return solicitarAPI('/productos', {
    method: 'POST',
    body: JSON.stringify(datosProducto)
  });
}

/**
 * Actualiza un producto existente.
 */
export async function actualizarProducto(idProducto, datosProducto) {
  return solicitarAPI(
    `/productos/${encodeURIComponent(idProducto)}`,
    {
      method: 'PUT',
      body: JSON.stringify(datosProducto)
    }
  );
}

/**
 * Elimina un producto.
 */
export async function eliminarProducto(idProducto) {
  return solicitarAPI(
    `/productos/${encodeURIComponent(idProducto)}`,
    {
      method: 'DELETE'
    }
  );
}

/**
 * Consulta el inventario de una sucursal.
 * Si no se indica una sucursal, la API utiliza
 * la sucursal del usuario autenticado.
 */
export async function obtenerInventarioSucursal({
  sucursal = '',
  pagina = 1,
  limite = 25
} = {}) {
  const parametros = new URLSearchParams();

  parametros.set('pagina', String(pagina));
  parametros.set('limite', String(limite));

  if (sucursal) {
    parametros.set('nombre', sucursal);
  }

  return solicitarAPI(
    `/productos/inventario/sucursal?${parametros.toString()}`
  );
}

/**
 * Consulta el inventario consolidado.
 * Disponible únicamente para Corporativo.
 */
export async function obtenerInventarioConsolidado({
  pagina = 1,
  limite = 25
} = {}) {
  const parametros = new URLSearchParams({
    pagina: String(pagina),
    limite: String(limite)
  });

  return solicitarAPI(
    `/productos/inventario/consolidado?${parametros.toString()}`
  );
}
