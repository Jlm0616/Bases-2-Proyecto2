
import { useEffect, useState } from 'react';
import {
  obtenerDetalleCliente,
  crearCliente,
  actualizarCliente
} from '../../servicios/clientes';

const camposPublicos = [
  { nombre: 'NombreCliente', etiqueta: 'Nombre del cliente', tipo: 'text', requerido: true, max: 100 },
  { nombre: 'IdCategoria', etiqueta: 'ID de categoría', tipo: 'numero', requerido: true },
  { nombre: 'IdGrupoCompra', etiqueta: 'ID de grupo de compra', tipo: 'numero' },
  { nombre: 'IdClienteFacturar', etiqueta: 'ID de cliente a facturar', tipo: 'numero' },
  { nombre: 'FechaApertura', etiqueta: 'Fecha de apertura', tipo: 'fecha', soloCrear: true },
  { nombre: 'DiasGraciaPago', etiqueta: 'Días de gracia para pago', tipo: 'numero' }
];

const camposPrivados = [
  { nombre: 'IdContactoPrimario', etiqueta: 'ID de contacto primario', tipo: 'numero', requerido: true },
  { nombre: 'IdContactoAlternativo', etiqueta: 'ID de contacto alternativo', tipo: 'numero' },
  { nombre: 'IdMetodoEntrega', etiqueta: 'ID de método de entrega', tipo: 'numero', requerido: true },
  { nombre: 'IdCiudadEntrega', etiqueta: 'ID de ciudad de entrega', tipo: 'numero', requerido: true },
  { nombre: 'IdCiudadPostal', etiqueta: 'ID de ciudad postal', tipo: 'numero' },
  { nombre: 'LimiteCredito', etiqueta: 'Límite de crédito', tipo: 'decimal' },
  { nombre: 'Telefono', etiqueta: 'Teléfono', tipo: 'text', max: 20 },
  { nombre: 'Fax', etiqueta: 'Fax', tipo: 'text', max: 20 },
  { nombre: 'SitioWeb', etiqueta: 'Sitio web', tipo: 'text', max: 256 },
  { nombre: 'DireccionEntregaLinea1', etiqueta: 'Dirección de entrega 1', tipo: 'text', max: 60 },
  { nombre: 'DireccionEntregaLinea2', etiqueta: 'Dirección de entrega 2', tipo: 'text', max: 60 },
  { nombre: 'CodigoPostalEntrega', etiqueta: 'Código postal de entrega', tipo: 'text', max: 10 },
  { nombre: 'DireccionPostalLinea1', etiqueta: 'Dirección postal 1', tipo: 'text', max: 60 },
  { nombre: 'DireccionPostalLinea2', etiqueta: 'Dirección postal 2', tipo: 'text', max: 60 },
  { nombre: 'CodigoPostalPostal', etiqueta: 'Código postal postal', tipo: 'text', max: 10 }
];

function valoresIniciales(campos) {
  return Object.fromEntries(campos.map(campo => [campo.nombre, '']));
}

function normalizarFecha(valor) {
  if (!valor) return '';
  return String(valor).slice(0, 10);
}

function normalizarDatos(datos, campos) {
  return Object.fromEntries(
    campos.map(campo => {
      let valor = datos?.[campo.nombre];

      if (campo.tipo === 'fecha') {
        valor = normalizarFecha(valor);
      }

      return [campo.nombre, valor ?? ''];
    })
  );
}

function convertirDatos(datos, campos) {
  return Object.fromEntries(
    campos.map(campo => {
      const valor = datos[campo.nombre];

      if (campo.tipo === 'numero' || campo.tipo === 'decimal') {
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

function GrupoCampos({ campos, valores, cambiar, esEdicion }) {
  return (
    <div className="clientes-formulario-grid">
      {campos
        .filter(campo => !esEdicion || !campo.soloCrear)
        .map(campo => (
          <div className="clientes-campo" key={campo.nombre}>
            <label htmlFor={`cliente-${campo.nombre}`}>
              {campo.etiqueta}
              {campo.requerido && ' *'}
            </label>

            <input
              id={`cliente-${campo.nombre}`}
              type={
                campo.tipo === 'numero' || campo.tipo === 'decimal'
                  ? 'number'
                  : campo.tipo === 'fecha'
                    ? 'date'
                    : 'text'
              }
              min={campo.tipo === 'numero' ? (campo.requerido ? 1 : 0) : undefined}
              step={campo.tipo === 'decimal' ? '0.01' : campo.tipo === 'numero' ? '1' : undefined}
              maxLength={campo.max}
              required={campo.requerido}
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

export default function FormularioCliente({
  idCliente = null,
  alCerrar,
  alGuardar
}) {
  const esEdicion = idCliente !== null;

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
        const respuesta = await obtenerDetalleCliente(idCliente);

        if (!activo) return;

        setPublicos(
          normalizarDatos(
            respuesta.cliente.datosPublicos,
            camposPublicos
          )
        );

        setPrivados(
          normalizarDatos(
            respuesta.cliente.datosPrivados,
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
    return () => { activo = false; };
  }, [idCliente, esEdicion]);

  function cambiarPublico(nombre, valor) {
    setPublicos(actual => ({ ...actual, [nombre]: valor }));
  }

  function cambiarPrivado(nombre, valor) {
    setPrivados(actual => ({ ...actual, [nombre]: valor }));
  }

  async function guardar(evento) {
    evento.preventDefault();
    if (guardando || cargando) return;

    const datosPublicos = convertirDatos(publicos, camposPublicos);
    const datosPrivados = convertirDatos(privados, camposPrivados);

    if (
      !datosPublicos.NombreCliente ||
      !Number.isInteger(datosPublicos.IdCategoria) ||
      datosPublicos.IdCategoria <= 0 ||
      !Number.isInteger(datosPrivados.IdContactoPrimario) ||
      datosPrivados.IdContactoPrimario <= 0 ||
      !Number.isInteger(datosPrivados.IdMetodoEntrega) ||
      datosPrivados.IdMetodoEntrega <= 0 ||
      !Number.isInteger(datosPrivados.IdCiudadEntrega) ||
      datosPrivados.IdCiudadEntrega <= 0
    ) {
      setError('Completá los campos obligatorios con valores válidos.');
      return;
    }

    setGuardando(true);
    setError('');

    try {
      const respuesta = esEdicion
        ? await actualizarCliente(
            idCliente,
            datosPublicos,
            datosPrivados
          )
        : await crearCliente(datosPublicos, datosPrivados);

      alGuardar(respuesta.mensaje || 'Operación completada.');
    } catch (err) {
      setError(
        `${err.message}. Si la operación se ejecutó parcialmente, revisá las bases de datos antes de reintentar.`
      );
    } finally {
      setGuardando(false);
    }
  }

  return (
    <div className="clientes-modal-fondo">
      <div
        className="clientes-modal clientes-modal-formulario"
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-formulario-cliente"
      >
        <header className="clientes-modal-encabezado">
          <div>
            <h2 id="titulo-formulario-cliente">
              {esEdicion ? 'Editar cliente' : 'Nuevo cliente'}
            </h2>
            <p>
              {esEdicion
                ? `Cliente #${idCliente}`
                : 'Registrar cliente en Sucursal y Corporativo'}
            </p>
          </div>

          <button
            type="button"
            className="clientes-modal-cerrar"
            onClick={alCerrar}
            disabled={guardando}
            aria-label="Cerrar formulario"
          >
            ×
          </button>
        </header>

        {cargando ? (
          <div className="clientes-modal-contenido">
            <p>Cargando información del cliente...</p>
            {error && <p className="clientes-error">{error}</p>}
          </div>
        ) : (
          <form onSubmit={guardar} className="clientes-formulario">
            <div className="clientes-modal-contenido">
              {error && (
                <p className="clientes-error" role="alert">
                  {error}
                </p>
              )}

              <section className="clientes-detalle-seccion">
                <h3>Datos generales — Sucursal</h3>
                <GrupoCampos
                  campos={camposPublicos}
                  valores={publicos}
                  cambiar={cambiarPublico}
                  esEdicion={esEdicion}
                />
              </section>

              <section className="clientes-detalle-seccion">
                <h3>Datos privados — Corporativo</h3>
                <GrupoCampos
                  campos={camposPrivados}
                  valores={privados}
                  cambiar={cambiarPrivado}
                  esEdicion={esEdicion}
                />
              </section>

              <p className="clientes-formulario-nota">
                * Campos obligatorios. Los identificadores deben existir
                en los catálogos correspondientes de SQL Server.
              </p>
            </div>

            <footer className="clientes-modal-pie">
              <button
                type="button"
                className="clientes-boton-secundario"
                onClick={alCerrar}
                disabled={guardando}
              >
                Cancelar
              </button>

              <button
                type="submit"
                className="clientes-boton-principal"
                disabled={guardando}
              >
                {guardando
                  ? 'Guardando...'
                  : esEdicion
                    ? 'Guardar cambios'
                    : 'Crear cliente'}
              </button>
            </footer>
          </form>
        )}
      </div>
    </div>
  );
}
