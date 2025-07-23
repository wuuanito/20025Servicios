#!/bin/bash

# Script para verificar el estado de los microservicios
# Útil para comprobar que todo esté funcionando después del inicio automático

echo "=== Estado de los Microservicios ==="
echo ""

# Verificar estado del servicio systemd
echo "1. Estado del servicio systemd:"
sudo systemctl status docker-microservices --no-pager -l
echo ""

# Verificar que Docker esté corriendo
echo "2. Estado de Docker:"
sudo systemctl status docker --no-pager | head -3
echo ""

# Verificar contenedores
echo "3. Estado de los contenedores:"
docker-compose ps
echo ""

# Verificar conectividad de los servicios
echo "4. Verificando conectividad de servicios:"

services=(
    "localhost:4001 Auth-Service"
    "localhost:3001 Solicitudes-Service"
    "localhost:3002 Servidor-RPS"
    "localhost:3003 Calendar-Service"
    "localhost:3004 Laboratorio-Service"
    "localhost:3005 Tecnomaco-Backend"
    "localhost:3006 Cremer-Backend"
    "localhost:8000 OSMOSIS-Service"
    "localhost:3000 Docker-Monitor"
)

for service in "${services[@]}"; do
    host_port=$(echo $service | cut -d' ' -f1)
    name=$(echo $service | cut -d' ' -f2)
    
    if curl -s --connect-timeout 5 "http://$host_port" > /dev/null 2>&1; then
        echo "✅ $name ($host_port) - ACTIVO"
    else
        echo "❌ $name ($host_port) - NO RESPONDE"
    fi
done

echo ""
echo "5. Uso de recursos:"
echo "CPU y Memoria de contenedores:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo ""
echo "=== Resumen ==="
running_containers=$(docker-compose ps --services --filter "status=running" | wc -l)
total_services=$(docker-compose ps --services | wc -l)

echo "Contenedores activos: $running_containers/$total_services"

if [ "$running_containers" -eq "$total_services" ]; then
    echo "✅ Todos los servicios están funcionando correctamente"
else
    echo "⚠️  Algunos servicios no están activos. Revisa los logs con:"
    echo "   docker-compose logs [nombre_servicio]"
    echo "   sudo journalctl -u docker-microservices -f"
fi

echo ""
echo "Para ver logs en tiempo real: docker-compose logs -f"
echo "Para reiniciar servicios: sudo systemctl restart docker-microservices"