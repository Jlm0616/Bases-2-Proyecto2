const {
  sql,
  conectarSanJose,
  conectarLimon,
  conectarCorporativo
} = require('../config/db');

async function conectarSucursal(sucursal) {
  if (sucursal === 'SanJose') {
    return await conectarSanJose();
  }

  if (sucursal === 'Limon') {
    return await conectarLimon();
  }

  return null;
}

async function listarProveedores(solicitud, respuesta) {
  try {
    const sucursal = solicitud.session.usuario.sucursal;
    const conexion = await conectarSucursal(sucursal);

    if (!conexion) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no válida'
      });
    }

    const pagina = Math.max(1, parseInt(solicitud.query.pagina) || 1);
    const tamanoPagina = Math.min(
      1000,
      Math.max(1, parseInt(solicitud.query.tamanoPagina) || 10)
    );

    const nombre = solicitud.query.nombre || null;
    const categoriaID = solicitud.query.categoriaID
      ? parseInt(solicitud.query.categoriaID)
      : null;

    const resultado = await conexion.request()
      .input('Nombre', sql.NVarChar(100), nombre)
      .input('CategoriaID', sql.Int, categoriaID)
      .input('PageNumber', sql.Int, pagina)
      .input('PageSize', sql.Int, tamanoPagina)
      .execute('dbo.Prov_sp_ListarProveedoresPaginado');

    const conteo = await conexion.request()
      .input('Nombre', sql.NVarChar(100), nombre)
      .input('CategoriaID', sql.Int, categoriaID)
      .execute('dbo.Prov_sp_ContarProveedores');

    const total = conteo.recordset[0].Total;

    return respuesta.json({
      sucursal,
      pagina,
      tamanoPagina,
      total,
      totalPaginas: Math.ceil(total / tamanoPagina),
      proveedores: resultado.recordset
    });

  } catch (error) {
    console.error(error);
    return respuesta.status(500).json({
      mensaje: 'Error al listar proveedores'
    });
  }
}

async function obtenerDetalleProveedor(solicitud, respuesta) {
  try {
    const id = Number(solicitud.params.id);

    if (!Number.isInteger(id) || id <= 0) {
      return respuesta.status(400).json({
        mensaje: 'ID de proveedor no válido'
      });
    }

    const sucursal = solicitud.session.usuario.sucursal;
    const conexion = await conectarSucursal(sucursal);

    if (!conexion) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no válida'
      });
    }

    const resultadoPublico = await conexion.request()
      .input('SupplierID', sql.Int, id)
      .execute('dbo.Prov_sp_DetalleProveedor');

    if (resultadoPublico.recordset.length === 0) {
      return respuesta.status(404).json({
        mensaje: 'Proveedor no encontrado'
      });
    }

    const conexionCorporativo = await conectarCorporativo();

    const resultadoPrivado = await conexionCorporativo.request()
      .input('SupplierID', sql.Int, id)
      .execute('dbo.Prov_sp_DetalleProveedorPrivado');

    return respuesta.json({
      sucursal,
      proveedor: {
        datosPublicos: resultadoPublico.recordset[0],
        datosPrivados: resultadoPrivado.recordset[0] || null
      }
    });

  } catch (error) {
    console.error(error);
    return respuesta.status(500).json({
      mensaje: 'Error al obtener el proveedor'
    });
  }
}

module.exports = {
  listarProveedores,
  obtenerDetalleProveedor
};
