import { useCallback, useEffect, useState } from 'react';

import { listarVentas } from '../../servicios/ventas';

import DetalleVenta from '../../componentes/ventas/DetalleVenta';
import FormularioVenta from '../../componentes/ventas/FormularioVenta';
import ConfirmarEliminar from '../../componentes/ventas/ConfirmarEliminar';

import '../../estilos/ventas.css';

const filtrosIniciales = {
  nombreCliente: '',
  fechaInicio: '',
  fechaFin: '',
  montoMinimo: '',
  montoMaximo: '',
  sucursalID: ''
};

export default function Ventas() {
  const [ventas, setVentas] = useState([]);

  const [filtros, setFiltros] = useState(filtrosIniciales);
  const [filtrosAplicados, setFiltrosAplicados] = useState(filtrosIniciales);

  const [pagina, setPagina] = useState(1);
  const [tamanoPagina, setTamanoPagina] = useState(25);
  const [totalPaginas, setTotalPaginas] = useState(0);
  const [totalVentas, setTotalVentas] = useState(0);

  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');
  const [mensaje, setMensaje] = useState('');
  const [revision, setRevision] = useState(0);

  const [sucursalUsuario, setSucursalUsuario] = useState('');

  const [idVentaDetalle, setIdVentaDetalle] = useState(null);
  const [formulario, setFormulario] = useState(null);
  const [ventaEliminar, setVentaEliminar] = useState(null);

  const esCorporativo = sucursalUsuario === 'Corporativo';

  const actualizarListado = useCallback(() => {
    setRevision(actual => actual + 1);
  }, []);

  useEffect(() => {
    let activo = true;

    async function cargarVentas() {
      setCargando(true);
      setError('');

      try {
        const datos = await listarVentas({
          ...filtrosAplicados,
          pagina,
          limite: tamanoPagina
        });

        if (!activo) return;

        const cantidadPaginas = datos.totalPaginas || 0;

        if (cantidadPaginas > 0 && pagina > cantidadPaginas) {
          setPagina(cantidadPaginas);
          return;
        }

        setVentas(datos.ventas || []);
        setTotalVentas(datos.total || 0);
        setTotalPaginas(cantidadPaginas);
        setSucursalUsuario(datos.sucursal || '');
      } catch (err) {
        if (!activo) return;

        setError(err.message || 'Error al cargar ventas');
        setVentas([]);
        setTotalVentas(0);
        setTotalPaginas(0);
      } finally {
        if (activo) setCargando(false);
      }
    }

    cargarVentas();

    return () => {
      activo = false;
    };
  }, [filtrosAplicados, pagina, tamanoPagina, revision]);

  function cambiarFiltro(evento) {
    const { name, value } = evento.target;

    setFiltros(actual => ({
      ...actual,
      [name]: value
    }));
  }

  function buscarVentas(evento) {
    evento.preventDefault();

    if (
      filtros.fechaInicio &&
      filtros.fechaFin &&
      filtros.fechaInicio > filtros.fechaFin
    ) {
      setError('La fecha inicial no puede ser posterior a la final.');
      return;
    }

    if (
      filtros.montoMinimo !== '' &&
      filtros.montoMaximo !== '' &&
      Number(filtros.montoMinimo) > Number(filtros.montoMaximo)
    ) {
      setError('El monto mínimo no puede superar al máximo.');
      return;
    }

    setError('');
    setPagina(1);

    setFiltrosAplicados({
      ...filtros,
      nombreCliente: filtros.nombreCliente.trim()
    });
  }

  function limpiarFiltros() {
    setFiltros({ ...filtrosIniciales });
    setFiltrosAplicados({ ...filtrosIniciales });
    setPagina(1);
    setError('');
  }

  function abrirCrear() {
    setMensaje('');
    setFormulario({ idVenta: null });
  }

  function abrirEditar(id) {
    setMensaje('');
    setFormulario({ idVenta: id });
  }

  function abrirEliminar(id, nombreCliente) {
    setMensaje('');

    setVentaEliminar({
      id,
      nombre: nombreCliente || `Factura #${id}`
    });
  }

  function operacionCompletada(texto) {
    setFormulario(null);
    setVentaEliminar(null);
    setIdVentaDetalle(null);
    setMensaje(texto);
    actualizarListado();
  }

  function generarPaginas() {
    if (totalPaginas <= 0) return [];

    const inicio = Math.max(
      1,
      Math.min(pagina - 2, totalPaginas - 4)
    );

    const fin = Math.min(totalPaginas, inicio + 4);
    const paginas = [];

    for (let numero = inicio; numero <= fin; numero++) {
      paginas.push(numero);
    }

    return paginas;
  }

  function formatearMonto(valor) {
    if (valor === null || valor === undefined) return '—';

    return Number(valor).toLocaleString('es-CR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });
  }

  function formatearFecha(valor) {
    if (!valor) return '—';
    return String(valor).slice(0, 10);
  }

  return (
    <div className="ventas-pagina">
      <header className="ventas-encabezado">
        <div>
          <h1>Gestión de ventas</h1>
          <p>
            Consulta y administración de facturas de venta.
          </p>
        </div>

        {!esCorporativo && (
          <button
            type="button"
            className="ventas-boton-principal"
            onClick={abrirCrear}
          >
            + Nueva venta
          </button>
        )}
      </header>

      {mensaje && (
        <div className="ventas-exito" role="status">
          <span>{mensaje}</span>

          <button
            type="button"
            onClick={() => setMensaje('')}
            aria-label="Cerrar mensaje"
          >
            ×
          </button>
        </div>
      )}

      <section className="ventas-tarjeta">
        <form
          className="ventas-filtros"
          onSubmit={buscarVentas}
        >
          <div className="ventas-campo">
            <label htmlFor="buscar-cliente-venta">
              Cliente
            </label>

            <input
              id="buscar-cliente-venta"
              name="nombreCliente"
              type="search"
              placeholder="Buscar por cliente..."
              value={filtros.nombreCliente}
              onChange={cambiarFiltro}
            />
          </div>

          <div className="ventas-campo">
            <label htmlFor="fecha-inicio-venta">
              Fecha inicial
            </label>

            <input
              id="fecha-inicio-venta"
              name="fechaInicio"
              type="date"
              value={filtros.fechaInicio}
              onChange={cambiarFiltro}
            />
          </div>

          <div className="ventas-campo">
            <label htmlFor="fecha-fin-venta">
              Fecha final
            </label>

            <input
              id="fecha-fin-venta"
              name="fechaFin"
              type="date"
              value={filtros.fechaFin}
              onChange={cambiarFiltro}
            />
          </div>

          <div className="ventas-campo">
            <label htmlFor="monto-minimo-venta">
              Monto mínimo
            </label>

            <input
              id="monto-minimo-venta"
              name="montoMinimo"
              type="number"
              min="0"
              step="0.01"
              placeholder="Mínimo"
              value={filtros.montoMinimo}
              onChange={cambiarFiltro}
            />
          </div>

          <div className="ventas-campo">
            <label htmlFor="monto-maximo-venta">
              Monto máximo
            </label>

            <input
              id="monto-maximo-venta"
              name="montoMaximo"
              type="number"
              min="0"
              step="0.01"
              placeholder="Máximo"
              value={filtros.montoMaximo}
              onChange={cambiarFiltro}
            />
          </div>

          {esCorporativo && (
            <div className="ventas-campo">
              <label htmlFor="sucursal-venta">
                Sucursal
              </label>

              <select
                id="sucursal-venta"
                name="sucursalID"
                value={filtros.sucursalID}
                onChange={cambiarFiltro}
              >
                <option value="">Todas</option>
                <option value="0">Histórico</option>
                <option value="1">San José</option>
                <option value="2">Limón</option>
              </select>
            </div>
          )}

          <div className="ventas-acciones-filtros">
            <button
              type="submit"
              className="ventas-boton-principal"
            >
              Buscar
            </button>

            <button
              type="button"
              className="ventas-boton-secundario"
              onClick={limpiarFiltros}
            >
              Limpiar
            </button>
          </div>
        </form>

        <div className="ventas-titulo-tabla">
          <div>
            <h2>Listado de ventas</h2>
            <p>Facturas registradas en el sistema.</p>
          </div>

          <span className="ventas-contador">
            {totalVentas} ventas
          </span>
        </div>

        {cargando && (
          <p className="ventas-mensaje">
            Cargando ventas...
          </p>
        )}

        {error && (
          <p className="ventas-error" role="alert">
            {error}
          </p>
        )}

        {!cargando && !error && (
          <>
            <div className="ventas-tabla-contenedor">
              <table className="ventas-tabla">
                <thead>
                  <tr>
                    <th>Factura</th>
                    <th>Fecha</th>
                    <th>Cliente</th>
                    <th>Método de entrega</th>
                    <th>Monto total</th>
                    {esCorporativo && <th>Sucursal</th>}
                    <th>Acciones</th>
                  </tr>
                </thead>

                <tbody>
                  {ventas.length === 0 ? (
                    <tr>
                      <td
                        colSpan={esCorporativo ? 7 : 6}
                        className="ventas-vacio"
                      >
                        No se encontraron ventas.
                      </td>
                    </tr>
                  ) : (
                    ventas.map(venta => {
                      const id = venta.NumeroFactura;
                      const cliente = venta.NombreCliente || '—';

                      return (
                        <tr key={`${venta.SucursalID ?? 'local'}-${id}`}>
                          <td>{id}</td>

                          <td>
                            {formatearFecha(venta.FechaFactura)}
                          </td>

                          <td className="ventas-nombre">
                            {cliente}
                          </td>

                          <td>
                            {venta.MetodoEntrega || '—'}
                          </td>

                          <td>
                            {formatearMonto(venta.MontoFactura)}
                          </td>

                          {esCorporativo && (
                            <td>
                              {venta.Sucursal || '—'}
                            </td>
                          )}

                          <td>
                            <div className="ventas-acciones-tabla">
                              <button
                                type="button"
                                className="ventas-boton-ver"
                                onClick={() =>
                                  setIdVentaDetalle(id)
                                }
                              >
                                Ver
                              </button>

                              {!esCorporativo && (
                                <>
                                  <button
                                    type="button"
                                    className="ventas-boton-editar"
                                    onClick={() => abrirEditar(id)}
                                  >
                                    Editar
                                  </button>

                                  <button
                                    type="button"
                                    className="ventas-boton-eliminar"
                                    onClick={() =>
                                      abrirEliminar(id, cliente)
                                    }
                                  >
                                    Eliminar
                                  </button>
                                </>
                              )}
                            </div>
                          </td>
                        </tr>
                      );
                    })
                  )}
                </tbody>
              </table>
            </div>

            <footer className="ventas-paginacion">
              <span className="ventas-paginacion-info">
                {totalVentas === 0
                  ? 'Sin registros'
                  : `Mostrando ${
                      (pagina - 1) * tamanoPagina + 1
                    } a ${
                      Math.min(
                        pagina * tamanoPagina,
                        totalVentas
                      )
                    } de ${totalVentas}`}
              </span>

              <div className="ventas-paginacion-botones">
                <button
                  type="button"
                  disabled={pagina <= 1}
                  onClick={() => setPagina(1)}
                  aria-label="Primera página"
                >
                  «
                </button>

                <button
                  type="button"
                  disabled={pagina <= 1}
                  onClick={() =>
                    setPagina(actual => actual - 1)
                  }
                  aria-label="Página anterior"
                >
                  ‹
                </button>

                {generarPaginas().map(numero => (
                  <button
                    key={numero}
                    type="button"
                    className={
                      numero === pagina
                        ? 'ventas-pagina-activa'
                        : ''
                    }
                    onClick={() => setPagina(numero)}
                  >
                    {numero}
                  </button>
                ))}

                <button
                  type="button"
                  disabled={
                    totalPaginas === 0 ||
                    pagina >= totalPaginas
                  }
                  onClick={() =>
                    setPagina(actual => actual + 1)
                  }
                  aria-label="Página siguiente"
                >
                  ›
                </button>

                <button
                  type="button"
                  disabled={
                    totalPaginas === 0 ||
                    pagina >= totalPaginas
                  }
                  onClick={() => setPagina(totalPaginas)}
                  aria-label="Última página"
                >
                  »
                </button>
              </div>

              <div className="ventas-tamano">
                <label htmlFor="tamano-ventas">
                  Por página:
                </label>

                <select
                  id="tamano-ventas"
                  value={tamanoPagina}
                  onChange={evento => {
                    setTamanoPagina(Number(evento.target.value));
                    setPagina(1);
                  }}
                >
                  <option value={25}>25</option>
                  <option value={50}>50</option>
                  <option value={100}>100</option>
                </select>
              </div>
            </footer>
          </>
        )}
      </section>

      {formulario !== null && (
        <FormularioVenta
          ventaId={formulario.idVenta}
          alCerrar={() => setFormulario(null)}
          alGuardar={operacionCompletada}
        />
      )}

      {idVentaDetalle !== null && (
        <DetalleVenta
          idVenta={idVentaDetalle}
          alCerrar={() => setIdVentaDetalle(null)}
        />
      )}

      {ventaEliminar !== null && (
        <ConfirmarEliminar
          venta={ventaEliminar}
          alCerrar={() => setVentaEliminar(null)}
          alEliminar={operacionCompletada}
        />
      )}
    </div>
  );
}
