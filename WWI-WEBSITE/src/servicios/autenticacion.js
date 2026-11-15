
import { solicitarAPI } from './api';

/**
 * Inicia sesión utilizando las credenciales del usuario.
 * @param {string} usuario - Nombre de usuario.
 * @param {string} contrasena - Contraseña del usuario.
 * @returns {Promise<object>} Datos de la sesión iniciada.
 */
export async function iniciarSesion(usuario, contrasena) {
  return solicitarAPI('/autenticacion/iniciar-sesion', {
    method: 'POST',
    body: JSON.stringify({
      usuario,
      contrasena
    })
  });
}

/**
 * Consulta si existe una sesión activa.
 * @returns {Promise<object>} Datos del usuario autenticado.
 */
export async function obtenerSesion() {
  return solicitarAPI('/autenticacion/sesion', {
    method: 'GET'
  });
}

/**
 * Cierra la sesión actual.
 * @returns {Promise<object>} Confirmación del cierre de sesión.
 */
export async function cerrarSesion() {
  return solicitarAPI('/autenticacion/cerrar-sesion', {
    method: 'POST'
  });
}
