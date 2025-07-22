# Microservicios - Despliegue con Docker

Este proyecto contiene 8 microservicios que se pueden desplegar fácilmente usando Docker Compose en un servidor Ubuntu.

## Servicios Incluidos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| auth-service | 4001 | Servicio de autenticación y autorización |
| solicitudes-service | 3001 | Sistema de solicitudes OT |
| servidor-rps | 3002 | Servidor RPS para SQL Server |
| calendar-service | 3003 | Servicio de gestión de calendario |
| laboratorio-service | 3004 | Gestión de defectos de laboratorio |
| tecnomaco-backend | 3005 | Backend para Tecnomaco |
| cremer-backend | 3006 | Backend para Cremer |
| osmosis-service | 8000 | Servicio de monitoreo de ósmosis |

## Bases de Datos

- **MySQL Principal** (Puerto 3306): Para la mayoría de servicios
- **MySQL OSMOSIS** (Puerto 3050): Específico para el servicio de ósmosis

## Requisitos Previos

### En Ubuntu Server:

1. **Instalar Docker:**
```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce
```

2. **Instalar Docker Compose:**
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

3. **Agregar usuario al grupo docker:**
```bash
sudo usermod -aG docker $USER
# Cerrar sesión y volver a iniciar para aplicar cambios
```

## Despliegue

### 1. Clonar el repositorio
```bash
git clone <tu-repositorio>
cd 20025Servicios
```

### 2. Configurar variables de entorno (opcional)
Puedes modificar las variables de entorno en el archivo `docker-compose.yml` según tus necesidades:
- Contraseñas de base de datos
- Secretos JWT
- URLs de frontend
- Configuraciones específicas

### 3. Construir y ejecutar todos los servicios
```bash
# Construir todas las imágenes
docker-compose build

# Ejecutar todos los servicios
docker-compose up -d
```

### 4. Verificar el estado de los servicios
```bash
# Ver todos los contenedores
docker-compose ps

# Ver logs de todos los servicios
docker-compose logs

# Ver logs de un servicio específico
docker-compose logs auth-service
```

## Comandos Útiles

### Gestión de servicios
```bash
# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v

# Reiniciar un servicio específico
docker-compose restart auth-service

# Reconstruir un servicio específico
docker-compose build auth-service
docker-compose up -d auth-service
```

### Monitoreo
```bash
# Ver uso de recursos
docker stats

# Acceder a un contenedor
docker-compose exec auth-service sh

# Ver logs en tiempo real
docker-compose logs -f auth-service
```

### Base de datos
```bash
# Conectar a MySQL principal
docker-compose exec mysql mysql -u naturepharma -p

# Conectar a MySQL OSMOSIS
docker-compose exec mysql-osmosis mysql -u root -p

# Backup de base de datos
docker-compose exec mysql mysqldump -u naturepharma -p sistema_solicitudes > backup.sql
```

## Configuración de Red

Todos los servicios están en la misma red Docker (`microservices-network`), lo que permite:
- Comunicación entre servicios usando nombres de contenedor
- Aislamiento de la red externa
- Balanceador de carga interno

## Volúmenes Persistentes

- `mysql_data`: Datos de MySQL principal
- `mysql_osmosis_data`: Datos de MySQL OSMOSIS
- Uploads de archivos mapeados a directorios locales

## Puertos Expuestos

| Puerto | Servicio |
|--------|----------|
| 3001 | Solicitudes OT |
| 3002 | Servidor RPS |
| 3003 | Calendar Service |
| 3004 | Laboratorio Service |
| 3005 | Tecnomaco Backend |
| 3006 | Cremer Backend |
| 3306 | MySQL Principal |
| 3050 | MySQL OSMOSIS |
| 4001 | Auth Service |
| 8000 | OSMOSIS Service |

## Solución de Problemas

### Problemas comunes:

1. **Puerto ya en uso:**
```bash
# Verificar qué proceso usa el puerto
sudo netstat -tulpn | grep :3001
# Detener el proceso o cambiar el puerto en docker-compose.yml
```

2. **Problemas de permisos:**
```bash
# Asegurar permisos correctos
sudo chown -R $USER:$USER .
sudo chmod -R 755 .
```

3. **Problemas de memoria:**
```bash
# Limpiar imágenes no utilizadas
docker system prune -a

# Ver uso de espacio
docker system df
```

4. **Reiniciar todo el sistema:**
```bash
docker-compose down
docker system prune -a
docker-compose build --no-cache
docker-compose up -d
```

## Configuración de Firewall (Ubuntu)

```bash
# Permitir puertos necesarios
sudo ufw allow 3001:3006/tcp
sudo ufw allow 4001/tcp
sudo ufw allow 8000/tcp
sudo ufw allow 22/tcp  # SSH
sudo ufw enable
```

## Backup y Restauración

### Backup completo:
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p backups/$DATE

# Backup bases de datos
docker-compose exec mysql mysqldump -u naturepharma -p --all-databases > backups/$DATE/mysql_backup.sql
docker-compose exec mysql-osmosis mysqldump -u root -p --all-databases > backups/$DATE/osmosis_backup.sql

# Backup archivos
cp -r ServicioSolicitudesOt/uploads backups/$DATE/solicitudes_uploads
cp -r laboratorio-service/uploads backups/$DATE/laboratorio_uploads
```

### Restauración:
```bash
# Restaurar base de datos
docker-compose exec mysql mysql -u naturepharma -p < backups/FECHA/mysql_backup.sql
```

## Monitoreo de Producción

Para un entorno de producción, considera agregar:
- Nginx como proxy reverso
- Certificados SSL
- Monitoreo con Prometheus/Grafana
- Logs centralizados con ELK Stack
- Backup automatizado

## Soporte

Para problemas específicos:
1. Revisar logs: `docker-compose logs [servicio]`
2. Verificar conectividad de red
3. Comprobar configuración de variables de entorno
4. Validar permisos de archivos y directorios