# 🚀 PC Bootstrap

A modern, declarative approach to setting up and configuring a Windows development environment using **WinGet** and **DSC (Desired State Configuration)**.

## ✨ Features
- **Declarative Setup**: Manage your Windows packages using a clean YAML configuration.
- **Automated Installation**: One command to install VS Code, WSL, Google Drive, and more.
- **Fail-Fast Scripting**: Robust PowerShell automation for reliable environment provisioning.

## 📦 Prerequisites
- **Windows 11** or **Windows 10** (latest updates)
- **App Installer** (Winget) installed via the Microsoft Store.

## 🛠️ Quick Start

### 1. Initialize Configuration
The environment is defined in `configuration.yaml`. You can customize this file to include any additional `winget` packages you need.

### 2. Run Setup
Execute the following command in an administrative PowerShell terminal to bootstrap your machine:

```powershell
.\Invoke-Bootstrap.ps1
```

Or run winget directly:

```powershell
winget configure --file configuration.yaml
```

## 📂 Repository Structure
- `configuration.yaml`: The main WinGet DSC configuration file.
- `Invoke-Bootstrap.ps1`: Automation script for validation and application.
- `config/tools.yaml`: The original tool manifest (source of truth for migration).

## 🐧 WSL Configuration
After the Windows host setup is complete, you can manually install the WSL-specific tools (brew, git, bun, etc.) listed in `config/tools.yaml` within your preferred Linux distribution.

---
*Maintained with ❤️ by Antigravity*