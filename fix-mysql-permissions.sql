-- Script para otorgar permisos al usuario naturepharma desde contenedores Docker
-- Ejecutar este script en el servidor MySQL local (192.168.20.158)

-- Crear el usuario naturepharma si no existe y otorgar permisos desde cualquier IP
CREATE USER IF NOT EXISTS 'naturepharma'@'%' IDENTIFIED BY 'Root123!';
CREATE USER IF NOT EXISTS 'naturepharma'@'localhost' IDENTIFIED BY 'Root123!';
CREATE USER IF NOT EXISTS 'naturepharma'@'192.168.20.158' IDENTIFIED BY 'Root123!';
CREATE USER IF NOT EXISTS 'naturepharma'@'172.18.0.%' IDENTIFIED BY 'Root123!';
CREATE USER IF NOT EXISTS 'naturepharma'@'172.%.%.%' IDENTIFIED BY 'Root123!';

-- Otorgar todos los privilegios en todas las bases de datos
GRANT ALL PRIVILEGES ON *.* TO 'naturepharma'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'naturepharma'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'naturepharma'@'192.168.20.158' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'naturepharma'@'172.18.0.%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'naturepharma'@'172.%.%.%' WITH GRANT OPTION;

-- Otorgar permisos específicos para cada base de datos desde diferentes hosts
GRANT ALL PRIVILEGES ON auth_service_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON auth_service_db.* TO 'naturepharma'@'172.18.0.%';
GRANT ALL PRIVILEGES ON auth_service_db.* TO 'naturepharma'@'172.%.%.%';

GRANT ALL PRIVILEGES ON auth_service_test.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON auth_service_test.* TO 'naturepharma'@'172.18.0.%';
GRANT ALL PRIVILEGES ON auth_service_test.* TO 'naturepharma'@'172.%.%.%';

GRANT ALL PRIVILEGES ON sistema_solicitudes.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON sistema_solicitudes.* TO 'naturepharma'@'172.18.0.%';
GRANT ALL PRIVILEGES ON sistema_solicitudes.* TO 'naturepharma'@'172.%.%.%';

GRANT ALL PRIVILEGES ON calendar_service_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON calendar_service_db.* TO 'naturepharma'@'172.18.0.%';
GRANT ALL PRIVILEGES ON calendar_service_db.* TO 'naturepharma'@'172.%.%.%';

GRANT ALL PRIVILEGES ON laboratorio_service_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON laboratorio_service_db.* TO 'naturepharma'@'172.18.0.%';
GRANT ALL PRIVILEGES ON laboratorio_service_db.* TO 'naturepharma'@'172.%.%.%';

GRANT ALL PRIVILEGES ON tecnomaco_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON tecnomaco_db.* TO 'naturepharma'@'172.18.0.%';
GRANT ALL PRIVILEGES ON tecnomaco_db.* TO 'naturepharma'@'172.%.%.%';

GRANT ALL PRIVILEGES ON cremer_db.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON cremer_db.* TO 'naturepharma'@'172.18.0.%';
GRANT ALL PRIVILEGES ON cremer_db.* TO 'naturepharma'@'172.%.%.%';

GRANT ALL PRIVILEGES ON osmosis_monitor.* TO 'naturepharma'@'%';
GRANT ALL PRIVILEGES ON osmosis_monitor.* TO 'naturepharma'@'172.18.0.%';
GRANT ALL PRIVILEGES ON osmosis_monitor.* TO 'naturepharma'@'172.%.%.%';

-- Aplicar los cambios
FLUSH PRIVILEGES;

-- Verificar los usuarios creados
SELECT User, Host FROM mysql.user WHERE User = 'naturepharma';

-- Mostrar los privilegios otorgados
SHOW GRANTS FOR 'naturepharma'@'%';
SHOW GRANTS FOR 'naturepharma'@'172.18.0.%';
SHOW GRANTS FOR 'naturepharma'@'172.%.%.%';