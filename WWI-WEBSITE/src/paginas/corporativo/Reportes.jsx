
import { useCallback, useEffect, useState } from 'react';

import {
  listarReportes,
  ejecutarReporte
} from '../../servicios/reportes';

import FiltrosReportes from '../../componentes/reportes/FiltrosReportes';
import TablaReporte from '../../componentes/reportes/TablaReporte';
import GraficosReportes from '../../componentes/reportes/GraficosReportes';

import '../../estilos/reportes.css';

const NOMBRES_REPORTES = {
  'montos-proveedores': 'Montos por proveedores',
  'montos-clientes': 'Montos por clientes',
  'top5-productos-ganancia': 'Top 5 productos por ganancia',
  'top5-clientes-facturas': 'Top 5 clientes por facturas',
  'top5-proveedores-ordenes': 'Top 5 proveedores por órdenes',
  'matriz-ventas-categoria': 'Matriz de ventas por categoría',
  'seguimiento-compras-cliente': 'Seguimiento de compras por cliente',
  'seguimiento-compras-proveedor': 'Seguimiento de compras por proveedor',
  'rotacion-inventario': 'Rotación de inventario',
  'metodo-envio-favorito-zona': 'Método de envío favorito por zona'
};

function obtenerMensajeError(error, mensajePredeterminado) {
  return (
    error?.response?.data?.mensaje ||
    error?.datos?.mensaje ||
    error?.mensaje ||
    error?.message ||
    mensajePredeterminado
  );
}

/**
 * Página principal de reportes del Corporativo.
 *
 * Responsabilidades:
 * - Consultar los reportes disponibles.
 * - Gestionar las solicitudes a la API.
 * - Mostrar errores y estados de carga.
 * - Presentar tablas y gráficos.
 *
 * Los cálculos se realizan en SQL Server.
 */
export default function Reportes() {
  const [reportes, setReportes] = useState([]);
  const [cargandoCatalogo, setCargandoCatalogo] = useState(true);
  const [cargandoReporte, setCargandoReporte] = useState(false);

  const [errorCatalogo, setErrorCatalogo] = useState('');
  const [errorReporte, setErrorReporte] = useState('');

  const [resultado, setResultado] = useState(null);
  const [mostrarGrafico, setMostrarGrafico] = useState(true);

  const cargarReportes = useCallback(async () => {
    setCargandoCatalogo(true);
    setErrorCatalogo('');

    try {
      const respuesta = await listarReportes();

      if (!Array.isArray(respuesta?.reportes)) {
        throw new Error(
          'La API no devolvió un catálogo de reportes válido.'
        );
      }

      setReportes(respuesta.reportes);
    } catch (error) {
      console.error('Error al cargar reportes:', error);

      setErrorCatalogo(
        obtenerMensajeError(
          error,
          'No se pudieron consultar los reportes disponibles.'
        )
      );

      setReportes([]);
    } finally {
      setCargandoCatalogo(false);
    }
  }, []);

  useEffect(() => {
    cargarReportes();
  }, [cargarReportes]);

  async function generarReporte(nombreReporte, filtros) {
    if (cargandoReporte) {
      return;
    }

    setCargandoReporte(true);
    setErrorReporte('');
    setResultado(null);

    try {
      const respuesta = await ejecutarReporte(
        nombreReporte,
        filtros
      );

      if (!Array.isArray(respuesta?.datos)) {
        throw new Error(
          'El servidor devolvió un resultado de reporte no válido.'
        );
      }

      setResultado({
        reporte: respuesta.reporte || nombreReporte,
        procedimiento: respuesta.procedimiento || '',
        filtros: respuesta.filtros || filtros,
        total: respuesta.datos.length,
        datos: respuesta.datos
      });
    } catch (error) {
      console.error('Error al ejecutar reporte:', error);

      setErrorReporte(
        obtenerMensajeError(
          error,
          'No se pudo generar el reporte solicitado.'
        )
      );
    } finally {
      setCargandoReporte(false);
    }
  }

  const nombreReporte = resultado
    ? NOMBRES_REPORTES[resultado.reporte] || resultado.reporte
    : '';

  return (
    <div className="reportes-contenedor">
      <header className="reportes-encabezado">
        <div>
          <h1>Estadísticas y Reportes</h1>

          <p>
            Consulte la información de WideWorldImporters
            mediante los reportes del Corporativo.
          </p>
        </div>
      </header>

      <div className="reportes-contenido">
        {cargandoCatalogo ? (
          <div className="reporte-cargando" role="status">
            Cargando reportes disponibles...
          </div>
        ) : errorCatalogo ? (
          <section className="reporte-panel-filtros">
            <h2>No se pudieron cargar los reportes</h2>

            <p className="reporte-error" role="alert">
              {errorCatalogo}
            </p>

            <div className="reporte-acciones">
              <button
                type="button"
                className="reporte-boton-ejecutar"
                onClick={cargarReportes}
              >
                Reintentar
              </button>
            </div>
          </section>
        ) : reportes.length === 0 ? (
          <section className="reporte-panel-filtros">
            <h2>Sin reportes disponibles</h2>

            <p className="reporte-estado">
              El Corporativo no tiene reportes disponibles
              en este momento.
            </p>
          </section>
        ) : (
          <FiltrosReportes
            reportes={reportes}
            alEjecutar={generarReporte}
            cargando={cargandoReporte}
          />
        )}

        {errorReporte && (
          <p className="reporte-error" role="alert">
            {errorReporte}
          </p>
        )}

        {cargandoReporte && (
          <div className="reporte-cargando" role="status">
            Ejecutando procedimiento almacenado...
          </div>
        )}

        {!cargandoReporte && resultado && (
          <>
            <section className="reporte-mensaje" role="status">
              <strong>Reporte generado correctamente.</strong>

              <div>
                {nombreReporte}
              </div>

              <div>
                Registros obtenidos: {resultado.total}
              </div>
            </section>

            <TablaReporte
              key={JSON.stringify([
                resultado.reporte,
                resultado.filtros
              ])}
              datos={resultado.datos}
              titulo={nombreReporte}
            />

            {resultado.datos.length > 0 && (
              <>
                <div className="reporte-acciones">
                  <button
                    type="button"
                    className="reporte-boton-ejecutar"
                    onClick={() =>
                      setMostrarGrafico((anterior) => !anterior)
                    }
                  >
                    {mostrarGrafico
                      ? 'Ocultar gráfico'
                      : 'Mostrar gráfico'}
                  </button>
                </div>

                {mostrarGrafico && (
                  <GraficosReportes
                    key={JSON.stringify([
                      resultado.reporte,
                      resultado.filtros
                    ])}
                    datos={resultado.datos}
                    titulo={`Gráfico: ${nombreReporte}`}
                  />
                )}
              </>
            )}
          </>
        )}
      </div>
    </div>
  );
}
