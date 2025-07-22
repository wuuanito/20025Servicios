# Sistema de Monitoreo de Servicios Docker

Sistema web de monitoreo en tiempo real para servicios Docker con capacidades de control remoto y visualización de logs.

## Características

- 🔄 **Monitoreo en tiempo real** de servicios Docker
- 🎛️ **Control remoto** de servicios (iniciar, detener, reiniciar)
- 📊 **Estadísticas del sistema** (CPU, memoria, disco)
- 📝 **Visualización de logs** en tiempo real
- 🌐 **Interfaz web responsive** accesible desde cualquier dispositivo
- 🔒 **Ejecución con permisos sudo** para control completo
- 📱 **Diseño moderno** con tema oscuro

## Requisitos

- Node.js 16 o superior
- Docker y Docker Compose
- Permisos sudo para el usuario que ejecuta el servicio
- Ubuntu Server (recomendado)

## Instalación

### Opción 1: Instalación con Docker (Recomendado)

El sistema de monitoreo está completamente dockerizado y se incluye en el docker-compose.yml principal:

```bash
# Desde el directorio raíz del proyecto (20025Servicios)
cd /path/to/20025Servicios

# Construir y ejecutar todos los servicios incluyendo el monitor
docker-compose up -d

# Solo construir el servicio de monitoreo
docker-compose build docker-monitor

# Solo ejecutar el servicio de monitoreo
docker-compose up -d docker-monitor
```

### Opción 2: Instalación Manual

```bash
# Navegar al directorio del proyecto
cd /path/to/monitor

# Instalar dependencias
npm install
```

### 2. Configurar permisos (Solo para instalación manual)

**Para Docker**: No se requiere configuración adicional, el contenedor tiene acceso al socket de Docker.

**Para instalación manual**: Configurar permisos sudo:

```bash
# Editar sudoers
sudo visudo

# Agregar la siguiente línea (reemplazar 'username' con tu usuario):
username ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/docker-compose
```

### 3. Configuración

**Para Docker**: La configuración se maneja automáticamente a través de variables de entorno en docker-compose.yml.

**Para instalación manual**: Editar `server.js` y ajustar la configuración:

```javascript
// Configuración en server.js
const DOCKER_COMPOSE_PATH = '/ruta/a/tu/docker-compose.yml';

const SERVICES = [
    { name: 'auth-service', description: 'Servicio de Autenticación', port: '4001' },
    { name: 'solicitudes-service', description: 'Servicio de Solicitudes OT', port: '3001' },
    { name: 'servidor-rps', description: 'Servidor RPS', port: '3002' },
    { name: 'calendar-service', description: 'Servicio de Calendario', port: '3003' },
    { name: 'laboratorio-service', description: 'Servicio de Laboratorio', port: '3004' },
    { name: 'tecnomaco-backend', description: 'Backend Tecnomaco', port: '3005' },
    { name: 'cremer-backend', description: 'Backend Cremer', port: '3006' },
    { name: 'osmosis-service', description: 'Servicio OSMOSIS', port: '8000' }
];
```

## Uso

### Con Docker (Recomendado)

```bash
# Iniciar todos los servicios incluyendo el monitor
docker-compose up -d

# Ver logs del monitor
docker-compose logs -f docker-monitor

# Reiniciar solo el monitor
docker-compose restart docker-monitor

# Detener el monitor
docker-compose stop docker-monitor
```

### Instalación Manual

```bash
# Desarrollo
npm run dev

# Producción
npm start
```

### Acceder a la interfaz web

Abrir navegador y navegar a:
- Local: `http://localhost:3000`
- Red interna: `http://192.168.20.158:3000`

**Nota**: Cuando se ejecuta con Docker, el monitor está disponible automáticamente en el puerto 3000.

## Funcionalidades

### Dashboard Principal
- **Estadísticas del sistema**: CPU, memoria, disco y uptime
- **Controles globales**: Iniciar, reiniciar o detener todos los servicios
- **Estado de servicios**: Vista en tiempo real del estado de cada servicio

### Control de Servicios Individuales
- **Iniciar servicio**: Botón verde con ícono de play
- **Reiniciar servicio**: Botón amarillo con ícono de reinicio
- **Detener servicio**: Botón rojo con ícono de stop
- **Ver logs**: Botón azul para acceder a los logs del servicio

### Visualización de Logs
- Selección de servicio desde dropdown
- Configuración del número de líneas a mostrar
- Actualización en tiempo real
- Función de limpieza de logs

### Notificaciones
- Notificaciones en tiempo real de cambios de estado
- Confirmaciones de comandos ejecutados
- Alertas de errores y problemas de conexión

## Estructura del Proyecto

```
monitor/
├── package.json          # Dependencias y scripts
├── server.js            # Servidor backend Node.js
├── public/
│   ├── index.html       # Interfaz web principal
│   ├── styles.css       # Estilos CSS
│   └── app.js          # Lógica frontend JavaScript
└── README.md           # Este archivo
```

## API Endpoints

### GET /api/services
Obtiene la lista de servicios configurados.

### GET /api/status
Obtiene el estado actual de todos los contenedores.

### GET /api/logs/:service
Obtiene los logs de un servicio específico.
- Query params: `lines` (número de líneas)

### POST /api/start/:service
Inicia un servicio específico.

### POST /api/stop/:service
Detiene un servicio específico.

### POST /api/restart/:service
Reinicia un servicio específico.

### POST /api/start-all
Inicia todos los servicios.

### POST /api/stop-all
Detiene todos los servicios.

### POST /api/restart-all
Reinicia todos los servicios.

### GET /api/system-stats
Obtiene estadísticas del sistema.

## WebSocket Events

El sistema utiliza Socket.IO para actualizaciones en tiempo real:

- `status-update`: Actualización del estado de servicios
- `system-update`: Actualización de estadísticas del sistema
- `service-restarted`: Notificación de servicio reiniciado
- `service-stopped`: Notificación de servicio detenido
- `service-started`: Notificación de servicio iniciado

## Configuración de Firewall

Para acceso desde la red interna:

```bash
# Permitir puerto 3000
sudo ufw allow 3000

# Verificar estado
sudo ufw status
```

## Configuración Docker

### Variables de Entorno

El contenedor Docker utiliza las siguientes variables de entorno:

```yaml
environment:
  - NODE_ENV=production
  - PORT=3000
  - DOCKER_COMPOSE_PATH=/app/docker-compose.yml
```

### Volúmenes Importantes

- `/var/run/docker.sock:/var/run/docker.sock:ro` - Socket de Docker para comunicación
- `./docker-compose.yml:/app/docker-compose.yml:ro` - Archivo de configuración de servicios

### Permisos y Seguridad

El contenedor requiere:
- Acceso al socket de Docker (`privileged: true`)
- Modo de solo lectura para archivos de configuración
- Red compartida con otros servicios

## Configuración como Servicio del Sistema (Solo instalación manual)

Para ejecutar como servicio systemd:

```bash
# Crear archivo de servicio
sudo nano /etc/systemd/system/docker-monitor.service
```

Contenido del archivo:

```ini
[Unit]
Description=Docker Services Monitor
After=network.target

[Service]
Type=simple
User=tu-usuario
WorkingDirectory=/ruta/completa/al/monitor
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

Habilitar y iniciar:

```bash
sudo systemctl daemon-reload
sudo systemctl enable docker-monitor
sudo systemctl start docker-monitor
sudo systemctl status docker-monitor
```

## Solución de Problemas

### Error de permisos
- Verificar configuración de sudo
- Asegurar que el usuario tenga permisos para Docker

### Servicios no aparecen
- Verificar ruta del docker-compose.yml
- Confirmar que los servicios estén definidos correctamente

### No se puede acceder desde la red
- Verificar firewall (puerto 3000)
- Confirmar que el servidor esté escuchando en 0.0.0.0

### Logs no se cargan
- Verificar que los contenedores existan
- Confirmar permisos de Docker

## Seguridad

⚠️ **Importante**: Este sistema ejecuta comandos con permisos sudo. Úsalo solo en redes internas confiables.

- Acceso restringido a red interna
- No exponer a internet público
- Configurar firewall apropiadamente
- Monitorear logs de acceso

## Contribución

Para contribuir al proyecto:
1. Fork del repositorio
2. Crear rama de feature
3. Commit de cambios
4. Push a la rama
5. Crear Pull Request

## Licencia

Este proyecto está bajo licencia MIT.