
const URL_BASE = 'http://localhost:3000/api';

/**
 * Realiza peticiones HTTP al backend de WideWorldImporters.
 * Incluye las cookies necesarias para mantener la sesión.
 */
export async function solicitarAPI(ruta, opciones = {}) {
  const respuesta = await fetch(`${URL_BASE}${ruta}`, {
    ...opciones,
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      ...opciones.headers
    }
  });

  const datos = await respuesta.json();

  if (!respuesta.ok) {
    throw new Error(datos.mensaje || 'Error al comunicarse con el servidor');
  }

  return datos;
}
