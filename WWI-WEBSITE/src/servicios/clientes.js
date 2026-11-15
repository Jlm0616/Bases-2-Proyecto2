
import { solicitarAPI } from './api';

export async function listarClientes({
  nombre = '',
  categoriaID = '',
  pagina = 1,
  tamanoPagina = 25
} = {}) {
  const parametros = new URLSearchParams();

  if (nombre.trim()) {
    parametros.set('nombre', nombre.trim());
  }

  if (categoriaID !== '') {
    parametros.set('categoriaID', categoriaID);
  }

  parametros.set('pagina', String(pagina));
  parametros.set('tamanoPagina', String(tamanoPagina));

  return solicitarAPI(
    `/clientes?${parametros.toString()}`
  );
}

export async function obtenerDetalleCliente(id) {
  return solicitarAPI(`/clientes/${id}`);
}

export async function crearCliente(datosPublicos, datosPrivados) {
  return solicitarAPI('/clientes', {
    method: 'POST',
    body: JSON.stringify({
      datosPublicos,
      datosPrivados
    })
  });
}

export async function actualizarCliente(
  id,
  datosPublicos,
  datosPrivados
) {
  return solicitarAPI(`/clientes/${id}`, {
    method: 'PUT',
    body: JSON.stringify({
      datosPublicos,
      datosPrivados
    })
  });
}

export async function eliminarCliente(id) {
  return solicitarAPI(`/clientes/${id}`, {
    method: 'DELETE'
  });
}
