
import { useEffect, useState } from 'react';
import {
  listarProductos,
  eliminarProducto
} from '../../servicios/productos';
import DetalleProducto from '../../componentes/productos/DetalleProducto';
import FormularioProducto from '../../componentes/productos/FormularioProducto';

import '../../estilos/productos.css';

export default function Productos() {
  const [productos, setProductos] = useState([]);

  const [nombre, setNombre] = useState('');
  const [filtroNombre, setFiltroNombre] = useState('');
  const [grupoID, setGrupoID] = useState('');
  const [filtroGrupoID, setFiltroGrupoID] = useState('');

  const [pagina, setPagina] = useState(1);
  const [tamanoPagina, setTamanoPagina] = useState(25);
  const [totalPaginas, setTotalPaginas] = useState(0);
  const [totalProductos, setTotalProductos] = useState(0);

  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');
  const [mensaje, setMensaje] = useState('');
  const [revision, setRevision] = useState(0);

  const [idProductoDetalle, setIdProductoDetalle] = useState(null);
  const [mostrarFormulario, setMostrarFormulario] = useState(false);
  const [idProductoEditar, setIdProductoEditar] = useState(null);

  const [productoEliminar, setProductoEliminar] = useState(null);
  const [eliminando, setEliminando] = useState(false);
  const [errorEliminar, setErrorEliminar] = useState('');

  useEffect(() => {
    let activo = true;

    async function cargarProductos() {
      setCargando(true);
      setError('');

      try {
        const datos = await listarProductos({
          nombre: filtroNombre,
          grupoID: filtroGrupoID,
          pagina,
          limite: tamanoPagina
        });

        if (!activo) return;

        const cantidadPaginas = datos.totalPaginas || 0;

        if (cantidadPaginas > 0 && pagina > cantidadPaginas) {
          setPagina(cantidadPaginas);
          return;
        }

        setProductos(datos.productos || []);
        setTotalProductos(datos.total || 0);
        setTotalPaginas(cantidadPaginas);
      } catch (err) {
        if (!activo) return;

        setError(err.message || 'Error al cargar productos');
        setProductos([]);
        setTotalProductos(0);
        setTotalPaginas(0);
      } finally {
        if (activo) setCargando(false);
      }
    }

    cargarProductos();

    return () => {
      activo = false;
    };
  }, [filtroNombre, filtroGrupoID, pagina, tamanoPagina, revision]);

  function buscarProductos(evento) {
    evento.preventDefault();
    setPagina(1);
    setFiltroNombre(nombre.trim());
    setFiltroGrupoID(grupoID);
  }

  function limpiarFiltros() {
    setNombre('');
    setGrupoID('');
    setFiltroNombre('');
    setFiltroGrupoID('');
    setPagina(1);
  }

  function abrirCrear() {
    setMensaje('');
    setIdProductoEditar(null);
    setMostrarFormulario(true);
  }

  function abrirEditar(id) {
    setMensaje('');
    setIdProductoEditar(id);
    setMostrarFormulario(true);
  }

  function cerrarFormulario() {
    setMostrarFormulario(false);
    setIdProductoEditar(null);
  }

  function productoGuardado(texto) {
    cerrarFormulario();
    setMensaje(texto);
    setRevision(actual => actual + 1);
  }

  function abrirEliminar(id, nombreProducto) {
    setMensaje('');
    setErrorEliminar('');
    setProductoEliminar({
      id,
      nombre: nombreProducto || `Producto #${id}`
    });
  }

  function cerrarEliminar() {
    if (eliminando) return;

    setProductoEliminar(null);
    setErrorEliminar('');
  }

  async function confirmarEliminar() {
    if (!productoEliminar || eliminando) return;

    setEliminando(true);
    setErrorEliminar('');

    try {
      await eliminarProducto(productoEliminar.id);

      setProductoEliminar(null);
      setMensaje('Producto eliminado correctamente');
      setRevision(actual => actual + 1);
    } catch (err) {
      setErrorEliminar(
        err.message || 'No se pudo eliminar el producto'
      );
    } finally {
      setEliminando(false);
    }
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
    <div className="productos-pagina">
      <header className="productos-encabezado">
        <div>
          <h1>Gestión de productos</h1>
          <p>Administración del catálogo de productos de la sucursal.</p>
        </div>

        <button
          type="button"
          className="productos-boton-principal"
          onClick={abrirCrear}
        >
          + Nuevo producto
        </button>
      </header>

      {mensaje && (
        <div className="productos-exito" role="status">
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

      <section className="productos-tarjeta">
        <form
          className="productos-filtros"
          onSubmit={buscarProductos}
        >
          <div className="productos-campo">
            <label htmlFor="buscar-producto">Nombre</label>
            <input
              id="buscar-producto"
              type="search"
              placeholder="Buscar por nombre..."
              value={nombre}
              onChange={evento => setNombre(evento.target.value)}
            />
          </div>

          <div className="productos-campo">
            <label htmlFor="grupo-producto">ID de grupo</label>
            <input
              id="grupo-producto"
              type="number"
              min="1"
              step="1"
              placeholder="Todos"
              value={grupoID}
              onChange={evento => setGrupoID(evento.target.value)}
            />
          </div>

          <div className="productos-acciones-filtros">
            <button
              type="submit"
              className="productos-boton-principal"
            >
              Buscar
            </button>

            <button
              type="button"
              className="productos-boton-secundario"
              onClick={limpiarFiltros}
            >
              Limpiar
            </button>
          </div>
        </form>

        <div className="productos-titulo-tabla">
          <div>
            <h2>Listado de productos</h2>
            <p>Productos registrados en el catálogo.</p>
          </div>

          <span className="productos-contador">
            {totalProductos} productos
          </span>
        </div>

        {cargando && (
          <p className="productos-mensaje">
            Cargando productos...
          </p>
        )}

        {error && (
          <p className="productos-error" role="alert">
            {error}
          </p>
        )}

        {!cargando && !error && (
          <>
            <div className="productos-tabla-contenedor">
              <table className="productos-tabla">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Proveedor</th>
                    <th>Precio unitario</th>
                    <th>Acciones</th>
                  </tr>
                </thead>

                <tbody>
                  {productos.length === 0 ? (
                    <tr>
                      <td
                        colSpan="5"
                        className="productos-vacio"
                      >
                        No se encontraron productos.
                      </td>
                    </tr>
                  ) : (
                    productos.map(producto => {
                      const id = producto.StockItemID
                        ?? producto.IdProducto;

                      const nombreProducto = producto.StockItemName
                        ?? producto.NombreProducto
                        ?? producto.Nombre;

                      const proveedor = producto.SupplierName
                        ?? producto.NombreProveedor
                        ?? producto.ProveedorID
                        ?? '—';

                      const precio = producto.UnitPrice
                        ?? producto.PrecioUnitario;

                      return (
                        <tr key={id}>
                          <td>{id}</td>

                          <td className="productos-nombre">
                            {nombreProducto || '—'}
                          </td>

                          <td>{proveedor}</td>

                          <td>
                            {precio == null
                              ? '—'
                              : Number(precio).toLocaleString(
                                  'es-CR',
                                  {
                                    minimumFractionDigits: 2,
                                    maximumFractionDigits: 2
                                  }
                                )}
                          </td>

                            <td>
                            <div className="productos-acciones-tabla">
                                <button
                                type="button"
                                className="productos-boton-ver"
                                onClick={() => setIdProductoDetalle(id)}
                                >
                                Ver
                                </button>

                                <button
                                type="button"
                                className="productos-boton-editar"
                                onClick={() => abrirEditar(id)}
                                >
                                Editar
                                </button>

                                <button
                                type="button"
                                className="productos-boton-eliminar"
                                onClick={() => abrirEliminar(id, nombreProducto)}
                                >
                                Eliminar
                                </button>
                            </div>
                            </td>
                        </tr>
                      );
                    })
                  )}
                </tbody>
              </table>
            </div>

            <footer className="productos-paginacion">
              <span className="productos-paginacion-info">
                {totalProductos === 0
                  ? 'Sin registros'
                  : `Mostrando ${
                      (pagina - 1) * tamanoPagina + 1
                    } a ${
                      Math.min(
                        pagina * tamanoPagina,
                        totalProductos
                      )
                    } de ${totalProductos}`}
              </span>

              <div className="productos-paginacion-botones">
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
                  onClick={() => setPagina(actual => actual - 1)}
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
                        ? 'productos-pagina-activa'
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
                    totalPaginas === 0 || pagina >= totalPaginas
                  }
                  onClick={() => setPagina(actual => actual + 1)}
                  aria-label="Página siguiente"
                >
                  ›
                </button>

                <button
                  type="button"
                  disabled={
                    totalPaginas === 0 || pagina >= totalPaginas
                  }
                  onClick={() => setPagina(totalPaginas)}
                  aria-label="Última página"
                >
                  »
                </button>
              </div>

              <div className="productos-tamano">
                <label htmlFor="tamano-productos">
                  Por página:
                </label>

                <select
                  id="tamano-productos"
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

      {mostrarFormulario && (
        <FormularioProducto
          productoId={idProductoEditar}
          alCerrar={cerrarFormulario}
          alGuardar={productoGuardado}
        />
      )}

      {idProductoDetalle !== null && (
        <DetalleProducto
          idProducto={idProductoDetalle}
          alCerrar={() => setIdProductoDetalle(null)}
        />
      )}

      {productoEliminar !== null && (
        <div
          className="productos-modal-fondo"
          onMouseDown={evento => {
            if (evento.target === evento.currentTarget) {
              cerrarEliminar();
            }
          }}
        >
          <section
            className="productos-modal"
            role="dialog"
            aria-modal="true"
            aria-labelledby="titulo-eliminar-producto"
            style={{ maxWidth: '480px' }}
          >
            <header className="productos-modal-encabezado">
              <div>
                <h2 id="titulo-eliminar-producto">
                  Eliminar producto
                </h2>
                <p>Confirmación de eliminación</p>
              </div>

              <button
                type="button"
                className="productos-modal-cerrar"
                onClick={cerrarEliminar}
                disabled={eliminando}
                aria-label="Cerrar"
              >
                ×
              </button>
            </header>

            <div className="productos-modal-contenido">
              <p>
                ¿Estás seguro de que querés eliminar el producto
                <strong> {productoEliminar.nombre}</strong>
                {' '} (ID: {productoEliminar.id})?
              </p>

              <p style={{ color: '#64748b', fontSize: '13px' }}>
                Esta operación puede afectar el catálogo de productos.
                Si el producto tiene registros relacionados, la base
                de datos podría impedir su eliminación.
              </p>

              {errorEliminar && (
                <p className="productos-error" role="alert">
                  {errorEliminar}
                </p>
              )}
            </div>

            <footer
              className="productos-modal-pie"
              style={{ gap: '12px' }}
            >
              <button
                type="button"
                className="productos-boton-secundario"
                onClick={cerrarEliminar}
                disabled={eliminando}
              >
                Cancelar
              </button>

              <button
                type="button"
                className="productos-boton-principal"
                style={{ backgroundColor: '#b91c1c' }}
                onClick={confirmarEliminar}
                disabled={eliminando}
              >
                {eliminando
                  ? 'Eliminando...'
                  : 'Sí, eliminar'}
              </button>
            </footer>
          </section>
        </div>
      )}
    </div>
  );
}
