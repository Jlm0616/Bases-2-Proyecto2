
import { useContext } from 'react';
import { ContextoAutenticacion } from '../../contextos/ContextoAutenticacion';
import BarraSuperior from '../../componentes/BarraSuperior';
import BarraLateral from '../../componentes/BarraLateral';
import '../../estilos/estructuraPanel.css';

export default function InicioSucursal() {
  const { usuario } = useContext(ContextoAutenticacion);

  const nombresSucursal = {
    SanJose: 'San José',
    Limon: 'Limón'
  };

  const nombreSucursal = nombresSucursal[usuario.sucursal];

  return (
    <div className="panel-contenedor">
      <BarraSuperior />

      <div className="panel-cuerpo">
        <BarraLateral />

        <main className="panel-contenido">
          <h1>Panel de Sucursal — {nombreSucursal}</h1>

          <p>Bienvenido, {usuario.nombreCompleto}</p>

          <section className="panel-tarjeta">
            <h2>Información de la sesión</h2>

            <p>
              <strong>Usuario:</strong> {usuario.nombreUsuario}
            </p>

            <p>
              <strong>Rol:</strong> {usuario.rol}
            </p>

            <p>
              <strong>Sucursal:</strong> {nombreSucursal}
            </p>
          </section>
        </main>
      </div>
    </div>
  );
}
