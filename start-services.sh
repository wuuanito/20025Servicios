#!/bin/bash

# Script de inicio rápido para los microservicios
# Uso: ./start-services.sh

echo "🚀 Iniciando microservicios..."

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Por favor, instala Docker primero."
    exit 1
fi

# Verificar si Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose no está instalado. Por favor, instala Docker Compose primero."
    exit 1
fi

# Verificar si Docker está ejecutándose
if ! docker info &> /dev/null; then
    echo "❌ Docker no está ejecutándose. Por favor, inicia Docker primero."
    exit 1
fi

echo "✅ Docker está disponible y ejecutándose"

# Crear directorios necesarios si no existen
echo "📁 Creando directorios necesarios..."
mkdir -p ServicioSolicitudesOt/uploads/{solicitud,necesidad,resultado}
mkdir -p laboratorio-service/uploads/defectos
mkdir -p auth-service/logs

# Detener servicios existentes si están ejecutándose
echo "🛑 Deteniendo servicios existentes..."
docker-compose down

# Construir las imágenes
echo "🔨 Construyendo imágenes Docker..."
docker-compose build

if [ $? -ne 0 ]; then
    echo "❌ Error al construir las imágenes. Revisa los logs arriba."
    exit 1
fi

# Iniciar los servicios
echo "🚀 Iniciando todos los servicios..."
docker-compose up -d

if [ $? -ne 0 ]; then
    echo "❌ Error al iniciar los servicios. Revisa los logs arriba."
    exit 1
fi

# Esperar un momento para que los servicios se inicien
echo "⏳ Esperando que los servicios se inicien..."
sleep 10

# Verificar el estado de los servicios
echo "📊 Estado de los servicios:"
docker-compose ps

echo ""
echo "✅ ¡Microservicios iniciados exitosamente!"
echo ""
echo "🌐 URLs de los servicios:"
echo "   • Auth Service:        http://localhost:4001"
echo "   • Solicitudes OT:      http://localhost:3001"
echo "   • Servidor RPS:        http://localhost:3002"
echo "   • Calendar Service:    http://localhost:3003"
echo "   • Laboratorio Service: http://localhost:3004"
echo "   • Tecnomaco Backend:   http://localhost:3005"
echo "   • Cremer Backend:      http://localhost:3006"
echo "   • OSMOSIS Service:     http://localhost:8000"
echo ""
echo "🗄️  Bases de datos:"
echo "   • MySQL Principal:     localhost:3306"
echo "   • MySQL OSMOSIS:       localhost:3050"
echo ""
echo "📝 Comandos útiles:"
echo "   • Ver logs:            docker-compose logs"
echo "   • Ver logs específico: docker-compose logs [servicio]"
echo "   • Detener servicios:   docker-compose down"
echo "   • Reiniciar servicio:  docker-compose restart [servicio]"
echo ""
echo "📖 Para más información, consulta README-DOCKER.md"