
import { useEffect, useState } from 'react';
import { obtenerDetalleProducto } from '../../servicios/productos';

function mostrar(valor) {
  if (valor === null || valor === undefined || valor === '') {
    return 'No especificado';
  }

  return String(valor);
}

function mostrarPrecio(valor) {
  if (valor === null || valor === undefined) {
    return 'No especificado';
  }

  return Number(valor).toLocaleString('es-CR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });
}

export default function DetalleProducto({ idProducto, alCerrar }) {
  const [producto, setProducto] = useState(null);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let activo = true;

    async function cargarDetalle() {
      setCargando(true);
      setError('');

      try {
        const datos = await obtenerDetalleProducto(idProducto);

        if (activo) {
          setProducto(datos.producto);
        }
      } catch (err) {
        if (activo) {
          setError(err.message || 'No se pudo consultar el producto');
        }
      } finally {
        if (activo) {
          setCargando(false);
        }
      }
    }

    cargarDetalle();

    return () => {
      activo = false;
    };
  }, [idProducto]);

  return (
    <div
      className="productos-modal-fondo"
      onMouseDown={evento => {
        if (evento.target === evento.currentTarget) {
          alCerrar();
        }
      }}
    >
      <section
        className="productos-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-detalle-producto"
      >
        <header className="productos-modal-encabezado">
          <div>
            <h2 id="titulo-detalle-producto">
              Detalle del producto
            </h2>
            <p>Información registrada en el catálogo.</p>
          </div>

          <button
            type="button"
            className="productos-modal-cerrar"
            onClick={alCerrar}
            aria-label="Cerrar"
          >
            ×
          </button>
        </header>

        <div className="productos-modal-contenido">
          {cargando && <p>Cargando información...</p>}

          {error && (
            <p className="productos-error" role="alert">
              {error}
            </p>
          )}

          {!cargando && !error && producto && (
            <>
              <h3 className="productos-seccion-titulo">
                Información general
              </h3>

              <div className="productos-detalle-grid">
                <div>
                  <strong>ID del producto</strong>
                  <span>{mostrar(producto.IdProducto)}</span>
                </div>

                <div>
                  <strong>Nombre</strong>
                  <span>{mostrar(producto.NombreProducto)}</span>
                </div>

                <div>
                  <strong>Proveedor</strong>
                  <span>{mostrar(producto.NombreProveedor)}</span>
                </div>

                <div>
                  <strong>ID del proveedor</strong>
                  <span>{mostrar(producto.IdProveedor)}</span>
                </div>

                <div>
                  <strong>Color</strong>
                  <span>{mostrar(producto.Color)}</span>
                </div>

                <div>
                  <strong>Marca</strong>
                  <span>{mostrar(producto.Marca)}</span>
                </div>

                <div>
                  <strong>Talla o tamaño</strong>
                  <span>{mostrar(producto.TallaTamano)}</span>
                </div>
              </div>

              <h3 className="productos-seccion-titulo">
                Empaquetamiento
              </h3>

              <div className="productos-detalle-grid">
                <div>
                  <strong>Unidad de empaquetamiento</strong>
                  <span>
                    {mostrar(producto.UnidadEmpaquetamiento)}
                  </span>
                </div>

                <div>
                  <strong>ID de unidad</strong>
                  <span>
                    {mostrar(producto.IdUnidadEmpaquetamiento)}
                  </span>
                </div>

                <div>
                  <strong>Empaquetamiento exterior</strong>
                  <span>
                    {mostrar(producto.Empaquetamiento)}
                  </span>
                </div>

                <div>
                  <strong>ID de empaquetamiento</strong>
                  <span>
                    {mostrar(producto.IdEmpaquetamiento)}
                  </span>
                </div>

                <div>
                  <strong>Cantidad por empaque</strong>
                  <span>
                    {mostrar(producto.CantidadEmpaquetamiento)}
                  </span>
                </div>
              </div>

              <h3 className="productos-seccion-titulo">
                Precios
              </h3>

              <div className="productos-detalle-grid">
                <div>
                  <strong>Precio unitario</strong>
                  <span>{mostrarPrecio(producto.PrecioUnitario)}</span>
                </div>

                <div>
                  <strong>Precio de venta</strong>
                  <span>{mostrarPrecio(producto.PrecioVenta)}</span>
                </div>

                <div>
                <strong>Impuesto (%)</strong>
                <span>
                    {producto.Impuesto == null
                    ? 'No especificado'
                    : `${mostrar(producto.Impuesto)} %`}
                </span>
                </div>
              </div>
            </>
          )}
        </div>

        <footer className="productos-modal-pie">
          <button
            type="button"
            className="productos-boton-secundario"
            onClick={alCerrar}
          >
            Cerrar
          </button>
        </footer>
      </section>
    </div>
  );
}
