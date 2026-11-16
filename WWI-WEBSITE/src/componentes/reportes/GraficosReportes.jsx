
import { useMemo, useState } from 'react';

const MAX_ELEMENTOS = 10;

const NOMBRES_COLUMNAS = {
  NombreCliente: 'Cliente',
  NombreProveedor: 'Proveedor',
  NombreProducto: 'Producto',
  CustomerName: 'Cliente',
  SupplierName: 'Proveedor',
  StockItemName: 'Producto',
  NombreSucursal: 'Sucursal',
  Sucursal: 'Sucursal',
  Categoria: 'Categoría',
  Subcategoria: 'Subcategoría',
  Anio: 'Año',
  Mes: 'Mes',
  Cantidad: 'Cantidad',
  MontoTotal: 'Monto total',
  TotalVentas: 'Total de ventas',
  TotalCompras: 'Total de compras',
  Ganancia: 'Ganancia',
  GananciaTotal: 'Ganancia total',
  TotalFacturas: 'Total de facturas',
  TotalOrdenes: 'Total de órdenes'
};

function nombreColumna(nombre) {
  return NOMBRES_COLUMNAS[nombre] || nombre;
}

function esNumero(valor) {
  return (
    typeof valor === 'number' &&
    Number.isFinite(valor)
  );
}

function esIdentificador(columna) {
  return /(^id$|id$|^id_|_id$)/i.test(columna);
}

function formatearNumero(valor) {
  return new Intl.NumberFormat('es-CR', {
    maximumFractionDigits: 2
  }).format(valor);
}

function obtenerEtiqueta(registro, columna, indice) {
  if (!columna) {
    return `Registro ${indice + 1}`;
  }

  const valor = registro[columna];

  if (
    valor === null ||
    valor === undefined ||
    valor === ''
  ) {
    return 'Sin especificar';
  }

  return String(valor);
}

/**
 * Visualización de los resultados de reportes.
 *
 * Props:
 * - datos: registros devueltos por la API.
 * - titulo: título de la sección.
 *
 * No agrega ni transforma indicadores financieros.
 * Cada barra representa un registro recibido desde SQL.
 */
export default function GraficosReportes({
  datos = [],
  titulo = 'Visualización de resultados'
}) {
  const [columnaValor, setColumnaValor] = useState('');
  const [columnaEtiqueta, setColumnaEtiqueta] = useState('');
  const [orden, setOrden] = useState('original');

  const registros = Array.isArray(datos) ? datos : [];

  const columnas = useMemo(() => {
    const nombres = new Set();

    registros.forEach((registro) => {
      Object.keys(registro).forEach((columna) => {
        nombres.add(columna);
      });
    });

    return Array.from(nombres);
  }, [datos]);

  const columnasNumericas = useMemo(() => {
    return columnas.filter((columna) => {
      if (esIdentificador(columna)) {
        return false;
      }

      return registros.some((registro) =>
        esNumero(registro[columna])
      );
    });
  }, [columnas, registros]);

  const columnasEtiquetas = useMemo(() => {
    return columnas.filter(
      (columna) => !esIdentificador(columna)
    );
  }, [columnas]);

  const columnaNumericaActual =
    columnasNumericas.includes(columnaValor)
      ? columnaValor
      : columnasNumericas.find(
          (columna) =>
            !/^(Anio|Mes|Year|Month)$/i.test(columna)
        ) || columnasNumericas[0] || '';

  const columnaEtiquetaActual =
    columnasEtiquetas.includes(columnaEtiqueta) &&
    columnaEtiqueta !== columnaNumericaActual
      ? columnaEtiqueta
      : columnasEtiquetas.find((columna) =>
          columna !== columnaNumericaActual &&
          registros.some((registro) =>
            typeof registro[columna] === 'string' &&
            registro[columna] !== ''
          )
        ) ||
        columnasEtiquetas.find(
          (columna) =>
            columna !== columnaNumericaActual
        ) ||
        '';

  const datosGrafico = useMemo(() => {
    if (!columnaNumericaActual) {
      return [];
    }

    const elementos = registros
      .filter((registro) =>
        esNumero(registro[columnaNumericaActual])
      )
      .map((registro, indice) => ({
        id: indice,
        etiqueta: obtenerEtiqueta(
          registro,
          columnaEtiquetaActual,
          indice
        ),
        valor: registro[columnaNumericaActual]
      }));

    if (orden === 'mayor') {
      elementos.sort((a, b) => b.valor - a.valor);
    }

    if (orden === 'menor') {
      elementos.sort((a, b) => a.valor - b.valor);
    }

    return elementos.slice(0, MAX_ELEMENTOS);
  }, [
    registros,
    columnaNumericaActual,
    columnaEtiquetaActual,
    orden
  ]);

  const maximo = Math.max(
    0,
    ...datosGrafico.map((elemento) =>
      Math.abs(elemento.valor)
    )
  );

  const tieneNegativos = datosGrafico.some(
    (elemento) => elemento.valor < 0
  );

  if (registros.length === 0) {
    return (
      <section className="reporte-grafico-panel">
        <h2>{titulo}</h2>
        <p className="reporte-estado">
          No hay datos para generar un gráfico.
        </p>
      </section>
    );
  }

  if (columnasNumericas.length === 0) {
    return (
      <section className="reporte-grafico-panel">
        <h2>{titulo}</h2>
        <p className="reporte-estado">
          Este reporte no contiene columnas numéricas
          disponibles para representar gráficamente.
          Puede consultar sus resultados en la tabla.
        </p>
      </section>
    );
  }

  return (
    <section className="reporte-grafico-panel">
      <div className="reporte-grafico-encabezado">
        <div>
          <h2>{titulo}</h2>
          <p>
            Comparación de hasta {MAX_ELEMENTOS} registros.
          </p>
        </div>
      </div>

      <div className="reporte-grafico-controles">
        <div className="reporte-campo">
          <label htmlFor="grafico-valor">
            Valor que se desea comparar
          </label>

          <select
            id="grafico-valor"
            value={columnaNumericaActual}
            onChange={(evento) =>
              setColumnaValor(evento.target.value)
            }
          >
            {columnasNumericas.map((columna) => (
              <option key={columna} value={columna}>
                {nombreColumna(columna)}
              </option>
            ))}
          </select>
        </div>

        <div className="reporte-campo">
          <label htmlFor="grafico-etiqueta">
            Agrupar visualmente por
          </label>

          <select
            id="grafico-etiqueta"
            value={columnaEtiquetaActual}
            onChange={(evento) =>
              setColumnaEtiqueta(evento.target.value)
            }
          >
            {columnasEtiquetas
              .filter(
                (columna) =>
                  columna !== columnaNumericaActual
              )
              .map((columna) => (
                <option key={columna} value={columna}>
                  {nombreColumna(columna)}
                </option>
              ))}
            {!columnaEtiquetaActual && (
              <option value="">
                Número de registro
              </option>
            )}
          </select>
        </div>

        <div className="reporte-campo">
          <label htmlFor="grafico-orden">
            Orden de visualización
          </label>

          <select
            id="grafico-orden"
            value={orden}
            onChange={(evento) =>
              setOrden(evento.target.value)
            }
          >
            <option value="original">
              Orden original
            </option>
            <option value="mayor">
              Mayor a menor
            </option>
            <option value="menor">
              Menor a mayor
            </option>
          </select>
        </div>
      </div>

      {datosGrafico.length === 0 ? (
        <p className="reporte-estado">
          No existen valores numéricos válidos
          en la columna seleccionada.
        </p>
      ) : (
        <div className="reporte-grafico-barras">
          {datosGrafico.map((elemento) => {
            const porcentaje =
              maximo > 0
                ? (Math.abs(elemento.valor) / maximo) * 100
                : 0;

            return (
              <div
                className="reporte-grafico-elemento"
                key={elemento.id}
              >
                <div className="reporte-grafico-fila">
                  <span
                    className="reporte-grafico-etiqueta"
                    title={elemento.etiqueta}
                  >
                    {elemento.etiqueta}
                  </span>

                  <strong className="reporte-grafico-valor">
                    {formatearNumero(elemento.valor)}
                  </strong>
                </div>

                <div
                  className="reporte-grafico-pista"
                  role="img"
                  aria-label={
                    `${elemento.etiqueta}: ` +
                    formatearNumero(elemento.valor)
                  }
                >
                  <div
                    className={
                      'reporte-grafico-barra' +
                      (elemento.valor < 0
                        ? ' reporte-grafico-barra-negativa'
                        : '')
                    }
                    style={{
                      width: `${porcentaje}%`
                    }}
                  />
                </div>
              </div>
            );
          })}
        </div>
      )}

      <div className="reporte-grafico-pie">
        <p>
          Cada barra representa un registro del reporte.
          Los valores se muestran sin sumar ni agrupar
          registros adicionales.
        </p>

        {registros.length > MAX_ELEMENTOS && (
          <p>
            Se visualizan como máximo {MAX_ELEMENTOS} de{' '}
            {registros.length} registros. La tabla permite
            consultar el resto.
          </p>
        )}

        {tieneNegativos && (
          <p>
            Los valores negativos se identifican con
            un estilo diferente. La longitud de las barras
            representa su magnitud absoluta.
          </p>
        )}
      </div>
    </section>
  );
}
