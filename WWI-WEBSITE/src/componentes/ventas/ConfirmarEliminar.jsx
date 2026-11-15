
import { useState } from 'react';
import { eliminarVenta } from '../../servicios/ventas';

export default function ConfirmarEliminar({
  venta,
  alCerrar,
  alEliminar
}) {
  const [eliminando, setEliminando] = useState(false);
  const [error, setError] = useState('');

  async function confirmar() {
    if (eliminando) return;

    setEliminando(true);
    setError('');

    try {
      const respuesta = await eliminarVenta(venta.id);

      alEliminar(
        respuesta?.mensaje || 'Factura eliminada correctamente.'
      );
    } catch (err) {
      setError(
        err.message || 'No se pudo eliminar la factura.'
      );
    } finally {
      setEliminando(false);
    }
  }

  return (
    <div
      className="ventas-modal-fondo"
      onMouseDown={evento => {
        if (
          evento.target === evento.currentTarget &&
          !eliminando
        ) {
          alCerrar();
        }
      }}
    >
      <section
        className="ventas-modal ventas-modal-confirmacion"
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="titulo-eliminar-venta"
        aria-describedby="descripcion-eliminar-venta"
      >
        <header className="ventas-modal-encabezado">
          <div>
            <h2 id="titulo-eliminar-venta">
              Eliminar factura
            </h2>

            <p>Confirmación de eliminación</p>
          </div>

          <button
            type="button"
            className="ventas-modal-cerrar"
            onClick={alCerrar}
            disabled={eliminando}
            aria-label="Cerrar confirmación"
          >
            ×
          </button>
        </header>

        <div className="ventas-modal-contenido">
          <p id="descripcion-eliminar-venta">
            ¿Estás seguro de que querés eliminar la factura
            <strong> #{venta.id}</strong>
            {venta.nombre && (
              <> del cliente <strong>{venta.nombre}</strong></>
            )}
            ?
          </p>

          <p className="ventas-advertencia">
            Esta operación eliminará la factura y sus líneas
            de venta. Según el procedimiento almacenado,
            también podría modificar las existencias del
            inventario.
          </p>

          <p className="ventas-advertencia">
            Esta acción no se puede deshacer desde la interfaz.
            Verificá que sea la factura correcta antes de
            continuar.
          </p>

          {error && (
            <p className="ventas-error" role="alert">
              {error}
            </p>
          )}
        </div>

        <footer className="ventas-modal-pie">
          <button
            type="button"
            className="ventas-boton-secundario"
            onClick={alCerrar}
            disabled={eliminando}
          >
            Cancelar
          </button>

          <button
            type="button"
            className="ventas-boton-peligro"
            onClick={confirmar}
            disabled={eliminando}
          >
            {eliminando ? 'Eliminando...' : 'Sí, eliminar'}
          </button>
        </footer>
      </section>
    </div>
  );
}
