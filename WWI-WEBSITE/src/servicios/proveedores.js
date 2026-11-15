
import { solicitarAPI } from './api';

export async function listarProveedores({
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
    `/proveedores?${parametros.toString()}`
  );
}

export async function obtenerDetalleProveedor(id) {
  return solicitarAPI(`/proveedores/${id}`);
}

export async function crearProveedor(datos) {
  return solicitarAPI('/proveedores', {
    method: 'POST',
    body: JSON.stringify(datos)
  });
}

export async function actualizarProveedor(id, datos) {
  return solicitarAPI(`/proveedores/${id}`, {
    method: 'PUT',
    body: JSON.stringify(datos)
  });
}

export async function eliminarProveedor(id) {
  return solicitarAPI(`/proveedores/${id}`, {
    method: 'DELETE'
  });
}
