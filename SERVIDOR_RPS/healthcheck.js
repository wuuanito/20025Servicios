const http = require('http');

const options = {
  hostname: 'localhost',
  port: process.env.PORT || 4000,
  path: '/api/test-connection',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 5000
};

const req = http.request(options, (res) => {
  if (res.statusCode === 200 || res.statusCode === 500) {
    // 200 = conexión exitosa, 500 = servidor funcionando pero BD no disponible
    console.log('Health check passed');
    process.exit(0);
  } else {
    console.log(`Health check failed with status: ${res.statusCode}`);
    process.exit(1);
  }
});

req.on('error', (err) => {
  console.log(`Health check failed: ${err.message}`);
  process.exit(1);
});

req.on('timeout', () => {
  console.log('Health check timeout');
  req.destroy();
  process.exit(1);
});

// Enviar datos vacíos para el test de conexión
req.write(JSON.stringify({}));
req.end();