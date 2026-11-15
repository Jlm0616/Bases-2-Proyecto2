const {
  sql,
  conectarSanJose,
  conectarLimon,
  conectarCorporativo
} = require('../config/db');

/**
 * Conecta a la base de datos de la sucursal especificada
 * @param {string} sucursal - Nombre de la sucursal ('SanJose' o 'Limon')
 * @returns {Promise<sql.ConnectionPool|null>} Pool de conexión o null si la sucursal no es válida
 */
async function conectarSucursal(sucursal) {
  if (sucursal === 'SanJose') return conectarSanJose();
  if (sucursal === 'Limon') return conectarLimon();
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
 * Valida que los datos de un proveedor contengan los campos obligatorios
 * @param {Object} datos - Datos del proveedor a validar
 * @returns {string[]} Array con los nombres de los campos faltantes
 */
function validarProveedor(datos) {
  const campos = [
    'SupplierName',
    'SupplierCategoryID',
    'PaymentDays',
    'PrimaryContactPersonID',
    'AlternateContactPersonID',
    'DeliveryCityID',
    'PostalCityID',
    'PhoneNumber',
    'FaxNumber',
    'WebsiteURL',
    'DeliveryAddressLine1',
    'DeliveryPostalCode',
    'PostalAddressLine1',
    'PostalPostalCode'
  ];

  return campos.filter(campo =>
    datos[campo] === undefined ||
    datos[campo] === null ||
    datos[campo] === ''
  );
}

/**
 * Agrega los datos generales del proveedor a una petición SQL
 * @param {sql.Request} peticion - Petición SQL
 * @param {Object} datos - Datos del proveedor
 * @returns {sql.Request} Petición SQL con los parámetros agregados
 */
function agregarDatosGenerales(peticion, datos) {
  return peticion
    .input('SupplierName', sql.NVarChar(100), datos.SupplierName)
    .input('SupplierCategoryID', sql.Int, datos.SupplierCategoryID)
    .input('PaymentDays', sql.Int, datos.PaymentDays)
    .input('SupplierReference', sql.NVarChar(20),
      datos.SupplierReference ?? null);
}

/**
 * Agrega los datos privados del proveedor a una petición SQL
 * @param {sql.Request} peticion - Petición SQL
 * @param {Object} datos - Datos del proveedor
 * @returns {sql.Request} Petición SQL con los parámetros agregados
 */
function agregarDatosPrivados(peticion, datos) {
  return peticion
    .input('PrimaryContactPersonID', sql.Int,
      datos.PrimaryContactPersonID)
    .input('AlternateContactPersonID', sql.Int,
      datos.AlternateContactPersonID)
    .input('DeliveryCityID', sql.Int, datos.DeliveryCityID)
    .input('PostalCityID', sql.Int, datos.PostalCityID)
    .input('PhoneNumber', sql.NVarChar(20), datos.PhoneNumber)
    .input('FaxNumber', sql.NVarChar(20), datos.FaxNumber)
    .input('WebsiteURL', sql.NVarChar(256), datos.WebsiteURL)
    .input('DeliveryAddressLine1', sql.NVarChar(60),
      datos.DeliveryAddressLine1)
    .input('DeliveryPostalCode', sql.NVarChar(10),
      datos.DeliveryPostalCode)
    .input('PostalAddressLine1', sql.NVarChar(60),
      datos.PostalAddressLine1)
    .input('PostalPostalCode', sql.NVarChar(10),
      datos.PostalPostalCode)
    .input('DeliveryMethodID', sql.Int,
      datos.DeliveryMethodID ?? null)
    .input('BankAccountName', sql.NVarChar(50),
      datos.BankAccountName ?? null)
    .input('BankAccountBranch', sql.NVarChar(50),
      datos.BankAccountBranch ?? null)
    .input('BankAccountCode', sql.NVarChar(20),
      datos.BankAccountCode ?? null)
    .input('BankAccountNumber', sql.NVarChar(20),
      datos.BankAccountNumber ?? null)
    .input('BankInternationalCode', sql.NVarChar(20),
      datos.BankInternationalCode ?? null)
    .input('InternalComments', sql.NVarChar(sql.MAX),
      datos.InternalComments ?? null)
    .input('DeliveryAddressLine2', sql.NVarChar(60),
      datos.DeliveryAddressLine2 ?? null)
    .input('PostalAddressLine2', sql.NVarChar(60),
      datos.PostalAddressLine2 ?? null);
}

/**
 * Lista proveedores paginados con filtros opcionales
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 */
async function listarProveedores(solicitud, respuesta) {
  try {
    const sucursal = solicitud.session.usuario.sucursal;
    const conexion = await conectarSucursal(sucursal);

    if (!conexion) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    const nombre = solicitud.query.nombre || null;
    const categoriaID = solicitud.query.categoriaID || null;
    const pagina = Number(solicitud.query.pagina || 1);
    const tamanoPagina = Number(solicitud.query.tamanoPagina || 10);

    if (!idValido(pagina) || !idValido(tamanoPagina) ||
        tamanoPagina > 1000 ||
        (categoriaID !== null && !idValido(Number(categoriaID)))) {
      return respuesta.status(400).json({
        mensaje: 'Filtros o paginación no válidos'
      });
    }

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
    console.error('Error al listar proveedores:', error);
    return respuesta.status(500).json({
      mensaje: 'Error al listar proveedores'
    });
  }
}

/**
 * Obtiene el detalle completo de un proveedor (datos públicos y privados)
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 */
async function obtenerDetalleProveedor(solicitud, respuesta) {
  try {
    const id = Number(solicitud.params.id);
    const sucursal = solicitud.session.usuario.sucursal;

    if (!idValido(id)) {
      return respuesta.status(400).json({
        mensaje: 'ID de proveedor no válido'
      });
    }

    const conexion = await conectarSucursal(sucursal);

    if (!conexion) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    const publico = await conexion.request()
      .input('SupplierID', sql.Int, id)
      .execute('dbo.Prov_sp_DetalleProveedor');

    if (publico.recordset.length === 0) {
      return respuesta.status(404).json({
        mensaje: 'Proveedor no encontrado'
      });
    }

    const corporativo = await conectarCorporativo();

    const privado = await corporativo.request()
      .input('SupplierID', sql.Int, id)
      .execute('dbo.Prov_sp_DetalleProveedorPrivado');

    return respuesta.json({
      sucursal,
      proveedor: {
        datosPublicos: publico.recordset[0],
        datosPrivados: privado.recordset[0] || null
      }
    });

  } catch (error) {
    console.error('Error al consultar proveedor:', error);
    return respuesta.status(500).json({
      mensaje: 'Error al obtener el proveedor'
    });
  }
}

/**
 * Crea un nuevo proveedor con datos generales en la sucursal y datos privados en Corporativo
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 */
async function crearProveedor(solicitud, respuesta) {
  let supplierID = null;
  let generalCreado = false;

  try {
    const usuario = solicitud.session.usuario;
    const datos = solicitud.body;

    if (usuario.sucursal !== 'SanJose' &&
        usuario.sucursal !== 'Limon') {
      return respuesta.status(403).json({
        mensaje: 'Solo las sucursales pueden crear proveedores'
      });
    }

    const faltantes = validarProveedor(datos);

    if (faltantes.length > 0) {
      return respuesta.status(400).json({
        mensaje: 'Faltan campos obligatorios',
        campos: faltantes
      });
    }

    const conexion = await conectarSucursal(usuario.sucursal);
    const corporativo = await conectarCorporativo();

    const resultadoID = await corporativo.request()
      .execute('dbo.Prov_sp_GenerarSupplierID');

    supplierID = resultadoID.recordset[0].SupplierID;

    if (!idValido(supplierID)) {
      throw new Error('No se generó un ID válido');
    }

    const general = agregarDatosGenerales(
      conexion.request(), datos
    );

    await general
      .input('SupplierID', sql.Int, supplierID)
      .input('LastEditedBy', sql.Int, usuario.id)
      .execute('dbo.Prov_sp_InsertarProveedorGeneral');

    generalCreado = true;

    const privado = agregarDatosPrivados(
      corporativo.request(), datos
    );

    await privado
      .input('SupplierID', sql.Int, supplierID)
      .execute('dbo.Prov_sp_InsertarProveedorPrivado');

    return respuesta.status(201).json({
      mensaje: 'Proveedor creado correctamente',
      SupplierID: supplierID,
      sucursal: usuario.sucursal
    });

  } catch (error) {
    console.error('Error al crear proveedor:', error);

    let compensacion = 'No requerida';

    if (generalCreado) {
      try {
        const sucursal = solicitud.session.usuario.sucursal;
        const conexion = await conectarSucursal(sucursal);

        await conexion.request()
          .input('SupplierID', sql.Int, supplierID)
          .execute('dbo.Prov_sp_EliminarProveedorGeneral');

        compensacion = 'Realizada';

      } catch (errorCompensacion) {
        console.error('Error de compensación:', errorCompensacion);
        compensacion = 'Fallida: requiere revisión manual';
      }
    }

    return respuesta.status(500).json({
      mensaje: 'No se pudo crear el proveedor',
      SupplierID: supplierID,
      compensacion: compensacion
    });
  }
}

/**
 * Actualiza un proveedor existente (datos generales y privados)
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 */
async function actualizarProveedor(solicitud, respuesta) {
  let generalActualizado = false;

  try {
    const usuario = solicitud.session.usuario;
    const id = Number(solicitud.params.id);
    const datos = solicitud.body;

    if (usuario.sucursal !== 'SanJose' &&
        usuario.sucursal !== 'Limon') {
      return respuesta.status(403).json({
        mensaje: 'Solo las sucursales pueden actualizar proveedores'
      });
    }

    if (!idValido(id)) {
      return respuesta.status(400).json({
        mensaje: 'ID de proveedor no válido'
      });
    }

    const faltantes = validarProveedor(datos);

    if (faltantes.length > 0) {
      return respuesta.status(400).json({
        mensaje: 'Faltan campos obligatorios',
        campos: faltantes
      });
    }

    const conexion = await conectarSucursal(usuario.sucursal);
    const corporativo = await conectarCorporativo();

    const general = agregarDatosGenerales(
      conexion.request(), datos
    );

    await general
      .input('SupplierID', sql.Int, id)
      .input('LastEditedBy', sql.Int, usuario.id)
      .execute('dbo.Prov_sp_ActualizarProveedorGeneral');

    generalActualizado = true;

    const privado = agregarDatosPrivados(
      corporativo.request(), datos
    );

    await privado
      .input('SupplierID', sql.Int, id)
      .execute('dbo.Prov_sp_ActualizarProveedorPrivado');

    return respuesta.json({
      mensaje: 'Proveedor actualizado correctamente',
      SupplierID: id
    });

  } catch (error) {
    console.error('Error al actualizar proveedor:', error);
    return respuesta.status(500).json({
      mensaje: 'No se pudo completar la actualización',
      actualizacionParcialPosible: generalActualizado
    });
  }
}

/**
 * Elimina un proveedor (datos generales en la sucursal y datos privados en Corporativo)
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 */
async function eliminarProveedor(solicitud, respuesta) {
  let generalEliminado = false;

  try {
    const usuario = solicitud.session.usuario;
    const id = Number(solicitud.params.id);

    if (usuario.sucursal !== 'SanJose' &&
        usuario.sucursal !== 'Limon') {
      return respuesta.status(403).json({
        mensaje: 'Solo las sucursales pueden eliminar proveedores'
      });
    }

    if (!idValido(id)) {
      return respuesta.status(400).json({
        mensaje: 'ID de proveedor no válido'
      });
    }

    const conexion = await conectarSucursal(usuario.sucursal);
    const corporativo = await conectarCorporativo();

    await conexion.request()
      .input('SupplierID', sql.Int, id)
      .execute('dbo.Prov_sp_EliminarProveedorGeneral');

    generalEliminado = true;

    await corporativo.request()
      .input('SupplierID', sql.Int, id)
      .execute('dbo.Prov_sp_EliminarProveedorPrivado');

    return respuesta.json({
      mensaje: 'Proveedor eliminado correctamente',
      SupplierID: id
    });

  } catch (error) {
    console.error('Error al eliminar proveedor:', error);
    return respuesta.status(500).json({
      mensaje: 'No se pudo completar la eliminación',
      eliminacionParcialPosible: generalEliminado
    });
  }
}

module.exports = {
  listarProveedores,
  obtenerDetalleProveedor,
  crearProveedor,
  actualizarProveedor,
  eliminarProveedor
};
