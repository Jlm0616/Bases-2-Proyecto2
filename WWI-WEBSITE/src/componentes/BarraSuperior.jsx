
import { useContext, useState } from 'react';
import { ContextoAutenticacion } from '../contextos/ContextoAutenticacion';
import '../estilos/barraSuperior.css';

/**
 * Barra superior compartida por Corporativo y Sucursales.
 */
export default function BarraSuperior() {
  const { usuario, cerrarSesion } = useContext(ContextoAutenticacion);

  const [cerrando, setCerrando] = useState(false);
  const [error, setError] = useState('');

  const nombresSucursal = {
    SanJose: 'San José',
    Limon: 'Limón',
    Corporativo: 'Corporativo'
  };

  async function manejarCierreSesion() {
    setError('');
    setCerrando(true);

    try {
      await cerrarSesion();
    } catch (error) {
      console.error('Error al cerrar sesión:', error);
      setError('No se pudo cerrar la sesión.');
    } finally {
      setCerrando(false);
    }
  }

  return (
    <header className="barra-superior">
      <div className="barra-superior-identidad">
        <span className="barra-superior-marca">WWI</span>
        <span className="barra-superior-sistema">
          WideWorldImporters
        </span>
      </div>

      <div className="barra-superior-usuario">
        <div className="barra-superior-datos">
          <strong>{usuario.nombreCompleto}</strong>

          <span>
            {usuario.rol} · {nombresSucursal[usuario.sucursal]}
          </span>
        </div>

        <button
          type="button"
          className="barra-superior-salir"
          onClick={manejarCierreSesion}
          disabled={cerrando}
        >
          {cerrando ? 'Cerrando...' : 'Cerrar sesión'}
        </button>
      </div>

      {error && (
        <p className="barra-superior-error" role="alert">
          {error}
        </p>
      )}
    </header>
  );
}
