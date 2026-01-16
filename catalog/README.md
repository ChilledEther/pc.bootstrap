# Custom MCP Catalog

This directory contains a custom catalog of MCP servers for use with `docker-mcp-gateway`.

## Servers Included

- **cloudrun**: Official Google Cloud Run MCP Server
- **context7**: Context7 MCP Server (Latest Info/Search)
- **github**: Official GitHub MCP Server
- **mcp-github-agentic**: Local Custom GitHub Agentic MCP Server

## Usage

### Automation Script (Windows/PowerShell)

A PowerShell script `setup-catalog.ps1` is provided to automate the setup and restoration processes.

**To Install the Custom Catalog:**
```powershell
.\Setup-Catalog.ps1
```

*Note: This script only sets up the catalog file. You may still need to run `docker mcp config reset` and `docker mcp install <server>` to activate specific tools.*

**To Restore the Default Catalog:**
```powershell
.\Setup-Catalog.ps1 -Restore
```

---

### Manual Method

#### Make this the Default Catalog

To override the default Docker catalog (which often contains 300+ tools) and use only these specific servers in Docker Desktop:

1. **Link the catalog file**:

   ```bash
   # Backup existing config
   mv ~/.docker/mcp/docker-mcp.yaml ~/.docker/mcp/docker-mcp.yaml.bak

   # Link this custom catalog
   ln -s ~/projects/repos/pc.bootstrap/catalog/mcp-servers.yaml ~/.docker/mcp/docker-mcp.yaml
   ```

2. **Reset and Re-enable**:

   ```bash
   # Clear the current enabled registry
   docker mcp config reset

   # Enable only your specific servers
   docker mcp install cloudrun
   docker mcp install context7
   docker mcp install github
   docker mcp install mcp-github-agentic
   ```

3. **Verify**:
   ```bash
   # Check active servers
   docker mcp ls
   ```

### Restore Default Catalog

If you need to revert back to the official Docker catalog:

#### Native CLI Method (Recommended)

The Docker MCP Toolkit provides native commands to manage and reset your catalogs:

```bash
# Reset the catalog system to defaults
docker mcp catalog reset

# If you want to create a fresh starter catalog with official examples
docker mcp catalog bootstrap ./official-starter-catalog.yaml
```

#### Manual Method

1. **Restore the original catalog file**:

   ```bash
   # Remove the symlink to the custom catalog
   rm ~/.docker/mcp/docker-mcp.yaml

   # Restore the backup (if you created one)
   mv ~/.docker/mcp/docker-mcp.yaml.bak ~/.docker/mcp/docker-mcp.yaml
   ```

2. **Reset configuration**:

   ```bash
   # Reset the registry and config to defaults
   docker mcp config reset
   ```

   _Note: If you didn't keep a backup, the official catalog will typically be re-downloaded the next time the CLI needs it or after a `config reset`._
