const { sql, conectarBD } = require('../config/db');

/**
 * Lista proveedores con filtros opcionales y paginación
 * @param {Object} req - Objeto de solicitud Express
 * @param {Object} req.body - Cuerpo de la solicitud
 * @param {string} [req.body.nombre] - Nombre del proveedor para filtrar
 * @param {number} [req.body.idCategoria] - ID de categoría para filtrar
 * @param {number} [req.body.page] - Número de página (default: 1)
 * @param {number} [req.body.pageSize] - Tamaño de página (default: 25)
 * @param {Object} res - Objeto de respuesta Express
 * @returns {Promise<void>} Devuelve estructura paginada de proveedores
 */
async function listarProveedores(req, res) {
  try {
    const {
      nombre = null,
      idCategoria = null,
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
        .input('CategoriaID', sql.Int, idCategoria)
        .input('PageNumber', sql.Int, pageNumber)
        .input('PageSize', sql.Int, pageSizeNumber)
        .execute('Prov_sp_ListarProveedoresPaginado'),
      conexion
        .request()
        .input('Nombre', sql.NVarChar(100), nombre)
        .input('CategoriaID', sql.Int, idCategoria)
        .execute('Prov_sp_ContarProveedores')
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
    console.error('Error al listar proveedores:', error);

    res.status(500).json({
      mensaje: 'Error al listar proveedores',
      error: error.message
    });
  }
}

/**
 * Obtiene el detalle de un proveedor específico
 * @param {Object} req - Objeto de solicitud Express
 * @param {Object} req.params - Parámetros de la URL
 * @param {string} req.params.id - ID del proveedor
 * @param {Object} res - Objeto de respuesta Express
 * @returns {Promise<void>} Devuelve el detalle del proveedor
 */
async function detalleProveedor(req, res) {
  try {
    const idProveedor = req.params.id;

    const conexion = await conectarBD();

    const resultado = await conexion
      .request()
      .input('SupplierID', sql.Int, idProveedor)
      .execute('Prov_sp_DetalleProveedor');

    res.json(resultado.recordset[0]);

  } catch (error) {
    console.error('Error al obtener detalle del proveedor:', error);

    res.status(500).json({
      mensaje: 'Error al obtener detalle del proveedor',
      error: error.message
    });
  }
}

/**
 * Inserta un nuevo proveedor en el sistema
 * @param {Object} req - Objeto de solicitud Express
 * @param {Object} req.body - Cuerpo de la solicitud con datos del proveedor
 * @param {string} req.body.nombreProveedor - Nombre del proveedor
 * @param {number} req.body.idCategoria - ID de categoría del proveedor
 * @param {number} req.body.idContactoPrimario - ID de persona de contacto primario
 * @param {number} req.body.idContactoAlternativo - ID de persona de contacto alternativo
 * @param {number} req.body.idMetodoEntrega - ID de método de entrega
 * @param {number} req.body.idCiudadEntrega - ID de ciudad de entrega
 * @param {number} req.body.idEditadoPor - ID de usuario que edita
 * @param {number} [req.body.idCiudadPostal] - ID de ciudad postal
 * @param {string} [req.body.telefono] - Teléfono del proveedor
 * @param {string} [req.body.direccionEntregaLinea1] - Dirección de entrega
 * @param {string} [req.body.codigoPostalEntrega] - Código postal de entrega
 * @param {string} [req.body.direccionPostalLinea1] - Dirección postal
 * @param {string} [req.body.codigoPostal] - Código postal
 * @param {Object} res - Objeto de respuesta Express
 * @returns {Promise<void>} Devuelve el ID del nuevo proveedor
 */
async function insertarProveedor(req, res) {
  try {
    const {
      nombreProveedor,
      idCategoria,
      idContactoPrimario,
      idContactoAlternativo,
      idMetodoEntrega,
      idCiudadEntrega,
      idEditadoPor,
      idCiudadPostal,
      telefono,
      direccionEntregaLinea1,
      codigoPostalEntrega,
      direccionPostalLinea1,
      codigoPostal
    } = req.body;

    const conexion = await conectarBD();

    const solicitud = conexion.request();

    solicitud
      .input('NombreProveedor', sql.NVarChar(100), nombreProveedor)
      .input('CategoriaID', sql.Int, idCategoria)
      .input('PrimaryContactID', sql.Int, idContactoPrimario)
      .input('AlternateContactID', sql.Int, idContactoAlternativo)
      .input('MetodoEntregaID', sql.Int, idMetodoEntrega)
      .input('DeliveryCityID', sql.Int, idCiudadEntrega)
      .input('LastEditedBy', sql.Int, idEditadoPor)
      .input('PostalCityID', sql.Int, idCiudadPostal)
      .input('PhoneNumber', sql.NVarChar(20), telefono || 'Sin definir')
      .input('DeliveryAddressLine1', sql.NVarChar(60), direccionEntregaLinea1 || 'Sin definir')
      .input('DeliveryPostalCode', sql.NVarChar(10), codigoPostalEntrega || '00000')
      .input('PostalAddressLine1', sql.NVarChar(60), direccionPostalLinea1 || 'Sin definir')
      .input('PostalPostalCode', sql.NVarChar(10), codigoPostal || '00000')
      .output('NuevoID', sql.Int);

    const resultado = await solicitud.execute('Prov_sp_InsertarProveedor');

    res.json({
      idProveedor: resultado.output.NuevoID,
      resultado: resultado.recordset
    });

  } catch (error) {
    console.error('Error al insertar proveedor:', error);

    res.status(500).json({
      mensaje: 'Error al insertar proveedor',
      error: error.message
    });
  }
}

/**
 * Actualiza un proveedor existente
 * @param {Object} req - Objeto de solicitud Express
 * @param {Object} req.params - Parámetros de la URL
 * @param {string} req.params.id - ID del proveedor a actualizar
 * @param {Object} req.body - Cuerpo de la solicitud con datos a actualizar
 * @param {string} req.body.nombreProveedor - Nombre del proveedor
 * @param {number} req.body.idCategoria - ID de categoría del proveedor
 * @param {number} req.body.idMetodoEntrega - ID de método de entrega
 * @param {number} req.body.idEditadoPor - ID de usuario que edita
 * @param {number} [req.body.idContactoPrimario] - ID de persona de contacto primario
 * @param {number} [req.body.idContactoAlternativo] - ID de persona de contacto alternativo
 * @param {number} [req.body.idCiudadEntrega] - ID de ciudad de entrega
 * @param {number} [req.body.idCiudadPostal] - ID de ciudad postal
 * @param {string} [req.body.telefono] - Teléfono del proveedor
 * @param {string} [req.body.direccionEntregaLinea1] - Dirección de entrega
 * @param {string} [req.body.codigoPostalEntrega] - Código postal de entrega
 * @param {string} [req.body.direccionPostalLinea1] - Dirección postal
 * @param {string} [req.body.codigoPostal] - Código postal
 * @param {Object} res - Objeto de respuesta Express
 * @returns {Promise<void>} Devuelve el proveedor actualizado
 */
async function actualizarProveedor(req, res) {
  try {
    const idProveedor = req.params.id;

    const {
      nombreProveedor,
      idCategoria,
      idMetodoEntrega,
      idEditadoPor,
      idContactoPrimario,
      idContactoAlternativo,
      idCiudadEntrega,
      idCiudadPostal,
      telefono,
      direccionEntregaLinea1,
      codigoPostalEntrega,
      direccionPostalLinea1,
      codigoPostal
    } = req.body;

    const conexion = await conectarBD();

    const resultado = await conexion
      .request()
      .input('SupplierID', sql.Int, idProveedor)
      .input('NombreProveedor', sql.NVarChar(100), nombreProveedor)
      .input('CategoriaID', sql.Int, idCategoria)
      .input('MetodoEntregaID', sql.Int, idMetodoEntrega)
      .input('LastEditedBy', sql.Int, idEditadoPor)
      .input('PrimaryContactID', sql.Int, idContactoPrimario)
      .input('AlternateContactID', sql.Int, idContactoAlternativo)
      .input('DeliveryCityID', sql.Int, idCiudadEntrega)
      .input('PostalCityID', sql.Int, idCiudadPostal)
      .input('PhoneNumber', sql.NVarChar(20), telefono || 'Sin definir')
      .input('DeliveryAddressLine1', sql.NVarChar(60), direccionEntregaLinea1 || 'Sin definir')
      .input('DeliveryPostalCode', sql.NVarChar(10), codigoPostalEntrega || '00000')
      .input('PostalAddressLine1', sql.NVarChar(60), direccionPostalLinea1 || 'Sin definir')
      .input('PostalPostalCode', sql.NVarChar(10), codigoPostal || '00000')
      .execute('Prov_sp_ActualizarProveedor');

    res.json(resultado.recordset[0]);

  } catch (error) {
    console.error('Error al actualizar proveedor:', error);

    res.status(500).json({
      mensaje: 'Error al actualizar proveedor',
      error: error.message
    });
  }
}

/**
 * Elimina un proveedor del sistema
 * @param {Object} req - Objeto de solicitud Express
 * @param {Object} req.params - Parámetros de la URL
 * @param {string} req.params.id - ID del proveedor a eliminar
 * @param {Object} res - Objeto de respuesta Express
 * @returns {Promise<void>} Devuelve el resultado de la eliminación
 */
async function eliminarProveedor(req, res) {
  try {
    const idProveedor = req.params.id;

    const conexion = await conectarBD();

    const resultado = await conexion
      .request()
      .input('SupplierID', sql.Int, idProveedor)
      .execute('Prov_sp_EliminarProveedor');

    res.json(resultado.recordset[0]);

  } catch (error) {
    console.error('Error al eliminar proveedor:', error);

    res.status(500).json({
      mensaje: 'Error al eliminar proveedor',
      error: error.message
    });
  }
}

module.exports = {
  listarProveedores,
  detalleProveedor,
  insertarProveedor,
  actualizarProveedor,
  eliminarProveedor
};