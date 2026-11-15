const {
  sql,
  conectarSanJose,
  conectarLimon,
  conectarCorporativo
} = require('../config/db');

async function obtenerConexion(sucursal) {
  if (sucursal === 'SanJose') {
    return conectarSanJose();
  }

  if (sucursal === 'Limon') {
    return conectarLimon();
  }

  if (sucursal === 'Corporativo') {
    return conectarCorporativo();
  }

  return null;
}

function obtenerFiltros(query, corporativo = false) {
  const filtros = {
    nombreCliente: query.nombreCliente || null,
    fechaInicio: query.fechaInicio || null,
    fechaFin: query.fechaFin || null,
    montoMinimo: query.montoMinimo === undefined
      ? null : Number(query.montoMinimo),
    montoMaximo: query.montoMaximo === undefined
      ? null : Number(query.montoMaximo),
    pagina: Number(query.pagina ?? 1),
    limite: Number(query.limite ?? 50),
    sucursalID: null
  };

  if (corporativo && query.sucursalID !== undefined) {
    filtros.sucursalID = Number(query.sucursalID);
  }

  return filtros;
}

function validarFiltros(filtros, corporativo) {
  if (!Number.isSafeInteger(filtros.pagina) ||
      filtros.pagina < 1 ||
      !Number.isSafeInteger(filtros.limite) ||
      filtros.limite < 1 ||
      filtros.limite > 500) {
    return 'Paginacion no valida';
  }

  if ((filtros.montoMinimo !== null &&
       !Number.isFinite(filtros.montoMinimo)) ||
      (filtros.montoMaximo !== null &&
       !Number.isFinite(filtros.montoMaximo))) {
    return 'Montos no validos';
  }

  if (filtros.montoMinimo !== null &&
      filtros.montoMaximo !== null &&
      filtros.montoMinimo > filtros.montoMaximo) {
    return 'Rango de montos invalido';
  }

  const fechaValida = (fecha) =>
    fecha === null ||
    (/^\d{4}-\d{2}-\d{2}$/.test(fecha) &&
     !Number.isNaN(Date.parse(fecha)));

  if (!fechaValida(filtros.fechaInicio) ||
      !fechaValida(filtros.fechaFin)) {
    return 'Fechas no validas';
  }

  if (filtros.fechaInicio && filtros.fechaFin &&
      filtros.fechaInicio > filtros.fechaFin) {
    return 'Rango de fechas invalido';
  }

  if (corporativo && filtros.sucursalID !== null &&
      ![0, 1, 2].includes(filtros.sucursalID)) {
    return 'SucursalID no valido';
  }

  return null;
}

function agregarFiltros(request, filtros, corporativo) {
  request
    .input('NombreCliente', sql.NVarChar(100),
      filtros.nombreCliente)
    .input('FechaInicio', sql.Date, filtros.fechaInicio)
    .input('FechaFin', sql.Date, filtros.fechaFin)
    .input('MontoMinimo', sql.Decimal(18, 2),
      filtros.montoMinimo)
    .input('MontoMaximo', sql.Decimal(18, 2),
      filtros.montoMaximo);

  if (corporativo) {
    request.input('SucursalID', sql.Int, filtros.sucursalID);
  }

  return request;
}

async function listarVentas(solicitud, respuesta) {
  try {
    const sucursal = solicitud.session?.usuario?.sucursal;

    if (!sucursal) {
      return respuesta.status(401).json({
        mensaje: 'Debe iniciar sesion'
      });
    }

    const conexion = await obtenerConexion(sucursal);

    if (!conexion) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    const corporativo = sucursal === 'Corporativo';
    const filtros = obtenerFiltros(solicitud.query, corporativo);
    const error = validarFiltros(filtros, corporativo);

    if (error) {
      return respuesta.status(400).json({ mensaje: error });
    }

    if (!corporativo && solicitud.query.sucursalID !== undefined) {
      return respuesta.status(403).json({
        mensaje: 'Solo Corporativo puede filtrar ventas por sucursal'
      });
    }

    const requestListado = agregarFiltros(
      conexion.request(), filtros, corporativo
    );

    requestListado
      .input('PageNumber', sql.Int, filtros.pagina)
      .input('PageSize', sql.Int, filtros.limite);

    const resultado = await requestListado.execute(
      'dbo.Vta_sp_ListarVentas'
    );

    const requestConteo = agregarFiltros(
      conexion.request(), filtros, corporativo
    );

    const conteo = await requestConteo.execute(
      'dbo.Vta_sp_ContarVentas'
    );

    const total = conteo.recordset[0]?.Total ?? 0;

    return respuesta.json({
      sucursal,
      pagina: filtros.pagina,
      limite: filtros.limite,
      total,
      totalPaginas: Math.ceil(total / filtros.limite),
      ventas: resultado.recordset
    });
  } catch (error) {
    console.error('Error al listar ventas:', error);

    return respuesta.status(500).json({
      mensaje: 'Error al consultar ventas'
    });
  }
}

async function detalleVenta(solicitud, respuesta) {
  try {
    const invoiceID = Number(solicitud.params.id);

    if (!Number.isSafeInteger(invoiceID) || invoiceID <= 0) {
      return respuesta.status(400).json({
        mensaje: 'ID de factura no valido'
      });
    }

    const sucursal = solicitud.session?.usuario?.sucursal;

    if (!sucursal) {
      return respuesta.status(401).json({
        mensaje: 'Debe iniciar sesion'
      });
    }

    const conexion = await obtenerConexion(sucursal);

    if (!conexion) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    const resultado = await conexion.request()
      .input('InvoiceID', sql.Int, invoiceID)
      .execute('dbo.Vta_sp_DetalleVenta');

    const encabezado = resultado.recordsets?.[0]?.[0];
    const lineas = resultado.recordsets?.[1] ?? [];

    if (!encabezado) {
      return respuesta.status(404).json({
        mensaje: 'Factura no encontrada'
      });
    }

    return respuesta.json({
      sucursal,
      venta: {
        encabezado,
        lineas
      }
    });
  } catch (error) {
    console.error('Error al consultar venta:', error);

    return respuesta.status(500).json({
      mensaje: 'Error al consultar el detalle de la venta'
    });
  }
}

async function crearVenta(solicitud, respuesta) {
  try {
    const usuario = solicitud.session?.usuario;

    if (!usuario) {
      return respuesta.status(401).json({
        mensaje: "Debe iniciar sesión"
      });
    }

    if (!["SanJose", "Limon"].includes(usuario.sucursal)) {
      return respuesta.status(403).json({
        mensaje: "Solo las sucursales pueden crear ventas"
      });
    }

    const datos = solicitud.body;

    const campos = [
      "CustomerID",
      "ContactPersonID",
      "SalespersonPersonID"
    ];

    const faltantes = campos.filter(
      campo => !Number.isSafeInteger(datos[campo]) ||
        datos[campo] <= 0
    );

    if (faltantes.length > 0) {
      return respuesta.status(400).json({
        mensaje: "Campos obligatorios inválidos",
        campos: faltantes
      });
    }

    if (!Array.isArray(datos.Lineas) ||
        datos.Lineas.length === 0) {
      return respuesta.status(400).json({
        mensaje: "La venta requiere al menos una línea"
      });
    }

    const productos = new Set();

    for (const linea of datos.Lineas) {
      if (!Number.isSafeInteger(linea.StockItemID) ||
          linea.StockItemID <= 0 ||
          !Number.isSafeInteger(linea.Quantity) ||
          linea.Quantity <= 0 ||
          typeof linea.UnitPrice !== "number" ||
          !Number.isFinite(linea.UnitPrice) ||
          linea.UnitPrice < 0 ||
          (linea.PackageTypeID != null &&
            (!Number.isSafeInteger(linea.PackageTypeID) ||
              linea.PackageTypeID <= 0))) {
        return respuesta.status(400).json({
          mensaje: "Hay líneas de venta inválidas"
        });
      }

      if (productos.has(linea.StockItemID)) {
        return respuesta.status(400).json({
          mensaje: "No se pueden repetir productos"
        });
      }

      productos.add(linea.StockItemID);
    }

    const conexion = await obtenerConexion(usuario.sucursal);

    const lineas = new sql.Table("dbo.TipoLineasFactura");

    lineas.columns.add("StockItemID", sql.Int, {
      nullable: false
    });
    lineas.columns.add("Quantity", sql.Int, {
      nullable: false
    });
    lineas.columns.add("UnitPrice", sql.Decimal(18, 2), {
      nullable: false
    });
    lineas.columns.add("PackageTypeID", sql.Int, {
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
      .input("CustomerID", sql.Int, datos.CustomerID)
      .input("ContactPersonID", sql.Int, datos.ContactPersonID)
      .input("SalespersonPersonID", sql.Int, datos.SalespersonPersonID)
      .input("LastEditedBy", sql.Int, usuario.id)
      .input("DeliveryMethodID", sql.Int,
        datos.DeliveryMethodID ?? 1)
      .input("AccountsPersonID", sql.Int,
        datos.AccountsPersonID ?? null)
      .input("PackedByPersonID", sql.Int,
        datos.PackedByPersonID ?? null)
      .input("CustomerPONumber", sql.NVarChar(20),
        datos.CustomerPONumber ?? null)
      .input("DeliveryInstructions", sql.NVarChar(100),
        datos.DeliveryInstructions ?? null)
      .input("Lineas", lineas)
      .output("NuevoID", sql.Int)
      .execute("dbo.Vta_sp_InsertarVenta");

    return respuesta.status(201).json({
      mensaje: "Venta creada correctamente",
      ventaID: resultado.output.NuevoID,
      resultado: resultado.recordset?.[0] ?? null
    });

  } catch (error) {
    console.error("Error al crear venta:", error);

    return respuesta.status(500).json({
      mensaje: "No se pudo crear la venta",
      error: error.originalError?.info?.message || error.message
    });
  }
}

async function actualizarVenta(solicitud, respuesta) {
  try {
    const usuario = solicitud.session?.usuario;

    if (!usuario) {
      return respuesta.status(401).json({
        mensaje: "Debe iniciar sesión"
      });
    }

    if (!["SanJose", "Limon"].includes(usuario.sucursal)) {
      return respuesta.status(403).json({
        mensaje: "Solo las sucursales pueden actualizar ventas"
      });
    }

    const invoiceID = Number(solicitud.params.id);

    if (!Number.isSafeInteger(invoiceID) || invoiceID <= 0) {
      return respuesta.status(400).json({
        mensaje: "ID de factura inválido"
      });
    }

    const datos = solicitud.body;

    const conexion = await obtenerConexion(usuario.sucursal);

    const resultado = await conexion.request()
      .input("InvoiceID", sql.Int, invoiceID)
      .input("DeliveryInstructions", sql.NVarChar(100),
        datos.DeliveryInstructions ?? null)
      .input("CustomerPONumber", sql.NVarChar(20),
        datos.CustomerPONumber ?? null)
      .input("LastEditedBy", sql.Int, usuario.id)
      .execute("dbo.Vta_sp_ActualizarVenta");

    return respuesta.json({
      mensaje: "Venta actualizada correctamente",
      ventaID: invoiceID,
      resultado: resultado.recordset?.[0] ?? null
    });

  } catch (error) {
    console.error("Error al actualizar venta:", error);

    return respuesta.status(500).json({
      mensaje: "No se pudo actualizar la venta",
      error: error.originalError?.info?.message || error.message
    });
  }
}

async function eliminarVenta(solicitud, respuesta) {
  try {
    const usuario = solicitud.session?.usuario;

    if (!usuario) {
      return respuesta.status(401).json({
        mensaje: "Debe iniciar sesión"
      });
    }

    if (!["SanJose", "Limon"].includes(usuario.sucursal)) {
      return respuesta.status(403).json({
        mensaje: "Solo las sucursales pueden eliminar ventas"
      });
    }

    const invoiceID = Number(solicitud.params.id);

    if (!Number.isSafeInteger(invoiceID) || invoiceID <= 0) {
      return respuesta.status(400).json({
        mensaje: "ID de factura inválido"
      });
    }

    const conexion = await obtenerConexion(usuario.sucursal);

    const resultado = await conexion.request()
      .input("InvoiceID", sql.Int, invoiceID)
      .execute("dbo.Vta_sp_EliminarVenta");

    return respuesta.json({
      mensaje: "Venta eliminada correctamente",
      ventaID: invoiceID,
      resultado: resultado.recordset?.[0] ?? null
    });

  } catch (error) {
    console.error("Error al eliminar venta:", error);

    return respuesta.status(500).json({
      mensaje: "No se pudo eliminar la venta",
      error: error.originalError?.info?.message || error.message
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
