
import { useEffect, useState } from 'react';
import { obtenerDetalleVenta } from '../../servicios/ventas';

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

function mostrarFecha(valor) {
  if (!valor) return 'No especificado';

  return String(valor).slice(0, 10);
}

export default function DetalleVenta({ idVenta, alCerrar }) {
  const [venta, setVenta] = useState(null);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let activo = true;

    async function cargarDetalle() {
      setCargando(true);
      setError('');
      setVenta(null);

      try {
        const datos = await obtenerDetalleVenta(idVenta);

        if (activo) {
          setVenta(datos.venta);
        }
      } catch (err) {
        if (activo) {
          setError(
            err.message || 'No se pudo consultar la factura'
          );
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
  }, [idVenta]);

  const encabezado = venta?.encabezado;
  const lineas = venta?.lineas || [];

  const totalFactura = lineas.reduce(
    (total, linea) =>
      total + Number(linea.TotalPorLinea || 0),
    0
  );

  return (
    <div
      className="ventas-modal-fondo"
      onMouseDown={evento => {
        if (evento.target === evento.currentTarget) {
          alCerrar();
        }
      }}
    >
      <section
        className="ventas-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-detalle-venta"
      >
        <header className="ventas-modal-encabezado">
          <div>
            <h2 id="titulo-detalle-venta">
              Detalle de la factura
            </h2>

            <p>
              Información general y productos facturados.
            </p>
          </div>

          <button
            type="button"
            className="ventas-modal-cerrar"
            onClick={alCerrar}
            aria-label="Cerrar"
          >
            ×
          </button>
        </header>

        <div className="ventas-modal-contenido">
          {cargando && (
            <p>Cargando información de la factura...</p>
          )}

          {error && (
            <p className="ventas-error" role="alert">
              {error}
            </p>
          )}

          {!cargando && !error && !encabezado && (
            <p className="ventas-mensaje">
              No se encontró información de la factura.
            </p>
          )}

          {!cargando && !error && encabezado && (
            <>
              <h3 className="ventas-seccion-titulo">
                Información general
              </h3>

              <div className="ventas-detalle-grid">
                <div>
                  <strong>Número de factura</strong>
                  <span>
                    {mostrar(encabezado.NumeroFactura)}
                  </span>
                </div>

                <div>
                  <strong>Fecha de factura</strong>
                  <span>
                    {mostrarFecha(encabezado.FechaFactura)}
                  </span>
                </div>

                <div>
                  <strong>Cliente</strong>
                  <span>
                    {mostrar(encabezado.NombreCliente)}
                  </span>
                </div>

                <div>
                  <strong>Método de entrega</strong>
                  <span>
                    {mostrar(encabezado.MetodoEntrega)}
                  </span>
                </div>

                {encabezado.Sucursal && (
                  <div>
                    <strong>Sucursal</strong>
                    <span>
                      {mostrar(encabezado.Sucursal)}
                    </span>
                  </div>
                )}

                <div>
                  <strong>Número de orden de compra</strong>
                  <span>
                    {mostrar(encabezado.NumeroOrdenCompra)}
                  </span>
                </div>
              </div>

              <h3 className="ventas-seccion-titulo">
                Personas relacionadas
              </h3>

              <div className="ventas-detalle-grid">
                <div>
                  <strong>Persona de contacto</strong>
                  <span>
                    {mostrar(encabezado.PersonaContacto)}
                  </span>
                </div>

                <div>
                  <strong>Vendedor</strong>
                  <span>
                    {mostrar(encabezado.NombreVendedor)}
                  </span>
                </div>
              </div>

              <h3 className="ventas-seccion-titulo">
                Información de entrega
              </h3>

              <div className="ventas-detalle-grid">
                <div className="ventas-detalle-ancho">
                  <strong>Instrucciones de entrega</strong>
                  <span>
                    {mostrar(encabezado.InstruccionesEntrega)}
                  </span>
                </div>
              </div>

              <h3 className="ventas-seccion-titulo">
                Productos facturados
              </h3>

              <div className="ventas-tabla-contenedor">
                <table className="ventas-tabla">
                  <thead>
                    <tr>
                      <th>Producto</th>
                      <th>Cantidad</th>
                      <th>Precio unitario</th>
                      <th>Impuesto (%)</th>
                      <th>Monto impuesto</th>
                      <th>Total</th>
                    </tr>
                  </thead>

                  <tbody>
                    {lineas.length === 0 ? (
                      <tr>
                        <td
                          colSpan={6}
                          className="ventas-vacio"
                        >
                          Esta factura no tiene productos.
                        </td>
                      </tr>
                    ) : (
                      lineas.map((linea, indice) => (
                        <tr key={indice}>
                          <td className="ventas-nombre">
                            {mostrar(linea.NombreProducto)}
                          </td>

                          <td>
                            {mostrar(linea.Cantidad)}
                          </td>

                          <td>
                            {mostrarPrecio(linea.PrecioUnitario)}
                          </td>

                          <td>
                            {linea.ImpuestoAplicado == null
                              ? '—'
                              : `${linea.ImpuestoAplicado} %`}
                          </td>

                          <td>
                            {mostrarPrecio(linea.MontoImpuesto)}
                          </td>

                          <td>
                            {mostrarPrecio(linea.TotalPorLinea)}
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>

              <div className="ventas-detalle-total">
                <strong>Total de la factura</strong>
                <span>
                  {mostrarPrecio(totalFactura)}
                </span>
              </div>
            </>
          )}
        </div>

        <footer className="ventas-modal-pie">
          <button
            type="button"
            className="ventas-boton-secundario"
            onClick={alCerrar}
          >
            Cerrar
          </button>
        </footer>
      </section>
    </div>
  );
}
