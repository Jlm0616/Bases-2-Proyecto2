
import { useContext, useState } from 'react';
import { ContextoAutenticacion } from '../../contextos/ContextoAutenticacion';

import BarraSuperior from '../../componentes/BarraSuperior';
import BarraLateral from '../../componentes/BarraLateral';

import Clientes from './Clientes';
import Productos from './Productos';

import '../../estilos/estructuraPanel.css';

export default function InicioSucursal() {
  const { usuario } = useContext(ContextoAutenticacion);

  const [seccionActiva, setSeccionActiva] = useState('inicio');

  const nombresSucursal = {
    SanJose: 'San José',
    Limon: 'Limón'
  };

  const nombreSucursal = nombresSucursal[usuario.sucursal];

  function mostrarContenido() {
    switch (seccionActiva) {
      case 'clientes':
        return <Clientes />;

      case 'productos':
        return <Productos />;

      case 'inicio':
        return (
          <>
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
          </>
        );

      default:
        return (
          <>
            <h1>Sección en desarrollo</h1>
            <p>
              El módulo seleccionado todavía no está implementado.
            </p>
          </>
        );
    }
  }

  return (
    <div className="panel-contenedor">
      <BarraSuperior />

      <div className="panel-cuerpo">
        <BarraLateral
          seccionActiva={seccionActiva}
          cambiarSeccion={setSeccionActiva}
        />

        <main className="panel-contenido">
          {mostrarContenido()}
        </main>
      </div>
    </div>
  );
}
