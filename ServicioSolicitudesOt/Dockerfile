# Usar la imagen oficial de Node.js
FROM node:18-alpine

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production

# Copiar el código fuente
COPY . .

# Crear directorios necesarios
RUN mkdir -p uploads/solicitud uploads/necesidad uploads/resultado logs

# Exponer el puerto
EXPOSE 3001

# Comando para ejecutar la aplicación
CMD ["npm", "start"]