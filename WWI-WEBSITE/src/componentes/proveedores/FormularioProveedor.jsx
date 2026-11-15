
import { useEffect, useState } from 'react';

import {
  obtenerDetalleProveedor,
  crearProveedor,
  actualizarProveedor
} from '../../servicios/proveedores';

const camposPublicos = [
  {
    nombre: 'SupplierName',
    campoSQL: 'NombreProveedor',
    etiqueta: 'Nombre del proveedor',
    tipo: 'text',
    requerido: true,
    max: 100
  },
  {
    nombre: 'SupplierReference',
    campoSQL: 'CodigoProveedor',
    etiqueta: 'Código del proveedor',
    tipo: 'text',
    max: 20
  },
  {
    nombre: 'SupplierCategoryID',
    campoSQL: 'IdCategoria',
    etiqueta: 'ID de categoría',
    tipo: 'numero',
    requerido: true
  },
  {
    nombre: 'PaymentDays',
    campoSQL: 'DiasGraciaPago',
    etiqueta: 'Días de gracia para pago',
    tipo: 'numero',
    requerido: true,
    permiteCero: true
  }
];

const camposPrivados = [
  {
    nombre: 'PrimaryContactPersonID',
    campoSQL: 'IdContactoPrimario',
    etiqueta: 'ID de contacto primario',
    tipo: 'numero',
    requerido: true
  },
  {
    nombre: 'AlternateContactPersonID',
    campoSQL: 'IdContactoAlternativo',
    etiqueta: 'ID de contacto alternativo',
    tipo: 'numero',
    requerido: true
  },
  {
    nombre: 'DeliveryMethodID',
    campoSQL: 'IdMetodoEntrega',
    etiqueta: 'ID de método de entrega',
    tipo: 'numero'
  },
  {
    nombre: 'DeliveryCityID',
    campoSQL: 'IdCiudadEntrega',
    etiqueta: 'ID de ciudad de entrega',
    tipo: 'numero',
    requerido: true
  },
  {
    nombre: 'PostalCityID',
    campoSQL: 'IdCiudadPostal',
    etiqueta: 'ID de ciudad postal',
    tipo: 'numero',
    requerido: true
  },
  {
    nombre: 'PhoneNumber',
    campoSQL: 'Telefono',
    etiqueta: 'Teléfono',
    tipo: 'text',
    requerido: true,
    max: 20
  },
  {
    nombre: 'FaxNumber',
    campoSQL: 'Fax',
    etiqueta: 'Fax',
    tipo: 'text',
    requerido: true,
    max: 20
  },
  {
    nombre: 'WebsiteURL',
    campoSQL: 'SitioWeb',
    etiqueta: 'Sitio web',
    tipo: 'text',
    requerido: true,
    max: 256
  },
  {
    nombre: 'DeliveryAddressLine1',
    campoSQL: 'DireccionEntregaLinea1',
    etiqueta: 'Dirección de entrega 1',
    tipo: 'text',
    requerido: true,
    max: 60
  },
  {
    nombre: 'DeliveryAddressLine2',
    campoSQL: 'DireccionEntregaLinea2',
    etiqueta: 'Dirección de entrega 2',
    tipo: 'text',
    max: 60
  },
  {
    nombre: 'DeliveryPostalCode',
    campoSQL: 'CodigoPostalEntrega',
    etiqueta: 'Código postal de entrega',
    tipo: 'text',
    requerido: true,
    max: 10
  },
  {
    nombre: 'PostalAddressLine1',
    campoSQL: 'DireccionPostalLinea1',
    etiqueta: 'Dirección postal 1',
    tipo: 'text',
    requerido: true,
    max: 60
  },
  {
    nombre: 'PostalAddressLine2',
    campoSQL: 'DireccionPostalLinea2',
    etiqueta: 'Dirección postal 2',
    tipo: 'text',
    max: 60
  },
  {
    nombre: 'PostalPostalCode',
    campoSQL: 'CodigoPostalPostal',
    etiqueta: 'Código postal postal',
    tipo: 'text',
    requerido: true,
    max: 10
  }
];

function valoresIniciales(campos) {
  return Object.fromEntries(
    campos.map(campo => [campo.nombre, ''])
  );
}

function normalizarDatos(datos, campos) {
  return Object.fromEntries(
    campos.map(campo => [
      campo.nombre,
      datos?.[campo.campoSQL] ?? ''
    ])
  );
}

function convertirDatos(datos, campos) {
  return Object.fromEntries(
    campos.map(campo => {
      const valor = datos[campo.nombre];

      if (campo.tipo === 'numero') {
        return [
          campo.nombre,
          valor === '' || valor === null
            ? null
            : Number(valor)
        ];
      }

      return [
        campo.nombre,
        typeof valor === 'string'
          ? valor.trim() || null
          : valor ?? null
      ];
    })
  );
}

function GrupoCampos({
  campos,
  valores,
  cambiar,
  deshabilitado
}) {
  return (
    <div className="proveedores-formulario-grid">
      {campos.map(campo => (
        <div className="proveedores-campo" key={campo.nombre}>
          <label htmlFor={`proveedor-${campo.nombre}`}>
            {campo.etiqueta}
            {campo.requerido && ' *'}
          </label>

          <input
            id={`proveedor-${campo.nombre}`}
            type={campo.tipo === 'numero' ? 'number' : 'text'}
            min={
              campo.tipo === 'numero'
                ? (campo.permiteCero ? 0 : 1)
                : undefined
            }
            step={campo.tipo === 'numero' ? 1 : undefined}
            maxLength={campo.max}
            required={campo.requerido}
            disabled={deshabilitado}
            value={valores[campo.nombre] ?? ''}
            onChange={evento =>
              cambiar(campo.nombre, evento.target.value)
            }
          />
        </div>
      ))}
    </div>
  );
}

export default function FormularioProveedor({
  idProveedor = null,
  alCerrar,
  alGuardar
}) {
  const esEdicion = idProveedor !== null;

  const [publicos, setPublicos] = useState(
    () => valoresIniciales(camposPublicos)
  );

  const [privados, setPrivados] = useState(
    () => valoresIniciales(camposPrivados)
  );

  const [cargando, setCargando] = useState(esEdicion);
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!esEdicion) return;

    let activo = true;

    async function cargar() {
      setCargando(true);
      setError('');

      try {
        const respuesta = await obtenerDetalleProveedor(idProveedor);

        if (!activo) return;

        if (!respuesta.proveedor?.datosPrivados) {
          throw new Error(
            'No se pudieron obtener los datos privados del proveedor.'
          );
        }

        setPublicos(
          normalizarDatos(
            respuesta.proveedor.datosPublicos,
            camposPublicos
          )
        );

        setPrivados(
          normalizarDatos(
            respuesta.proveedor.datosPrivados,
            camposPrivados
          )
        );
      } catch (err) {
        if (activo) setError(err.message);
      } finally {
        if (activo) setCargando(false);
      }
    }

    cargar();

    return () => {
      activo = false;
    };
  }, [idProveedor, esEdicion]);

  function cambiarPublico(nombre, valor) {
    setPublicos(actual => ({
      ...actual,
      [nombre]: valor
    }));
  }

  function cambiarPrivado(nombre, valor) {
    setPrivados(actual => ({
      ...actual,
      [nombre]: valor
    }));
  }

  async function guardar(evento) {
    evento.preventDefault();

    if (guardando || cargando) return;

    const datos = {
      ...convertirDatos(publicos, camposPublicos),
      ...convertirDatos(privados, camposPrivados)
    };

    const campos = [...camposPublicos, ...camposPrivados];

    const invalidos = campos.filter(campo => {
      if (!campo.requerido) return false;

      const valor = datos[campo.nombre];

      if (campo.tipo === 'numero') {
        return !Number.isInteger(valor) ||
          valor < (campo.permiteCero ? 0 : 1);
      }

      return !valor;
    });

    if (invalidos.length > 0) {
      setError(
        'Completá los campos obligatorios con valores válidos.'
      );
      return;
    }

    setGuardando(true);
    setError('');

    try {
      const respuesta = esEdicion
        ? await actualizarProveedor(idProveedor, datos)
        : await crearProveedor(datos);

      alGuardar(
        respuesta.mensaje || 'Operación completada.'
      );
    } catch (err) {
      setError(
        `${err.message}. Si la operación fue parcial, ` +
        'revisá las bases de datos antes de reintentar.'
      );
    } finally {
      setGuardando(false);
    }
  }

  return (
    <div className="proveedores-modal-fondo">
      <div
        className="proveedores-modal proveedores-modal-formulario"
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-formulario-proveedor"
      >
        <header className="proveedores-modal-encabezado">
          <div>
            <h2 id="titulo-formulario-proveedor">
              {esEdicion ? 'Editar proveedor' : 'Nuevo proveedor'}
            </h2>

            <p>
              {esEdicion
                ? `Proveedor #${idProveedor}`
                : 'Registrar proveedor en Sucursal y Corporativo'}
            </p>
          </div>

          <button
            type="button"
            className="proveedores-modal-cerrar"
            onClick={alCerrar}
            disabled={guardando}
            aria-label="Cerrar formulario"
          >
            ×
          </button>
        </header>

        {cargando ? (
          <div className="proveedores-modal-contenido">
            <p>Cargando información del proveedor...</p>
            {error && (
              <p className="proveedores-error" role="alert">
                {error}
              </p>
            )}
          </div>
        ) : (
          <form
            onSubmit={guardar}
            className="proveedores-formulario"
          >
            <div className="proveedores-modal-contenido">
              {error && (
                <p className="proveedores-error" role="alert">
                  {error}
                </p>
              )}

              <section className="proveedores-detalle-seccion">
                <h3>Datos generales — Sucursal</h3>

                <GrupoCampos
                  campos={camposPublicos}
                  valores={publicos}
                  cambiar={cambiarPublico}
                  deshabilitado={guardando}
                />
              </section>

              <section className="proveedores-detalle-seccion">
                <h3>Datos privados — Corporativo</h3>

                <GrupoCampos
                  campos={camposPrivados}
                  valores={privados}
                  cambiar={cambiarPrivado}
                  deshabilitado={guardando}
                />
              </section>

              <p className="proveedores-formulario-nota">
                * Campos obligatorios. Los identificadores deben
                existir en los catálogos correspondientes de SQL Server.
              </p>
            </div>

            <footer className="proveedores-modal-pie">
              <button
                type="button"
                className="proveedores-boton-secundario"
                onClick={alCerrar}
                disabled={guardando}
              >
                Cancelar
              </button>

              <button
                type="submit"
                className="proveedores-boton-principal"
                disabled={guardando || Boolean(error && esEdicion)}
              >
                {guardando
                  ? 'Guardando...'
                  : esEdicion
                    ? 'Guardar cambios'
                    : 'Crear proveedor'}
              </button>
            </footer>
          </form>
        )}
      </div>
    </div>
  );
}
