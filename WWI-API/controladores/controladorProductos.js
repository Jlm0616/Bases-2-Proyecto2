const {
  sql,
  conectarSanJose,
  conectarLimon,
  conectarCorporativo
} = require('../config/db');

const camposProducto = {
  Nombre: sql.NVarChar(100),
  ProveedorID: sql.Int,
  ColorID: sql.Int,
  UnidadEmpaqueID: sql.Int,
  EmpaqueExteriorID: sql.Int,
  Marca: sql.NVarChar(50),
  Tamano: sql.NVarChar(20),
  DiasEntrega: sql.Int,
  CantidadPorEmpaque: sql.Int,
  RequiereRefrigeracion: sql.Bit,
  CodigoBarras: sql.NVarChar(50),
  Impuesto: sql.Decimal(18, 3),
  PrecioUnitario: sql.Decimal(18, 2),
  PrecioVenta: sql.Decimal(18, 2),
  Peso: sql.Decimal(18, 3)
};

function agregarParametrosProducto(request, datos) {
  for (const [nombre, tipo] of Object.entries(camposProducto)) {
    request.input(nombre, tipo, datos[nombre] ?? null);
  }

  return request;
}

function validarProducto(datos) {
  const obligatorios = [
    "Nombre",
    "ProveedorID",
    "UnidadEmpaqueID",
    "EmpaqueExteriorID",
    "DiasEntrega",
    "CantidadPorEmpaque",
    "RequiereRefrigeracion",
    "Impuesto",
    "PrecioUnitario",
    "Peso"
  ];

  return obligatorios.filter(
    (campo) => datos[campo] === undefined ||
      datos[campo] === null ||
      datos[campo] === ""
  );
}

async function obtenerConexion(sucursal) {
  if (sucursal === 'SanJose') {
    return await conectarSanJose();
  }

  if (sucursal === 'Limon') {
    return await conectarLimon();
  }

  if (sucursal === 'Corporativo') {
    return await conectarCorporativo();
  }

  throw new Error('Sucursal no válida');
}

async function listarProductos(solicitud, respuesta) {
  try {
    const sucursal = solicitud.session.usuario.sucursal;
    const conexion = await obtenerConexion(sucursal);

    const nombre = solicitud.query.nombre || null;
    const grupoID = solicitud.query.grupoID || null;
    const pagina = Number(solicitud.query.pagina) || 1;
    const limite = Number(solicitud.query.limite) || 25;

    const resultado = await conexion.request()
      .input('Nombre', sql.NVarChar(100), nombre)
      .input('GrupoID', sql.Int, grupoID)
      .input('PageNumber', sql.Int, pagina)
      .input('PageSize', sql.Int, limite)
      .execute('dbo.Inv_sp_ListarProductosPaginado');

    const conteo = await conexion.request()
      .input('Nombre', sql.NVarChar(100), nombre)
      .input('GrupoID', sql.Int, grupoID)
      .execute('dbo.Inv_sp_ContarProductos');

    const total = conteo.recordset[0].Total;

    respuesta.json({
      pagina,
      limite,
      total,
      totalPaginas: Math.ceil(total / limite),
      productos: resultado.recordset
    });

  } catch (error) {
    console.error(error);

    respuesta.status(500).json({
      mensaje: 'Error al consultar productos'
    });
  }
}

async function detalleProducto(solicitud, respuesta) {
  try {
    const id = Number(solicitud.params.id);

    if (!Number.isInteger(id) || id <= 0) {
      return respuesta.status(400).json({
        mensaje: 'ID de producto no válido'
      });
    }

    const sucursal = solicitud.session.usuario.sucursal;
    const conexion = await obtenerConexion(sucursal);

    const resultado = await conexion.request()
      .input('StockItemID', sql.Int, id)
      .execute('dbo.Inv_sp_DetalleProducto');

    if (resultado.recordset.length === 0) {
      return respuesta.status(404).json({
        mensaje: 'Producto no encontrado'
      });
    }

    respuesta.json({
      producto: resultado.recordset[0]
    });

  } catch (error) {
    console.error(error);

    respuesta.status(500).json({
      mensaje: 'Error al consultar el detalle del producto'
    });
  }
}

async function inventarioPorSucursal(solicitud, respuesta) {
  try {
    const usuario = solicitud.session.usuario;
    const sucursalUsuario = usuario.sucursal;
    const sucursal = solicitud.query.nombre || sucursalUsuario;

    if (!['SanJose', 'Limon'].includes(sucursal)) {
      return respuesta.status(400).json({
        mensaje: 'Sucursal no válida'
      });
    }

    if (sucursalUsuario !== 'Corporativo' &&
        sucursalUsuario !== sucursal) {
      return respuesta.status(403).json({
        mensaje: 'No tiene permisos para consultar esta sucursal'
      });
    }

    const pagina = Number(solicitud.query.pagina || 1);
    const limite = Number(solicitud.query.limite || 25);

    if (!Number.isInteger(pagina) || pagina < 1 ||
        !Number.isInteger(limite) || limite < 1 || limite > 1000) {
      return respuesta.status(400).json({
        mensaje: 'Parámetros de paginación no válidos'
      });
    }

    const conexion = await conectarCorporativo();

    const resultado = await conexion.request()
      .input('Sucursal', sql.VarChar(20), sucursal)
      .input('PageNumber', sql.Int, pagina)
      .input('PageSize', sql.Int, limite)
      .execute('dbo.Inv_sp_InventarioPorSucursal');

    respuesta.json({
      sucursal,
      pagina,
      limite,
      inventario: resultado.recordset
    });

  } catch (error) {
    console.error(error);

    respuesta.status(500).json({
      mensaje: 'Error al consultar inventario por sucursal'
    });
  }
}

async function inventarioConsolidado(solicitud, respuesta) {
  try {
    const pagina = Number(solicitud.query.pagina || 1);
    const limite = Number(solicitud.query.limite || 25);

    if (!Number.isInteger(pagina) || pagina < 1 ||
        !Number.isInteger(limite) || limite < 1 || limite > 1000) {
      return respuesta.status(400).json({
        mensaje: 'Parámetros de paginación no válidos'
      });
    }

    const conexion = await conectarCorporativo();

    const resultado = await conexion.request()
      .input('PageNumber', sql.Int, pagina)
      .input('PageSize', sql.Int, limite)
      .execute('dbo.Inv_sp_InventarioConsolidado');

    respuesta.json({
      pagina,
      limite,
      inventario: resultado.recordset
    });

  } catch (error) {
    console.error(error);

    respuesta.status(500).json({
      mensaje: 'Error al consultar inventario consolidado'
    });
  }
}

async function crearProducto(solicitud, respuesta) {
  try {
    const faltantes = validarProducto(solicitud.body);

    if (faltantes.length > 0) {
      return respuesta.status(400).json({
        mensaje: "Faltan campos obligatorios",
        campos: faltantes
      });
    }

    const { sucursal, id } = solicitud.session.usuario;

    if (!["SanJose", "Limon"].includes(sucursal)) {
      return respuesta.status(403).json({
        mensaje: "Solo las sucursales pueden crear productos"
      });
    }

    const corporativo = await conectarCorporativo();

    const resultadoID = await corporativo.request()
      .execute("dbo.Inv_sp_GenerarStockItemID");

    const nuevoID = resultadoID.recordset[0].StockItemID;

    const conexion = await obtenerConexion(sucursal);

    const request = agregarParametrosProducto(
      conexion.request(),
      solicitud.body
    );

    request.input("StockItemID", sql.Int, nuevoID);
    request.input("UsuarioEditor", sql.Int, id);

    const resultado = await request.execute(
      "dbo.Inv_sp_CrearProducto"
    );

    return respuesta.status(201).json({
      mensaje: "Producto creado correctamente",
      producto: resultado.recordset[0]
    });
  } catch (error) {
    console.error("Error al crear producto:", error);

    return respuesta.status(500).json({
      mensaje: "No se pudo crear el producto",
      error: error.originalError?.info?.message || error.message
    });
  }
}

async function actualizarProducto(solicitud, respuesta) {
  try {
    const stockItemID = Number(solicitud.params.id);

    if (!Number.isSafeInteger(stockItemID) || stockItemID <= 0) {
      return respuesta.status(400).json({
        mensaje: "ID de producto inválido"
      });
    }

    const faltantes = validarProducto(solicitud.body);

    if (faltantes.length > 0) {
      return respuesta.status(400).json({
        mensaje: "Faltan campos obligatorios",
        campos: faltantes
      });
    }

    const { sucursal, id } = solicitud.session.usuario;
    const conexion = await obtenerConexion(sucursal);

    const request = agregarParametrosProducto(
      conexion.request(),
      solicitud.body
    );

    request.input("StockItemID", sql.Int, stockItemID);
    request.input("UsuarioEditor", sql.Int, id);

    const resultado = await request.execute(
      "dbo.Inv_sp_ActualizarProducto"
    );

    return respuesta.json({
      mensaje: "Producto actualizado correctamente",
      producto: resultado.recordset[0]
    });
  } catch (error) {
    console.error("Error al actualizar producto:", error);

    return respuesta.status(500).json({
      mensaje: "No se pudo actualizar el producto",
      error: error.originalError?.info?.message || error.message
    });
  }
}

async function eliminarProducto(solicitud, respuesta) {
  try {
    const stockItemID = Number(solicitud.params.id);

    if (!Number.isSafeInteger(stockItemID) || stockItemID <= 0) {
      return respuesta.status(400).json({
        mensaje: "ID de producto inválido"
      });
    }

    const { sucursal } = solicitud.session.usuario;
    const conexion = await obtenerConexion(sucursal);

    const resultado = await conexion.request()
      .input("StockItemID", sql.Int, stockItemID)
      .execute("dbo.Inv_sp_EliminarProducto");

    return respuesta.json({
      mensaje: "Producto eliminado correctamente",
      resultado: resultado.recordset[0]
    });
  } catch (error) {
    console.error("Error al eliminar producto:", error);

    return respuesta.status(500).json({
      mensaje: "No se pudo eliminar el producto",
      error: error.originalError?.info?.message || error.message
    });
  }
}

module.exports = {
  listarProductos,
  detalleProducto,
  inventarioPorSucursal,
  inventarioConsolidado,
  crearProducto,
  actualizarProducto,
  eliminarProducto
};
