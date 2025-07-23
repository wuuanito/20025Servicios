# Configuración de Inicio Automático para Microservicios

Este documento explica cómo configurar los microservicios para que se inicien automáticamente al arrancar el servidor Ubuntu.

## Requisitos Previos

- Servidor Ubuntu con Docker y Docker Compose instalados
- Usuario con permisos sudo
- Usuario agregado al grupo docker: `sudo usermod -aG docker $USER`

## Método 1: Instalación Automática (Recomendado)

1. **Transferir archivos al servidor Ubuntu:**
   ```bash
   # Copia todo el proyecto al servidor Ubuntu
   scp -r /ruta/local/20025Servicios usuario@servidor:/home/usuario/Desktop/
   ```

2. **Ejecutar el script de instalación:**
   ```bash
   cd /home/usuario/Desktop/20025Servicios
   chmod +x install-autostart.sh
   ./install-autostart.sh
   ```

3. **Verificar la instalación:**
   ```bash
   sudo systemctl status docker-microservices
   ```

## Método 2: Instalación Manual

1. **Copiar el archivo de servicio:**
   ```bash
   sudo cp docker-microservices.service /etc/systemd/system/
   ```

2. **Editar el archivo de servicio (si es necesario):**
   ```bash
   sudo nano /etc/systemd/system/docker-microservices.service
   ```
   
   Asegúrate de que:
   - `WorkingDirectory` apunte al directorio correcto del proyecto
   - `User` sea tu usuario actual
   - Las rutas sean correctas para tu sistema

3. **Recargar systemd y habilitar el servicio:**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable docker-microservices.service
   ```

## Comandos Útiles

### Gestión del Servicio
```bash
# Iniciar servicios manualmente
sudo systemctl start docker-microservices

# Detener servicios
sudo systemctl stop docker-microservices

# Reiniciar servicios
sudo systemctl restart docker-microservices

# Ver estado del servicio
sudo systemctl status docker-microservices

# Habilitar inicio automático
sudo systemctl enable docker-microservices

# Deshabilitar inicio automático
sudo systemctl disable docker-microservices
```

### Monitoreo y Logs
```bash
# Ver logs del servicio systemd
sudo journalctl -u docker-microservices -f

# Ver logs de los contenedores
docker-compose logs -f

# Ver estado de los contenedores
docker-compose ps
```

## Verificación del Inicio Automático

1. **Reiniciar el servidor:**
   ```bash
   sudo reboot
   ```

2. **Después del reinicio, verificar que los servicios estén corriendo:**
   ```bash
   sudo systemctl status docker-microservices
   docker-compose ps
   ```

## Configuración del Docker Compose

El archivo `docker-compose.yml` ya está configurado con:
- `restart: unless-stopped` en todos los servicios
- Esto asegura que los contenedores se reinicien automáticamente si fallan

## Puertos de los Servicios

Una vez iniciados automáticamente, los servicios estarán disponibles en:

- **Auth Service**: http://servidor:4001
- **Solicitudes Service**: http://servidor:3001
- **Servidor RPS**: http://servidor:3002
- **Calendar Service**: http://servidor:3003
- **Laboratorio Service**: http://servidor:3004
- **Tecnomaco Backend**: http://servidor:3005
- **Cremer Backend**: http://servidor:3006
- **OSMOSIS Service**: http://servidor:8000
- **Docker Monitor**: http://servidor:3000

## Solución de Problemas

### El servicio no inicia automáticamente
1. Verificar que el servicio esté habilitado:
   ```bash
   sudo systemctl is-enabled docker-microservices
   ```

2. Verificar logs de errores:
   ```bash
   sudo journalctl -u docker-microservices --no-pager
   ```

### Problemas de permisos
1. Asegurar que el usuario esté en el grupo docker:
   ```bash
   groups $USER
   sudo usermod -aG docker $USER
   # Cerrar sesión y volver a iniciar
   ```

### Contenedores no inician
1. Verificar que Docker esté corriendo:
   ```bash
   sudo systemctl status docker
   ```

2. Verificar el archivo docker-compose.yml:
   ```bash
   docker-compose config
   ```

## Notas Importantes

- El servicio systemd esperará a que Docker esté completamente iniciado antes de ejecutar docker-compose
- Los contenedores se iniciarán en modo detached (-d)
- Si algún contenedor falla, se reiniciará automáticamente debido a la política `restart: unless-stopped`
- Para cambios en el docker-compose.yml, reinicia el servicio: `sudo systemctl restart docker-microservices`

## Desinstalación

Para remover el inicio automático:

```bash
# Deshabilitar y detener el servicio
sudo systemctl disable docker-microservices
sudo systemctl stop docker-microservices

# Remover el archivo de servicio
sudo rm /etc/systemd/system/docker-microservices.service

# Recargar systemd
sudo systemctl daemon-reload
```