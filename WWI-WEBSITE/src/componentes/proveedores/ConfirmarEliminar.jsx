
import { useState } from 'react';
import { eliminarProveedor } from '../../servicios/proveedores';

export default function ConfirmarEliminar({
  proveedor,
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
      const respuesta = await eliminarProveedor(
        proveedor.IdProveedor
      );

      alEliminar(
        respuesta.mensaje || 'Proveedor eliminado correctamente.'
      );
    } catch (err) {
      setError(
        `${err.message}. Verificá el estado del proveedor ` +
        'en ambas bases de datos antes de reintentar.'
      );
    } finally {
      setEliminando(false);
    }
  }

  return (
    <div className="proveedores-modal-fondo">
      <div
        className="proveedores-modal proveedores-modal-confirmacion"
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="titulo-eliminar-proveedor"
        aria-describedby="descripcion-eliminar-proveedor"
      >
        <header className="proveedores-modal-encabezado">
          <div>
            <h2 id="titulo-eliminar-proveedor">
              Eliminar proveedor
            </h2>
            <p>Confirmación de eliminación</p>
          </div>
        </header>

        <div className="proveedores-modal-contenido">
          <p id="descripcion-eliminar-proveedor">
            ¿Estás seguro de eliminar al proveedor
            <strong> {proveedor.NombreProveedor}</strong>
            {' '}(ID {proveedor.IdProveedor})?
          </p>

          <p>
            Esta operación intenta eliminar sus datos
            de la sucursal y de Corporativo.
          </p>

          <p className="proveedores-advertencia">
            Esta acción no se puede deshacer desde la interfaz.
            Usala únicamente con registros de prueba.
          </p>

          {error && (
            <p className="proveedores-error" role="alert">
              {error}
            </p>
          )}
        </div>

        <footer className="proveedores-modal-pie">
          <button
            type="button"
            className="proveedores-boton-secundario"
            onClick={alCerrar}
            disabled={eliminando}
          >
            Cancelar
          </button>

          <button
            type="button"
            className="proveedores-boton-peligro"
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
