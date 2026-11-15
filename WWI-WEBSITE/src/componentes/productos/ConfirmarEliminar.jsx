
import { useState } from 'react';
import { eliminarProducto } from '../../servicios/productos';

export default function ConfirmarEliminar({
  producto,
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
      const respuesta = await eliminarProducto(producto.id);

      alEliminar(
        respuesta?.mensaje || 'Producto eliminado correctamente.'
      );
    } catch (err) {
      setError(
        err.message || 'No se pudo eliminar el producto.'
      );
    } finally {
      setEliminando(false);
    }
  }

  return (
    <div
      className="productos-modal-fondo"
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
        className="productos-modal productos-modal-confirmacion"
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="titulo-eliminar-producto"
        aria-describedby="descripcion-eliminar-producto"
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
            onClick={alCerrar}
            disabled={eliminando}
            aria-label="Cerrar confirmación"
          >
            ×
          </button>
        </header>

        <div className="productos-modal-contenido">
          <p id="descripcion-eliminar-producto">
            ¿Estás seguro de que querés eliminar el producto
            <strong> {producto.nombre}</strong>
            {' '}(ID: {producto.id})?
          </p>

          <p className="productos-advertencia">
            Esta operación puede afectar el catálogo de productos.
            Si el producto tiene registros relacionados, la base
            de datos podría impedir su eliminación.
          </p>

          {error && (
            <p className="productos-error" role="alert">
              {error}
            </p>
          )}
        </div>

        <footer className="productos-modal-pie">
          <button
            type="button"
            className="productos-boton-secundario"
            onClick={alCerrar}
            disabled={eliminando}
          >
            Cancelar
          </button>

          <button
            type="button"
            className="productos-boton-peligro"
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
