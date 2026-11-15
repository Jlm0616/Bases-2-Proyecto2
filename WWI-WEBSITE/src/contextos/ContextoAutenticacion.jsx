
import { createContext, useCallback, useEffect, useState } from 'react';
import {
  iniciarSesion as iniciarSesionAPI,
  obtenerSesion as obtenerSesionAPI,
  cerrarSesion as cerrarSesionAPI
} from '../servicios/autenticacion';

// Contexto compartido para la autenticación
export const ContextoAutenticacion = createContext(null);

/**
 * Proveedor que administra la sesión del usuario.
 */
export function ProveedorAutenticacion({ children }) {
  const [usuario, setUsuario] = useState(null);
  const [cargando, setCargando] = useState(true);

  // Recuperar la sesión al cargar la aplicación
  useEffect(() => {
    let activo = true;

    async function verificarSesion() {
      try {
        const datos = await obtenerSesionAPI();

        if (activo) {
          setUsuario(datos.usuario);
        }
      } catch {
        if (activo) {
          setUsuario(null);
        }
      } finally {
        if (activo) {
          setCargando(false);
        }
      }
    }

    verificarSesion();

    return () => {
      activo = false;
    };
  }, []);

  // Iniciar sesión
  const iniciarSesion = useCallback(async (nombreUsuario, contrasena) => {
    const datos = await iniciarSesionAPI(nombreUsuario, contrasena);

    setUsuario(datos.usuario);

    return datos;
  }, []);

  // Cerrar sesión
  const cerrarSesion = useCallback(async () => {
    await cerrarSesionAPI();
    setUsuario(null);
  }, []);

  return (
    <ContextoAutenticacion.Provider
      value={{
        usuario,
        cargando,
        autenticado: usuario !== null,
        iniciarSesion,
        cerrarSesion
      }}
    >
      {children}
    </ContextoAutenticacion.Provider>
  );
}
