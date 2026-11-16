
import { useContext, useState } from 'react';

import { ContextoAutenticacion } from '../../contextos/ContextoAutenticacion';

import BarraSuperior from '../../componentes/BarraSuperior';
import BarraLateral from '../../componentes/BarraLateral';

import Reportes from './Reportes';

import '../../estilos/estructuraPanel.css';

export default function InicioCorporativo() {
  const { usuario } = useContext(ContextoAutenticacion);

  const [seccionActiva, cambiarSeccion] = useState('inicio');

  function mostrarContenido() {
    switch (seccionActiva) {
      case 'inicio':
        return (
          <>
            <h1>Panel Corporativo</h1>

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
                <strong>Ubicación:</strong> Corporativo
              </p>
            </section>
          </>
        );

      case 'reportes':
        return <Reportes />;

      default:
        return (
          <section className="panel-tarjeta">
            <h2>Sección no disponible</h2>

            <p>
              Seleccione una opción válida del menú.
            </p>
          </section>
        );
    }
  }

  return (
    <div className="panel-contenedor">
      <BarraSuperior />

      <div className="panel-cuerpo">
        <BarraLateral
          seccionActiva={seccionActiva}
          cambiarSeccion={cambiarSeccion}
        />

        <main className="panel-contenido">
          {mostrarContenido()}
        </main>
      </div>
    </div>
  );
}
