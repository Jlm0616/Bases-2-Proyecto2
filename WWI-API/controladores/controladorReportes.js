const { sql, conectarCorporativo } = require('../config/db');

const reportes = {
  'montos-proveedores': {
    procedimiento: 'dbo.Rpt_sp_MontosProveedores',
    filtros: {
      NombreProveedor: 'texto',
      Categoria: 'texto'
    }
  },

  'montos-clientes': {
    procedimiento: 'dbo.Rpt_sp_MontosClientes',
    filtros: {
      NombreCliente: 'texto',
      Categoria: 'texto'
    }
  },

  'top5-productos-ganancia': {
    procedimiento: 'dbo.Rpt_sp_Top5ProductosPorGanancia',
    filtros: {
      Anio: 'numero'
    }
  },

  'top5-clientes-facturas': {
    procedimiento: 'dbo.Rpt_sp_Top5ClientesPorFacturas',
    filtros: {
      AnioInicio: 'numero',
      AnioFin: 'numero'
    }
  },

  'top5-proveedores-ordenes': {
    procedimiento: 'dbo.Rpt_sp_Top5ProveedoresPorOrdenes',
    filtros: {
      AnioInicio: 'numero',
      AnioFin: 'numero'
    }
  },

  'matriz-ventas-categoria': {
    procedimiento: 'dbo.Rpt_sp_MatrizVentasPorCategoria',
    filtros: {}
  },

  'seguimiento-compras-cliente': {
    procedimiento: 'dbo.Rpt_sp_SeguimientoComprasCliente',
    filtros: {
      Anio: 'numero',
      Mes: 'numero',
      Categoria: 'texto',
      Subcategoria: 'texto'
    }
  },

  'seguimiento-compras-proveedor': {
    procedimiento: 'dbo.Rpt_sp_SeguimientoComprasProveedor',
    filtros: {
      Anio: 'numero',
      Mes: 'numero',
      Categoria: 'texto',
      Subcategoria: 'texto'
    }
  },

  'rotacion-inventario': {
    procedimiento: 'dbo.Rpt_sp_RotacionInventario',
    filtros: {
      Categoria: 'texto',
      Anio: 'numero',
      Proveedor: 'texto'
    }
  },

  'metodo-envio-favorito-zona': {
    procedimiento: 'dbo.Rpt_sp_MetodoEnvioFavoritoPorZona',
    filtros: {
      Anio: 'numero',
      Mes: 'numero',
      CategoriaCliente: 'texto',
      CategoriaProducto: 'texto',
      Producto: 'texto'
    }
  }
};

function usuarioCorporativo(solicitud) {
  const usuario = solicitud.session?.usuario;

  return usuario &&
    usuario.rol === 'Corporativo' &&
    usuario.sucursal === 'Corporativo';
}

function listarReportes(solicitud, respuesta) {
  if (!solicitud.session?.usuario) {
    return respuesta.status(401).json({
      mensaje: 'Debe iniciar sesión'
    });
  }

  if (!usuarioCorporativo(solicitud)) {
    return respuesta.status(403).json({
      mensaje: 'Solo Corporativo puede consultar reportes'
    });
  }

  const lista = [];

  for (const [ruta, reporte] of Object.entries(reportes)) {
    lista.push({
      ruta: ruta,
      procedimiento: reporte.procedimiento,
      filtros: Object.keys(reporte.filtros)
    });
  }

  return respuesta.json({
    reportes: lista
  });
}

async function ejecutarReporte(solicitud, respuesta) {
  try {
    if (!solicitud.session?.usuario) {
      return respuesta.status(401).json({
        mensaje: 'Debe iniciar sesión'
      });
    }

    if (!usuarioCorporativo(solicitud)) {
      return respuesta.status(403).json({
        mensaje: 'Solo Corporativo puede consultar reportes'
      });
    }

    const nombre = solicitud.params.reporte;
    const reporte = Object.prototype.hasOwnProperty.call(
      reportes, nombre
    ) ? reportes[nombre] : null;

    if (!reporte) {
      return respuesta.status(404).json({
        mensaje: 'Reporte no encontrado'
      });
    }

    for (const nombreFiltro of Object.keys(solicitud.query)) {
      if (!Object.prototype.hasOwnProperty.call(
        reporte.filtros, nombreFiltro
      )) {
        return respuesta.status(400).json({
          mensaje: `Filtro no admitido: ${nombreFiltro}`
        });
      }
    }

    const parametros = {};
    const conexion = await conectarCorporativo();
    const peticion = conexion.request();

    for (const [filtro, tipo] of Object.entries(reporte.filtros)) {
      let valor = solicitud.query[filtro];

      if (valor === undefined || valor === '') {
        valor = null;
      }

      if (valor !== null && typeof valor !== 'string') {
        return respuesta.status(400).json({
          mensaje: `Filtro no válido: ${filtro}`
        });
      }

      if (tipo === 'numero' && valor !== null) {
        if (!/^\d+$/.test(valor)) {
          return respuesta.status(400).json({
            mensaje: `${filtro} debe ser un número entero`
          });
        }

        valor = Number(valor);

        if (!Number.isInteger(valor) || valor < 1 || valor > 9999) {
          return respuesta.status(400).json({
            mensaje: `Valor no válido para ${filtro}`
          });
        }

        if (filtro === 'Mes' && valor > 12) {
          return respuesta.status(400).json({
            mensaje: 'El mes debe estar entre 1 y 12'
          });
        }
      }

      if (tipo === 'texto' && valor !== null &&
          valor.length > 100) {
        return respuesta.status(400).json({
          mensaje: `${filtro} supera los 100 caracteres`
        });
      }

      parametros[filtro] = valor;

      if (tipo === 'numero') {
        peticion.input(filtro, sql.Int, valor);
      } else {
        peticion.input(filtro, sql.NVarChar(100), valor);
      }
    }

    if (parametros.AnioInicio != null &&
        parametros.AnioFin != null &&
        parametros.AnioInicio > parametros.AnioFin) {
      return respuesta.status(400).json({
        mensaje: 'Rango de años no válido'
      });
    }

    const resultado = await peticion.execute(
      reporte.procedimiento
    );

    return respuesta.json({
      reporte: nombre,
      procedimiento: reporte.procedimiento,
      filtros: parametros,
      total: resultado.recordset?.length ?? 0,
      datos: resultado.recordset ?? []
    });

  } catch (error) {
    console.error('Error al ejecutar reporte:', error);
    return respuesta.status(500).json({
      mensaje: 'No se pudo generar el reporte'
    });
  }
}

module.exports = {
  listarReportes,
  ejecutarReporte
};
