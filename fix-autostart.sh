#!/bin/bash

# Script para corregir el problema del servicio docker-microservices
# El error 203/EXEC indica que no puede encontrar el comando docker-compose

echo "=== Diagnosticando y corrigiendo el servicio docker-microservices ==="
echo ""

# Verificar la ubicación de docker-compose
echo "1. Verificando ubicación de docker-compose:"
DOCKER_COMPOSE_PATH=$(which docker-compose)
if [ -z "$DOCKER_COMPOSE_PATH" ]; then
    echo "❌ docker-compose no encontrado en PATH"
    echo "Verificando si está instalado como plugin de Docker..."
    if docker compose version &> /dev/null; then
        echo "✅ Docker Compose está disponible como plugin: 'docker compose'"
        DOCKER_COMPOSE_CMD="/usr/bin/docker compose"
    else
        echo "❌ Docker Compose no está instalado"
        echo "Por favor instala Docker Compose primero:"
        echo "  sudo apt update"
        echo "  sudo apt install docker-compose-plugin"
        exit 1
    fi
else
    echo "✅ docker-compose encontrado en: $DOCKER_COMPOSE_PATH"
    DOCKER_COMPOSE_CMD="$DOCKER_COMPOSE_PATH"
fi

echo ""
echo "2. Comando a usar: $DOCKER_COMPOSE_CMD"
echo ""

# Obtener el directorio actual del proyecto
PROJECT_DIR=$(pwd)
echo "3. Directorio del proyecto: $PROJECT_DIR"
echo ""

# Crear el archivo de servicio systemd corregido
echo "4. Creando archivo de servicio systemd corregido..."
sudo tee /etc/systemd/system/docker-microservices.service > /dev/null <<EOF
[Unit]
Description=Docker Compose Microservices
Requires=docker.service
After=docker.service
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PROJECT_DIR
ExecStart=$DOCKER_COMPOSE_CMD up -d
ExecStop=$DOCKER_COMPOSE_CMD down
TimeoutStartSec=0
User=$USER
Group=docker
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Archivo de servicio actualizado"
echo ""

# Recargar systemd
echo "5. Recargando systemd..."
sudo systemctl daemon-reload
echo "✅ Systemd recargado"
echo ""

# Probar el servicio
echo "6. Probando el servicio..."
sudo systemctl start docker-microservices
echo ""

# Verificar el estado
echo "7. Verificando estado del servicio:"
sudo systemctl status docker-microservices --no-pager
echo ""

# Verificar contenedores
echo "8. Verificando contenedores:"
docker-compose ps
echo ""

echo "=== Diagnóstico completado ==="
echo ""
echo "Si el servicio ahora está activo, el problema se ha resuelto."
echo "Si sigue fallando, revisa los logs con: sudo journalctl -u docker-microservices -f"