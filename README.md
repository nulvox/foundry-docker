# Foundry VTT Docker Setup

Run Foundry Virtual Tabletop in a Docker container.

## Prerequisites

- Docker
- Docker Compose
- Foundry VTT license key
- Downloaded Node.js version of Foundry VTT from https://foundryvtt.com

## Initial Setup

### 1. Download Foundry VTT

1. Log in to your Foundry VTT account at https://foundryvtt.com
2. Go to "Purchased Licenses" tab
3. Select the version you want (recommend latest stable)
4. Choose **"Node.js"** from the Operating System dropdown
5. Click "Download" (or use "Timed URL" for command-line download)

### 2. Extract Foundry VTT Files

Extract the downloaded zip file to a directory named `foundryvtt` in this project:

```bash
unzip foundryvtt-*.zip -d ./foundryvtt
```

Your directory structure should look like:

```
.
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── setup.sh
├── activate.sh
├── README.md
└── foundryvtt/
    ├── main.js
    ├── package.json
    └── [other Foundry files...]
```

### 3. Configure License Key

Run the activation script with your license key:

```bash
chmod +x activate.sh
./activate.sh XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX
```

This creates `./data/Config/options.json` with your license key pre-configured.

### 4. Configure Environment

Copy and edit the environment file:

```bash
cp .env.example .env
```

Edit `.env` to customize your setup. Key options:

- `FOUNDRY_PORT` - Port exposed on host (default: 30000)
- `FOUNDRY_INTERNAL_PORT` - Port Foundry listens on inside container (default: 30000)
  - If you change this, you must also add `--port=<value>` to `FOUNDRY_ARGS`
- `DATA_PATH` - Where world data is stored (default: ./data)
- `CONFIG_PATH` - Where configuration is stored (default: ./config)
- `LOGS_PATH` - Where logs are stored (default: ./logs)
- `MODULES_PATH` - Where modules are stored (default: ./modules)
- `SYSTEMS_PATH` - Where game systems are stored (default: ./systems)
- `FOUNDRY_ARGS` - Additional command-line arguments
- `TZ` - Timezone (default: UTC)

### 5. Build and Start

Run the setup script:

```bash
chmod +x setup.sh
./setup.sh
```

Or manually:

```bash
mkdir -p data config logs
docker-compose build
docker-compose up -d
```

## Usage

### Access Foundry VTT

Open your browser to: `http://localhost:30000` (or your configured port)

On first launch, you'll need to accept the EULA. The license key is already configured.

### Common Commands

```bash
# Start Foundry VTT
docker-compose up -d

# Stop Foundry VTT
docker-compose down

# View logs
docker-compose logs -f

# Restart
docker-compose restart

# Rebuild after changes
docker-compose build --no-cache
docker-compose up -d
```

### Update Foundry VTT

1. Download the new Node.js version from Foundry VTT website
2. Remove old `foundryvtt` directory
3. Extract new version to `./foundryvtt`
4. Rebuild: `docker-compose build --no-cache`
5. Restart: `docker-compose up -d`

## Advanced Configuration

### Custom Command-Line Arguments

Add arguments to `FOUNDRY_ARGS` in `.env`:

```bash
# Change internal port (must also set FOUNDRY_INTERNAL_PORT)
FOUNDRY_INTERNAL_PORT=8080
FOUNDRY_ARGS=--port=8080

# Enable UPnP
FOUNDRY_ARGS=--upnp=true

# Set hostname and SSL proxy
FOUNDRY_ARGS=--hostname=example.com --proxySSL=true --proxyPort=443

# Multiple arguments with custom port
FOUNDRY_INTERNAL_PORT=8080
FOUNDRY_ARGS=--port=8080 --upnp=true --hostname=example.com
```

Available arguments:
- `--port=<number>` - Port to listen on
- `--hostname=<string>` - Public hostname
- `--routePrefix=<string>` - URL prefix
- `--proxySSL=<boolean>` - Behind SSL proxy
- `--proxyPort=<number>` - Proxy port
- `--upnp=<boolean>` - Enable UPnP
- `--upnpLeaseDuration=<number>` - UPnP lease duration in seconds
- `--awsConfig=<path>` - AWS S3 configuration file path

### Custom Data Locations

Modify paths in `.env` to use different host directories:

```bash
DATA_PATH=/mnt/storage/foundry/data
CONFIG_PATH=/mnt/storage/foundry/config
LOGS_PATH=/var/log/foundry
MODULES_PATH=/mnt/storage/foundry/modules
SYSTEMS_PATH=/mnt/storage/foundry/systems
```

### Port Forwarding

If running on a server, configure your router to forward external port to `FOUNDRY_PORT`.

### Timezone

Set `TZ` in `.env` to your timezone:

```bash
TZ=America/New_York
TZ=Europe/London
TZ=Asia/Tokyo
```

## File Structure

```
.
├── foundryvtt/          # Extracted Foundry VTT application (you provide)
├── data/                # World data, user configs (persistent)
├── config/              # Application configuration (persistent)
│   └── options.json     # Contains license key
├── logs/                # Application logs (persistent)
├── modules/             # Game modules (persistent, mounted to /data/Data/modules)
├── systems/             # Game systems (persistent, mounted to /data/Data/systems)
├── Dockerfile           # Container image definition
├── docker-compose.yml   # Service orchestration
└── .env                 # Your configuration
```

## Adding Modules and Systems

Modules and systems are bind-mounted from host directories for easy management.

### Adding Modules

Extract module zips to the `./modules/` directory:

```bash
# Download and extract a module
cd modules
wget https://github.com/some-module/releases/download/v1.0.0/module.zip
unzip module.zip -d ./
rm module.zip
cd ..
```

Or manually:
```bash
mkdir -p ./modules/my-module
unzip my-module.zip -d ./modules/my-module
```

Restart Foundry to detect new modules:
```bash
docker-compose restart
```

### Adding Systems

Same process, but use `./systems/` directory:

```bash
mkdir -p ./systems/my-system
unzip my-system.zip -d ./systems/my-system
docker-compose restart
```

### Installing from Foundry UI

Modules and systems installed through the Foundry UI are automatically stored in the bind-mounted directories and persist across container restarts.

## Troubleshooting

### License activation fails

If automatic activation doesn't work:
1. Ensure `./config/options.json` exists and contains your license key
2. Check you have an internet connection (required for activation)
3. Verify your license key is correct
4. Check logs: `docker-compose logs -f`

### Permission issues

The container runs as UID/GID 1000. If you have permission issues:

1. Check ownership: `ls -la data config logs modules systems`
2. Fix ownership: `sudo chown -R 1000:1000 data config logs modules systems`
3. Restart: `docker-compose restart`

The `setup.sh` script attempts to set correct ownership automatically.

### Can't connect

1. Check container is running: `docker-compose ps`
2. Check logs: `docker-compose logs -f`
3. Verify port in `.env` matches URL
4. Check firewall rules

### Port already in use

Change `FOUNDRY_PORT` in `.env` to an unused port, then restart.

## Backup

Back up these directories regularly:
- `./data` - Your worlds and user data
- `./config` - Configuration including license key
- `./modules` - Installed modules
- `./systems` - Installed game systems

```bash
tar -czf foundry-backup-$(date +%Y%m%d).tar.gz data config modules systems
```

## Security Notes

- Keep `./config/options.json` secure (contains license key)
- Don't commit `.env` or `config/` to version control
- Consider using a reverse proxy with SSL for production
- Restrict access to Foundry port in firewall rules