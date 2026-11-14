
const { sql, conectarCorporativo } = require('../config/db');

// Iniciar sesión
async function iniciarSesion(solicitud, respuesta) {
  try {
    const usuario = solicitud.body.usuario;
    const contrasena = solicitud.body.contrasena;

    if (typeof usuario !== 'string' || typeof contrasena !== 'string') {
      return respuesta.status(400).json({
        mensaje: 'Usuario y contraseña son obligatorios'
      });
    }

    if (usuario.trim() === '' || contrasena === '') {
      return respuesta.status(400).json({
        mensaje: 'Usuario y contraseña son obligatorios'
      });
    }

    // Consultar el usuario en Corporativo
    const conexion = await conectarCorporativo();

    const resultado = await conexion.request()
      .input('Username', sql.NVarChar(50), usuario.trim())
      .input('Password', sql.NVarChar(100), contrasena)
      .execute('Application.Usr_sp_Login');

    if (resultado.recordset.length === 0) {
      return respuesta.status(401).json({
        mensaje: 'Usuario o contraseña incorrectos'
      });
    }

    const datosUsuario = resultado.recordset[0];

    // Validar rol y sucursal
    if (datosUsuario.Role === 'Administrador') {
      if (datosUsuario.Sucursal !== 'SanJose' &&
          datosUsuario.Sucursal !== 'Limon') {
        return respuesta.status(403).json({
          mensaje: 'Sucursal no autorizada'
        });
      }
    } else if (datosUsuario.Role === 'Corporativo') {
      if (datosUsuario.Sucursal !== 'Corporativo') {
        return respuesta.status(403).json({
          mensaje: 'Sucursal no autorizada'
        });
      }
    } else {
      return respuesta.status(403).json({
        mensaje: 'Rol no autorizado'
      });
    }

    // Crear sesión
    solicitud.session.regenerate(function(error) {
      if (error) {
        console.error(error);

        return respuesta.status(500).json({
          mensaje: 'Error al crear la sesión'
        });
      }

      solicitud.session.usuario = {
        id: datosUsuario.UserID,
        nombreUsuario: datosUsuario.Username,
        nombreCompleto: datosUsuario.FullName,
        rol: datosUsuario.Role,
        sucursal: datosUsuario.Sucursal
      };

      solicitud.session.save(function(error) {
        if (error) {
          console.error(error);

          return respuesta.status(500).json({
            mensaje: 'Error al guardar la sesión'
          });
        }

        return respuesta.json({
          mensaje: 'Inicio de sesión exitoso',
          usuario: solicitud.session.usuario
        });
      });
    });

  } catch (error) {
    console.error(error);

    return respuesta.status(500).json({
      mensaje: 'Error al iniciar sesión'
    });
  }
}

// Consultar sesión actual
function obtenerSesion(solicitud, respuesta) {
  if (solicitud.session == null || solicitud.session.usuario == null) {
    return respuesta.status(401).json({
      mensaje: 'No hay una sesión activa'
    });
  }

  return respuesta.json({
    usuario: solicitud.session.usuario
  });
}

// Cerrar sesión
function cerrarSesion(solicitud, respuesta) {
  if (solicitud.session == null) {
    return respuesta.status(401).json({
      mensaje: 'No hay una sesión activa'
    });
  }

  solicitud.session.destroy(function(error) {
    if (error) {
      console.error(error);

      return respuesta.status(500).json({
        mensaje: 'Error al cerrar sesión'
      });
    }

    respuesta.clearCookie('wwi.sid');

    return respuesta.json({
      mensaje: 'Sesión cerrada correctamente'
    });
  });
}

module.exports = {
  iniciarSesion,
  obtenerSesion,
  cerrarSesion
};
