
/**
 * Middleware para verificar que el usuario tenga una sesión activa
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 * @param {import('express').NextFunction} siguiente - Función para pasar al siguiente middleware
 */
function verificarSesion(solicitud, respuesta, siguiente) {
  if (solicitud.session == null) {
    return respuesta.status(401).json({
      mensaje: 'Debe iniciar sesión'
    });
  }

  if (solicitud.session.usuario == null) {
    return respuesta.status(401).json({
      mensaje: 'Debe iniciar sesión'
    });
  }

  siguiente();
}

/**
 * Middleware para verificar que el usuario sea Administrador de una sucursal (SanJosé o Limón)
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 * @param {import('express').NextFunction} siguiente - Función para pasar al siguiente middleware
 */
function verificarAdministrador(solicitud, respuesta, siguiente) {
  if (solicitud.session == null || solicitud.session.usuario == null) {
    return respuesta.status(401).json({
      mensaje: 'Debe iniciar sesión'
    });
  }

  const usuario = solicitud.session.usuario;

  if (usuario.rol != 'Administrador') {
    return respuesta.status(403).json({
      mensaje: 'No tiene permisos de administrador'
    });
  }

  if (usuario.sucursal != 'SanJose' && usuario.sucursal != 'Limon') {
    return respuesta.status(403).json({
      mensaje: 'Sucursal no autorizada'
    });
  }

  siguiente();
}

/**
 * Middleware para verificar que el usuario sea de rol Corporativo y esté en la sucursal Corporativo
 * @param {import('express').Request} solicitud - Objeto de solicitud Express
 * @param {import('express').Response} respuesta - Objeto de respuesta Express
 * @param {import('express').NextFunction} siguiente - Función para pasar al siguiente middleware
 */
function verificarCorporativo(solicitud, respuesta, siguiente) {
  if (solicitud.session == null || solicitud.session.usuario == null) {
    return respuesta.status(401).json({
      mensaje: 'Debe iniciar sesión'
    });
  }

  const usuario = solicitud.session.usuario;

  if (usuario.rol != 'Corporativo') {
    return respuesta.status(403).json({
      mensaje: 'No tiene permisos corporativos'
    });
  }

  if (usuario.sucursal != 'Corporativo') {
    return respuesta.status(403).json({
      mensaje: 'Sucursal no autorizada'
    });
  }

  siguiente();
}

module.exports = {
  verificarSesion,
  verificarAdministrador,
  verificarCorporativo
};
