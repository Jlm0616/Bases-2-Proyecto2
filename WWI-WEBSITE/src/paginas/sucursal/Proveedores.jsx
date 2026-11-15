
import { useCallback, useEffect, useState } from 'react';
import { listarProveedores } from '../../servicios/proveedores';

import DetalleProveedor from '../../componentes/proveedores/DetalleProveedor';
import FormularioProveedor from '../../componentes/proveedores/FormularioProveedor';
import ConfirmarEliminar from '../../componentes/proveedores/ConfirmarEliminar';

import '../../estilos/proveedores.css';

export default function Proveedores() {
  const [proveedores, setProveedores] = useState([]);

  const [nombre, setNombre] = useState('');
  const [filtroNombre, setFiltroNombre] = useState('');
  const [categoria, setCategoria] = useState('');
  const [filtroCategoria, setFiltroCategoria] = useState('');

  const [pagina, setPagina] = useState(1);
  const [tamanoPagina, setTamanoPagina] = useState(25);
  const [totalPaginas, setTotalPaginas] = useState(0);
  const [totalProveedores, setTotalProveedores] = useState(0);

  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');
  const [mensaje, setMensaje] = useState('');
  const [revision, setRevision] = useState(0);

  const [idProveedorDetalle, setIdProveedorDetalle] = useState(null);
  const [formulario, setFormulario] = useState(null);
  const [proveedorEliminar, setProveedorEliminar] = useState(null);

  const actualizarListado = useCallback(() => {
    setRevision(actual => actual + 1);
  }, []);

  useEffect(() => {
    let activo = true;

    async function cargarProveedores() {
      setCargando(true);
      setError('');

      try {
        const datos = await listarProveedores({
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

        setProveedores(datos.proveedores || []);
        setTotalPaginas(cantidadPaginas);
        setTotalProveedores(datos.total || 0);
      } catch (err) {
        if (!activo) return;

        setError(err.message);
        setProveedores([]);
        setTotalProveedores(0);
        setTotalPaginas(0);
      } finally {
        if (activo) setCargando(false);
      }
    }

    cargarProveedores();

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

  function buscarProveedores(evento) {
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
    setProveedorEliminar(null);
    setIdProveedorDetalle(null);
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
    <div className="proveedores-pagina">
      <header className="proveedores-encabezado">
        <div>
          <h1>Gestión de proveedores</h1>
          <p>Administración de proveedores de la sucursal.</p>
        </div>

        <button
          type="button"
          className="proveedores-boton-principal"
          onClick={() => {
            setMensaje('');
            setFormulario({ idProveedor: null });
          }}
        >
          + Nuevo proveedor
        </button>
      </header>

      {mensaje && (
        <div className="proveedores-exito" role="status">
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

      <section className="proveedores-tarjeta">
        <form
          className="proveedores-filtros"
          onSubmit={buscarProveedores}
        >
          <div className="proveedores-campo">
            <label htmlFor="buscar-proveedor">
              Nombre
            </label>

            <input
              id="buscar-proveedor"
              type="search"
              placeholder="Buscar por nombre..."
              value={nombre}
              onChange={evento => setNombre(evento.target.value)}
            />
          </div>

          <div className="proveedores-campo">
            <label htmlFor="categoria-proveedor">
              ID de categoría
            </label>

            <input
              id="categoria-proveedor"
              type="number"
              min="1"
              step="1"
              placeholder="Todas"
              value={categoria}
              onChange={evento => setCategoria(evento.target.value)}
            />
          </div>

          <div className="proveedores-acciones-filtros">
            <button
              type="submit"
              className="proveedores-boton-principal"
            >
              Buscar
            </button>

            <button
              type="button"
              className="proveedores-boton-secundario"
              onClick={limpiarFiltros}
            >
              Limpiar
            </button>
          </div>
        </form>

        <div className="proveedores-titulo-tabla">
          <div>
            <h2>Listado de proveedores</h2>
            <p>Proveedores registrados en el catálogo.</p>
          </div>

          <span className="proveedores-contador">
            {totalProveedores} proveedores
          </span>
        </div>

        {cargando && (
          <p className="proveedores-mensaje">
            Cargando proveedores...
          </p>
        )}

        {error && (
          <p className="proveedores-error" role="alert">
            {error}
          </p>
        )}

        {!cargando && !error && (
          <>
            <div className="proveedores-tabla-contenedor">
              <table className="proveedores-tabla">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Código</th>
                    <th>Nombre</th>
                    <th>Categoría</th>
                    <th>Días de pago</th>
                    <th>Acciones</th>
                  </tr>
                </thead>

                <tbody>
                  {proveedores.length === 0 ? (
                    <tr>
                      <td
                        colSpan="6"
                        className="proveedores-vacio"
                      >
                        No se encontraron proveedores.
                      </td>
                    </tr>
                  ) : (
                    proveedores.map(proveedor => (
                      <tr key={proveedor.IdProveedor}>
                        <td>{proveedor.IdProveedor}</td>

                        <td>
                          {proveedor.CodigoProveedor || '—'}
                        </td>

                        <td className="proveedores-nombre">
                          {proveedor.NombreProveedor}
                        </td>

                        <td>
                          {proveedor.CategoriaProveedor || '—'}
                        </td>

                        <td>
                          {proveedor.DiasGraciaPago ?? '—'}
                        </td>

                        <td>
                          <div className="proveedores-acciones-tabla">
                            <button
                              type="button"
                              className="proveedores-boton-ver"
                              onClick={() =>
                                setIdProveedorDetalle(
                                  proveedor.IdProveedor
                                )
                              }
                            >
                              Ver
                            </button>

                            <button
                              type="button"
                              className="proveedores-boton-editar"
                              onClick={() => {
                                setMensaje('');
                                setFormulario({
                                  idProveedor: proveedor.IdProveedor
                                });
                              }}
                            >
                              Editar
                            </button>

                            <button
                              type="button"
                              className="proveedores-boton-eliminar"
                              onClick={() => {
                                setMensaje('');
                                setProveedorEliminar(proveedor);
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

            <footer className="proveedores-paginacion">
              <span className="proveedores-paginacion-info">
                {totalProveedores === 0
                  ? 'Sin registros'
                  : `Mostrando ${
                      (pagina - 1) * tamanoPagina + 1
                    } a ${
                      Math.min(
                        pagina * tamanoPagina,
                        totalProveedores
                      )
                    } de ${totalProveedores}`}
              </span>

              <div className="proveedores-paginacion-botones">
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
                        ? 'proveedores-pagina-activa'
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

              <div className="proveedores-tamano">
                <label htmlFor="tamano-proveedores">
                  Por página:
                </label>

                <select
                  id="tamano-proveedores"
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

      {idProveedorDetalle !== null && (
        <DetalleProveedor
          idProveedor={idProveedorDetalle}
          alCerrar={() => setIdProveedorDetalle(null)}
        />
      )}

      {formulario !== null && (
        <FormularioProveedor
          idProveedor={formulario.idProveedor}
          alCerrar={() => setFormulario(null)}
          alGuardar={operacionCompletada}
        />
      )}

      {proveedorEliminar !== null && (
        <ConfirmarEliminar
          proveedor={proveedorEliminar}
          alCerrar={() => setProveedorEliminar(null)}
          alEliminar={operacionCompletada}
        />
      )}
    </div>
  );
}
