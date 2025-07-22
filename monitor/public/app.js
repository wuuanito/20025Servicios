// Configuración global
const API_BASE = window.location.origin;
const socket = io();

// Variables globales
let services = [];
let containersStatus = [];
let systemStats = {};

// Inicialización
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    setupSocketListeners();
    setupEventListeners();
});

// Inicializar aplicación
function initializeApp() {
    loadServices();
    refreshStatus();
    updateLastUpdateTime();
}

// Configurar listeners de WebSocket
function setupSocketListeners() {
    socket.on('connect', () => {
        console.log('Conectado al servidor');
        showNotification('Conectado al servidor de monitoreo', 'success');
    });
    
    socket.on('disconnect', () => {
        console.log('Desconectado del servidor');
        showNotification('Desconectado del servidor', 'error');
    });
    
    socket.on('status-update', (data) => {
        if (data.success) {
            containersStatus = data.containers;
            updateServicesDisplay();
            updateLastUpdateTime();
        }
    });
    
    socket.on('system-update', (data) => {
        if (data.success) {
            systemStats = data.stats;
            updateSystemStats();
        }
    });
    
    socket.on('service-restarted', (data) => {
        showNotification(`Servicio ${data.service} reiniciado exitosamente`, 'success');
    });
    
    socket.on('service-stopped', (data) => {
        showNotification(`Servicio ${data.service} detenido`, 'info');
    });
    
    socket.on('service-started', (data) => {
        showNotification(`Servicio ${data.service} iniciado`, 'success');
    });
    
    socket.on('all-services-restarted', () => {
        showNotification('Todos los servicios han sido reiniciados', 'success');
    });
    
    socket.on('all-services-stopped', () => {
        showNotification('Todos los servicios han sido detenidos', 'info');
    });
    
    socket.on('all-services-started', () => {
        showNotification('Todos los servicios han sido iniciados', 'success');
    });
}

// Configurar event listeners
function setupEventListeners() {
    // Auto-refresh logs cuando cambia el servicio seleccionado
    document.getElementById('logService').addEventListener('change', function() {
        if (this.value) {
            loadLogs();
        }
    });
}

// Cargar lista de servicios
async function loadServices() {
    try {
        const response = await fetch(`${API_BASE}/api/services`);
        services = await response.json();
        populateLogServiceSelect();
        updateServicesDisplay();
    } catch (error) {
        console.error('Error cargando servicios:', error);
        showNotification('Error cargando lista de servicios', 'error');
    }
}

// Poblar select de servicios para logs
function populateLogServiceSelect() {
    const select = document.getElementById('logService');
    select.innerHTML = '<option value="">Seleccionar servicio...</option>';
    
    services.forEach(service => {
        const option = document.createElement('option');
        option.value = service.name;
        option.textContent = `${service.description} (${service.name})`;
        select.appendChild(option);
    });
}

// Actualizar estadísticas del sistema
function updateSystemStats() {
    // Mostrar estadísticas de Docker
    document.getElementById('containersInfo').textContent = systemStats.containers ? 
        systemStats.containers.split('\n').length - 1 + ' contenedores' : 'N/A';
    document.getElementById('imagesInfo').textContent = systemStats.images ? 
        systemStats.images.split('\n').length - 1 + ' imágenes' : 'N/A';
    document.getElementById('volumesInfo').textContent = systemStats.volumes ? 
        systemStats.volumes.split('\n').length - 1 + ' volúmenes' : 'N/A';
    document.getElementById('networksInfo').textContent = systemStats.networks ? 
        systemStats.networks.split('\n').length - 1 + ' redes' : 'N/A';
}

// Actualizar visualización de servicios
function updateServicesDisplay() {
    const grid = document.getElementById('servicesGrid');
    grid.innerHTML = '';
    
    services.forEach(service => {
        const container = containersStatus.find(c => c.Service === service.name);
        const card = createServiceCard(service, container);
        grid.appendChild(card);
    });
}

// Crear tarjeta de servicio
function createServiceCard(service, container) {
    const card = document.createElement('div');
    card.className = 'service-card';
    
    const status = getServiceStatus(container);
    const statusClass = getStatusClass(status);
    
    card.innerHTML = `
        <div class="service-header">
            <h3 class="service-name">${service.description}</h3>
            <span class="service-status ${statusClass}">${status}</span>
        </div>
        <div class="service-info">
            <p><strong>Servicio:</strong> ${service.name}</p>
            <p><strong>Puerto:</strong> ${service.port}</p>
            ${container ? `
                <p><strong>Estado:</strong> ${container.State}</p>
                <p><strong>Puertos:</strong> ${container.Ports || 'N/A'}</p>
            ` : ''}
        </div>
        <div class="service-controls">
            <button class="btn btn-success" onclick="startService('${service.name}')">
                <i class="fas fa-play"></i> Iniciar
            </button>
            <button class="btn btn-warning" onclick="restartService('${service.name}')">
                <i class="fas fa-redo"></i> Reiniciar
            </button>
            <button class="btn btn-danger" onclick="stopService('${service.name}')">
                <i class="fas fa-stop"></i> Detener
            </button>
            <button class="btn btn-info" onclick="viewLogs('${service.name}')">
                <i class="fas fa-file-alt"></i> Logs
            </button>
        </div>
    `;
    
    return card;
}

// Obtener estado del servicio
function getServiceStatus(container) {
    if (!container) return 'Desconocido';
    
    switch (container.State.toLowerCase()) {
        case 'running':
            return 'Ejecutándose';
        case 'exited':
        case 'stopped':
            return 'Detenido';
        case 'restarting':
            return 'Reiniciando';
        default:
            return container.State;
    }
}

// Obtener clase CSS para el estado
function getStatusClass(status) {
    switch (status.toLowerCase()) {
        case 'ejecutándose':
        case 'running':
            return 'status-running';
        case 'detenido':
        case 'exited':
        case 'stopped':
            return 'status-stopped';
        default:
            return 'status-unknown';
    }
}

// Funciones de control de servicios
async function startService(serviceName) {
    await executeServiceCommand('start', serviceName, `Iniciando ${serviceName}...`);
}

async function restartService(serviceName) {
    await executeServiceCommand('restart', serviceName, `Reiniciando ${serviceName}...`);
}

async function stopService(serviceName) {
    await executeServiceCommand('stop', serviceName, `Deteniendo ${serviceName}...`);
}

// Ejecutar comando de servicio
async function executeServiceCommand(action, serviceName, loadingMessage) {
    showLoading(loadingMessage);
    
    try {
        const response = await fetch(`${API_BASE}/api/${action}/${serviceName}`, {
            method: 'POST'
        });
        
        const result = await response.json();
        
        if (result.success) {
            showNotification(`${action} de ${serviceName} ejecutado exitosamente`, 'success');
        } else {
            showNotification(`Error en ${action} de ${serviceName}: ${result.error}`, 'error');
        }
    } catch (error) {
        console.error(`Error en ${action} de servicio:`, error);
        showNotification(`Error de conexión al ejecutar ${action}`, 'error');
    } finally {
        hideLoading();
    }
}

// Funciones de control global
async function startAllServices() {
    await executeGlobalCommand('start-all', 'Iniciando todos los servicios...');
}

async function restartAllServices() {
    await executeGlobalCommand('restart-all', 'Reiniciando todos los servicios...');
}

async function stopAllServices() {
    await executeGlobalCommand('stop-all', 'Deteniendo todos los servicios...');
}

// Ejecutar comando global
async function executeGlobalCommand(action, loadingMessage) {
    showLoading(loadingMessage);
    
    try {
        const response = await fetch(`${API_BASE}/api/${action}`, {
            method: 'POST'
        });
        
        const result = await response.json();
        
        if (result.success) {
            showNotification('Comando ejecutado exitosamente', 'success');
        } else {
            showNotification(`Error: ${result.error}`, 'error');
        }
    } catch (error) {
        console.error('Error en comando global:', error);
        showNotification('Error de conexión', 'error');
    } finally {
        hideLoading();
    }
}

// Actualizar estado manualmente
async function refreshStatus() {
    try {
        const response = await fetch(`${API_BASE}/api/status`);
        const result = await response.json();
        
        if (result.success) {
            containersStatus = result.containers;
            updateServicesDisplay();
            updateLastUpdateTime();
            showNotification('Estado actualizado', 'success');
        } else {
            showNotification('Error actualizando estado', 'error');
        }
    } catch (error) {
        console.error('Error actualizando estado:', error);
        showNotification('Error de conexión', 'error');
    }
}

// Ver logs de un servicio específico
function viewLogs(serviceName) {
    document.getElementById('logService').value = serviceName;
    loadLogs();
    
    // Scroll a la sección de logs
    document.querySelector('.logs-section').scrollIntoView({ 
        behavior: 'smooth' 
    });
}

// Cargar logs
async function loadLogs() {
    const serviceName = document.getElementById('logService').value;
    const lines = document.getElementById('logLines').value;
    
    if (!serviceName) {
        showNotification('Selecciona un servicio primero', 'error');
        return;
    }
    
    showLoading('Cargando logs...');
    
    try {
        const response = await fetch(`${API_BASE}/api/logs/${serviceName}?lines=${lines}`);
        const result = await response.json();
        
        const logsContent = document.getElementById('logsContent');
        
        if (result.success) {
            logsContent.textContent = result.stdout || 'No hay logs disponibles';
            showNotification('Logs cargados exitosamente', 'success');
        } else {
            logsContent.textContent = `Error cargando logs: ${result.error}`;
            showNotification('Error cargando logs', 'error');
        }
    } catch (error) {
        console.error('Error cargando logs:', error);
        document.getElementById('logsContent').textContent = 'Error de conexión';
        showNotification('Error de conexión', 'error');
    } finally {
        hideLoading();
    }
}

// Limpiar logs
function clearLogs() {
    document.getElementById('logsContent').textContent = 'Selecciona un servicio para ver sus logs...';
    document.getElementById('logService').value = '';
}

// Actualizar tiempo de última actualización
function updateLastUpdateTime() {
    const now = new Date();
    const timeString = now.toLocaleTimeString('es-ES');
    document.getElementById('lastUpdate').textContent = timeString;
}

// Mostrar overlay de carga
function showLoading(message = 'Procesando...') {
    const overlay = document.getElementById('loadingOverlay');
    const text = overlay.querySelector('p');
    text.textContent = message;
    overlay.style.display = 'flex';
}

// Ocultar overlay de carga
function hideLoading() {
    document.getElementById('loadingOverlay').style.display = 'none';
}

// Mostrar notificación
function showNotification(message, type = 'info') {
    const container = document.getElementById('notifications');
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <span>${message}</span>
            <button onclick="this.parentElement.parentElement.remove()" style="background: none; border: none; color: inherit; cursor: pointer; font-size: 1.2rem;">&times;</button>
        </div>
    `;
    
    container.appendChild(notification);
    
    // Auto-remove después de 5 segundos
    setTimeout(() => {
        if (notification.parentElement) {
            notification.remove();
        }
    }, 5000);
}

// Manejo de errores globales
window.addEventListener('error', function(event) {
    console.error('Error global:', event.error);
    showNotification('Ha ocurrido un error inesperado', 'error');
});

// Manejo de errores de promesas no capturadas
window.addEventListener('unhandledrejection', function(event) {
    console.error('Promise rejection no manejada:', event.reason);
    showNotification('Error de conexión o servidor', 'error');
});