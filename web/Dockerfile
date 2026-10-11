# ==========================================
# Dockerfile for Node.js E-Commerce Service
# Security Hardening: Non-root user 'node'
# ==========================================
FROM node:20-alpine

# Set production environment
ENV NODE_ENV=production
ENV PORT=3000

# Create application directory
WORKDIR /app

# Install dependencies separately to leverage Docker layer caching
COPY package*.json ./
RUN npm install --omit=dev --no-audit --no-fund \
    && npm cache clean --force

# Copy application source code
COPY --chown=node:node . .

# Create logs directory and assign permissions to non-root node user
RUN mkdir -p /app/logs && chown -R node:node /app

# Switch to non-root user (Principle of Least Privilege)
USER node

# Expose internal service port
EXPOSE 3000

# Health check instruction inside container
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/health || exit 1

# Start application
CMD ["node", "server.js"]
