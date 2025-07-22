#!/bin/bash

# Script para detener todos los microservicios
# Uso: ./stop-services.sh [--clean]

echo "🛑 Deteniendo microservicios..."

# Verificar si Docker Compose está disponible
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose no está instalado."
    exit 1
fi

# Detener y eliminar contenedores
echo "📦 Deteniendo contenedores..."
docker-compose down

if [ "$1" = "--clean" ]; then
    echo "🧹 Limpieza completa solicitada..."
    
    # Eliminar volúmenes
    echo "💾 Eliminando volúmenes..."
    docker-compose down -v
    
    # Eliminar imágenes del proyecto
    echo "🗑️  Eliminando imágenes del proyecto..."
    docker images | grep "20025servicios" | awk '{print $3}' | xargs -r docker rmi
    
    # Limpiar sistema Docker
    echo "🧽 Limpiando sistema Docker..."
    docker system prune -f
    
    echo "✅ Limpieza completa realizada"
else
    echo "✅ Servicios detenidos"
    echo "💡 Usa './stop-services.sh --clean' para una limpieza completa"
fi

echo ""
echo "📊 Estado actual de contenedores:"
docker ps -a | grep -E "(auth-service|solicitudes-service|servidor-rps|calendar-service|laboratorio-service|tecnomaco-backend|cremer-backend|osmosis-service|mysql)"

echo ""
echo "📝 Para reiniciar los servicios, ejecuta: ./start-services.sh"