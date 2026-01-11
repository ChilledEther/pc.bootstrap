# 🚀 PC Bootstrap

A modern, declarative approach to setting up and configuring a Windows development environment using **WinGet** and **DSC (Desired State Configuration)**.

## ✨ Features
- **Declarative Setup**: Manage your Windows packages and OS settings using a clean YAML configuration.
- **Automated Installation**: One command to install VS Code, Docker, WSL, and more.
- **Fail-Fast Scripting**: Robust PowerShell automation for reliable environment provisioning.
- **DSCv3 Powered**: Utilizes the latest native DSCv3 resources for high-fidelity configuration.

## 📦 Prerequisites
- **Windows 11** or **Windows 10** (latest updates)
- **App Installer** (Winget) installed via the Microsoft Store.
- **Administrative Privileges** for applying system-wide configurations.

## 🛠️ Usage & Workflow

### 1. Validate Syntax
Before running the installation, ensure your `configuration.yaml` is syntactically correct:
```powershell
winget configure validate --file configuration.yaml
```

### 2. Preview Changes (Dry Run)
You can see which resources are already in the desired state and which ones will be modified by running a "test":
```powershell
winget configure test --file configuration.yaml
```
*This will output the status (InDesiredState or NotInDesiredState) for each resource without making changes.*

### 3. Apply Configuration
Run the automated bootstrap script in an **Administrative PowerShell** terminal:
```powershell
.\Invoke-Bootstrap.ps1
```
Alternatively, apply the configuration manually:
```powershell
winget configure --file configuration.yaml --accept-configuration-agreements
```

### 4. Verify Installation
After completion, you can verify that all packages are correctly installed by listing the configuration details:
```powershell
winget configure show --file configuration.yaml
```

## 📂 Repository Structure
- `configuration.yaml`: The main WinGet DSC configuration file (DSCv3).
- `Invoke-Bootstrap.ps1`: Automation script for validation and application.
- `config/tools.yaml`: The original tool manifest (kept for reference).
- `DEVELOPMENT.md`: Detailed technical guide and knowledge base.

## 🐧 WSL Configuration
Once the Windows host is configured, initialize your WSL distribution and refer to `config/tools.yaml` for Linux-specific packages (brew, bun, etc.).

---
*Maintained with ❤️ by Antigravity*