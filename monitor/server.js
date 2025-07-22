const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const { exec } = require('child_process');
const path = require('path');
const cors = require('cors');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 8080;
const DOCKER_COMPOSE_PATH = process.env.DOCKER_COMPOSE_PATH || '/home/rnp/20025Servicios';

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Configuración de servicios
const SERVICES = [
  { name: 'auth-service', port: 3001, description: 'Servicio de Autenticación' },
  { name: 'solicitudes-service', port: 3002, description: 'Servicio de Solicitudes' },
  { name: 'servidor-rps', port: 3003, description: 'Servidor RPS' },
  { name: 'calendar-service', port: 3004, description: 'Servicio de Calendario' },
  { name: 'tecnomaco-backend', port: 3005, description: 'Backend Tecnomaco' },
  { name: 'cremer-backend', port: 3000, description: 'Backend Cremer' },
  { name: 'laboratorio-service', port: 3006, description: 'Servicio de Laboratorio' },
  { name: 'osmosis-service', port: 3007, description: 'Servicio OSMOSIS' }
];

// Función para ejecutar comandos Docker (adaptado para contenedor)
function execSudoCommand(command, callback) {
  // En contenedor Docker no necesitamos sudo
  const dockerCommand = process.env.NODE_ENV === 'production' ? command : command;
  const fullCommand = `cd ${DOCKER_COMPOSE_PATH} && ${dockerCommand}`;
  console.log(`Ejecutando: ${fullCommand}`);
  
  exec(fullCommand, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error.message}`);
      callback({ success: false, error: error.message, stderr });
      return;
    }
    if (stderr) {
      console.warn(`Stderr: ${stderr}`);
    }
    console.log(`Stdout: ${stdout}`);
    callback({ success: true, stdout, stderr });
  });
}

// Función para obtener estado de contenedores
function getContainersStatus(callback) {
  execSudoCommand('docker-compose ps --format json', (result) => {
    if (result.success) {
      try {
        const lines = result.stdout.trim().split('\n').filter(line => line.trim());
        const containers = lines.map(line => {
          try {
            return JSON.parse(line);
          } catch (e) {
            return null;
          }
        }).filter(container => container !== null);
        
        callback({ success: true, containers });
      } catch (error) {
        callback({ success: false, error: 'Error parsing container status' });
      }
    } else {
      callback(result);
    }
  });
}

// Función para obtener logs de un servicio
function getServiceLogs(serviceName, lines = 50, callback) {
  execSudoCommand(`docker-compose logs --tail=${lines} ${serviceName}`, callback);
}

// Función para obtener estadísticas del sistema
function getSystemStats(callback) {
  const commands = {
    memory: "free -h | grep '^Mem:'",
    disk: "df -h / | tail -1",
    cpu: "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1",
    uptime: "uptime -p"
  };
  
  const stats = {};
  let completed = 0;
  const total = Object.keys(commands).length;
  
  Object.entries(commands).forEach(([key, command]) => {
    exec(command, (error, stdout, stderr) => {
      if (!error) {
        stats[key] = stdout.trim();
      } else {
        stats[key] = 'N/A';
      }
      completed++;
      if (completed === total) {
        callback({ success: true, stats });
      }
    });
  });
}

// Rutas API
app.get('/api/services', (req, res) => {
  res.json(SERVICES);
});

app.get('/api/status', (req, res) => {
  getContainersStatus((result) => {
    res.json(result);
  });
});

app.get('/api/logs/:service', (req, res) => {
  const serviceName = req.params.service;
  const lines = req.query.lines || 50;
  
  getServiceLogs(serviceName, lines, (result) => {
    res.json(result);
  });
});

app.get('/api/system', (req, res) => {
  getSystemStats((result) => {
    res.json(result);
  });
});

// Rutas para comandos de control
app.post('/api/restart/:service', (req, res) => {
  const serviceName = req.params.service;
  execSudoCommand(`docker-compose restart ${serviceName}`, (result) => {
    res.json(result);
    if (result.success) {
      io.emit('service-restarted', { service: serviceName });
    }
  });
});

app.post('/api/stop/:service', (req, res) => {
  const serviceName = req.params.service;
  execSudoCommand(`docker-compose stop ${serviceName}`, (result) => {
    res.json(result);
    if (result.success) {
      io.emit('service-stopped', { service: serviceName });
    }
  });
});

app.post('/api/start/:service', (req, res) => {
  const serviceName = req.params.service;
  execSudoCommand(`docker-compose start ${serviceName}`, (result) => {
    res.json(result);
    if (result.success) {
      io.emit('service-started', { service: serviceName });
    }
  });
});

app.post('/api/restart-all', (req, res) => {
  execSudoCommand('docker-compose restart', (result) => {
    res.json(result);
    if (result.success) {
      io.emit('all-services-restarted');
    }
  });
});

app.post('/api/stop-all', (req, res) => {
  execSudoCommand('docker-compose stop', (result) => {
    res.json(result);
    if (result.success) {
      io.emit('all-services-stopped');
    }
  });
});

app.post('/api/start-all', (req, res) => {
  execSudoCommand('docker-compose up -d', (result) => {
    res.json(result);
    if (result.success) {
      io.emit('all-services-started');
    }
  });
});

// WebSocket para actualizaciones en tiempo real
io.on('connection', (socket) => {
  console.log('Cliente conectado:', socket.id);
  
  // Enviar estado inicial
  getContainersStatus((result) => {
    socket.emit('status-update', result);
  });
  
  getSystemStats((result) => {
    socket.emit('system-update', result);
  });
  
  socket.on('disconnect', () => {
    console.log('Cliente desconectado:', socket.id);
  });
});

// Actualización periódica del estado
setInterval(() => {
  getContainersStatus((result) => {
    io.emit('status-update', result);
  });
  
  getSystemStats((result) => {
    io.emit('system-update', result);
  });
}, 5000); // Cada 5 segundos

// Servir la página principal
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor de monitoreo ejecutándose en http://0.0.0.0:${PORT}`);
  console.log(`📊 Accesible desde la red en http://192.168.20.158:${PORT}`);
  console.log(`📁 Directorio Docker Compose: ${DOCKER_COMPOSE_PATH}`);
  console.log(`🐳 Entorno: ${process.env.NODE_ENV || 'development'}`);
});