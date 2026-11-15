const {
  sql,
  conectarSanJose,
  conectarLimon,
  conectarCorporativo
} = require('../config/db');

/**
 * Conecta a la base de datos según la sucursal especificada
 * @param {string} sucursal - Nombre de la sucursal ('SanJose', 'Limon' o 'Corporativo')
 * @returns {Promise<sql.ConnectionPool|null>} Pool de conexión o null si la sucursal no es válida
 */
async function obtenerConexion(sucursal) {
  if (sucursal === 'SanJose') return conectarSanJose();
  if (sucursal === 'Limon') return conectarLimon();
  if (sucursal === 'Corporativo') return conectarCorporativo();
  return null;
}

/**
 * Valida que un ID sea un entero positivo válido
 * @param {number} id - ID a validar
 * @returns {boolean} true si el ID es válido
 */
function idValido(id) {
  return Number.isInteger(id) && id > 0 && id <= 2147483647;
}

/**
 * Lista ventas paginadas con filtros opcionales
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 */
async function listarVentas(solicitud, respuesta) {
  try {
    const usuario = solicitud.session?.usuario;

    if (!usuario) {
      return respuesta.status(401).json({
        mensaje: 'Debe iniciar sesión'
      });
    }

    const conexion = await obtenerConexion(usuario.sucursal);

    if (!conexion) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    const corporativo = usuario.sucursal === 'Corporativo';

    const nombreCliente = solicitud.query.nombreCliente || null;
    const fechaInicio = solicitud.query.fechaInicio || null;
    const fechaFin = solicitud.query.fechaFin || null;

    const montoMinimo = solicitud.query.montoMinimo == null ||
      solicitud.query.montoMinimo === ''
      ? null : Number(solicitud.query.montoMinimo);

    const montoMaximo = solicitud.query.montoMaximo == null ||
      solicitud.query.montoMaximo === ''
      ? null : Number(solicitud.query.montoMaximo);

    const pagina = Number(solicitud.query.pagina || 1);
    const limite = Number(solicitud.query.limite || 50);

    const sucursalID = corporativo &&
      solicitud.query.sucursalID !== undefined
      ? Number(solicitud.query.sucursalID)
      : null;

    if (!idValido(pagina) || !idValido(limite) || limite > 500) {
      return respuesta.status(400).json({
        mensaje: 'Paginación no válida'
      });
    }

    if ((montoMinimo !== null && !Number.isFinite(montoMinimo)) ||
        (montoMaximo !== null && !Number.isFinite(montoMaximo)) ||
        (montoMinimo !== null && montoMaximo !== null &&
         montoMinimo > montoMaximo)) {
      return respuesta.status(400).json({
        mensaje: 'Rango de montos no válido'
      });
    }

    if ((fechaInicio && !/^\d{4}-\d{2}-\d{2}$/.test(fechaInicio)) ||
        (fechaFin && !/^\d{4}-\d{2}-\d{2}$/.test(fechaFin)) ||
        (fechaInicio && Number.isNaN(Date.parse(fechaInicio))) ||
        (fechaFin && Number.isNaN(Date.parse(fechaFin))) ||
        (fechaInicio && fechaFin && fechaInicio > fechaFin)) {
      return respuesta.status(400).json({
        mensaje: 'Rango de fechas no válido'
      });
    }

    if (!corporativo && solicitud.query.sucursalID !== undefined) {
      return respuesta.status(403).json({
        mensaje: 'Solo Corporativo puede filtrar por sucursal'
      });
    }

    if (corporativo && sucursalID !== null &&
        ![0, 1, 2].includes(sucursalID)) {
      return respuesta.status(400).json({
        mensaje: 'SucursalID no válido'
      });
    }

    const peticion = conexion.request()
      .input('NombreCliente', sql.NVarChar(100), nombreCliente)
      .input('FechaInicio', sql.Date, fechaInicio)
      .input('FechaFin', sql.Date, fechaFin)
      .input('MontoMinimo', sql.Decimal(18, 2), montoMinimo)
      .input('MontoMaximo', sql.Decimal(18, 2), montoMaximo)
      .input('PageNumber', sql.Int, pagina)
      .input('PageSize', sql.Int, limite);

    if (corporativo) {
      peticion.input('SucursalID', sql.Int, sucursalID);
    }

    const resultado = await peticion.execute(
      'dbo.Vta_sp_ListarVentas'
    );

    const peticionConteo = conexion.request()
      .input('NombreCliente', sql.NVarChar(100), nombreCliente)
      .input('FechaInicio', sql.Date, fechaInicio)
      .input('FechaFin', sql.Date, fechaFin)
      .input('MontoMinimo', sql.Decimal(18, 2), montoMinimo)
      .input('MontoMaximo', sql.Decimal(18, 2), montoMaximo);

    if (corporativo) {
      peticionConteo.input('SucursalID', sql.Int, sucursalID);
    }

    const conteo = await peticionConteo.execute(
      'dbo.Vta_sp_ContarVentas'
    );

    const total = conteo.recordset[0]?.Total ?? 0;

    return respuesta.json({
      sucursal: usuario.sucursal,
      pagina,
      limite,
      total,
      totalPaginas: Math.ceil(total / limite),
      ventas: resultado.recordset
    });

  } catch (error) {
    console.error('Error al listar ventas:', error);
    return respuesta.status(500).json({
      mensaje: 'Error al consultar ventas'
    });
  }
}

/**
 * Obtiene el detalle de una factura (encabezado y líneas)
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 */
async function detalleVenta(solicitud, respuesta) {
  try {
    const usuario = solicitud.session?.usuario;
    const id = Number(solicitud.params.id);

    if (!usuario) {
      return respuesta.status(401).json({
        mensaje: 'Debe iniciar sesión'
      });
    }

    if (!idValido(id)) {
      return respuesta.status(400).json({
        mensaje: 'ID de factura no válido'
      });
    }

    const conexion = await obtenerConexion(usuario.sucursal);

    if (!conexion) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    const resultado = await conexion.request()
      .input('InvoiceID', sql.Int, id)
      .execute('dbo.Vta_sp_DetalleVenta');

    const encabezado = resultado.recordsets?.[0]?.[0];
    const lineas = resultado.recordsets?.[1] ?? [];

    if (!encabezado) {
      return respuesta.status(404).json({
        mensaje: 'Factura no encontrada'
      });
    }

    return respuesta.json({
      sucursal: usuario.sucursal,
      venta: {
        encabezado,
        lineas
      }
    });

  } catch (error) {
    console.error('Error al consultar factura:', error);
    return respuesta.status(500).json({
      mensaje: 'Error al consultar el detalle de la venta'
    });
  }
}

/**
 * Crea una nueva venta con sus líneas de factura
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 */
async function crearVenta(solicitud, respuesta) {
  try {
    const usuario = solicitud.session?.usuario;
    const datos = solicitud.body;

    if (!usuario) {
      return respuesta.status(401).json({
        mensaje: 'Debe iniciar sesión'
      });
    }

    if (usuario.sucursal !== 'SanJose' &&
        usuario.sucursal !== 'Limon') {
      return respuesta.status(403).json({
        mensaje: 'Solo las sucursales pueden crear ventas'
      });
    }

    if (!idValido(datos.CustomerID) ||
        !idValido(datos.ContactPersonID) ||
        !idValido(datos.SalespersonPersonID)) {
      return respuesta.status(400).json({
        mensaje: 'Campos obligatorios inválidos'
      });
    }

    if (!Array.isArray(datos.Lineas) || datos.Lineas.length === 0) {
      return respuesta.status(400).json({
        mensaje: 'La venta requiere al menos una línea'
      });
    }

    const productos = new Set();

    for (const linea of datos.Lineas) {
      if (!idValido(linea.StockItemID) ||
          !idValido(linea.Quantity) ||
          typeof linea.UnitPrice !== 'number' ||
          !Number.isFinite(linea.UnitPrice) ||
          linea.UnitPrice < 0 ||
          (linea.PackageTypeID != null &&
           !idValido(linea.PackageTypeID))) {
        return respuesta.status(400).json({
          mensaje: 'Hay líneas de venta inválidas'
        });
      }

      if (productos.has(linea.StockItemID)) {
        return respuesta.status(400).json({
          mensaje: 'No se pueden repetir productos'
        });
      }

      productos.add(linea.StockItemID);
    }

    const conexion = await obtenerConexion(usuario.sucursal);

    const lineas = new sql.Table('dbo.TipoLineasFactura');

    lineas.columns.add('StockItemID', sql.Int, {
      nullable: false
    });

    lineas.columns.add('Quantity', sql.Int, {
      nullable: false
    });

    lineas.columns.add('UnitPrice', sql.Decimal(18, 2), {
      nullable: false
    });

    lineas.columns.add('PackageTypeID', sql.Int, {
      nullable: true
    });

    for (const linea of datos.Lineas) {
      lineas.rows.add(
        linea.StockItemID,
        linea.Quantity,
        linea.UnitPrice,
        linea.PackageTypeID ?? null
      );
    }

    const resultado = await conexion.request()
      .input('CustomerID', sql.Int, datos.CustomerID)
      .input('ContactPersonID', sql.Int, datos.ContactPersonID)
      .input('SalespersonPersonID', sql.Int, datos.SalespersonPersonID)
      .input('LastEditedBy', sql.Int, usuario.id)
      .input('DeliveryMethodID', sql.Int,
        datos.DeliveryMethodID ?? 1)
      .input('AccountsPersonID', sql.Int,
        datos.AccountsPersonID ?? null)
      .input('PackedByPersonID', sql.Int,
        datos.PackedByPersonID ?? null)
      .input('CustomerPONumber', sql.NVarChar(20),
        datos.CustomerPONumber ?? null)
      .input('DeliveryInstructions', sql.NVarChar(100),
        datos.DeliveryInstructions ?? null)
      .input('Lineas', lineas)
      .output('NuevoID', sql.Int)
      .execute('dbo.Vta_sp_InsertarVenta');

    return respuesta.status(201).json({
      mensaje: 'Venta creada correctamente',
      ventaID: resultado.output.NuevoID,
      resultado: resultado.recordset?.[0] ?? null
    });

  } catch (error) {
    console.error('Error al crear venta:', error);
    return respuesta.status(500).json({
      mensaje: 'No se pudo crear la venta'
    });
  }
}

/**
 * Actualiza una venta existente
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 */
async function actualizarVenta(solicitud, respuesta) {
  try {
    const usuario = solicitud.session?.usuario;
    const id = Number(solicitud.params.id);
    const datos = solicitud.body;

    if (!usuario) {
      return respuesta.status(401).json({
        mensaje: 'Debe iniciar sesión'
      });
    }

    if (usuario.sucursal !== 'SanJose' &&
        usuario.sucursal !== 'Limon') {
      return respuesta.status(403).json({
        mensaje: 'Solo las sucursales pueden actualizar ventas'
      });
    }

    if (!idValido(id)) {
      return respuesta.status(400).json({
        mensaje: 'ID de factura no válido'
      });
    }

    const conexion = await obtenerConexion(usuario.sucursal);

    const resultado = await conexion.request()
      .input('InvoiceID', sql.Int, id)
      .input('DeliveryInstructions', sql.NVarChar(100),
        datos.DeliveryInstructions ?? null)
      .input('CustomerPONumber', sql.NVarChar(20),
        datos.CustomerPONumber ?? null)
      .input('LastEditedBy', sql.Int, usuario.id)
      .execute('dbo.Vta_sp_ActualizarVenta');

    return respuesta.json({
      mensaje: 'Venta actualizada correctamente',
      ventaID: id,
      resultado: resultado.recordset?.[0] ?? null
    });

  } catch (error) {
    console.error('Error al actualizar venta:', error);
    return respuesta.status(500).json({
      mensaje: 'No se pudo actualizar la venta'
    });
  }
}

/**
 * Elimina una venta (reintegra inventario)
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 */
async function eliminarVenta(solicitud, respuesta) {
  try {
    const usuario = solicitud.session?.usuario;
    const id = Number(solicitud.params.id);

    if (!usuario) {
      return respuesta.status(401).json({
        mensaje: 'Debe iniciar sesión'
      });
    }

    if (usuario.sucursal !== 'SanJose' &&
        usuario.sucursal !== 'Limon') {
      return respuesta.status(403).json({
        mensaje: 'Solo las sucursales pueden eliminar ventas'
      });
    }

    if (!idValido(id)) {
      return respuesta.status(400).json({
        mensaje: 'ID de factura no válido'
      });
    }

    const conexion = await obtenerConexion(usuario.sucursal);

    const resultado = await conexion.request()
      .input('InvoiceID', sql.Int, id)
      .execute('dbo.Vta_sp_EliminarVenta');

    return respuesta.json({
      mensaje: 'Venta eliminada correctamente',
      ventaID: id,
      resultado: resultado.recordset?.[0] ?? null
    });

  } catch (error) {
    console.error('Error al eliminar venta:', error);
    return respuesta.status(500).json({
      mensaje: 'No se pudo eliminar la venta'
    });
  }
}

module.exports = {
  listarVentas,
  detalleVenta,
  crearVenta,
  actualizarVenta,
  eliminarVenta
};
