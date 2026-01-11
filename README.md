# 🚀 PC Bootstrap

A modern, declarative approach to setting up and configuring a Windows development environment using **WinGet** and **DSC v3 (Desired State Configuration)**.

## ✨ Features

- **Declarative Setup**: Manage Windows packages and OS settings using clean YAML configuration
- **Drift Detection**: See what's already configured vs. what needs changes
- **Automated Installation**: One command to install VS Code, Docker, WSL, and more
- **DSCv3 Powered**: Uses native DSCv3 resources for reliable configuration
- **WSL Integration**: Automatically bootstraps your Linux development environment

## 📦 Prerequisites

- **Windows 11** or **Windows 10** (latest updates)
- **App Installer** (WinGet) installed via the Microsoft Store
- **Administrative Privileges** for system-wide configurations

## 🛠️ Quick Start

### Test Configuration (Dry Run)
See what's already in desired state and what would change:
```powershell
.\Invoke-Bootstrap.ps1 -Test
```

### Apply Configuration
Run the bootstrap interactively (shows drift, asks for confirmation):
```powershell
.\Invoke-Bootstrap.ps1
```

### Force Apply (No Confirmation)
For automation/CI scenarios:
```powershell
.\Invoke-Bootstrap.ps1 -Force
```

### Validate Syntax Only
```powershell
.\Invoke-Lint.ps1
```

## 📂 Repository Structure

```
pc.bootstrap/
├── configuration.yaml      # Main DSCv3 configuration (template)
├── Invoke-Bootstrap.ps1    # Main automation script
├── Invoke-Lint.ps1         # Configuration syntax validator
├── Invoke-WslBootstrap.ps1 # WSL environment setup
├── wsl-tools.yaml          # WSL development tools manifest
├── DEVELOPMENT.md          # Development guide
└── docs/                   # Detailed documentation
    ├── dsc-resources.md    # DSCv3 resource reference
    └── scripts.md          # Script usage reference
```

## 🐧 WSL Configuration

The bootstrap automatically:
1. Enables WSL and VirtualMachinePlatform Windows features
2. Installs Ubuntu via WinGet
3. Runs `Invoke-WslBootstrap.ps1` inside WSL to set up development tools

WSL tools are defined in `wsl-tools.yaml` (APT packages, Homebrew formulas, Bun packages).

## 📚 Documentation

- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Development guide and quick reference
- **[docs/dsc-resources.md](docs/dsc-resources.md)** - DSCv3 resource types reference
- **[docs/scripts.md](docs/scripts.md)** - Script usage and parameters

---

*Maintained with ❤️ by Antigravity*