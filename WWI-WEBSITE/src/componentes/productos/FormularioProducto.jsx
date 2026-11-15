
import { useEffect, useState } from 'react';
import {
  crearProducto,
  actualizarProducto,
  obtenerDetalleProducto
} from '../../servicios/productos';

const inicial = {
  Nombre: '',
  ProveedorID: '',
  ColorID: '',
  UnidadEmpaqueID: '',
  EmpaqueExteriorID: '',
  Marca: '',
  Tamano: '',
  DiasEntrega: '',
  CantidadPorEmpaque: '',
  RequiereRefrigeracion: false,
  CodigoBarras: '',
  Impuesto: '',
  PrecioUnitario: '',
  PrecioVenta: '',
  Peso: ''
};

const campos = [
  { nombre: 'Nombre', etiqueta: 'Nombre del producto', tipo: 'text', requerido: true, max: 100 },
  { nombre: 'ProveedorID', etiqueta: 'ID del proveedor (catálogo)', tipo: 'number', requerido: true, min: 1, paso: 1 },
  { nombre: 'ColorID', etiqueta: 'ID del color (opcional, catálogo)', tipo: 'number', min: 1, paso: 1 },
  { nombre: 'UnidadEmpaqueID', etiqueta: 'ID de unidad de empaque (catálogo)', tipo: 'number', requerido: true, min: 1, paso: 1 },
  { nombre: 'EmpaqueExteriorID', etiqueta: 'ID de empaque exterior (catálogo)', tipo: 'number', requerido: true, min: 1, paso: 1 },
  { nombre: 'Marca', etiqueta: 'Marca (opcional)', tipo: 'text', max: 50 },
  { nombre: 'Tamano', etiqueta: 'Tamaño (opcional)', tipo: 'text', max: 20 },
  { nombre: 'DiasEntrega', etiqueta: 'Plazo de entrega (días)', tipo: 'number', requerido: true, min: 0, paso: 1 },
  { nombre: 'CantidadPorEmpaque', etiqueta: 'Unidades por empaque', tipo: 'number', requerido: true, min: 1, paso: 1 },
  { nombre: 'CodigoBarras', etiqueta: 'Código de barras (opcional)', tipo: 'text', max: 50 },
  { nombre: 'Impuesto', etiqueta: 'Impuesto (%)', tipo: 'number', requerido: true, min: 0, paso: '0.001' },
  { nombre: 'PrecioUnitario', etiqueta: 'Precio unitario', tipo: 'number', requerido: true, min: 0, paso: '0.01' },
  { nombre: 'PrecioVenta', etiqueta: 'Precio de venta recomendado (opcional)', tipo: 'number', min: 0, paso: '0.01' },
  { nombre: 'Peso', etiqueta: 'Peso por unidad (kg)', tipo: 'number', requerido: true, min: 0, paso: '0.001' }
];

const enteros = new Set([
  'ProveedorID',
  'ColorID',
  'UnidadEmpaqueID',
  'EmpaqueExteriorID',
  'DiasEntrega',
  'CantidadPorEmpaque'
]);

const numeros = new Set([
  ...enteros,
  'Impuesto',
  'PrecioUnitario',
  'PrecioVenta',
  'Peso'
]);

function convertirFormulario(producto) {
  const valores = {
    Nombre: producto.NombreProducto,
    ProveedorID: producto.IdProveedor,
    ColorID: producto.IdColor,
    UnidadEmpaqueID: producto.IdUnidadEmpaquetamiento,
    EmpaqueExteriorID: producto.IdEmpaquetamiento,
    Marca: producto.Marca,
    Tamano: producto.TallaTamano,
    DiasEntrega: producto.DiasEntrega,
    CantidadPorEmpaque: producto.CantidadEmpaquetamiento,
    RequiereRefrigeracion: producto.RequiereRefrigeracion,
    CodigoBarras: producto.CodigoBarras,
    Impuesto: producto.Impuesto,
    PrecioUnitario: producto.PrecioUnitario,
    PrecioVenta: producto.PrecioVenta,
    Peso: producto.Peso
  };

  const resultado = {};

  for (const clave of Object.keys(inicial)) {
    if (clave === 'RequiereRefrigeracion') {
      resultado[clave] =
        valores[clave] === true ||
        valores[clave] === 1;
    } else {
      resultado[clave] =
        valores[clave] === null ||
        valores[clave] === undefined
          ? ''
          : String(valores[clave]);
    }
  }

  return resultado;
}

export default function FormularioProducto({
  alCerrar,
  alGuardar,
  productoId = null
}) {
  const editando = productoId !== null && productoId !== undefined;

  const [datos, setDatos] = useState({ ...inicial });
  const [cargando, setCargando] = useState(editando);
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    let activo = true;

    if (!editando) {
      setDatos({ ...inicial });
      setCargando(false);
      setError('');
      return;
    }

    async function cargarProducto() {
      setCargando(true);
      setError('');

      try {
        const respuesta = await obtenerDetalleProducto(productoId);
        const producto = respuesta.producto;

        if (!producto) {
          throw new Error('No se encontró el producto');
        }

        if (activo) {
          setDatos(convertirFormulario(producto));
        }
      } catch (err) {
        if (activo) {
          setError(
            err.message || 'No se pudo cargar el producto'
          );
        }
      } finally {
        if (activo) {
          setCargando(false);
        }
      }
    }

    cargarProducto();

    return () => {
      activo = false;
    };
  }, [productoId, editando]);

  function cambiar(evento) {
    const { name, value, type, checked } = evento.target;

    setDatos(actual => ({
      ...actual,
      [name]: type === 'checkbox' ? checked : value
    }));
  }

  async function guardar(evento) {
    evento.preventDefault();

    if (guardando || cargando) return;

    setError('');

    const payload = {};

    for (const [clave, valor] of Object.entries(datos)) {
      if (clave === 'RequiereRefrigeracion') {
        payload[clave] = valor;
      } else if (numeros.has(clave)) {
        if (valor === '') {
          payload[clave] = null;
        } else {
          const numero = Number(valor);

          if (
            !Number.isFinite(numero) ||
            (enteros.has(clave) && !Number.isInteger(numero))
          ) {
            setError(`Valor numérico no válido: ${clave}`);
            return;
          }

          payload[clave] = numero;
        }
      } else {
        payload[clave] = valor.trim() || null;
      }
    }

    setGuardando(true);

    try {
      if (editando) {
        await actualizarProducto(productoId, payload);
        alGuardar('Producto actualizado correctamente');
      } else {
        await crearProducto(payload);
        alGuardar('Producto creado correctamente');
      }
    } catch (err) {
      setError(
        err.message ||
        (editando
          ? 'No se pudo actualizar el producto'
          : 'No se pudo crear el producto')
      );
    } finally {
      setGuardando(false);
    }
  }

  return (
    <div
      className="productos-modal-fondo"
      onMouseDown={evento => {
        if (
          evento.target === evento.currentTarget &&
          !guardando
        ) {
          alCerrar();
        }
      }}
    >
      <section
        className="productos-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-formulario-producto"
      >
        <header className="productos-modal-encabezado">
          <div>
            <h2 id="titulo-formulario-producto">
              {editando ? 'Editar producto' : 'Nuevo producto'}
            </h2>

            <p>
              {editando
                ? `Modificá la información del producto #${productoId}.`
                : 'Registrá un producto en el catálogo.'}
            </p>
          </div>

          <button
            type="button"
            className="productos-modal-cerrar"
            onClick={alCerrar}
            disabled={guardando}
            aria-label="Cerrar"
          >
            ×
          </button>
        </header>

        <form
          onSubmit={guardar}
          className="productos-modal-contenido"
          id="formulario-producto"
        >
          {error && (
            <p className="productos-error" role="alert">
              {error}
            </p>
          )}

          {cargando ? (
            <p>Cargando información del producto...</p>
          ) : (
            <>
              <p
                style={{
                  marginTop: 0,
                  marginBottom: '18px',
                  color: '#475569',
                  fontSize: '13px'
                }}
              >
                Los IDs de proveedor, color y empaquetamiento
                deben corresponder a registros existentes en
                los catálogos. Los campos sin la indicación
                «opcional» son obligatorios.
              </p>

              <div className="productos-detalle-grid">
                {campos.map(campo => (
                  <div
                    className="productos-campo"
                    key={campo.nombre}
                  >
                    <label htmlFor={`producto-${campo.nombre}`}>
                      {campo.etiqueta}
                    </label>

                    <input
                      id={`producto-${campo.nombre}`}
                      name={campo.nombre}
                      type={campo.tipo}
                      value={datos[campo.nombre]}
                      onChange={cambiar}
                      required={Boolean(campo.requerido)}
                      min={campo.min}
                      step={campo.paso}
                      maxLength={campo.max}
                      disabled={guardando}
                    />
                  </div>
                ))}

                <label className="productos-campo">
                  <span>Requiere refrigeración</span>

                  <input
                    type="checkbox"
                    name="RequiereRefrigeracion"
                    checked={datos.RequiereRefrigeracion}
                    onChange={cambiar}
                    disabled={guardando}
                  />
                </label>
              </div>
            </>
          )}
        </form>

        <footer
          className="productos-modal-pie"
          style={{ gap: '12px' }}
        >
          <button
            type="button"
            className="productos-boton-secundario"
            onClick={alCerrar}
            disabled={guardando}
          >
            Cancelar
          </button>

          <button
            type="submit"
            form="formulario-producto"
            className="productos-boton-principal"
            disabled={guardando || cargando || Boolean(error && cargando)}
          >
            {guardando
              ? 'Guardando...'
              : editando
                ? 'Guardar cambios'
                : 'Crear producto'}
          </button>
        </footer>
      </section>
    </div>
  );
}
