
import { useContext } from 'react';
import {
  ContextoAutenticacion
} from './contextos/ContextoAutenticacion';

import Login from './paginas/Login';
import InicioCorporativo from './paginas/corporativo/InicioCorporativo';
import InicioSucursal from './paginas/sucursal/InicioSucursal';

function App() {
  const { usuario, cargando } = useContext(ContextoAutenticacion);

  if (cargando) {
    return <p>Verificando sesión...</p>;
  }

  if (!usuario) {
    return <Login />;
  }

  // Panel exclusivo del Corporativo
  if (
    usuario.rol === 'Corporativo' &&
    usuario.sucursal === 'Corporativo'
  ) {
    return <InicioCorporativo />;
  }

  // Panel de administradores de sucursales
  if (
    usuario.rol === 'Administrador' &&
    ['SanJose', 'Limon'].includes(usuario.sucursal)
  ) {
    return <InicioSucursal />;
  }

  // Usuario sin rol o sucursal autorizados
  return (
    <main>
      <h1>Acceso no autorizado</h1>
      <p>Tu usuario no tiene un rol o sucursal válida.</p>
    </main>
  );
}

export default App;
