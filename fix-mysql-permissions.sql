-- Script para otorgar permisos al usuario naturepharma desde contenedores Docker
-- Ejecutar este script en el servidor MySQL local (192.168.20.158)

-- Crear el usuario naturepharma si no existe y otorgar permisos desde cualquier IP
CREATE USER IF NOT EXISTS 'naturepharma'@'%' IDENTIFIED BY 'Root123!';

-- Otorgar todos los privilegios en todas las bases de datos
GRANT ALL PRIVILEGES ON *.* TO 'naturepharma'@'%' WITH GRANT OPTION;

-- Otorgar permisos específicos para cada base de datos
GRANT ALL PRIVILEGES ON auth_service_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON auth_service_test.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON sistema_solicitudes.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON calendar_service_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON laboratorio_service_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON tecnomaco_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON cremer_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON osmosis_monitor.* TO 'naturepharma'@'%';

-- Aplicar los cambios
FLUSH PRIVILEGES;

-- Verificar los usuarios creados
SELECT User, Host FROM mysql.user WHERE User = 'naturepharma';

-- Mostrar los privilegios otorgados
SHOW GRANTS FOR 'naturepharma'@'%';