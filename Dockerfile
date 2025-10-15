FROM node:22-alpine

# Set working directory
WORKDIR /opt/foundryvtt

# Copy pre-extracted Foundry VTT files
COPY ./foundryvtt/ .

# Create directories for data, config, and logs
RUN mkdir -p /data /config /logs && \
    chown -R 1000:1000 /opt/foundryvtt /data /config /logs

# Switch to UID/GID 1000
USER 1000:1000

# Expose default Foundry VTT port
EXPOSE 30000

# Set default data path
ENV FOUNDRY_DATA_PATH=/data

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD node -e "require('http').get('http://localhost:30000', (r) => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

# Start Foundry VTT
CMD ["sh", "-c", "node main.js --dataPath=${FOUNDRY_DATA_PATH} ${FOUNDRY_ARGS}"]