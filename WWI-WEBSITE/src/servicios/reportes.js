
import { solicitarAPI } from './api';

/**
 * Obtiene los reportes disponibles para Corporativo.
 *
 * GET /api/reportes
 */
export async function listarReportes() {
  return solicitarAPI('/reportes');
}

/**
 * Ejecuta un reporte con los filtros indicados.
 *
 * GET /api/reportes/:reporte
 *
 * @param {string} nombreReporte
 * @param {Object} filtros
 */
export async function ejecutarReporte(nombreReporte, filtros = {}) {
  if (!nombreReporte || typeof nombreReporte !== 'string') {
    throw new Error('Debe seleccionar un reporte válido');
  }

  const parametros = new URLSearchParams();

  for (const [nombre, valor] of Object.entries(filtros)) {
    if (
      valor !== undefined &&
      valor !== null &&
      String(valor).trim() !== ''
    ) {
      parametros.append(nombre, String(valor).trim());
    }
  }

  const consulta = parametros.toString();

  const ruta = `/reportes/${encodeURIComponent(nombreReporte)}`;

  return solicitarAPI(
    consulta ? `${ruta}?${consulta}` : ruta
  );
}
