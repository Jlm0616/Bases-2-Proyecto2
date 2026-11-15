
import { useEffect, useState } from 'react';
import { obtenerDetalleProveedor } from '../../servicios/proveedores';

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

const camposPrivadosVisibles = [
  'IdContactoPrimario',
  'IdContactoAlternativo',
  'IdMetodoEntrega',
  'MetodoEntrega',
  'IdCiudadEntrega',
  'CiudadEntrega',
  'IdCiudadPostal',
  'CiudadPostal',
  'Telefono',
  'Fax',
  'SitioWeb',
  'DireccionEntregaLinea1',
  'DireccionEntregaLinea2',
  'CodigoPostalEntrega',
  'UbicacionEntregaMapa',
  'DireccionPostalLinea1',
  'DireccionPostalLinea2',
  'CodigoPostalPostal'
];

function filtrarDatosPrivados(datos) {
  if (!datos) return null;

  return Object.fromEntries(
    Object.entries(datos).filter(([campo]) =>
      camposPrivadosVisibles.includes(campo)
    )
  );
}

function SeccionDatos({ titulo, datos }) {
  if (!datos || Object.keys(datos).length === 0) {
    return <p>No hay información disponible.</p>;
  }

  return (
    <section className="proveedores-detalle-seccion">
      <h3>{titulo}</h3>

      <div className="proveedores-detalle-grid">
        {Object.entries(datos).map(([campo, valor]) => (
          <div className="proveedores-detalle-campo" key={campo}>
            <span className="proveedores-detalle-etiqueta">
              {campo.replace(/([a-z])([A-Z])/g, '$1 $2')}
            </span>

            <span className="proveedores-detalle-valor">
              {formatearValor(valor)}
            </span>
          </div>
        ))}
      </div>
    </section>
  );
}

export default function DetalleProveedor({
  idProveedor,
  alCerrar
}) {
  const [detalle, setDetalle] = useState(null);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let activo = true;

    async function cargarDetalle() {
      setCargando(true);
      setError('');
      setDetalle(null);

      try {
        const respuesta = await obtenerDetalleProveedor(idProveedor);

        if (activo) {
          setDetalle(respuesta.proveedor);
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
  }, [idProveedor]);

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

  const datosPrivados = filtrarDatosPrivados(
    detalle?.datosPrivados
  );

  return (
    <div
      className="proveedores-modal-fondo"
      onMouseDown={(evento) => {
        if (evento.target === evento.currentTarget) {
          alCerrar();
        }
      }}
    >
      <div
        className="proveedores-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-detalle-proveedor"
      >
        <header className="proveedores-modal-encabezado">
          <div>
            <h2 id="titulo-detalle-proveedor">
              Detalle del proveedor
            </h2>
            <p>Proveedor #{idProveedor}</p>
          </div>

          <button
            type="button"
            className="proveedores-modal-cerrar"
            onClick={alCerrar}
            aria-label="Cerrar detalle"
          >
            ×
          </button>
        </header>

        <div className="proveedores-modal-contenido">
          {cargando && (
            <p>Cargando detalle del proveedor...</p>
          )}

          {error && (
            <p className="proveedores-error" role="alert">
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
                titulo="Datos de contacto — Corporativo"
                datos={datosPrivados}
              />
            </>
          )}

          {!cargando && !error && !detalle && (
            <p>No se encontró información del proveedor.</p>
          )}
        </div>

        <footer className="proveedores-modal-pie">
          <button
            type="button"
            className="proveedores-boton-secundario"
            onClick={alCerrar}
          >
            Cerrar
          </button>
        </footer>
      </div>
    </div>
  );
}
