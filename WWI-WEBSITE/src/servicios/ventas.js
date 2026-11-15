
import { solicitarAPI } from './api';

/**
 * Lista ventas con filtros y paginación.
 * El filtro sucursalID está disponible únicamente
 * para usuarios de Corporativo.
 */
export async function listarVentas({
  nombreCliente = '',
  fechaInicio = '',
  fechaFin = '',
  montoMinimo = '',
  montoMaximo = '',
  sucursalID = '',
  pagina = 1,
  limite = 25
} = {}) {
  const parametros = new URLSearchParams();

  parametros.set('pagina', String(pagina));
  parametros.set('limite', String(limite));

  if (nombreCliente.trim()) {
    parametros.set('nombreCliente', nombreCliente.trim());
  }

  if (fechaInicio) {
    parametros.set('fechaInicio', fechaInicio);
  }

  if (fechaFin) {
    parametros.set('fechaFin', fechaFin);
  }

  if (
    montoMinimo !== '' &&
    montoMinimo !== null &&
    montoMinimo !== undefined
  ) {
    parametros.set('montoMinimo', String(montoMinimo));
  }

  if (
    montoMaximo !== '' &&
    montoMaximo !== null &&
    montoMaximo !== undefined
  ) {
    parametros.set('montoMaximo', String(montoMaximo));
  }

  if (
    sucursalID !== '' &&
    sucursalID !== null &&
    sucursalID !== undefined
  ) {
    parametros.set('sucursalID', String(sucursalID));
  }

  return solicitarAPI(`/ventas?${parametros.toString()}`);
}

/**
 * Consulta el detalle de una factura.
 * Devuelve el encabezado y las líneas de venta.
 */
export async function obtenerDetalleVenta(idVenta) {
  return solicitarAPI(
    `/ventas/${encodeURIComponent(idVenta)}`
  );
}

/**
 * Crea una venta en la sucursal del usuario.
 * La venta debe incluir al menos una línea.
 */
export async function crearVenta(datosVenta) {
  return solicitarAPI('/ventas', {
    method: 'POST',
    body: JSON.stringify(datosVenta)
  });
}

/**
 * Actualiza una venta existente.
 * La API permite modificar las instrucciones
 * de entrega y el número de orden de compra.
 */
export async function actualizarVenta(idVenta, datosVenta) {
  return solicitarAPI(
    `/ventas/${encodeURIComponent(idVenta)}`,
    {
      method: 'PUT',
      body: JSON.stringify(datosVenta)
    }
  );
}

/**
 * Elimina una venta.
 * La operación se ejecuta en la sucursal
 * correspondiente al usuario autenticado.
 */
export async function eliminarVenta(idVenta) {
  return solicitarAPI(
    `/ventas/${encodeURIComponent(idVenta)}`,
    {
      method: 'DELETE'
    }
  );
}
