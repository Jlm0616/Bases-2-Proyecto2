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

const camposGenerales = {
  SupplierName: sql.NVarChar(100),
  SupplierCategoryID: sql.Int,
  PaymentDays: sql.Int,
  SupplierReference: sql.NVarChar(20)
};

const camposPrivados = {
  PrimaryContactPersonID: sql.Int,
  AlternateContactPersonID: sql.Int,
  DeliveryCityID: sql.Int,
  PostalCityID: sql.Int,
  PhoneNumber: sql.NVarChar(20),
  FaxNumber: sql.NVarChar(20),
  WebsiteURL: sql.NVarChar(256),
  DeliveryAddressLine1: sql.NVarChar(60),
  DeliveryPostalCode: sql.NVarChar(10),
  PostalAddressLine1: sql.NVarChar(60),
  PostalPostalCode: sql.NVarChar(10),
  DeliveryMethodID: sql.Int,
  BankAccountName: sql.NVarChar(50),
  BankAccountBranch: sql.NVarChar(50),
  BankAccountCode: sql.NVarChar(20),
  BankAccountNumber: sql.NVarChar(20),
  BankInternationalCode: sql.NVarChar(20),
  InternalComments: sql.NVarChar(sql.MAX),
  DeliveryAddressLine2: sql.NVarChar(60),
  PostalAddressLine2: sql.NVarChar(60)
};

const obligatorios = [
  "SupplierName",
  "SupplierCategoryID",
  "PaymentDays",
  "PrimaryContactPersonID",
  "AlternateContactPersonID",
  "DeliveryCityID",
  "PostalCityID",
  "PhoneNumber",
  "FaxNumber",
  "WebsiteURL",
  "DeliveryAddressLine1",
  "DeliveryPostalCode",
  "PostalAddressLine1",
  "PostalPostalCode"
];

function validarDatos(datos) {
  return obligatorios.filter(
    campo => datos[campo] === undefined ||
      datos[campo] === null ||
      datos[campo] === ""
  );
}

function agregarCampos(request, campos, datos) {
  for (const [nombre, tipo] of Object.entries(campos)) {
    request.input(nombre, tipo, datos[nombre] ?? null);
  }

  return request;
}

function errorSQL(error) {
  return error.originalError?.info?.message || error.message;
}

function validarSucursal(solicitud, respuesta) {
  const sucursal = solicitud.session?.usuario?.sucursal;

  if (!["SanJose", "Limon"].includes(sucursal)) {
    respuesta.status(403).json({
      mensaje: "Solo los administradores de sucursal pueden modificar proveedores"
    });
    return null;
  }

  return sucursal;
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

async function crearProveedor(solicitud, respuesta) {
  const sucursal = validarSucursal(solicitud, respuesta);
  if (!sucursal) return;

  const faltantes = validarDatos(solicitud.body);

  if (faltantes.length) {
    return respuesta.status(400).json({
      mensaje: "Faltan campos obligatorios",
      campos: faltantes
    });
  }

  let supplierID = null;
  let generalCreado = false;

  try {
    const corporativo = await conectarCorporativo();
    const conexionSucursal = await conectarSucursal(sucursal);

    const resultadoID = await corporativo.request()
      .execute("dbo.Prov_sp_GenerarSupplierID");

    supplierID = resultadoID.recordset?.[0]?.SupplierID;

    if (!Number.isInteger(supplierID) || supplierID <= 0) {
      throw new Error("Corporativo no devolvió un SupplierID válido");
    }

    const general = agregarCampos(
      conexionSucursal.request(),
      camposGenerales,
      solicitud.body
    );

    general.input("SupplierID", sql.Int, supplierID);
    general.input(
      "LastEditedBy",
      sql.Int,
      solicitud.session.usuario.id
    );

    await general.execute("dbo.Prov_sp_InsertarProveedorGeneral");
    generalCreado = true;

    const privado = agregarCampos(
      corporativo.request(),
      camposPrivados,
      solicitud.body
    );

    privado.input("SupplierID", sql.Int, supplierID);

    await privado.execute("dbo.Prov_sp_InsertarProveedorPrivado");

    return respuesta.status(201).json({
      mensaje: "Proveedor creado correctamente",
      SupplierID: supplierID,
      sucursal: sucursal
    });
  } catch (error) {
    console.error("Error al crear proveedor:", error);

    let compensacion = "No requerida";

    if (generalCreado) {
      try {
        const conexion = await conectarSucursal(sucursal);

        await conexion.request()
          .input("SupplierID", sql.Int, supplierID)
          .execute("dbo.Prov_sp_EliminarProveedorGeneral");

        compensacion = "Realizada";
      } catch (errorCompensacion) {
        console.error("Error de compensación:", errorCompensacion);
        compensacion = "Fallida: requiere revisión manual";
      }
    }

    return respuesta.status(500).json({
      mensaje: "No se pudo crear el proveedor",
      error: errorSQL(error),
      SupplierID: supplierID,
      compensacion: compensacion
    });
  }
}

async function actualizarProveedor(solicitud, respuesta) {
  const sucursal = validarSucursal(solicitud, respuesta);
  if (!sucursal) return;

  const supplierID = Number(solicitud.params.id);

  if (!Number.isSafeInteger(supplierID) || supplierID <= 0) {
    return respuesta.status(400).json({
      mensaje: "ID de proveedor inválido"
    });
  }

  const faltantes = validarDatos(solicitud.body);

  if (faltantes.length) {
    return respuesta.status(400).json({
      mensaje: "Faltan campos obligatorios",
      campos: faltantes
    });
  }

  let generalActualizado = false;

  try {
    const conexionSucursal = await conectarSucursal(sucursal);
    const corporativo = await conectarCorporativo();

    const general = agregarCampos(
      conexionSucursal.request(),
      camposGenerales,
      solicitud.body
    );

    general.input("SupplierID", sql.Int, supplierID);
    general.input(
      "LastEditedBy",
      sql.Int,
      solicitud.session.usuario.id
    );

    await general.execute("dbo.Prov_sp_ActualizarProveedorGeneral");
    generalActualizado = true;

    const privado = agregarCampos(
      corporativo.request(),
      camposPrivados,
      solicitud.body
    );

    privado.input("SupplierID", sql.Int, supplierID);

    await privado.execute("dbo.Prov_sp_ActualizarProveedorPrivado");

    return respuesta.json({
      mensaje: "Proveedor actualizado correctamente",
      SupplierID: supplierID
    });
  } catch (error) {
    console.error("Error al actualizar proveedor:", error);

    return respuesta.status(500).json({
      mensaje: "No se pudo completar la actualización",
      error: errorSQL(error),
      actualizacionParcialPosible: generalActualizado
    });
  }
}

async function eliminarProveedor(solicitud, respuesta) {
  const sucursal = validarSucursal(solicitud, respuesta);
  if (!sucursal) return;

  const supplierID = Number(solicitud.params.id);

  if (!Number.isSafeInteger(supplierID) || supplierID <= 0) {
    return respuesta.status(400).json({
      mensaje: "ID de proveedor inválido"
    });
  }

  let generalEliminado = false;

  try {
    const conexionSucursal = await conectarSucursal(sucursal);
    const corporativo = await conectarCorporativo();

    await conexionSucursal.request()
      .input("SupplierID", sql.Int, supplierID)
      .execute("dbo.Prov_sp_EliminarProveedorGeneral");

    generalEliminado = true;

    await corporativo.request()
      .input("SupplierID", sql.Int, supplierID)
      .execute("dbo.Prov_sp_EliminarProveedorPrivado");

    return respuesta.json({
      mensaje: "Proveedor eliminado correctamente",
      SupplierID: supplierID
    });
  } catch (error) {
    console.error("Error al eliminar proveedor:", error);

    return respuesta.status(500).json({
      mensaje: "No se pudo completar la eliminación",
      error: errorSQL(error),
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
