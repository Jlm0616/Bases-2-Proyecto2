
import { useState } from 'react';
import { useContext } from 'react';
import { ContextoAutenticacion } from '../contextos/ContextoAutenticacion';
import '../estilos/login.css';

/**
 * Página de inicio de sesión de WideWorldImporters.
 */
export default function Login() {
  const { iniciarSesion } = useContext(ContextoAutenticacion);

  const [usuario, setUsuario] = useState('');
  const [contrasena, setContrasena] = useState('');
  const [error, setError] = useState('');
  const [cargando, setCargando] = useState(false);

  async function manejarInicioSesion(evento) {
    evento.preventDefault();
    setError('');
    setCargando(true);

    try {
      await iniciarSesion(usuario, contrasena);
    } catch (error) {
      setError(error.message);
    } finally {
      setCargando(false);
    }
  }

  return (
    <main className="login-contenedor">
      <section className="login-tarjeta">
        <div className="login-encabezado">
          <div className="login-logo">WWI</div>

          <h1>WideWorldImporters</h1>
          <p>Sistema de Gestión Distribuida</p>
        </div>

        <form onSubmit={manejarInicioSesion}>
          <div className="login-campo">
            <label htmlFor="usuario">Usuario</label>
            <input
              id="usuario"
              type="text"
              value={usuario}
              onChange={(evento) => setUsuario(evento.target.value)}
              placeholder="Ingrese su usuario"
              autoComplete="username"
              maxLength={50}
              required
            />
          </div>

          <div className="login-campo">
            <label htmlFor="contrasena">Contraseña</label>
            <input
              id="contrasena"
              type="password"
              value={contrasena}
              onChange={(evento) => setContrasena(evento.target.value)}
              placeholder="Ingrese su contraseña"
              autoComplete="current-password"
              required
            />
          </div>

          {error && (
            <p className="login-error" role="alert">
              {error}
            </p>
          )}

          <button
            type="submit"
            className="login-boton"
            disabled={cargando}
          >
            {cargando ? 'Iniciando sesión...' : 'Iniciar sesión'}
          </button>
        </form>

        <footer className="login-pie">
          WideWorldImporters · Sistema Corporativo
        </footer>
      </section>
    </main>
  );
}
