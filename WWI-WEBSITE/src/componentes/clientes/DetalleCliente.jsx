
import { useEffect, useState } from 'react';
import { obtenerDetalleCliente } from '../../servicios/clientes';

function formatearValor(valor) {
  if (valor === null || valor === undefined || valor === '') {
    return '—';
  }

  if (typeof valor === 'boolean') {
    return valor ? 'Sí' : 'No';
  }

  if (typeof valor === 'object') {
    return JSON.stringify(valor);
  }

  return String(valor);
}

function SeccionDatos({ titulo, datos }) {
  if (!datos || Object.keys(datos).length === 0) {
    return <p>No hay información disponible.</p>;
  }

  return (
    <section className="clientes-detalle-seccion">
      <h3>{titulo}</h3>

      <div className="clientes-detalle-grid">
        {Object.entries(datos).map(([campo, valor]) => (
          <div className="clientes-detalle-campo" key={campo}>
            <span className="clientes-detalle-etiqueta">
              {campo.replace(/([a-z])([A-Z])/g, '$1 $2')}
            </span>

            <span className="clientes-detalle-valor">
              {formatearValor(valor)}
            </span>
          </div>
        ))}
      </div>
    </section>
  );
}

export default function DetalleCliente({ idCliente, alCerrar }) {
  const [detalle, setDetalle] = useState(null);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let activo = true;

    async function cargarDetalle() {
      setCargando(true);
      setError('');

      try {
        const respuesta = await obtenerDetalleCliente(idCliente);

        if (activo) {
          setDetalle(respuesta.cliente);
        }
      } catch (error) {
        if (activo) {
          setError(error.message);
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
  }, [idCliente]);

  useEffect(() => {
    function manejarTecla(evento) {
      if (evento.key === 'Escape') {
        alCerrar();
      }
    }

    window.addEventListener('keydown', manejarTecla);

    return () => {
      window.removeEventListener('keydown', manejarTecla);
    };
  }, [alCerrar]);

  return (
    <div
      className="clientes-modal-fondo"
      onMouseDown={(evento) => {
        if (evento.target === evento.currentTarget) {
          alCerrar();
        }
      }}
    >
      <div
        className="clientes-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-detalle-cliente"
      >
        <header className="clientes-modal-encabezado">
          <div>
            <h2 id="titulo-detalle-cliente">
              Detalle del cliente
            </h2>
            <p>Cliente #{idCliente}</p>
          </div>

          <button
            type="button"
            className="clientes-modal-cerrar"
            onClick={alCerrar}
            aria-label="Cerrar detalle"
          >
            ×
          </button>
        </header>

        <div className="clientes-modal-contenido">
          {cargando && <p>Cargando detalle del cliente...</p>}

          {error && (
            <p className="clientes-error" role="alert">
              {error}
            </p>
          )}

          {!cargando && !error && detalle && (
            <>
              <SeccionDatos
                titulo="Datos generales — Sucursal"
                datos={detalle.datosPublicos}
              />

              <SeccionDatos
                titulo="Datos privados — Corporativo"
                datos={detalle.datosPrivados}
              />
            </>
          )}
        </div>

        <footer className="clientes-modal-pie">
          <button
            type="button"
            className="clientes-boton-secundario"
            onClick={alCerrar}
          >
            Cerrar
          </button>
        </footer>
      </div>
    </div>
  );
}
