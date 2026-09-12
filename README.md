# MTA:SA Trident Sky Edition

Professional Docker image for Multi Theft Auto: San Andreas servers with integrated FastDL (Fast Download) support, complete MySQL compatibility, and optimized performance.

## Features

- ✅ **Complete MySQL Support** - Works with all MySQL modules (`mta_mysql.so`, `dbconmy.so`, `dbConnect`)
- ✅ **Automated FastDL** - Nginx-powered resource acceleration with auto-configuration
- ✅ **Auto-Install MySQL Module** - Automatically downloads and installs `mta_mysql.so`
- ✅ **Latest MTA Version** - Automatically downloads the latest stable release from the official MTA mirror
- ✅ **Ubuntu 22.04 LTS** - Modern, optimized, and secure base image
- ✅ **Clean Console Output** - Professional, error-free startup messages
- ✅ **Security Hardened** - Read-only system files, protected configuration
- ✅ **Pterodactyl Optimized** - Native integration with Pterodactyl Panel

## Quick Start

### For Server Administrators

1. Import the egg file `egg-mta-tridentsky.json` into your Pterodactyl Panel
2. Create a new server using the "MTA:SA Trident Sky" egg
3. Allocate ports for:
   - Main server port (default: 22003)
   - HTTP port (default: 22005)
   - ASE query port (Main port + 123, e.g., 22126)
   - FastDL port (default: 22014) - optional, only if using FastDL
4. Set `FASTDL_ENABLED=1` to enable FastDL (optional)
5. Start your server - MySQL module installs automatically!

### Docker Image

```
ghcr.io/tridentsky/mta-fastdl:latest
```

## Port Configuration

MTA:SA requires multiple ports to function correctly:

| Port | Default | Protocol | Description | Auto-configured |
|------|---------|----------|-------------|-----------------|
| **Main Port** | 22003 | UDP | Primary server port for game connections | Set by Pterodactyl |
| **HTTP Port** | 22005 | TCP | Web resources and admin panel | Yes |
| **ASE Port** | 22126 | UDP | Query port for server list (Main + 123) | Automatic |
| **FastDL Port** | 22014 | TCP | Optional Nginx FastDL port | Yes (if enabled) |

**Important:** The ASE port is automatically calculated as Main Port + 123 and must be allocated in Pterodactyl for the server to appear in the public server list.

## Configuration Variables

| Variable | Description | Default | Editable |
|----------|-------------|---------|----------|
| `FASTDL_ENABLED` | Enable/Disable FastDL (0=Off, 1=On) | `1` | Yes |
| `FASTDL_PORT` | Nginx port for FastDL service | `22014` | No |
| `SERVER_WEBPORT` | HTTP port for resources and admin panel | `22005` | No |

## Which MTA build you get, and how to change it

MTA's **stable** channel publishes rarely. Measured on 2026-09-12, the file it serves
(`linux.multitheftauto.com/dl/multitheftauto_linux_x64.tar.gz`) was built on **27 July 2025**, while
the nightly channel was already on `1.6.0-rc-24147`. That is why a fresh install could feel like it
shipped old files — and there was no way to ask for anything newer, nor to know afterwards what you
had installed.

Two variables now control it:

| Variable | Default | What it does |
|---|---|---|
| `MTA_CHANNEL` | `stable` | `stable` (multitheftauto.com) or `nightly` (latest `1.6.0-rc`) |
| `MTA_BUILD` | *(empty)* | Pin an exact build, e.g. `1.6.0-rc-24147`, for reproducible installs |

The default stays `stable`: a customer buying hosting should not receive a release candidate unless
they ask for one. The **`1.7.0-untested`** line is never selected automatically — you can only reach
it by naming it in `MTA_BUILD`, and the installer warns when you do.

Every install writes `VERSION-TRIDENTSKY.txt` at the server root with the channel, the exact source
URL, the package name and the timestamp. Before, there was no way to tell which build a running
server came from, which is precisely what made "my files are old" impossible to diagnose.

### Downloads are verified now

Each download is checked for size and archive integrity before anything is copied. A truncated file
or an HTML error page used to install a broken server silently; now the install **aborts and says
why**. Verified: an invalid `MTA_BUILD` stops with a clear message and leaves `/mnt/server` empty
rather than half-populated.

> **Note on `baseconfig.tar.gz`:** it is served from MTA's own mirror and was last updated in
> **October 2022**. That is upstream's file, not ours — it only provides the starting `mtaserver.conf`
> and ACL templates, which the panel overwrites with your allocated ports on first boot.

## MySQL Compatibility

This image provides **complete MySQL/MariaDB support** out of the box:

### Supported Modules
- ✅ `mta_mysql.so` - Auto-installed on first startup
- ✅ `dbconmy.so` - Pre-configured with OpenSSL 1.1
- ✅ `dbConnect` - Native MTA function (no module needed)

### Pre-installed Libraries
- `libmysqlclient.so.16` - From official MTA repository
- `libssl.so.1.1` - OpenSSL 1.1 for module compatibility

**No manual configuration needed!** Just upload your gamemode and connect to your external MySQL/MariaDB database.

## FastDL System

### When FASTDL_ENABLED=1:
- Nginx automatically starts on the specified FastDL port
- `httpdownloadurl` is automatically configured in `mtaserver.conf` with your server IP
- Resources are served from `mods/deathmatch/resource-cache/http-client-files/`
- Significantly faster client downloads for large resources
- Gzip compression enabled for optimal performance

### When FASTDL_ENABLED=0:
- Nginx is disabled
- `httpdownloadurl` is removed from `mtaserver.conf`
- Standard MTA HTTP downloads are used

## Technical Details

### Base Image
- **Ubuntu 22.04 LTS** - Latest stable release with long-term support
- Pre-installed: Nginx, libncurses5, MySQL client libraries, OpenSSL 1.1

### Optimizations
- Clean console output (no unnecessary warnings)
- Access logs disabled for better performance
- Gzip compression for FastDL transfers
- Open file cache for fast repeated downloads under player rush
- `sendfile` + `tcp_nopush` + `tcp_nodelay` for maximum static throughput

### Security
- System scripts are read-only (protected via `file_denylist`)
- No arbitrary bash execution allowed
- Minimal container footprint
- Non-root user execution
- Nginx hardened against DoS: per-IP connection limit, strict client timeouts (anti-slowloris), single-range requests only
- Only GET/HEAD methods allowed on FastDL, hidden files blocked, no version disclosure (`server_tokens off`)
- Patched OpenSSL 1.1 (final focal security release)

### Auto-Updates
- Installation script fetches the latest stable MTA:SA build from `linux.multitheftauto.com` (GitHub releases no longer ship Linux tarballs)
- Includes latest default resources and baseconfig
- MySQL module auto-downloads from official MTA repository
- Every image build is also tagged `sha-<commit>` on GHCR for instant rollback

## Building from Source

```bash
git clone https://github.com/TridentSky/mta-fastdl-docker.git
cd mta-fastdl-docker
docker build -t mta-fastdl:latest .
```

## Compatibility

### Tested With:
- ✅ Ubuntu 22.04 LTS (Wings)
- ✅ Pterodactyl Panel (latest)
- ✅ All major MTA gamemodes (Roleplay, DM, Race, etc.)
- ✅ External MySQL/MariaDB databases

### Gamemode Compatibility:
- Downtown Roleplay ✅
- Custom gamemodes with MySQL ✅
- dbConnect-based resources ✅
- mta_mysql.so-based resources ✅
- dbconmy.so-based resources ✅

## Support

For issues, questions, or contributions:
- Website: [https://tridentsky.net/](https://tridentsky.net/)
- Issues: [GitHub Issues](https://github.com/TridentSky/mta-fastdl-docker/issues)

## License

This project is open source. Multi Theft Auto: San Andreas is developed by the MTA team.

## Credits

- **MTA:SA** - [Multi Theft Auto Team](https://multitheftauto.com)
- **Pterodactyl** - [Pterodactyl Panel](https://pterodactyl.io)
- **Development** - Built with [Claude Code](https://claude.com/claude-code) by Anthropic
- **Powered by** - [Trident Sky](https://tridentsky.net/)

---

## Changelog

### Latest Version
- **Hardened Nginx FastDL**: per-IP connection limits, strict timeouts, GET/HEAD only, hidden files blocked, open file cache
- **Patched OpenSSL 1.1** (1.1.1f-1ubuntu2.24, final focal security release) with fallback
- **Install script updated** for MTA v1.6+ (official mirror instead of removed GitHub Linux assets)
- **Rollback tags**: every build published as `sha-<commit>` alongside `latest`
- **Ubuntu 22.04 LTS** base for better performance and compatibility
- **Auto-install MySQL module** (`mta_mysql.so`) on first startup
- **Complete MySQL support** (all modules: `mta_mysql.so`, `dbconmy.so`, `dbConnect`)
- **OpenSSL 1.1** support for `dbconmy.so` module
- **Clean console output** - No unnecessary warnings or errors
- **Optimized Nginx** configuration for FastDL
- Professional startup messages and status indicators

---

**Note:** This is a production-ready image maintained by Trident Sky. The Docker image is public and can be used by anyone, but the Pterodactyl egg configuration file is required for proper integration.
