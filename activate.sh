#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}Error: License key required${NC}"
    echo ""
    echo "Usage: $0 <license-key>"
    echo ""
    echo "Example: $0 XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX"
    exit 1
fi

LICENSE_KEY="$1"

# Check if data directory exists
if [ ! -d "./data" ]; then
    echo -e "${YELLOW}Creating data directory...${NC}"
    mkdir -p ./data
fi

# Create Data/Config directory structure
mkdir -p ./data/Config

# Create options.json with license key in the data directory
cat > ./data/Config/options.json << EOF
{
  "port": 30000,
  "upnp": false,
  "fullscreen": false,
  "hostname": null,
  "localHostname": null,
  "routePrefix": null,
  "sslCert": null,
  "sslKey": null,
  "awsConfig": null,
  "dataPath": "/data",
  "proxySSL": false,
  "proxyPort": null,
  "compressStatic": true,
  "updateChannel": "stable",
  "language": "en.core",
  "upnpLeaseDuration": null,
  "licenseKey": "${LICENSE_KEY}",
  "telemetry": false
}
EOF

# Set ownership to UID/GID 1000
if [ "$(id -u)" -eq 0 ]; then
    chown -R 1000:1000 ./data
elif ! chown -R 1000:1000 ./data 2>/dev/null; then
    echo -e "${YELLOW}Setting permissions with sudo...${NC}"
    sudo chown -R 1000:1000 ./data
fi

echo -e "${GREEN}✓ License key configured in ./data/Config/options.json${NC}"
echo ""
echo "When you first start Foundry VTT, it will activate automatically."
echo "You still need to accept the EULA on first launch."