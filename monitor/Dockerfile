# Usar imagen base de Node.js
FROM node:18-alpine

# Instalar Docker CLI para poder ejecutar comandos Docker desde el contenedor
RUN apk add --no-cache docker-cli

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production

# Copiar código fuente
COPY . .

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs
RUN adduser -S monitor -u 1001

# Cambiar permisos del directorio de trabajo
RUN chown -R monitor:nodejs /app
USER monitor

# Exponer puerto
EXPOSE 3000

# Comando de inicio
CMD ["node", "server.js"]