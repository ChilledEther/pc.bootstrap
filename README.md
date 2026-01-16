# 🚀 PC Bootstrap

A modern, declarative approach to setting up and configuring a Windows development environment using **Native DSC v3**.

## ✨ Features

- **Declarative Setup**: Manage Windows packages and OS settings using clean YAML configuration.
- **Drift Detection**: See what's already configured vs. what needs changes.
- **Automated Installation**: One command to install VS Code, Docker, WSL, and more.
- **Native DSCv3**: Uses the latest DSC engine for reliable, independent configuration.
- **WSL Integration**: Automatically bootstraps your Linux development environment including PowerShell and DSC.

## 📦 Prerequisites

- **Windows 11** or **Windows 10** (latest updates).
- **App Installer** (WinGet) installed via the Microsoft Store.
- **Administrative Privileges** for system-wide configurations.

## 🛠️ Quick Start

### Windows Setup

Run the bootstrap interactively (shows drift, asks for confirmation):

```powershell
.\setup.ps1
```

**Common Flags:**

- `-Test`: Run in dry-run mode (see drift only).
- `-Force`: Apply changes immediately without confirmation.

### Linux/WSL Setup

The Windows setup automatically triggers the WSL bootstrap. To run it manually inside WSL:

```bash
./scripts/bootstrap-linux.sh
```

## 📂 Repository Structure

```text
pc.bootstrap/
├── configuration.yaml         # Main DSCv3 configuration (Windows)
├── setup.ps1                  # Entry point (Proxy to scripts/Invoke-WindowsSetup.ps1)
├── configs/                   # Dotfiles and configuration templates
├── docs/                      # Documentation
│   ├── guide.md               # Architecture & Script guide
│   └── resources.md           # DSCv3 resource reference
└── scripts/                   # Implementation scripts
```

## 🐧 WSL Configuration

The bootstrap automatically:

1. Enables WSL and VirtualMachinePlatform Windows features.
2. Installs Ubuntu via WinGet.
3. Runs `scripts/bootstrap-linux.sh` inside WSL, which:
   - Installs **PowerShell** and **DSC v3** if missing.
   - Executes `scripts/Invoke-WslBootstrap.ps1` to install tools (Apt, Homebrew).

WSL tools are defined directly within `scripts/Invoke-WslBootstrap.ps1`.

## 📚 Documentation

- **[docs/guide.md](docs/guide.md)** - Comprehensive architecture and usage guide.
- **[docs/resources.md](docs/resources.md)** - Deep dive into DSCv3 resource types.

---

_Maintained with ❤️ by Antigravity_
