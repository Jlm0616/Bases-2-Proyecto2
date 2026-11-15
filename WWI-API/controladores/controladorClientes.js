
const {
  sql,
  conectarSanJose,
  conectarLimon,
  conectarCorporativo
} = require('../config/db');

/**
 * Conecta a la base de datos de la sucursal especificada
 */
async function conectarSucursal(sucursal) {
  if (sucursal === 'SanJose') {
    return conectarSanJose();
  }

  if (sucursal === 'Limon') {
    return conectarLimon();
  }

  return null;
}

/**
 * Valida que un ID sea un entero positivo válido
 */
function idValido(id) {
  return Number.isInteger(id) && id > 0 && id <= 2147483647;
}

/**
 * Lista clientes paginados con filtros opcionales
 */
async function listarClientes(solicitud, respuesta) {
  try {
    const sucursal = solicitud.session.usuario.sucursal;
    const conexion = await conectarSucursal(sucursal);

    if (!conexion) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    const nombre = solicitud.query.nombre || null;
    const categoria = solicitud.query.categoriaID || null;
    const pagina = Number(solicitud.query.pagina || 1);
    const tamanoPagina = Number(solicitud.query.tamanoPagina || 25);

    if (!Number.isInteger(pagina) || pagina < 1 ||
        !Number.isInteger(tamanoPagina) || tamanoPagina < 1 ||
        tamanoPagina > 1000) {
      return respuesta.status(400).json({
        mensaje: 'Paginación no válida'
      });
    }

    if (categoria !== null && !idValido(Number(categoria))) {
      return respuesta.status(400).json({
        mensaje: 'Categoría no válida'
      });
    }

    const resultado = await conexion.request()
      .input('Nombre', sql.NVarChar(100), nombre)
      .input('CategoriaID', sql.Int, categoria)
      .input('PageNumber', sql.Int, pagina)
      .input('PageSize', sql.Int, tamanoPagina)
      .execute('dbo.Cli_sp_ListarClientesPaginado');

    const conteo = await conexion.request()
      .input('Nombre', sql.NVarChar(100), nombre)
      .input('CategoriaID', sql.Int, categoria)
      .execute('dbo.Cli_sp_ContarClientes');

    const totalClientes = conteo.recordset[0].Total;

    return respuesta.json({
      sucursal: sucursal,
      pagina: pagina,
      tamanoPagina: tamanoPagina,
      totalClientes: totalClientes,
      totalPaginas: Math.ceil(totalClientes / tamanoPagina),
      clientes: resultado.recordset
    });

  } catch (error) {
    console.error('Error al listar clientes:', error);

    return respuesta.status(500).json({
      mensaje: 'Error al consultar los clientes'
    });
  }
}

/**
 * Obtiene el detalle completo de un cliente
 */
async function obtenerDetalleCliente(solicitud, respuesta) {
  try {
    const idCliente = Number(solicitud.params.id);
    const sucursal = solicitud.session.usuario.sucursal;

    if (!idValido(idCliente)) {
      return respuesta.status(400).json({
        mensaje: 'ID de cliente no válido'
      });
    }

    const conexionSucursal = await conectarSucursal(sucursal);

    if (!conexionSucursal) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    const publico = await conexionSucursal.request()
      .input('CustomerID', sql.Int, idCliente)
      .execute('dbo.Cli_sp_DetalleCliente');

    if (publico.recordset.length === 0) {
      return respuesta.status(404).json({
        mensaje: 'Cliente no encontrado'
      });
    }

    const conexionCorporativo = await conectarCorporativo();

    const privado = await conexionCorporativo.request()
      .input('CustomerID', sql.Int, idCliente)
      .execute('dbo.Cli_sp_DetalleClientePrivado');

    if (privado.recordset.length === 0) {
      return respuesta.status(409).json({
        mensaje: 'El cliente no tiene datos privados en Corporativo'
      });
    }

    return respuesta.json({
      sucursal: sucursal,
      cliente: {
        datosPublicos: publico.recordset[0],
        datosPrivados: privado.recordset[0]
      }
    });

  } catch (error) {
    console.error('Error al consultar cliente:', error);

    return respuesta.status(500).json({
      mensaje: 'Error al consultar el detalle del cliente'
    });
  }
}

/**
 * Crea un cliente con datos públicos en la sucursal
 * y datos privados en Corporativo.
 */
async function crearCliente(solicitud, respuesta) {
  let idCliente = null;
  let publicoInsertado = false;
  let conexionSucursal = null;
  let conexionCorporativo = null;

  // Evita enviar NULL en campos que necesitan un valor.
  const textoOPredeterminado = (valor, predeterminado) => {
    if (valor === null || valor === undefined) {
      return predeterminado;
    }

    const texto = String(valor).trim();
    return texto.length > 0 ? texto : predeterminado;
  };

  try {
    const sucursal = solicitud.session.usuario.sucursal;
    const datosPublicos = solicitud.body?.datosPublicos;
    const datosPrivados = solicitud.body?.datosPrivados;

    conexionSucursal = await conectarSucursal(sucursal);

    if (!conexionSucursal) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    if (!datosPublicos || !datosPrivados ||
        !datosPublicos.NombreCliente ||
        !idValido(datosPublicos.IdCategoria) ||
        !idValido(datosPrivados.IdContactoPrimario) ||
        !idValido(datosPrivados.IdMetodoEntrega) ||
        !idValido(datosPrivados.IdCiudadEntrega)) {
      return respuesta.status(400).json({
        mensaje: 'Faltan datos obligatorios del cliente'
      });
    }

    conexionCorporativo = await conectarCorporativo();

    // Generar ID único desde Corporativo.
    const resultadoID = await conexionCorporativo.request()
      .output('NuevoCustomerID', sql.Int)
      .execute('dbo.Cli_sp_GenerarCustomerID');

    idCliente = resultadoID.output.NuevoCustomerID;

    // Insertar datos generales en la sucursal.
    await conexionSucursal.request()
      .input('CustomerID', sql.Int, idCliente)
      .input('NombreCliente', sql.NVarChar(100), datosPublicos.NombreCliente)
      .input('CategoriaID', sql.Int, datosPublicos.IdCategoria)
      .input('LastEditedBy', sql.Int, solicitud.session.usuario.id)
      .input('BuyingGroupID', sql.Int, datosPublicos.IdGrupoCompra)
      .input('BillToCustomerID', sql.Int, datosPublicos.IdClienteFacturar)
      .input('AccountOpenedDate', sql.Date, datosPublicos.FechaApertura)
      .input('PaymentDays', sql.Int, datosPublicos.DiasGraciaPago)
      .execute('dbo.Cli_sp_InsertarClienteGeneral');

    publicoInsertado = true;

    // Valores predeterminados para campos privados.
    const telefono = textoOPredeterminado(
      datosPrivados.Telefono,
      'Sin definir'
    );

    const fax = textoOPredeterminado(
      datosPrivados.Fax,
      telefono
    );

    // Insertar datos privados en Corporativo.
    await conexionCorporativo.request()
      .input('CustomerID', sql.Int, idCliente)
      .input('PrimaryContactID', sql.Int, datosPrivados.IdContactoPrimario)
      .input('MetodoEntregaID', sql.Int, datosPrivados.IdMetodoEntrega)
      .input('DeliveryCityID', sql.Int, datosPrivados.IdCiudadEntrega)
      .input('AlternateContactID', sql.Int, datosPrivados.IdContactoAlternativo)
      .input('CreditLimit', sql.Decimal(18, 2), datosPrivados.LimiteCredito)
      .input('PostalCityID', sql.Int, datosPrivados.IdCiudadPostal)
      .input('PhoneNumber', sql.NVarChar(20), telefono)
      .input('FaxNumber', sql.NVarChar(20), fax)
      .input(
        'WebsiteURL',
        sql.NVarChar(256),
        textoOPredeterminado(
          datosPrivados.SitioWeb,
          'http://www.AunNoSe.com'
        )
      )
      .input(
        'DeliveryAddressLine1',
        sql.NVarChar(60),
        textoOPredeterminado(
          datosPrivados.DireccionEntregaLinea1,
          'Sin definir'
        )
      )
      .input(
        'DeliveryAddressLine2',
        sql.NVarChar(60),
        datosPrivados.DireccionEntregaLinea2
      )
      .input(
        'DeliveryPostalCode',
        sql.NVarChar(10),
        textoOPredeterminado(
          datosPrivados.CodigoPostalEntrega,
          '00000'
        )
      )
      .input(
        'PostalAddressLine1',
        sql.NVarChar(60),
        textoOPredeterminado(
          datosPrivados.DireccionPostalLinea1,
          'Sin definir'
        )
      )
      .input(
        'PostalAddressLine2',
        sql.NVarChar(60),
        datosPrivados.DireccionPostalLinea2
      )
      .input(
        'PostalPostalCode',
        sql.NVarChar(10),
        textoOPredeterminado(
          datosPrivados.CodigoPostalPostal,
          '00000'
        )
      )
      .execute('dbo.Cli_sp_InsertarClientePrivado');

    return respuesta.status(201).json({
      mensaje: 'Cliente creado correctamente',
      sucursal: sucursal,
      idCliente: idCliente
    });

  } catch (error) {
    console.error('Error al crear cliente:', error);

    // Si Corporativo falla, intentar revertir la
    // inserción previamente realizada en la sucursal.
    let compensacion = 'no necesaria';

    if (publicoInsertado && idCliente !== null) {
      try {
        // Comprobar si Corporativo llegó a guardar
        // el registro antes de intentar eliminarlo.
        const privado = await conexionCorporativo.request()
          .input('CustomerID', sql.Int, idCliente)
          .query(`
            SELECT CustomerID
            FROM Sales.CustomersPrivate
            WHERE CustomerID = @CustomerID
          `);

        if (privado.recordset.length > 0) {
          compensacion =
            'pendiente: existe registro privado en Corporativo';
        } else {
          await conexionSucursal.request()
            .input('CustomerID', sql.Int, idCliente)
            .execute('dbo.Cli_sp_EliminarClienteGeneral');

          compensacion = 'completada';
          publicoInsertado = false;
        }

      } catch (errorCompensacion) {
        console.error(
          'No se pudo compensar el alta del cliente:',
          errorCompensacion
        );

        compensacion = 'fallida: requiere revisión manual';
      }
    }

    return respuesta.status(500).json({
      mensaje: 'Error al crear el cliente',
      idCliente: idCliente,
      insercionPublicaCompletada: publicoInsertado,
      compensacion: compensacion
    });
  }
}

/**
 * Actualiza los datos públicos y privados de un cliente.
 */
async function actualizarCliente(solicitud, respuesta) {
  try {
    const idCliente = Number(solicitud.params.id);
    const sucursal = solicitud.session.usuario.sucursal;
    const datosPublicos = solicitud.body.datosPublicos;
    const datosPrivados = solicitud.body.datosPrivados;

    if (!idValido(idCliente)) {
      return respuesta.status(400).json({
        mensaje: 'ID de cliente no válido'
      });
    }

    if (!datosPublicos || !datosPrivados) {
      return respuesta.status(400).json({
        mensaje: 'Debe proporcionar los datos públicos y privados'
      });
    }

    const conexionSucursal = await conectarSucursal(sucursal);

    if (!conexionSucursal) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    const conexionCorporativo = await conectarCorporativo();

    await conexionSucursal.request()
      .input('CustomerID', sql.Int, idCliente)
      .input('LastEditedBy', sql.Int, solicitud.session.usuario.id)
      .input('NombreCliente', sql.NVarChar(100), datosPublicos.NombreCliente)
      .input('CategoriaID', sql.Int, datosPublicos.IdCategoria)
      .input('BuyingGroupID', sql.Int, datosPublicos.IdGrupoCompra)
      .input('BillToCustomerID', sql.Int, datosPublicos.IdClienteFacturar)
      .input('PaymentDays', sql.Int, datosPublicos.DiasGraciaPago)
      .execute('dbo.Cli_sp_ActualizarClienteGeneral');

    await conexionCorporativo.request()
      .input('CustomerID', sql.Int, idCliente)
      .input('PrimaryContactID', sql.Int, datosPrivados.IdContactoPrimario)
      .input('AlternateContactID', sql.Int, datosPrivados.IdContactoAlternativo)
      .input('CreditLimit', sql.Decimal(18, 2), datosPrivados.LimiteCredito)
      .input('MetodoEntregaID', sql.Int, datosPrivados.IdMetodoEntrega)
      .input('DeliveryCityID', sql.Int, datosPrivados.IdCiudadEntrega)
      .input('PostalCityID', sql.Int, datosPrivados.IdCiudadPostal)
      .input('PhoneNumber', sql.NVarChar(20), datosPrivados.Telefono)
      .input('FaxNumber', sql.NVarChar(20), datosPrivados.Fax)
      .input('WebsiteURL', sql.NVarChar(256), datosPrivados.SitioWeb)
      .input(
        'DeliveryAddressLine1',
        sql.NVarChar(60),
        datosPrivados.DireccionEntregaLinea1
      )
      .input(
        'DeliveryAddressLine2',
        sql.NVarChar(60),
        datosPrivados.DireccionEntregaLinea2
      )
      .input(
        'DeliveryPostalCode',
        sql.NVarChar(10),
        datosPrivados.CodigoPostalEntrega
      )
      .input(
        'PostalAddressLine1',
        sql.NVarChar(60),
        datosPrivados.DireccionPostalLinea1
      )
      .input(
        'PostalAddressLine2',
        sql.NVarChar(60),
        datosPrivados.DireccionPostalLinea2
      )
      .input(
        'PostalPostalCode',
        sql.NVarChar(10),
        datosPrivados.CodigoPostalPostal
      )
      .execute('dbo.Cli_sp_ActualizarClientePrivado');

    return respuesta.json({
      mensaje: 'Cliente actualizado correctamente',
      sucursal: sucursal,
      idCliente: idCliente
    });

  } catch (error) {
    console.error('Error al actualizar cliente:', error);

    return respuesta.status(500).json({
      mensaje: 'Error al actualizar el cliente',
      detalle: error.message
    });
  }
}

/**
 * Elimina los datos privados en Corporativo y
 * los datos generales en la sucursal.
 */
async function eliminarCliente(solicitud, respuesta) {
  try {
    const idCliente = Number(solicitud.params.id);
    const sucursal = solicitud.session.usuario.sucursal;

    if (!idValido(idCliente)) {
      return respuesta.status(400).json({
        mensaje: 'ID de cliente no válido'
      });
    }

    const conexionSucursal = await conectarSucursal(sucursal);

    if (!conexionSucursal) {
      return respuesta.status(403).json({
        mensaje: 'Sucursal no autorizada'
      });
    }

    const conexionCorporativo = await conectarCorporativo();

    await conexionCorporativo.request()
      .input('CustomerID', sql.Int, idCliente)
      .execute('dbo.Cli_sp_EliminarClientePrivado');

    await conexionSucursal.request()
      .input('CustomerID', sql.Int, idCliente)
      .execute('dbo.Cli_sp_EliminarClienteGeneral');

    return respuesta.json({
      mensaje: 'Cliente eliminado correctamente',
      sucursal: sucursal,
      idCliente: idCliente
    });

  } catch (error) {
    console.error('Error al eliminar cliente:', error);

    return respuesta.status(500).json({
      mensaje: 'Error al eliminar el cliente',
      detalle: error.message
    });
  }
}

module.exports = {
  listarClientes,
  obtenerDetalleCliente,
  crearCliente,
  actualizarCliente,
  eliminarCliente
};
