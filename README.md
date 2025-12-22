# MTA:SA Docker Image with FastDL

Professional Docker image for Multi Theft Auto: San Andreas servers with integrated FastDL (Fast Download) support using Nginx and MySQL compatibility.

## Features

- ✅ **Automated FastDL** - Nginx-powered resource acceleration
- ✅ **MySQL Support** - Pre-configured MySQL client libraries
- ✅ **Auto-Configuration** - FastDL URL automatically configured in mtaserver.conf
- ✅ **Latest MTA Version** - Automatically downloads latest stable release
- ✅ **Security Hardened** - Read-only system files, minimal attack surface
- ✅ **Pterodactyl Optimized** - Native integration with Pterodactyl Panel

## Quick Start

### For Server Administrators

1. Import the egg file `egg-mta-tridentsky.json` into your Pterodactyl Panel
2. Create a new server using the "MTA:SA Trident Sky" egg
3. Allocate ports for:
   - Main server port (default: 22003)
   - HTTP port (default: 22005)
   - FastDL port (default: 22015) - if using FastDL
4. Set `FASTDL_ENABLED=1` to enable FastDL
5. Start your server

### Docker Image

```
ghcr.io/tridentsky/mta-fastdl:latest
```

## Configuration Variables

| Variable | Description | Default | Editable |
|----------|-------------|---------|----------|
| `FASTDL_ENABLED` | Enable/Disable FastDL (0=Off, 1=On) | `0` | Yes |
| `FASTDL_PORT` | Nginx port for FastDL service | `22015` | No |
| `SERVER_WEBPORT` | HTTP port for resources and admin panel | `22005` | No |

## FastDL System

When `FASTDL_ENABLED=1`:
- Nginx automatically starts on the specified FastDL port
- `httpdownloadurl` is automatically configured in mtaserver.conf
- Resources are served from `mods/deathmatch/resource-cache/http-client-files/`
- Significantly faster client downloads for large resources

When `FASTDL_ENABLED=0`:
- Nginx is disabled
- `httpdownloadurl` is removed from mtaserver.conf
- Standard MTA HTTP downloads are used

## Technical Details

### Base Image
- `ghcr.io/parkervcp/yolks:debian`
- Pre-installed: Nginx, libncurses5, MySQL client libraries

### Security
- System scripts are read-only (protected via file_denylist)
- No arbitrary bash execution allowed
- Minimal container footprint

### Auto-Updates
- Installation script fetches latest MTA:SA release from GitHub
- Falls back to stable version if API fails
- Includes latest default resources and baseconfig

## Building from Source

```bash
git clone https://github.com/TridentSky/mta-fastdl-docker.git
cd mta-fastdl-docker
docker build -t mta-fastdl:latest .
```

## Support

For issues, questions, or contributions:
- Website: [www.tridentsky.net](https://www.tridentsky.net)
- Issues: [GitHub Issues](https://github.com/TridentSky/mta-fastdl-docker/issues)

## License

This project is open source. Multi Theft Auto: San Andreas is developed by the MTA team.

## Credits

- **MTA:SA** - [Multi Theft Auto Team](https://multitheftauto.com)
- **Pterodactyl** - [Pterodactyl Panel](https://pterodactyl.io)
- **Powered by** - [Trident Sky](https://www.tridentsky.net)

---

**Note:** This is a production-ready image. The Docker image is public and can be used by anyone, but requires the Pterodactyl egg configuration file for proper integration.
