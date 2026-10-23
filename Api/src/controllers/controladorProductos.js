const { sql, conectarBD } = require('../config/db');

/**
 * Lista productos con filtros opcionales y paginación
 * @param {Object} req - Objeto de solicitud Express
 * @param {Object} req.body - Cuerpo de la solicitud
 * @param {string} [req.body.nombre] - Nombre del producto para filtrar
 * @param {number} [req.body.idGrupo] - ID de grupo para filtrar
 * @param {number} [req.body.page] - Número de página (default: 1)
 * @param {number} [req.body.pageSize] - Tamaño de página (default: 25)
 * @param {Object} res - Objeto de respuesta Express
 * @returns {Promise<void>} Devuelve estructura paginada de productos
 */
async function listarProductos(req, res) {
  try {
    const {
      nombre = null,
      idGrupo = null,
      page = 1,
      pageSize = 25
    } = req.body;

    const conexion = await conectarBD();

    // Validar y sanitizar parámetros de paginación
    const pageNumber = Math.max(1, Number(page));
    const pageSizeNumber = Math.min(1000, Math.max(1, Number(pageSize)));

    // Ejecutar consulta paginada y conteo en paralelo
    const [resultadoPaginado, resultadoConteo] = await Promise.all([
      conexion
        .request()
        .input('Nombre', sql.NVarChar(100), nombre)
        .input('GrupoID', sql.Int, idGrupo)
        .input('PageNumber', sql.Int, pageNumber)
        .input('PageSize', sql.Int, pageSizeNumber)
        .execute('Inv_sp_ListarProductosPaginado'),
      conexion
        .request()
        .input('Nombre', sql.NVarChar(100), nombre)
        .input('GrupoID', sql.Int, idGrupo)
        .execute('Inv_sp_ContarProductos')
    ]);

    const totalRecords = resultadoConteo.recordset[0]?.Total || 0;
    const totalPages = Math.ceil(totalRecords / pageSizeNumber);

    // Manejar páginas fuera de rango
    const adjustedPage = pageNumber > totalPages && totalPages > 0 ? totalPages : pageNumber;

    res.json({
      data: resultadoPaginado.recordset,
      pagination: {
        page: adjustedPage,
        pageSize: pageSizeNumber,
        totalRecords: totalRecords,
        totalPages: totalPages
      }
    });

  } catch (error) {
    console.error('Error al listar productos:', error);

    res.status(500).json({
      mensaje: 'Error al listar productos',
      error: error.message
    });
  }
}

/**
 * Obtiene el detalle de un producto específico
 * @param {Object} req - Objeto de solicitud Express
 * @param {Object} req.params - Parámetros de la URL
 * @param {string} req.params.id - ID del producto
 * @param {Object} res - Objeto de respuesta Express
 * @returns {Promise<void>} Devuelve el detalle del producto
 */
async function detalleProducto(req, res) {
  try {
    const idProducto = req.params.id;

    const conexion = await conectarBD();

    const resultado = await conexion
      .request()
      .input('StockItemID', sql.Int, idProducto)
      .execute('Inv_sp_DetalleProducto');

    res.json(resultado.recordset[0]);

  } catch (error) {
    console.error('Error al obtener detalle del producto:', error);

    res.status(500).json({
      mensaje: 'Error al obtener detalle del producto',
      error: error.message
    });
  }
}

/**
 * Inserta un nuevo producto en el sistema
 * @param {Object} req - Objeto de solicitud Express
 * @param {Object} req.body - Cuerpo de la solicitud con datos del producto
 * @param {string} req.body.nombreProducto - Nombre del producto
 * @param {number} req.body.idProveedor - ID del proveedor
 * @param {number} req.body.idEmpaqueUnidad - ID de empaque unidad
 * @param {number} req.body.idEmpaqueExterior - ID de empaque exterior
 * @param {number} req.body.idEditadoPor - ID de usuario que edita
 * @param {number} req.body.idColor - ID de color
 * @param {string} req.body.marca - Marca del producto
 * @param {string} req.body.talla - Talla del producto
 * @param {number} [req.body.diasEntrega] - Días de entrega
 * @param {number} [req.body.cantidadPorEmpaque] - Cantidad por empaque
 * @param {number} [req.body.esRefrigerado] - Indica si es refrigerado
 * @param {number} [req.body.impuesto] - Tasa de impuesto
 * @param {number} [req.body.precioUnitario] - Precio unitario
 * @param {number} [req.body.precioVenta] - Precio de venta
 * @param {number} [req.body.peso] - Peso del producto
 * @param {Object} res - Objeto de respuesta Express
 * @returns {Promise<void>} Devuelve el ID del nuevo producto
 */
async function insertarProducto(req, res) {
  try {
    const {
      nombreProducto,
      idProveedor,
      idEmpaqueUnidad,
      idEmpaqueExterior,
      idEditadoPor,
      idColor,
      marca,
      talla,
      diasEntrega,
      cantidadPorEmpaque,
      esRefrigerado,
      impuesto,
      precioUnitario,
      precioVenta,
      peso
    } = req.body;

    const conexion = await conectarBD();

    const solicitud = conexion.request();

    solicitud
      .input('NombreProducto', sql.NVarChar(100), nombreProducto)
      .input('SupplierID', sql.Int, idProveedor)
      .input('UnitPackageID', sql.Int, idEmpaqueUnidad)
      .input('OuterPackageID', sql.Int, idEmpaqueExterior)
      .input('LastEditedBy', sql.Int, idEditadoPor)
      .input('ColorID', sql.Int, idColor)
      .input('Marca', sql.NVarChar(50), marca)
      .input('Talla', sql.NVarChar(20), talla)
      .input('LeadTimeDays', sql.Int, diasEntrega || 7)
      .input('QuantityPerOuter', sql.Int, cantidadPorEmpaque || 1)
      .input('IsChillerStock', sql.Bit, esRefrigerado || 0)
      .input('TaxRate', sql.Decimal(18, 3), impuesto || 15)
      .input('UnitPrice', sql.Decimal(18, 2), precioUnitario || 0)
      .input('PrecioVenta', sql.Decimal(18, 2), precioVenta || null)
      .input('Peso', sql.Decimal(18, 3), peso || 0)
      .output('NuevoID', sql.Int);

    const resultado = await solicitud.execute('Inv_sp_InsertarProducto');

    res.json({
      idProducto: resultado.output.NuevoID,
      resultado: resultado.recordset
    });

  } catch (error) {
    console.error('Error al insertar producto:', error);

    res.status(500).json({
      mensaje: 'Error al insertar producto',
      error: error.message
    });
  }
}

/**
 * Actualiza un producto existente
 * @param {Object} req - Objeto de solicitud Express
 * @param {Object} req.params - Parámetros de la URL
 * @param {string} req.params.id - ID del producto a actualizar
 * @param {Object} req.body - Cuerpo de la solicitud con datos a actualizar
 * @param {string} req.body.nombreProducto - Nombre del producto
 * @param {number} req.body.idProveedor - ID del proveedor
 * @param {number} req.body.idEmpaqueUnidad - ID de empaque unidad
 * @param {number} req.body.idEmpaqueExterior - ID de empaque exterior
 * @param {number} req.body.precioUnitario - Precio unitario
 * @param {number} req.body.precioVenta - Precio de venta
 * @param {number} req.body.impuesto - Tasa de impuesto
 * @param {number} req.body.idEditadoPor - ID de usuario que edita
 * @param {number} req.body.idColor - ID de color
 * @param {string} req.body.marca - Marca del producto
 * @param {string} req.body.talla - Talla del producto
 * @param {number} [req.body.diasEntrega] - Días de entrega
 * @param {number} [req.body.cantidadPorEmpaque] - Cantidad por empaque
 * @param {number} [req.body.peso] - Peso del producto
 * @param {Object} res - Objeto de respuesta Express
 * @returns {Promise<void>} Devuelve el producto actualizado
 */
async function actualizarProducto(req, res) {
  try {
    const idProducto = req.params.id;

    const {
      nombreProducto,
      idProveedor,
      idEmpaqueUnidad,
      idEmpaqueExterior,
      precioUnitario,
      precioVenta,
      impuesto,
      idEditadoPor,
      idColor,
      marca,
      talla,
      diasEntrega,
      cantidadPorEmpaque,
      peso
    } = req.body;

    const conexion = await conectarBD();

    const resultado = await conexion
      .request()
      .input('StockItemID', sql.Int, idProducto)
      .input('NombreProducto', sql.NVarChar(100), nombreProducto)
      .input('SupplierID', sql.Int, idProveedor)
      .input('UnitPackageID', sql.Int, idEmpaqueUnidad)
      .input('OuterPackageID', sql.Int, idEmpaqueExterior)
      .input('UnitPrice', sql.Decimal(18, 2), precioUnitario || 0)
      .input('PrecioVenta', sql.Decimal(18, 2), precioVenta || null)
      .input('TaxRate', sql.Decimal(18, 3), impuesto || 15)
      .input('LastEditedBy', sql.Int, idEditadoPor)
      .input('ColorID', sql.Int, idColor)
      .input('Marca', sql.NVarChar(50), marca)
      .input('Talla', sql.NVarChar(20), talla)
      .input('LeadTimeDays', sql.Int, diasEntrega || null)
      .input('QuantityPerOuter', sql.Int, cantidadPorEmpaque || null)
      .input('Peso', sql.Decimal(18, 3), peso || null)
      .execute('Inv_sp_ActualizarProducto');

    res.json(resultado.recordset[0]);

  } catch (error) {
    console.error('Error al actualizar producto:', error);

    res.status(500).json({
      mensaje: 'Error al actualizar producto',
      error: error.message
    });
  }
}

/**
 * Elimina un producto del sistema
 * @param {Object} req - Objeto de solicitud Express
 * @param {Object} req.params - Parámetros de la URL
 * @param {string} req.params.id - ID del producto a eliminar
 * @param {Object} res - Objeto de respuesta Express
 * @returns {Promise<void>} Devuelve el resultado de la eliminación
 */
async function eliminarProducto(req, res) {
  try {
    const idProducto = req.params.id;

    const conexion = await conectarBD();

    const resultado = await conexion
      .request()
      .input('StockItemID', sql.Int, idProducto)
      .execute('Inv_sp_EliminarProducto');

    res.json(resultado.recordset[0]);

  } catch (error) {
    console.error('Error al eliminar producto:', error);

    res.status(500).json({
      mensaje: 'Error al eliminar producto',
      error: error.message
    });
  }
}

module.exports = {
  listarProductos,
  detalleProducto,
  insertarProducto,
  actualizarProducto,
  eliminarProducto
};