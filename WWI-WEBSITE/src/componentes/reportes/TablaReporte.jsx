
import { useMemo, useState } from 'react';

/**
 * Nombres amigables para columnas comunes.
 * Las columnas que no estén aquí conservarán
 * su nombre original.
 */
const NOMBRES_COLUMNAS = {
  SucursalID: 'ID de sucursal',
  Sucursal: 'Sucursal',
  NombreSucursal: 'Sucursal',

  CustomerID: 'ID del cliente',
  NombreCliente: 'Cliente',
  CustomerName: 'Cliente',

  SupplierID: 'ID del proveedor',
  NombreProveedor: 'Proveedor',
  SupplierName: 'Proveedor',

  StockItemID: 'ID del producto',
  NombreProducto: 'Producto',
  StockItemName: 'Producto',

  Categoria: 'Categoría',
  Subcategoria: 'Subcategoría',

  Anio: 'Año',
  Mes: 'Mes',

  TotalFacturas: 'Total de facturas',
  CantidadFacturas: 'Cantidad de facturas',
  TotalOrdenes: 'Total de órdenes',
  CantidadOrdenes: 'Cantidad de órdenes',

  Cantidad: 'Cantidad',
  TotalCantidad: 'Cantidad total',

  MontoTotal: 'Monto total',
  TotalVentas: 'Total de ventas',
  TotalCompras: 'Total de compras',
  Ganancia: 'Ganancia',
  GananciaTotal: 'Ganancia total',

  Porcentaje: 'Porcentaje',
  PorcentajeParticipacion: 'Participación (%)'
};

const FILAS_POR_PAGINA = 10;

/**
 * Convierte valores SQL en texto para mostrar.
 */
function formatearValor(valor) {
  if (valor === null || valor === undefined) {
    return '—';
  }

  if (typeof valor === 'boolean') {
    return valor ? 'Sí' : 'No';
  }

  if (typeof valor === 'number') {
    return new Intl.NumberFormat('es-CR', {
      maximumFractionDigits: 4
    }).format(valor);
  }

  if (typeof valor === 'string') {
    if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/.test(valor)) {
      const fecha = new Date(valor);

      if (!Number.isNaN(fecha.getTime())) {
        return new Intl.DateTimeFormat('es-CR', {
          dateStyle: 'short',
          timeStyle: 'short'
        }).format(fecha);
      }
    }

    return valor === '' ? '—' : valor;
  }

  return String(valor);
}

/**
 * Tabla dinámica para resultados de los reportes.
 *
 * Props:
 * - datos: arreglo de registros recibido desde la API.
 * - titulo: nombre del reporte.
 * - cargando: estado de la consulta.
 */
export default function TablaReporte({
  datos = [],
  titulo = 'Resultados del reporte',
  cargando = false
}) {
  const [pagina, setPagina] = useState(1);

  const registros = Array.isArray(datos) ? datos : [];

  const columnas = useMemo(() => {
    if (registros.length === 0) {
      return [];
    }

    const nombres = new Set();

    registros.forEach((registro) => {
      Object.keys(registro).forEach((columna) => {
        nombres.add(columna);
      });
    });

    return Array.from(nombres);
  }, [datos]);

  const totalPaginas = Math.max(
    1,
    Math.ceil(registros.length / FILAS_POR_PAGINA)
  );

  // Si llega otro resultado más pequeño,
  // usamos una página válida.
  const paginaActual = Math.min(pagina, totalPaginas);

  const indiceInicial = (paginaActual - 1) * FILAS_POR_PAGINA;

  const registrosPagina = registros.slice(
    indiceInicial,
    indiceInicial + FILAS_POR_PAGINA
  );

  function paginaAnterior() {
    setPagina((actual) => Math.max(1, actual - 1));
  }

  function paginaSiguiente() {
    setPagina((actual) => Math.min(totalPaginas, actual + 1));
  }

  if (cargando) {
    return (
      <section className="reporte-tabla-panel">
        <h2>{titulo}</h2>

        <p className="reporte-estado">
          Consultando información del Corporativo...
        </p>
      </section>
    );
  }

  if (registros.length === 0) {
    return (
      <section className="reporte-tabla-panel">
        <h2>{titulo}</h2>

        <p className="reporte-estado">
          No hay resultados para mostrar con los filtros seleccionados.
        </p>
      </section>
    );
  }

  return (
    <section className="reporte-tabla-panel">
      <div className="reporte-tabla-encabezado">
        <div>
          <h2>{titulo}</h2>

          <p>
            {registros.length}{' '}
            {registros.length === 1
              ? 'registro encontrado'
              : 'registros encontrados'}
          </p>
        </div>
      </div>

      <div className="reporte-tabla-desplazamiento">
        <table className="reporte-tabla">
          <thead>
            <tr>
              {columnas.map((columna) => (
                <th key={columna} scope="col">
                  {NOMBRES_COLUMNAS[columna] || columna}
                </th>
              ))}
            </tr>
          </thead>

          <tbody>
            {registrosPagina.map((registro, indice) => (
              <tr key={indiceInicial + indice}>
                {columnas.map((columna) => (
                  <td key={columna}>
                    {formatearValor(registro[columna])}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {totalPaginas > 1 && (
        <div className="reporte-paginacion">
          <span>
            Página {paginaActual} de {totalPaginas}
          </span>

          <div className="reporte-paginacion-botones">
            <button
              type="button"
              onClick={paginaAnterior}
              disabled={paginaActual === 1}
            >
              Anterior
            </button>

            <button
              type="button"
              onClick={paginaSiguiente}
              disabled={paginaActual === totalPaginas}
            >
              Siguiente
            </button>
          </div>
        </div>
      )}
    </section>
  );
}
