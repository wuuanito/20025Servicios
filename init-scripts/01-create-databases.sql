-- Script de inicialización para crear todas las bases de datos necesarias

-- Base de datos para el servicio de autenticación
CREATE DATABASE IF NOT EXISTS auth_service_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS auth_service_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Base de datos para el sistema de solicitudes
CREATE DATABASE IF NOT EXISTS sistema_solicitudes CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Base de datos para el servicio de calendario
CREATE DATABASE IF NOT EXISTS calendar_service_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Base de datos para el servicio de laboratorio
CREATE DATABASE IF NOT EXISTS laboratorio_service_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Base de datos para Tecnomaco
CREATE DATABASE IF NOT EXISTS tecnomaco_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Base de datos para Cremer
CREATE DATABASE IF NOT EXISTS cremer_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Otorgar permisos al usuario naturepharma
GRANT ALL PRIVILEGES ON auth_service_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON auth_service_test.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON sistema_solicitudes.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON calendar_service_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON laboratorio_service_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON tecnomaco_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON cremer_db.* TO 'naturepharma'@'%';

FLUSH PRIVILEGES;