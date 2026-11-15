
import { useEffect, useState } from 'react';

import {
  crearVenta,
  actualizarVenta,
  obtenerDetalleVenta
} from '../../servicios/ventas';

import {
  listarClientesVenta,
  listarPersonasVenta,
  listarVendedoresVenta,
  listarMetodosEntregaVenta,
  listarProductosVenta,
  listarTiposEmpaqueVenta
} from '../../servicios/filtrosVentas';

const datosIniciales = {
  CustomerID: '',
  ContactPersonID: '',
  SalespersonPersonID: '',
  DeliveryMethodID: '',
  AccountsPersonID: '',
  PackedByPersonID: '',
  CustomerPONumber: '',
  DeliveryInstructions: ''
};

const catalogosIniciales = {
  clientes: [],
  personas: [],
  vendedores: [],
  metodosEntrega: [],
  productos: [],
  tiposEmpaque: []
};

function nuevaLinea() {
  return {
    clave: `${Date.now()}-${Math.random()}`,
    StockItemID: '',
    Quantity: '1',
    UnitPrice: '',
    PackageTypeID: ''
  };
}

function convertirTexto(valor) {
  return valor === null || valor === undefined
    ? ''
    : String(valor);
}

function numeroEntero(valor, nombre, obligatorio = true) {
  if (valor === '' || valor === null || valor === undefined) {
    if (!obligatorio) return null;
    throw new Error(`El campo ${nombre} es obligatorio.`);
  }

  const numero = Number(valor);

  if (!Number.isInteger(numero) || numero <= 0) {
    throw new Error(`${nombre} debe ser un entero positivo.`);
  }

  return numero;
}

/**
 * Selector reutilizable para los catálogos.
 *
 * Permite buscar por nombre o ID cuando el catálogo
 * contiene más de 15 registros.
 *
 * El valor almacenado sigue siendo el ID requerido
 * por los procedimientos almacenados.
 */
function SelectorCatalogo({
  id,
  etiqueta,
  valor,
  opciones,
  campoId,
  campoNombre,
  alCambiar,
  requerido = false,
  deshabilitado = false
}) {
  const [busqueda, setBusqueda] = useState('');

  const opcionesFiltradas = opciones.filter(opcion => {
    const nombre = convertirTexto(opcion[campoNombre]);
    const identificador = convertirTexto(opcion[campoId]);

    const texto = busqueda.trim().toLowerCase();

    return (
      nombre.toLowerCase().includes(texto) ||
      identificador.includes(texto)
    );
  });

  const mostrarBusqueda = opciones.length > 15;

  const seleccionActual = opciones.find(
    opcion => String(opcion[campoId]) === String(valor)
  );

  const opcionesVisibles = [...opcionesFiltradas];

  if (
    seleccionActual &&
    !opcionesVisibles.some(
      opcion =>
        String(opcion[campoId]) === String(valor)
    )
  ) {
    opcionesVisibles.unshift(seleccionActual);
  }

  return (
    <div className="ventas-campo">
      <label htmlFor={id}>
        {etiqueta}
      </label>

      {mostrarBusqueda && (
        <input
          type="text"
          value={busqueda}
          onChange={evento =>
            setBusqueda(evento.target.value)
          }
          placeholder={`Buscar ${etiqueta.toLowerCase()}...`}
          disabled={deshabilitado}
          aria-label={`Buscar ${etiqueta.toLowerCase()}`}
          style={{ marginBottom: '8px' }}
        />
      )}

      <select
        id={id}
        value={valor}
        onChange={evento =>
          alCambiar(evento.target.value)
        }
        required={requerido}
        disabled={deshabilitado}
      >
        <option value="">
          {requerido
            ? 'Seleccione una opción'
            : 'Sin seleccionar (opcional)'}
        </option>

        {opcionesVisibles.map(opcion => (
          <option
            key={opcion[campoId]}
            value={opcion[campoId]}
          >
            {opcion[campoNombre]} (ID: {opcion[campoId]})
          </option>
        ))}
      </select>

      {mostrarBusqueda &&
        busqueda.trim() &&
        opcionesFiltradas.length === 0 && (
          <small>
            No se encontraron coincidencias.
          </small>
        )}
    </div>
  );
}

export default function FormularioVenta({
  alCerrar,
  alGuardar,
  ventaId = null
}) {
  const editando =
    ventaId !== null && ventaId !== undefined;

  const [datos, setDatos] = useState({
    ...datosIniciales
  });

  const [lineas, setLineas] = useState([
    nuevaLinea()
  ]);

  const [catalogos, setCatalogos] = useState({
    ...catalogosIniciales
  });

  const [cargando, setCargando] = useState(editando);
  const [cargandoFiltros, setCargandoFiltros] = useState(!editando);
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState('');

  /**
   * Carga la factura cuando se está editando.
   *
   * Se conserva el comportamiento original:
   * solamente se modifican la orden de compra
   * y las instrucciones de entrega.
   */
  useEffect(() => {
    let activo = true;

    if (!editando) {
      setDatos({ ...datosIniciales });
      setLineas([nuevaLinea()]);
      setCargando(false);
      setError('');

      return () => {
        activo = false;
      };
    }

    async function cargarVenta() {
      setCargando(true);
      setError('');

      try {
        const respuesta = await obtenerDetalleVenta(ventaId);
        const encabezado = respuesta.venta?.encabezado;

        if (!encabezado) {
          throw new Error('No se encontró la factura.');
        }

        if (activo) {
          setDatos(actual => ({
            ...actual,
            CustomerPONumber: convertirTexto(
              encabezado.NumeroOrdenCompra
            ),
            DeliveryInstructions: convertirTexto(
              encabezado.InstruccionesEntrega
            )
          }));
        }
      } catch (err) {
        if (activo) {
          setError(
            err.message ||
            'No se pudo cargar la factura.'
          );
        }
      } finally {
        if (activo) {
          setCargando(false);
        }
      }
    }

    cargarVenta();

    return () => {
      activo = false;
    };
  }, [ventaId, editando]);

  /**
   * Obtiene los seis catálogos únicamente
   * cuando se crea una venta nueva.
   *
   * La edición no necesita estos catálogos.
   */
  useEffect(() => {
    if (editando) {
      setCargandoFiltros(false);
      return;
    }

    let activo = true;

    async function cargarCatalogos() {
      setCargandoFiltros(true);

      try {
        const [
          respuestaClientes,
          respuestaPersonas,
          respuestaVendedores,
          respuestaMetodos,
          respuestaProductos,
          respuestaEmpaques
        ] = await Promise.all([
          listarClientesVenta(),
          listarPersonasVenta(),
          listarVendedoresVenta(),
          listarMetodosEntregaVenta(),
          listarProductosVenta(),
          listarTiposEmpaqueVenta()
        ]);

        if (!activo) return;

        setCatalogos({
          clientes: respuestaClientes.datos || [],
          personas: respuestaPersonas.datos || [],
          vendedores: respuestaVendedores.datos || [],
          metodosEntrega: respuestaMetodos.datos || [],
          productos: respuestaProductos.datos || [],
          tiposEmpaque: respuestaEmpaques.datos || []
        });
      } catch (err) {
        if (activo) {
          setError(
            err.message ||
            'No se pudieron cargar los catálogos de ventas.'
          );
        }
      } finally {
        if (activo) {
          setCargandoFiltros(false);
        }
      }
    }

    cargarCatalogos();

    return () => {
      activo = false;
    };
  }, [editando]);

  function cambiarDato(evento) {
    const { name, value } = evento.target;

    setDatos(actual => ({
      ...actual,
      [name]: value
    }));
  }

  function cambiarDatoCatalogo(nombre, valor) {
    setDatos(actual => ({
      ...actual,
      [nombre]: valor
    }));
  }

  function cambiarLinea(clave, campo, valor) {
    setLineas(actual =>
      actual.map(linea =>
        linea.clave === clave
          ? {
              ...linea,
              [campo]: valor
            }
          : linea
      )
    );
  }

  /**
   * Al seleccionar un producto se coloca
   * automáticamente su precio del catálogo.
   *
   * El precio continúa siendo editable.
   */
  function seleccionarProducto(clave, valor) {
    const producto = catalogos.productos.find(
      item =>
        String(item.IdProducto) === String(valor)
    );

    setLineas(actual =>
      actual.map(linea =>
        linea.clave === clave
          ? {
              ...linea,
              StockItemID: valor,
              UnitPrice: producto
                ? convertirTexto(producto.PrecioUnitario)
                : ''
            }
          : linea
      )
    );
  }

  function agregarLinea() {
    setLineas(actual => [
      ...actual,
      nuevaLinea()
    ]);
  }

  function quitarLinea(clave) {
    setLineas(actual =>
      actual.length > 1
        ? actual.filter(
            linea => linea.clave !== clave
          )
        : actual
    );
  }

  /**
   * Prepara las líneas para el procedimiento
   * dbo.Vta_sp_InsertarVenta.
   *
   * Se conserva la validación de productos
   * repetidos y cantidades positivas.
   */
  function prepararLineas() {
    if (lineas.length === 0) {
      throw new Error(
        'La factura debe tener al menos un producto.'
      );
    }

    const productosUsados = new Set();

    return lineas.map((linea, indice) => {
      const numero = indice + 1;

      const StockItemID = numeroEntero(
        linea.StockItemID,
        `ID del producto en línea ${numero}`
      );

      const Quantity = numeroEntero(
        linea.Quantity,
        `Cantidad en línea ${numero}`
      );

      const PackageTypeID = numeroEntero(
        linea.PackageTypeID,
        `ID de empaque en línea ${numero}`,
        false
      );

      if (linea.UnitPrice === '') {
        throw new Error(
          `El precio de la línea ${numero} es obligatorio.`
        );
      }

      const UnitPrice = Number(linea.UnitPrice);

      if (
        !Number.isFinite(UnitPrice) ||
        UnitPrice < 0
      ) {
        throw new Error(
          `El precio de la línea ${numero} no es válido.`
        );
      }

      if (productosUsados.has(StockItemID)) {
        throw new Error(
          `El producto #${StockItemID} está repetido.`
        );
      }

      productosUsados.add(StockItemID);

      return {
        StockItemID,
        Quantity,
        UnitPrice,
        PackageTypeID
      };
    });
  }

  /**
   * Guarda una venta nueva o actualiza
   * los datos permitidos de una factura.
   */
  async function guardar(evento) {
    evento.preventDefault();

    if (
      guardando ||
      cargando ||
      cargandoFiltros
    ) {
      return;
    }

    setError('');

    try {
      let payload;

      if (editando) {
        payload = {
          CustomerPONumber:
            datos.CustomerPONumber.trim() || null,
          DeliveryInstructions:
            datos.DeliveryInstructions.trim() || null
        };
      } else {
        payload = {
          CustomerID: numeroEntero(
            datos.CustomerID,
            'ID del cliente'
          ),

          ContactPersonID: numeroEntero(
            datos.ContactPersonID,
            'ID de persona de contacto'
          ),

          SalespersonPersonID: numeroEntero(
            datos.SalespersonPersonID,
            'ID del vendedor'
          ),

          DeliveryMethodID: numeroEntero(
            datos.DeliveryMethodID,
            'ID del método de entrega',
            false
          ),

          AccountsPersonID: numeroEntero(
            datos.AccountsPersonID,
            'ID de persona de cuentas',
            false
          ),

          PackedByPersonID: numeroEntero(
            datos.PackedByPersonID,
            'ID de persona de empaque',
            false
          ),

          CustomerPONumber:
            datos.CustomerPONumber.trim() || null,

          DeliveryInstructions:
            datos.DeliveryInstructions.trim() || null,

          Lineas: prepararLineas()
        };
      }

      setGuardando(true);

      if (editando) {
        await actualizarVenta(ventaId, payload);
        alGuardar('Factura actualizada correctamente');
      } else {
        await crearVenta(payload);
        alGuardar('Factura creada correctamente');
      }
    } catch (err) {
      setError(
        err.message ||
        (editando
          ? 'No se pudo actualizar la factura'
          : 'No se pudo crear la factura')
      );
    } finally {
      setGuardando(false);
    }
  }

  const formularioDeshabilitado =
    guardando || cargandoFiltros;

  return (
    <div
      className="ventas-modal-fondo"
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
        className="ventas-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-formulario-venta"
      >
        <header className="ventas-modal-encabezado">
          <div>
            <h2 id="titulo-formulario-venta">
              {editando
                ? 'Editar factura'
                : 'Nueva venta'}
            </h2>

            <p>
              {editando
                ? `Modificá los datos de la factura #${ventaId}.`
                : 'Registrá una factura con sus productos.'}
            </p>
          </div>

          <button
            type="button"
            className="ventas-modal-cerrar"
            onClick={alCerrar}
            disabled={guardando}
            aria-label="Cerrar"
          >
            ×
          </button>
        </header>

        <form
          id="formulario-venta"
          className="ventas-modal-contenido"
          onSubmit={guardar}
        >
          {error && (
            <p
              className="ventas-error"
              role="alert"
            >
              {error}
            </p>
          )}

          {cargando ? (
            <p>
              Cargando información de la factura...
            </p>
          ) : (
            <>
              {!editando && (
                <>
                  <h3 className="ventas-seccion-titulo">
                    Información de la venta
                  </h3>

                  {cargandoFiltros ? (
                    <p className="ventas-mensaje">
                      Cargando clientes, personas,
                      vendedores y demás catálogos...
                    </p>
                  ) : (
                    <>
                      <p className="ventas-mensaje">
                        Seleccioná los registros por
                        nombre. Los identificadores se
                        enviarán automáticamente al
                        guardar la venta.
                      </p>

                      <div className="ventas-detalle-grid">
                        <SelectorCatalogo
                          id="venta-CustomerID"
                          etiqueta="Cliente"
                          valor={datos.CustomerID}
                          opciones={catalogos.clientes}
                          campoId="IdCliente"
                          campoNombre="NombreCliente"
                          alCambiar={valor =>
                            cambiarDatoCatalogo(
                              'CustomerID',
                              valor
                            )
                          }
                          requerido
                          deshabilitado={formularioDeshabilitado}
                        />

                        <SelectorCatalogo
                          id="venta-ContactPersonID"
                          etiqueta="Persona de contacto"
                          valor={datos.ContactPersonID}
                          opciones={catalogos.personas}
                          campoId="IdPersona"
                          campoNombre="NombrePersona"
                          alCambiar={valor =>
                            cambiarDatoCatalogo(
                              'ContactPersonID',
                              valor
                            )
                          }
                          requerido
                          deshabilitado={formularioDeshabilitado}
                        />

                        <SelectorCatalogo
                          id="venta-SalespersonPersonID"
                          etiqueta="Vendedor"
                          valor={datos.SalespersonPersonID}
                          opciones={catalogos.vendedores}
                          campoId="IdPersona"
                          campoNombre="NombrePersona"
                          alCambiar={valor =>
                            cambiarDatoCatalogo(
                              'SalespersonPersonID',
                              valor
                            )
                          }
                          requerido
                          deshabilitado={formularioDeshabilitado}
                        />

                        <SelectorCatalogo
                          id="venta-DeliveryMethodID"
                          etiqueta="Método de entrega"
                          valor={datos.DeliveryMethodID}
                          opciones={catalogos.metodosEntrega}
                          campoId="IdMetodoEntrega"
                          campoNombre="NombreMetodoEntrega"
                          alCambiar={valor =>
                            cambiarDatoCatalogo(
                              'DeliveryMethodID',
                              valor
                            )
                          }
                          deshabilitado={formularioDeshabilitado}
                        />

                        <SelectorCatalogo
                          id="venta-AccountsPersonID"
                          etiqueta="Persona de cuentas"
                          valor={datos.AccountsPersonID}
                          opciones={catalogos.personas}
                          campoId="IdPersona"
                          campoNombre="NombrePersona"
                          alCambiar={valor =>
                            cambiarDatoCatalogo(
                              'AccountsPersonID',
                              valor
                            )
                          }
                          deshabilitado={formularioDeshabilitado}
                        />

                        <SelectorCatalogo
                          id="venta-PackedByPersonID"
                          etiqueta="Persona de empaque"
                          valor={datos.PackedByPersonID}
                          opciones={catalogos.personas}
                          campoId="IdPersona"
                          campoNombre="NombrePersona"
                          alCambiar={valor =>
                            cambiarDatoCatalogo(
                              'PackedByPersonID',
                              valor
                            )
                          }
                          deshabilitado={formularioDeshabilitado}
                        />
                      </div>
                    </>
                  )}
                </>
              )}

              <h3 className="ventas-seccion-titulo">
                Información de entrega
              </h3>

              <div className="ventas-detalle-grid">
                <div className="ventas-campo">
                  <label htmlFor="venta-orden-compra">
                    Número de orden de compra
                  </label>

                  <input
                    id="venta-orden-compra"
                    name="CustomerPONumber"
                    type="text"
                    maxLength={20}
                    value={datos.CustomerPONumber}
                    onChange={cambiarDato}
                    disabled={guardando}
                    placeholder="Opcional"
                  />
                </div>

                <div className="ventas-campo ventas-detalle-ancho">
                  <label htmlFor="venta-instrucciones">
                    Instrucciones de entrega
                  </label>

                  <textarea
                    id="venta-instrucciones"
                    name="DeliveryInstructions"
                    rows={3}
                    maxLength={100}
                    value={datos.DeliveryInstructions}
                    onChange={cambiarDato}
                    disabled={guardando}
                    placeholder="Opcional"
                  />
                </div>
              </div>

              {!editando && (
                <>
                  <h3 className="ventas-seccion-titulo">
                    Productos de la factura
                  </h3>

                  {lineas.map((linea, indice) => (
                    <div
                      key={linea.clave}
                      className="ventas-linea-formulario"
                    >
                      <div className="ventas-linea-encabezado">
                        <strong>
                          Producto {indice + 1}
                        </strong>

                        <button
                          type="button"
                          className="ventas-boton-eliminar"
                          onClick={() =>
                            quitarLinea(linea.clave)
                          }
                          disabled={
                            formularioDeshabilitado ||
                            lineas.length === 1
                          }
                        >
                          Quitar
                        </button>
                      </div>

                      <div className="ventas-detalle-grid">
                        <SelectorCatalogo
                          id={`linea-${linea.clave}-StockItemID`}
                          etiqueta="Producto"
                          valor={linea.StockItemID}
                          opciones={catalogos.productos}
                          campoId="IdProducto"
                          campoNombre="NombreProducto"
                          alCambiar={valor =>
                            seleccionarProducto(
                              linea.clave,
                              valor
                            )
                          }
                          requerido
                          deshabilitado={formularioDeshabilitado}
                        />

                        <div className="ventas-campo">
                          <label
                            htmlFor={`linea-${linea.clave}-Quantity`}
                          >
                            Cantidad
                          </label>

                          <input
                            id={`linea-${linea.clave}-Quantity`}
                            type="number"
                            min="1"
                            step="1"
                            value={linea.Quantity}
                            onChange={evento =>
                              cambiarLinea(
                                linea.clave,
                                'Quantity',
                                evento.target.value
                              )
                            }
                            required
                            disabled={formularioDeshabilitado}
                          />
                        </div>

                        <div className="ventas-campo">
                          <label
                            htmlFor={`linea-${linea.clave}-UnitPrice`}
                          >
                            Precio unitario
                          </label>

                          <input
                            id={`linea-${linea.clave}-UnitPrice`}
                            type="number"
                            min="0"
                            step="0.01"
                            value={linea.UnitPrice}
                            onChange={evento =>
                              cambiarLinea(
                                linea.clave,
                                'UnitPrice',
                                evento.target.value
                              )
                            }
                            required
                            disabled={formularioDeshabilitado}
                          />
                        </div>

                        <SelectorCatalogo
                          id={`linea-${linea.clave}-PackageTypeID`}
                          etiqueta="Tipo de empaque"
                          valor={linea.PackageTypeID}
                          opciones={catalogos.tiposEmpaque}
                          campoId="IdTipoEmpaque"
                          campoNombre="NombreTipoEmpaque"
                          alCambiar={valor =>
                            cambiarLinea(
                              linea.clave,
                              'PackageTypeID',
                              valor
                            )
                          }
                          deshabilitado={formularioDeshabilitado}
                        />
                      </div>
                    </div>
                  ))}

                  <button
                    type="button"
                    className="ventas-boton-secundario"
                    onClick={agregarLinea}
                    disabled={formularioDeshabilitado}
                  >
                    + Agregar producto
                  </button>
                </>
              )}
            </>
          )}
        </form>

        <footer
          className="ventas-modal-pie"
          style={{ gap: '12px' }}
        >
          <button
            type="button"
            className="ventas-boton-secundario"
            onClick={alCerrar}
            disabled={guardando}
          >
            Cancelar
          </button>

          <button
            type="submit"
            form="formulario-venta"
            className="ventas-boton-principal"
            disabled={
              guardando ||
              cargando ||
              cargandoFiltros
            }
          >
            {guardando
              ? 'Guardando...'
              : editando
                ? 'Guardar cambios'
                : 'Crear venta'}
          </button>
        </footer>
      </section>
    </div>
  );
}
