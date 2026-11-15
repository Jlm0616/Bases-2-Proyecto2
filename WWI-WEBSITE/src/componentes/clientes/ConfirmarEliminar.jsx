
import { useState } from 'react';
import { eliminarCliente } from '../../servicios/clientes';

export default function ConfirmarEliminar({
  cliente,
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
      const respuesta = await eliminarCliente(cliente.IdCliente);
      alEliminar(
        respuesta.mensaje || 'Cliente eliminado correctamente.'
      );
    } catch (err) {
      setError(
        `${err.message}. Verificá el estado del cliente antes de reintentar.`
      );
    } finally {
      setEliminando(false);
    }
  }

  return (
    <div className="clientes-modal-fondo">
      <div
        className="clientes-modal clientes-modal-confirmacion"
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="titulo-eliminar-cliente"
        aria-describedby="descripcion-eliminar-cliente"
      >
        <header className="clientes-modal-encabezado">
          <div>
            <h2 id="titulo-eliminar-cliente">
              Eliminar cliente
            </h2>
            <p>Confirmación de eliminación</p>
          </div>
        </header>

        <div className="clientes-modal-contenido">
          <p id="descripcion-eliminar-cliente">
            ¿Estás seguro de eliminar al cliente
            <strong> {cliente.NombreCliente}</strong>
            {' '}(ID {cliente.IdCliente})?
          </p>

          <p>
            Esta operación intenta eliminar sus datos de
            Corporativo y de la sucursal.
          </p>

          <p className="clientes-advertencia">
            Esta acción no se puede deshacer desde la interfaz.
            Usala únicamente con registros de prueba.
          </p>

          {error && (
            <p className="clientes-error" role="alert">
              {error}
            </p>
          )}
        </div>

        <footer className="clientes-modal-pie">
          <button
            type="button"
            className="clientes-boton-secundario"
            onClick={alCerrar}
            disabled={eliminando}
          >
            Cancelar
          </button>

          <button
            type="button"
            className="clientes-boton-peligro"
            onClick={confirmar}
            disabled={eliminando}
          >
            {eliminando ? 'Eliminando...' : 'Sí, eliminar'}
          </button>
        </footer>
      </div>
    </div>
  );
}
