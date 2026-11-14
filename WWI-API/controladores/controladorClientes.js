
const { sql, conectarSanJose, conectarLimon } = require('../config/db');

// Listar clientes
async function listarClientes(solicitud, respuesta) {
  try {
    const sucursal = solicitud.session.usuario.sucursal;

    // Parámetros de búsqueda
    const nombre = solicitud.query.nombre || null;
    const categoria = solicitud.query.categoriaID || null;
    const pagina = Number(solicitud.query.pagina || 1);
    const tamanoPagina = Number(solicitud.query.tamanoPagina || 25);

    // Validar paginación
    if (!Number.isInteger(pagina) || pagina < 1 ||
        !Number.isInteger(tamanoPagina) || tamanoPagina < 1 ||
        tamanoPagina > 1000) {
      return respuesta.status(400).json({
        mensaje: 'Paginación no válida'
      });
    }

    // Validar categoría
    if (categoria != null &&
        (!Number.isInteger(Number(categoria)) || Number(categoria) <= 0)) {
      return respuesta.status(400).json({
        mensaje: 'Categoría no válida'
      });
    }

    // Seleccionar conexión
    let conexion;

    if (sucursal === 'SanJose') {
      conexion = await conectarSanJose();
    } else if (sucursal === 'Limon') {
      conexion = await conectarLimon();
    } else {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    // Ejecutar procedimiento almacenado
    const resultado = await conexion.request()
      .input('Nombre', sql.NVarChar(100), nombre)
      .input('CategoriaID', sql.Int, categoria)
      .input('PageNumber', sql.Int, pagina)
      .input('PageSize', sql.Int, tamanoPagina)
      .execute('dbo.Cli_sp_ListarClientesPaginado');

    return respuesta.json({
      sucursal: sucursal,
      pagina: pagina,
      tamanoPagina: tamanoPagina,
      clientes: resultado.recordset
    });

  } catch (error) {
    console.error('Error al listar clientes:', error);

    return respuesta.status(500).json({
      mensaje: 'Error al consultar los clientes'
    });
  }
}

module.exports = {
  listarClientes
};
