#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Foundry VTT Docker Setup${NC}"
echo "================================"

# Check if foundryvtt directory exists
if [ ! -d "./foundryvtt" ]; then
    echo -e "${RED}Error: ./foundryvtt directory not found${NC}"
    echo ""
    echo "Please extract the Node.js version of Foundry VTT to ./foundryvtt"
    echo "The directory should contain main.js and other Foundry files"
    exit 1
fi

# Check if main.js exists
if [ ! -f "./foundryvtt/main.js" ]; then
    echo -e "${RED}Error: main.js not found in ./foundryvtt${NC}"
    echo ""
    echo "Make sure you extracted the correct Node.js version of Foundry VTT"
    exit 1
fi

# Check if .env exists, if not copy from example
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Creating .env file from .env.example${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ .env file created${NC}"
    echo ""
    echo -e "${YELLOW}Please edit .env file with your configuration${NC}"
    echo "Then run: docker-compose up -d"
    exit 0
fi

# Create directories if they don't exist
echo "Creating directories..."
mkdir -p data config logs modules systems
echo -e "${GREEN}✓ Directories created${NC}"

# Set ownership to UID/GID 1000 for container access
echo "Setting directory permissions..."
if [ "$(id -u)" -eq 0 ]; then
    chown -R 1000:1000 data config logs modules systems
    echo -e "${GREEN}✓ Permissions set${NC}"
else
    # Not running as root, attempt without sudo first
    if chown -R 1000:1000 data config logs modules systems 2>/dev/null; then
        echo -e "${GREEN}✓ Permissions set${NC}"
    else
        echo -e "${YELLOW}⚠ Need sudo to set directory ownership to UID/GID 1000${NC}"
        sudo chown -R 1000:1000 data config logs modules systems
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Permissions set${NC}"
        else
            echo -e "${RED}Failed to set permissions${NC}"
            exit 1
        fi
    fi
fi

# Build and start
echo ""
echo "Building Docker image..."
docker-compose build

echo ""
echo "Starting Foundry VTT..."
docker-compose up -d

echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Foundry VTT should be accessible at: http://localhost:$(grep FOUNDRY_PORT .env | cut -d'=' -f2 | tr -d ' ' || echo '30000')"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down"