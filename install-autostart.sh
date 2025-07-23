#!/bin/bash

# Script para configurar el inicio automático de los microservicios con Docker Compose
# Este script debe ejecutarse en el servidor Ubuntu

echo "=== Configurando inicio automático de microservicios ==="

# Verificar que Docker y Docker Compose estén instalados
if ! command -v docker &> /dev/null; then
    echo "Error: Docker no está instalado. Por favor instala Docker primero."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose no está instalado. Por favor instala Docker Compose primero."
    exit 1
fi

# Obtener el directorio actual del proyecto
PROJECT_DIR=$(pwd)
echo "Directorio del proyecto: $PROJECT_DIR"

# Crear el archivo de servicio systemd
echo "Creando archivo de servicio systemd..."
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
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=0
User=$USER
Group=docker

[Install]
WantedBy=multi-user.target
EOF

# Recargar systemd
echo "Recargando systemd..."
sudo systemctl daemon-reload

# Habilitar el servicio para que se inicie automáticamente
echo "Habilitando el servicio para inicio automático..."
sudo systemctl enable docker-microservices.service

# Verificar el estado del servicio
echo "Verificando configuración..."
sudo systemctl status docker-microservices.service --no-pager

echo ""
echo "=== Configuración completada ==="
echo "Los microservicios ahora se iniciarán automáticamente al reiniciar el servidor."
echo ""
echo "Comandos útiles:"
echo "  - Iniciar servicios manualmente: sudo systemctl start docker-microservices"
echo "  - Detener servicios: sudo systemctl stop docker-microservices"
echo "  - Ver estado: sudo systemctl status docker-microservices"
echo "  - Ver logs: sudo journalctl -u docker-microservices -f"
echo "  - Deshabilitar inicio automático: sudo systemctl disable docker-microservices"
echo ""
echo "Para probar el inicio automático, puedes reiniciar el servidor con: sudo reboot"