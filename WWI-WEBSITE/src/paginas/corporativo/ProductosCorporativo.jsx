import { useCallback, useEffect, useState } from 'react';
import {
  listarProductos,
  obtenerInventarioSucursal,
  obtenerInventarioConsolidado
} from '../../servicios/productos';

import DetalleProducto from '../../componentes/productos/DetalleProducto';

import '../../estilos/productos.css';

export default function ProductosCorporativo() {
  const [productos, setProductos] = useState([]);
  const [tipoConsulta, setTipoConsulta] = useState('catalogo');

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

  const [idProductoDetalle, setIdProductoDetalle] = useState(null);

  useEffect(() => {
    let activo = true;

    async function cargarProductos() {
      setCargando(true);
      setError('');

      try {
        let datos;

        if (tipoConsulta === 'catalogo') {
          datos = await listarProductos({
            nombre: filtroNombre,
            grupoID: filtroGrupoID,
            pagina,
            limite: tamanoPagina
          });

          if (!activo) return;

          const paginas = Number(datos.totalPaginas ?? 0);

          if (paginas > 0 && pagina > paginas) {
            setPagina(paginas);
            return;
          }

          setProductos(datos.productos || []);
          setTotalProductos(Number(datos.total ?? 0));
          setTotalPaginas(paginas);

        } else {
          // Obtener registros de inventario.
          if (tipoConsulta === 'consolidado') {
            datos = await obtenerInventarioConsolidado({
              pagina,
              limite: tamanoPagina
            });
          } else {
            datos = await obtenerInventarioSucursal({
              sucursal: tipoConsulta,
              pagina,
              limite: tamanoPagina
            });
          }

          if (!activo) return;

          const inventario = datos.inventario || [];
          const total = Number(datos.total ?? inventario.length);
          const paginas = Number(datos.totalPaginas ?? Math.ceil(total / tamanoPagina));

          if (paginas > 0 && pagina > paginas) {
            setPagina(paginas);
            return;
          }

          setProductos(inventario);
          setTotalProductos(total);
          setTotalPaginas(paginas);
        }

      } catch (err) {
        if (!activo) return;

        setError(err.message || 'Error al cargar productos');
        setProductos([]);
        setTotalProductos(0);
        setTotalPaginas(0);

      } finally {
        if (activo) {
          setCargando(false);
        }
      }
    }

    cargarProductos();

    return () => {
      activo = false;
    };
  }, [
    filtroNombre,
    filtroGrupoID,
    pagina,
    tamanoPagina,
    tipoConsulta
  ]);

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

  function generarPaginas() {
    if (totalPaginas <= 0) return [];

    const inicio = Math.max(1, Math.min(pagina - 2, totalPaginas - 4));
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
          <h1>Productos Corporativo</h1>
          <p>Consulta de productos de todas las sucursales.</p>
        </div>
      </header>

      <section className="productos-tarjeta">
        <form className="productos-filtros" onSubmit={buscarProductos}>
          <div className="productos-campo">
            <label htmlFor="tipo-consulta">Consultar</label>

            <select
              id="tipo-consulta"
              value={tipoConsulta}
              onChange={evento => {
                setTipoConsulta(evento.target.value);
                setPagina(1);
              }}
            >
              <option value="catalogo">Catálogo de productos</option>
              <option value="SanJose">Inventario San José</option>
              <option value="Limon">Inventario Limón</option>
              <option value="consolidado">Inventario consolidado</option>
            </select>
          </div>

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
            <button type="submit" className="productos-boton-principal">
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
            <h2>
              {tipoConsulta === 'catalogo'
                ? 'Catálogo de productos'
                : tipoConsulta === 'SanJose'
                  ? 'Inventario San José'
                  : tipoConsulta === 'Limon'
                    ? 'Inventario Limón'
                    : 'Inventario consolidado'}
            </h2>

            <p>Consulta de productos e inventario del sistema.</p>
          </div>
          <span className="productos-contador">
            {totalProductos} productos
          </span>
        </div>

        {cargando && <p className="productos-mensaje">Cargando productos...</p>}

        {error && <p className="productos-error" role="alert">{error}</p>}

        {!cargando && !error && (
          <div>
            {tipoConsulta !== 'catalogo' && (
              <div className="productos-tabla-contenedor">
                <table className="productos-tabla">
                  <thead>
                    {tipoConsulta === 'consolidado' ? (
                      <tr>
                        <th>ID del producto</th>
                        <th>Inventario San José</th>
                        <th>Inventario Limón</th>
                        <th>Inventario total</th>
                        <th>Acciones</th>
                      </tr>
                    ) : (
                      <tr>
                        <th>ID del producto</th>
                        <th>Sucursal</th>
                        <th>Cantidad en inventario</th>
                        <th>Acciones</th>
                      </tr>
                    )}
                  </thead>

                  <tbody>
                    {productos.length === 0 ? (
                      <tr>
                        <td
                          colSpan={tipoConsulta === 'consolidado' ? 5 : 4}
                          className="productos-vacio"
                        >
                          No se encontraron registros de inventario.
                        </td>
                      </tr>
                    ) : (
                      productos.map(producto => (
                        <tr key={producto.IdProducto}>
                          <td>{producto.IdProducto}</td>

                          {tipoConsulta === 'consolidado' ? (
                            <>
                              <td>
                                {Number(producto.InventarioSanJose).toLocaleString('es-CR')}
                              </td>

                              <td>
                                {Number(producto.InventarioLimon).toLocaleString('es-CR')}
                              </td>

                              <td>
                                <strong>
                                  {Number(producto.InventarioTotal).toLocaleString('es-CR')}
                                </strong>
                              </td>
                            </>
                          ) : (
                            <>
                              <td>
                                {producto.Sucursal === 'SanJose'
                                  ? 'San José'
                                  : 'Limón'}
                              </td>

                              <td>
                                {Number(producto.CantidadInventario).toLocaleString('es-CR')}
                              </td>
                            </>
                          )}

                          <td>
                            <button
                              type="button"
                              className="productos-boton-ver"
                              onClick={() => setIdProductoDetalle(producto.IdProducto)}
                            >
                              Ver
                            </button>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            )}

            {tipoConsulta === 'catalogo' && (
              <>
                <div className="productos-tabla-contenedor">
                  <table className="productos-tabla">
                    <thead>
                      <tr>
                        <th>ID</th>
                        <th>Nombre</th>
                        <th>Inventario</th>
                        <th>Acciones</th>
                      </tr>
                    </thead>
                    <tbody>
                      {productos.length === 0 ? (
                        <tr>
                          <td colSpan="4" className="productos-vacio">
                            No se encontraron productos.
                          </td>
                        </tr>
                      ) : (
                        productos.map(producto => (
                          <tr key={producto.IdProducto}>
                            <td>{producto.IdProducto}</td>

                            <td className="productos-nombre">
                              {producto.NombreProducto}
                            </td>

                            <td>{producto.CantidadEnInventario ?? 'No disponible'}</td>

                            <td>
                              <div className="productos-acciones-tabla">
                                <button
                                  type="button"
                                  className="productos-boton-ver"
                                  onClick={() => setIdProductoDetalle(producto.IdProducto)}
                                >
                                  Ver
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))
                      )}
                    </tbody>
                  </table>
                </div>

                <footer className="productos-paginacion">
                  <span className="productos-paginacion-info">
                    {totalProductos === 0
                      ? 'Sin registros'
                      : `Mostrando ${(pagina - 1) * tamanoPagina + 1} a ${Math.min(pagina * tamanoPagina, totalProductos)} de ${totalProductos}`}
                  </span>

                  <div className="productos-paginacion-botones">
                    <button type="button" disabled={pagina <= 1} onClick={() => setPagina(1)}>«</button>
                    <button type="button" disabled={pagina <= 1} onClick={() => setPagina(p => p - 1)}>‹</button>
                    {generarPaginas().map(numero => (
                      <button
                        key={numero}
                        type="button"
                        className={numero === pagina ? 'productos-pagina-activa' : ''}
                        onClick={() => setPagina(numero)}
                      >
                        {numero}
                      </button>
                    ))}
                    <button type="button" disabled={pagina >= totalPaginas} onClick={() => setPagina(p => p + 1)}>›</button>
                    <button type="button" disabled={pagina >= totalPaginas} onClick={() => setPagina(totalPaginas)}>»</button>
                  </div>

                  <div className="productos-tamano">
                    <label htmlFor="tamano-productos">Por página:</label>
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
          </div>
        )}
      </section>

      {idProductoDetalle !== null && (
        <DetalleProducto
          idProducto={idProductoDetalle}
          alCerrar={() => setIdProductoDetalle(null)}
        />
      )}
    </div>
  );
}
