
import { useContext } from 'react';
import { ContextoAutenticacion } from '../contextos/ContextoAutenticacion';
import '../estilos/barraLateral.css';

export default function BarraLateral({
  seccionActiva = 'inicio',
  cambiarSeccion = () => {}
}) {
  const { usuario } = useContext(ContextoAutenticacion);

  const esCorporativo = usuario.rol === 'Corporativo';

  const opciones = esCorporativo
    ? [
        { id: 'inicio', nombre: 'Inicio', icono: '⌂' },
        { id: 'clientes', nombre: 'Clientes', icono: '♙' },
        { id: 'proveedores', nombre: 'Proveedores', icono: '▣' },
        { id: 'reportes', nombre: 'Reportes', icono: '▥' }
      ]
    : [
        { id: 'inicio', nombre: 'Inicio', icono: '⌂' },
        { id: 'clientes', nombre: 'Clientes', icono: '♙' },
        { id: 'proveedores', nombre: 'Proveedores', icono: '▣' },
        { id: 'productos', nombre: 'Productos', icono: '▣' },
        { id: 'ventas', nombre: 'Ventas', icono: '▤' },
        { id: 'reportes', nombre: 'Reportes', icono: '▥' }
      ];

  return (
    <aside className="barra-lateral">
      <div className="barra-lateral-encabezado">
        <span className="barra-lateral-etiqueta">
          PANEL DE CONTROL
        </span>

        <h2>
          {esCorporativo ? 'Corporativo' : 'Sucursal'}
        </h2>

        {!esCorporativo && (
          <p>
            {usuario.sucursal === 'SanJose'
              ? 'San José'
              : 'Limón'}
          </p>
        )}
      </div>

      <nav className="barra-lateral-menu" aria-label="Menú principal">
        {opciones.map((opcion) => (
          <button
            key={opcion.id}
            type="button"
            className={`barra-lateral-opcion ${
              seccionActiva === opcion.id ? 'activa' : ''
            }`}
            onClick={() => cambiarSeccion(opcion.id)}
          >
            <span className="barra-lateral-icono" aria-hidden="true">
              {opcion.icono}
            </span>
            <span>{opcion.nombre}</span>
          </button>
        ))}
      </nav>

      <div className="barra-lateral-pie">
        WideWorldImporters
      </div>
    </aside>
  );
}
