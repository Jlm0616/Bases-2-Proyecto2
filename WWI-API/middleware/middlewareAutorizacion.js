
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
