const {
  sql,
  conectarSanJose,
  conectarLimon,
  conectarCorporativo
} = require('../config/db');

async function obtenerConexion(sucursal) {
  if (sucursal === 'SanJose') return conectarSanJose();
  if (sucursal === 'Limon') return conectarLimon();
  if (sucursal === 'Corporativo') return conectarCorporativo();
  return null;
}

function idValido(id) {
  return Number.isInteger(id) && id > 0 && id <= 2147483647;
}

function validarProducto(datos) {
  const campos = [
    'Nombre',
    'ProveedorID',
    'UnidadEmpaqueID',
    'EmpaqueExteriorID',
    'DiasEntrega',
    'CantidadPorEmpaque',
    'RequiereRefrigeracion',
    'Impuesto',
    'PrecioUnitario',
    'Peso'
  ];

  return campos.filter(campo =>
    datos[campo] === undefined ||
    datos[campo] === null ||
    datos[campo] === ''
  );
}

function agregarDatosProducto(peticion, datos) {
  return peticion
    .input('Nombre', sql.NVarChar(100), datos.Nombre)
    .input('ProveedorID', sql.Int, datos.ProveedorID)
    .input('ColorID', sql.Int, datos.ColorID ?? null)
    .input('UnidadEmpaqueID', sql.Int, datos.UnidadEmpaqueID)
    .input('EmpaqueExteriorID', sql.Int, datos.EmpaqueExteriorID)
    .input('Marca', sql.NVarChar(50), datos.Marca ?? null)
    .input('Tamano', sql.NVarChar(20), datos.Tamano ?? null)
    .input('DiasEntrega', sql.Int, datos.DiasEntrega)
    .input('CantidadPorEmpaque', sql.Int, datos.CantidadPorEmpaque)
    .input('RequiereRefrigeracion', sql.Bit, datos.RequiereRefrigeracion)
    .input('CodigoBarras', sql.NVarChar(50), datos.CodigoBarras ?? null)
    .input('Impuesto', sql.Decimal(18, 3), datos.Impuesto)
    .input('PrecioUnitario', sql.Decimal(18, 2), datos.PrecioUnitario)
    .input('PrecioVenta', sql.Decimal(18, 2), datos.PrecioVenta ?? null)
    .input('Peso', sql.Decimal(18, 3), datos.Peso);
}

async function listarProductos(solicitud, respuesta) {
  try {
    const sucursal = solicitud.session.usuario.sucursal;
    const conexion = await obtenerConexion(sucursal);

    if (!conexion) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    const nombre = solicitud.query.nombre || null;
    const grupoID = solicitud.query.grupoID || null;
    const pagina = Number(solicitud.query.pagina || 1);
    const limite = Number(solicitud.query.limite || 25);

    if (!idValido(pagina) || !idValido(limite) || limite > 1000 ||
        (grupoID !== null && !idValido(Number(grupoID)))) {
      return respuesta.status(400).json({
        mensaje: 'Filtros o paginación no válidos'
      });
    }

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

    return respuesta.json({
      pagina,
      limite,
      total,
      totalPaginas: Math.ceil(total / limite),
      productos: resultado.recordset
    });

  } catch (error) {
    console.error('Error al listar productos:', error);
    return respuesta.status(500).json({
      mensaje: 'Error al consultar productos'
    });
  }
}

async function detalleProducto(solicitud, respuesta) {
  try {
    const id = Number(solicitud.params.id);

    if (!idValido(id)) {
      return respuesta.status(400).json({
        mensaje: 'ID de producto no válido'
      });
    }

    const sucursal = solicitud.session.usuario.sucursal;
    const conexion = await obtenerConexion(sucursal);

    if (!conexion) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    const resultado = await conexion.request()
      .input('StockItemID', sql.Int, id)
      .execute('dbo.Inv_sp_DetalleProducto');

    if (resultado.recordset.length === 0) {
      return respuesta.status(404).json({
        mensaje: 'Producto no encontrado'
      });
    }

    return respuesta.json({
      producto: resultado.recordset[0]
    });

  } catch (error) {
    console.error('Error al consultar producto:', error);
    return respuesta.status(500).json({
      mensaje: 'Error al consultar el detalle del producto'
    });
  }
}

async function inventarioPorSucursal(solicitud, respuesta) {
  try {
    const sucursalUsuario = solicitud.session.usuario.sucursal;
    const sucursal = solicitud.query.nombre || sucursalUsuario;

    if (sucursal !== 'SanJose' && sucursal !== 'Limon') {
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

    if (!idValido(pagina) || !idValido(limite) || limite > 1000) {
      return respuesta.status(400).json({
        mensaje: 'Paginación no válida'
      });
    }

    const conexion = await conectarCorporativo();

    const resultado = await conexion.request()
      .input('Sucursal', sql.VarChar(20), sucursal)
      .input('PageNumber', sql.Int, pagina)
      .input('PageSize', sql.Int, limite)
      .execute('dbo.Inv_sp_InventarioPorSucursal');

    return respuesta.json({
      sucursal,
      pagina,
      limite,
      inventario: resultado.recordset
    });

  } catch (error) {
    console.error('Error al consultar inventario:', error);
    return respuesta.status(500).json({
      mensaje: 'Error al consultar inventario por sucursal'
    });
  }
}

async function inventarioConsolidado(solicitud, respuesta) {
  try {
    const pagina = Number(solicitud.query.pagina || 1);
    const limite = Number(solicitud.query.limite || 25);

    if (!idValido(pagina) || !idValido(limite) || limite > 1000) {
      return respuesta.status(400).json({
        mensaje: 'Paginación no válida'
      });
    }

    const conexion = await conectarCorporativo();

    const resultado = await conexion.request()
      .input('PageNumber', sql.Int, pagina)
      .input('PageSize', sql.Int, limite)
      .execute('dbo.Inv_sp_InventarioConsolidado');

    return respuesta.json({
      pagina,
      limite,
      inventario: resultado.recordset
    });

  } catch (error) {
    console.error('Error al consultar inventario consolidado:', error);
    return respuesta.status(500).json({
      mensaje: 'Error al consultar inventario consolidado'
    });
  }
}

async function crearProducto(solicitud, respuesta) {
  try {
    const usuario = solicitud.session.usuario;
    const datos = solicitud.body;

    if (usuario.sucursal !== 'SanJose' &&
        usuario.sucursal !== 'Limon') {
      return respuesta.status(403).json({
        mensaje: 'Solo las sucursales pueden crear productos'
      });
    }

    const faltantes = validarProducto(datos);

    if (faltantes.length > 0) {
      return respuesta.status(400).json({
        mensaje: 'Faltan campos obligatorios',
        campos: faltantes
      });
    }

    const corporativo = await conectarCorporativo();

    const resultadoID = await corporativo.request()
      .execute('dbo.Inv_sp_GenerarStockItemID');

    const nuevoID = resultadoID.recordset[0].StockItemID;
    const conexion = await obtenerConexion(usuario.sucursal);

    const peticion = agregarDatosProducto(conexion.request(), datos);

    const resultado = await peticion
      .input('StockItemID', sql.Int, nuevoID)
      .input('UsuarioEditor', sql.Int, usuario.id)
      .execute('dbo.Inv_sp_CrearProducto');

    return respuesta.status(201).json({
      mensaje: 'Producto creado correctamente',
      producto: resultado.recordset[0]
    });

  } catch (error) {
    console.error('Error al crear producto:', error);
    return respuesta.status(500).json({
      mensaje: 'No se pudo crear el producto'
    });
  }
}

async function actualizarProducto(solicitud, respuesta) {
  try {
    const usuario = solicitud.session.usuario;
    const id = Number(solicitud.params.id);
    const datos = solicitud.body;

    if (usuario.sucursal !== 'SanJose' &&
        usuario.sucursal !== 'Limon') {
      return respuesta.status(403).json({
        mensaje: 'Solo las sucursales pueden actualizar productos'
      });
    }

    if (!idValido(id)) {
      return respuesta.status(400).json({
        mensaje: 'ID de producto no válido'
      });
    }

    const faltantes = validarProducto(datos);

    if (faltantes.length > 0) {
      return respuesta.status(400).json({
        mensaje: 'Faltan campos obligatorios',
        campos: faltantes
      });
    }

    const conexion = await obtenerConexion(usuario.sucursal);
    const peticion = agregarDatosProducto(conexion.request(), datos);

    const resultado = await peticion
      .input('StockItemID', sql.Int, id)
      .input('UsuarioEditor', sql.Int, usuario.id)
      .execute('dbo.Inv_sp_ActualizarProducto');

    return respuesta.json({
      mensaje: 'Producto actualizado correctamente',
      producto: resultado.recordset[0]
    });

  } catch (error) {
    console.error('Error al actualizar producto:', error);
    return respuesta.status(500).json({
      mensaje: 'No se pudo actualizar el producto'
    });
  }
}

async function eliminarProducto(solicitud, respuesta) {
  try {
    const usuario = solicitud.session.usuario;
    const id = Number(solicitud.params.id);

    if (usuario.sucursal !== 'SanJose' &&
        usuario.sucursal !== 'Limon') {
      return respuesta.status(403).json({
        mensaje: 'Solo las sucursales pueden eliminar productos'
      });
    }

    if (!idValido(id)) {
      return respuesta.status(400).json({
        mensaje: 'ID de producto no válido'
      });
    }

    const conexion = await obtenerConexion(usuario.sucursal);

    const resultado = await conexion.request()
      .input('StockItemID', sql.Int, id)
      .execute('dbo.Inv_sp_EliminarProducto');

    return respuesta.json({
      mensaje: 'Producto eliminado correctamente',
      resultado: resultado.recordset[0]
    });

  } catch (error) {
    console.error('Error al eliminar producto:', error);
    return respuesta.status(500).json({
      mensaje: 'No se pudo eliminar el producto'
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
