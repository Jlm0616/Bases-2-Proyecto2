
import { useState } from 'react';

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

const NOMBRES_FILTROS = {
  NombreProveedor: 'Nombre del proveedor',
  NombreCliente: 'Nombre del cliente',
  Categoria: 'Categoría',
  Subcategoria: 'Subcategoría',
  Anio: 'Año',
  AnioInicio: 'Año inicial',
  AnioFin: 'Año final',
  Mes: 'Mes',
  Proveedor: 'Proveedor',
  CategoriaCliente: 'Categoría del cliente',
  CategoriaProducto: 'Categoría del producto',
  Producto: 'Producto'
};

const FILTROS_NUMERICOS = [
  'Anio',
  'AnioInicio',
  'AnioFin',
  'Mes'
];

const MESES = [
  { valor: '1', nombre: 'Enero' },
  { valor: '2', nombre: 'Febrero' },
  { valor: '3', nombre: 'Marzo' },
  { valor: '4', nombre: 'Abril' },
  { valor: '5', nombre: 'Mayo' },
  { valor: '6', nombre: 'Junio' },
  { valor: '7', nombre: 'Julio' },
  { valor: '8', nombre: 'Agosto' },
  { valor: '9', nombre: 'Septiembre' },
  { valor: '10', nombre: 'Octubre' },
  { valor: '11', nombre: 'Noviembre' },
  { valor: '12', nombre: 'Diciembre' }
];

const SUCURSALES = [
  { valor: '', nombre: 'Consolidado (todas las sucursales)' },
  { valor: '1', nombre: 'San José' },
  { valor: '2', nombre: 'Limón' }
];

/**
 * Formulario dinámico para los reportes del Corporativo.
 *
 * Props:
 * - reportes: catálogo obtenido desde GET /api/reportes
 * - alEjecutar: función que recibe (rutaReporte, filtros)
 * - cargando: indica si hay una consulta en ejecución
 */
export default function FiltrosReportes({
  reportes = [],
  alEjecutar,
  cargando = false
}) {
  const [reporteSeleccionado, setReporteSeleccionado] = useState('');
  const [sucursalSeleccionada, setSucursalSeleccionada] = useState('');
  const [valoresFiltros, setValoresFiltros] = useState({});
  const [error, setError] = useState('');

  const reporteActual = reportes.find(
    (reporte) => reporte.ruta === reporteSeleccionado
  );

  const filtrosDisponibles = (reporteActual?.filtros || [])
    .filter((filtro) => filtro !== 'SucursalID');
  
  function cambiarReporte(evento) {
    setReporteSeleccionado(evento.target.value);
    setValoresFiltros({});
    setError('');
  }

  function cambiarSucursal(evento) {
    setSucursalSeleccionada(evento.target.value);
    setError('');
  }

  function cambiarFiltro(nombre, valor) {
    setValoresFiltros((anteriores) => ({
      ...anteriores,
      [nombre]: valor
    }));

    setError('');
  }

  function renderizarFiltro(nombre) {
    const valor = valoresFiltros[nombre] ?? '';
    const etiqueta = NOMBRES_FILTROS[nombre] || nombre;

    if (nombre === 'Mes') {
      return (
        <div className="reporte-campo" key={nombre}>
          <label htmlFor={`reporte-${nombre}`}>
            {etiqueta}
          </label>

          <select
            id={`reporte-${nombre}`}
            value={valor}
            disabled={cargando}
            onChange={(evento) =>
              cambiarFiltro(nombre, evento.target.value)
            }
          >
            <option value="">Todos los meses</option>

            {MESES.map((mes) => (
              <option key={mes.valor} value={mes.valor}>
                {mes.nombre}
              </option>
            ))}
          </select>
        </div>
      );
    }

    if (FILTROS_NUMERICOS.includes(nombre)) {
      return (
        <div className="reporte-campo" key={nombre}>
          <label htmlFor={`reporte-${nombre}`}>
            {etiqueta}
          </label>

          <input
            id={`reporte-${nombre}`}
            type="number"
            min="1"
            max="9999"
            step="1"
            placeholder="Ejemplo: 2026"
            value={valor}
            disabled={cargando}
            onChange={(evento) =>
              cambiarFiltro(nombre, evento.target.value)
            }
          />
        </div>
      );
    }

    return (
      <div className="reporte-campo" key={nombre}>
        <label htmlFor={`reporte-${nombre}`}>
          {etiqueta}
        </label>

        <input
          id={`reporte-${nombre}`}
          type="text"
          maxLength={100}
          placeholder={`Ingrese ${etiqueta.toLowerCase()}`}
          value={valor}
          disabled={cargando}
          onChange={(evento) =>
            cambiarFiltro(nombre, evento.target.value)
          }
        />
      </div>
    );
  }

  function ejecutar(evento) {
    evento.preventDefault();
    setError('');

    if (!reporteSeleccionado) {
      setError('Seleccione un reporte para continuar.');
      return;
    }

    if (typeof alEjecutar !== 'function') {
      setError('No está configurada la ejecución del reporte.');
      return;
    }

    const filtros = {};

    // Filtro de sucursal.
    // Si está vacío, no se envía SucursalID y SQL utiliza NULL.
    if (sucursalSeleccionada !== '') {
      if (!['1', '2'].includes(sucursalSeleccionada)) {
        setError('La sucursal seleccionada no es válida.');
        return;
      }

      filtros.SucursalID = sucursalSeleccionada;
    }

    // Filtros particulares del reporte seleccionado.
    for (const nombre of filtrosDisponibles) {
      const valor = String(valoresFiltros[nombre] ?? '').trim();

      if (valor !== '') {
        if (FILTROS_NUMERICOS.includes(nombre)) {
          const numero = Number(valor);

          if (
            !/^\d+$/.test(valor) ||
            !Number.isInteger(numero) ||
            numero < 1 ||
            numero > 9999 ||
            (nombre === 'Mes' && numero > 12)
          ) {
            setError(
              `El valor de ${NOMBRES_FILTROS[nombre] || nombre} no es válido.`
            );
            return;
          }
        }

        filtros[nombre] = valor;
      }
    }

    if (
      filtros.AnioInicio &&
      filtros.AnioFin &&
      Number(filtros.AnioInicio) > Number(filtros.AnioFin)
    ) {
      setError('El año inicial no puede superar al año final.');
      return;
    }

    alEjecutar(reporteSeleccionado, filtros);
  }

  return (
    <section className="reporte-panel-filtros">
      <div className="reporte-panel-encabezado">
        <h2>Consultar reportes</h2>
        <p>
          Seleccione un reporte, la sucursal y los filtros
          que desea aplicar.
        </p>
      </div>

      <form onSubmit={ejecutar}>
        <div className="reporte-filtros-grid">
          <div className="reporte-campo">
            <label htmlFor="reporte-seleccion">
              Tipo de reporte
            </label>

            <select
              id="reporte-seleccion"
              value={reporteSeleccionado}
              onChange={cambiarReporte}
              disabled={cargando || reportes.length === 0}
              required
            >
              <option value="">
                Seleccione un reporte
              </option>

              {reportes.map((reporte) => (
                <option key={reporte.ruta} value={reporte.ruta}>
                  {NOMBRES_REPORTES[reporte.ruta] || reporte.ruta}
                </option>
              ))}
            </select>
          </div>

          <div className="reporte-campo">
            <label htmlFor="reporte-sucursal">
              Sucursal
            </label>

            <select
              id="reporte-sucursal"
              value={sucursalSeleccionada}
              onChange={cambiarSucursal}
              disabled={cargando}
            >
              {SUCURSALES.map((sucursal) => (
                <option
                  key={sucursal.nombre}
                  value={sucursal.valor}
                >
                  {sucursal.nombre}
                </option>
              ))}
            </select>
          </div>
        </div>

        {reporteActual && (
          <div className="reporte-filtros-contenedor">
            <h3>Filtros adicionales</h3>

            {filtrosDisponibles.length === 0 ? (
              <p className="reporte-sin-filtros">
                Este reporte no requiere filtros adicionales.
              </p>
            ) : (
              <div className="reporte-filtros-grid">
                {filtrosDisponibles.map(renderizarFiltro)}
              </div>
            )}

            <p className="reporte-ayuda">
              Los filtros adicionales son opcionales.
              Si los deja vacíos, se utilizarán los valores
              predeterminados del procedimiento almacenado.
            </p>
          </div>
        )}

        {error && (
          <p className="reporte-error" role="alert">
            {error}
          </p>
        )}

        <div className="reporte-acciones">
          <button
            type="submit"
            className="reporte-boton-ejecutar"
            disabled={cargando || !reporteSeleccionado}
          >
            {cargando ? 'Generando reporte...' : 'Generar reporte'}
          </button>
        </div>
      </form>
    </section>
  );
}
