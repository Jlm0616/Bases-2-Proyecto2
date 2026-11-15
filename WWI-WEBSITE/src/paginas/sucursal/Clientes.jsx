
import { useCallback, useEffect, useState } from 'react';
import { listarClientes } from '../../servicios/clientes';

import DetalleCliente from '../../componentes/clientes/DetalleCliente';
import FormularioCliente from '../../componentes/clientes/FormularioCliente';
import ConfirmarEliminar from '../../componentes/clientes/ConfirmarEliminar';

import '../../estilos/clientes.css';

export default function Clientes() {
  const [clientes, setClientes] = useState([]);

  const [nombre, setNombre] = useState('');
  const [filtroNombre, setFiltroNombre] = useState('');
  const [categoria, setCategoria] = useState('');
  const [filtroCategoria, setFiltroCategoria] = useState('');

  const [pagina, setPagina] = useState(1);
  const [tamanoPagina, setTamanoPagina] = useState(25);
  const [totalPaginas, setTotalPaginas] = useState(0);
  const [totalClientes, setTotalClientes] = useState(0);

  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');
  const [mensaje, setMensaje] = useState('');
  const [revision, setRevision] = useState(0);

  const [idClienteDetalle, setIdClienteDetalle] = useState(null);
  const [formulario, setFormulario] = useState(null);
  const [clienteEliminar, setClienteEliminar] = useState(null);

  const actualizarListado = useCallback(() => {
    setRevision(actual => actual + 1);
  }, []);

  useEffect(() => {
    let activo = true;

    async function cargarClientes() {
      setCargando(true);
      setError('');

      try {
        const datos = await listarClientes({
          nombre: filtroNombre,
          categoriaID: filtroCategoria,
          pagina,
          tamanoPagina
        });

        if (!activo) return;

        const cantidadPaginas = datos.totalPaginas || 0;

        if (cantidadPaginas > 0 && pagina > cantidadPaginas) {
          setPagina(cantidadPaginas);
          return;
        }

        setClientes(datos.clientes || []);
        setTotalPaginas(cantidadPaginas);
        setTotalClientes(datos.totalClientes || 0);
      } catch (err) {
        if (!activo) return;

        setError(err.message);
        setClientes([]);
        setTotalClientes(0);
        setTotalPaginas(0);
      } finally {
        if (activo) setCargando(false);
      }
    }

    cargarClientes();

    return () => {
      activo = false;
    };
  }, [
    filtroNombre,
    filtroCategoria,
    pagina,
    tamanoPagina,
    revision
  ]);

  function buscarClientes(evento) {
    evento.preventDefault();
    setPagina(1);
    setFiltroNombre(nombre.trim());
    setFiltroCategoria(categoria);
  }

  function limpiarFiltros() {
    setNombre('');
    setCategoria('');
    setFiltroNombre('');
    setFiltroCategoria('');
    setPagina(1);
  }

  function operacionCompletada(texto) {
    setFormulario(null);
    setClienteEliminar(null);
    setIdClienteDetalle(null);
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

  return (
    <div className="clientes-pagina">
      <header className="clientes-encabezado">
        <div>
          <h1>Gestión de clientes</h1>
          <p>Administración de clientes de la sucursal.</p>
        </div>

        <button
          type="button"
          className="clientes-boton-principal"
          onClick={() => {
            setMensaje('');
            setFormulario({ idCliente: null });
          }}
        >
          + Nuevo cliente
        </button>
      </header>

      {mensaje && (
        <div className="clientes-exito" role="status">
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

      <section className="clientes-tarjeta">
        <form
          className="clientes-filtros"
          onSubmit={buscarClientes}
        >
          <div className="clientes-campo">
            <label htmlFor="buscar-cliente">Nombre</label>
            <input
              id="buscar-cliente"
              type="search"
              placeholder="Buscar por nombre..."
              value={nombre}
              onChange={evento => setNombre(evento.target.value)}
            />
          </div>

          <div className="clientes-campo">
            <label htmlFor="categoria-cliente">
              ID de categoría
            </label>
            <input
              id="categoria-cliente"
              type="number"
              min="1"
              step="1"
              placeholder="Todas"
              value={categoria}
              onChange={evento => setCategoria(evento.target.value)}
            />
          </div>

          <div className="clientes-acciones-filtros">
            <button
              type="submit"
              className="clientes-boton-principal"
            >
              Buscar
            </button>

            <button
              type="button"
              className="clientes-boton-secundario"
              onClick={limpiarFiltros}
            >
              Limpiar
            </button>
          </div>
        </form>

        <div className="clientes-titulo-tabla">
          <div>
            <h2>Listado de clientes</h2>
            <p>Clientes registrados en tu sucursal.</p>
          </div>

          <span className="clientes-contador">
            {totalClientes} clientes
          </span>
        </div>

        {cargando && (
          <p className="clientes-mensaje">
            Cargando clientes...
          </p>
        )}

        {error && (
          <p className="clientes-error" role="alert">
            {error}
          </p>
        )}

        {!cargando && !error && (
          <>
            <div className="clientes-tabla-contenedor">
              <table className="clientes-tabla">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Categoría</th>
                    <th>Acciones</th>
                  </tr>
                </thead>

                <tbody>
                  {clientes.length === 0 ? (
                    <tr>
                      <td
                        colSpan="4"
                        className="clientes-vacio"
                      >
                        No se encontraron clientes.
                      </td>
                    </tr>
                  ) : (
                    clientes.map(cliente => (
                      <tr key={cliente.IdCliente}>
                        <td>{cliente.IdCliente}</td>

                        <td className="clientes-nombre">
                          {cliente.NombreCliente}
                        </td>

                        <td>{cliente.CategoriaCliente}</td>

                        <td>
                          <div className="clientes-acciones-tabla">
                            <button
                              type="button"
                              className="clientes-boton-ver"
                              onClick={() =>
                                setIdClienteDetalle(
                                  cliente.IdCliente
                                )
                              }
                            >
                              Ver
                            </button>

                            <button
                              type="button"
                              className="clientes-boton-editar"
                              onClick={() => {
                                setMensaje('');
                                setFormulario({
                                  idCliente: cliente.IdCliente
                                });
                              }}
                            >
                              Editar
                            </button>

                            <button
                              type="button"
                              className="clientes-boton-eliminar"
                              onClick={() => {
                                setMensaje('');
                                setClienteEliminar(cliente);
                              }}
                            >
                              Eliminar
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>

            <footer className="clientes-paginacion">
              <span className="clientes-paginacion-info">
                {totalClientes === 0
                  ? 'Sin registros'
                  : `Mostrando ${
                      (pagina - 1) * tamanoPagina + 1
                    } a ${
                      Math.min(
                        pagina * tamanoPagina,
                        totalClientes
                      )
                    } de ${totalClientes}`}
              </span>

              <div className="clientes-paginacion-botones">
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
                        ? 'clientes-pagina-activa'
                        : ''
                    }
                    onClick={() => setPagina(numero)}
                  >
                    {numero}
                  </button>
                ))}

                <button
                  type="button"
                  disabled={pagina >= totalPaginas}
                  onClick={() =>
                    setPagina(actual => actual + 1)
                  }
                  aria-label="Página siguiente"
                >
                  ›
                </button>

                <button
                  type="button"
                  disabled={pagina >= totalPaginas}
                  onClick={() => setPagina(totalPaginas)}
                  aria-label="Última página"
                >
                  »
                </button>
              </div>

              <div className="clientes-tamano">
                <label htmlFor="tamano-clientes">
                  Por página:
                </label>

                <select
                  id="tamano-clientes"
                  value={tamanoPagina}
                  onChange={evento => {
                    setTamanoPagina(
                      Number(evento.target.value)
                    );
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

      {idClienteDetalle !== null && (
        <DetalleCliente
          idCliente={idClienteDetalle}
          alCerrar={() => setIdClienteDetalle(null)}
        />
      )}

      {formulario !== null && (
        <FormularioCliente
          idCliente={formulario.idCliente}
          alCerrar={() => setFormulario(null)}
          alGuardar={operacionCompletada}
        />
      )}

      {clienteEliminar !== null && (
        <ConfirmarEliminar
          cliente={clienteEliminar}
          alCerrar={() => setClienteEliminar(null)}
          alEliminar={operacionCompletada}
        />
      )}
    </div>
  );
}
