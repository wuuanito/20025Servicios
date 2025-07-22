# Servidor RPS - Autocompletado SQL Server

## Descripción
Servicio Node.js que proporciona funcionalidad de autocompletado para órdenes de fabricación conectándose a una base de datos SQL Server.

## Características
- API REST para búsqueda de órdenes de fabricación
- Conexión a SQL Server con configuración flexible
- Endpoint de prueba de conexión
- Health check integrado
- Configuración mediante variables de entorno
- Contenedor Docker optimizado

## Endpoints

### POST /api/search
Busca órdenes de fabricación por término de búsqueda.

**Request Body:**
```json
{
  "term": "término de búsqueda"
}
```

**Response:**
```json
[
  {
    "label": "ORD001",
    "value": "ORD001",
    "description": "Descripción de la orden",
    "quantity": 100,
    "codArticle": "ART001"
  }
]
```

### POST /api/test-connection
Prueba la conexión a la base de datos.

**Request Body:**
```json
{
  "config": {
    "user": "usuario",
    "password": "contraseña",
    "server": "servidor",
    "database": "base_datos"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Conexión exitosa a la base de datos"
}
```

## Variables de Entorno

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `PORT` | Puerto del servidor | `4000` |
| `DB_SERVER` | Servidor SQL Server | `192.168.11.2` |
| `DB_PORT` | Puerto SQL Server | `1433` |
| `DB_NAME` | Nombre de la base de datos | `RpsNext` |
| `DB_USER` | Usuario de la base de datos | `rpsuser` |
| `DB_PASSWORD` | Contraseña de la base de datos | `rpsnext` |
| `NODE_ENV` | Entorno de ejecución | `development` |

## Desarrollo Local

### Prerrequisitos
- Node.js 18+
- npm
- Acceso a SQL Server

### Instalación
```bash
npm install
```

### Ejecución
```bash
# Desarrollo
npm run dev

# Producción
npm start
```

## Docker

### Construcción
```bash
docker build -t servidor-rps .
```

### Ejecución
```bash
docker run -p 4000:4000 \
  -e DB_SERVER=tu_servidor \
  -e DB_USER=tu_usuario \
  -e DB_PASSWORD=tu_contraseña \
  servidor-rps
```

## Docker Compose

El servicio está configurado en `docker-compose.yml`:

```yaml
servidor-rps:
  build: ./SERVIDOR_RPS
  container_name: servidor-rps
  ports:
    - "4000:4000"
  environment:
    - NODE_ENV=production
    - PORT=4000
    - DB_SERVER=192.168.20.158
    - DB_PORT=1433
    - DB_NAME=RpsNext
    - DB_USER=rpsuser
    - DB_PASSWORD=rpsnext
  healthcheck:
    test: ["CMD", "node", "healthcheck.js"]
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 40s
```

### Comandos útiles
```bash
# Iniciar solo el servicio RPS
docker-compose up -d servidor-rps

# Ver logs
docker-compose logs -f servidor-rps

# Reconstruir
docker-compose build --no-cache servidor-rps

# Health check manual
docker-compose exec servidor-rps node healthcheck.js
```

## Estructura del Proyecto
```
SERVIDOR_RPS/
├── server.js           # Servidor principal
├── package.json        # Dependencias y scripts
├── package-lock.json   # Lock de dependencias
├── Dockerfile          # Configuración Docker
├── .dockerignore       # Archivos excluidos de Docker
├── healthcheck.js      # Script de health check
└── README.md          # Esta documentación
```

## Seguridad
- Ejecuta como usuario no-root en el contenedor
- Usa dumb-init para manejo de señales
- Variables de entorno para configuración sensible
- Health check para monitoreo

## Troubleshooting

### Error de conexión a la base de datos
1. Verificar que SQL Server esté ejecutándose
2. Comprobar las credenciales en las variables de entorno
3. Verificar conectividad de red
4. Usar el endpoint `/api/test-connection` para diagnóstico

### Problemas de construcción Docker
1. Limpiar cache: `docker system prune -a`
2. Reconstruir sin cache: `docker-compose build --no-cache servidor-rps`
3. Verificar que todos los archivos estén presentes

### Health check fallando
1. Verificar que el puerto 4000 esté disponible
2. Comprobar logs del contenedor
3. Ejecutar health check manualmente

## Monitoreo

El servicio incluye:
- Health check automático cada 30 segundos
- Logs estructurados
- Endpoint de prueba de conexión
- Manejo de errores detallado