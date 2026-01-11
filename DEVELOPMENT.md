# 🧠 Development & Knowledge Base

This repository serves as a modern, declarative bootstrap system for Windows workstations using **Native DSC v3**.

---

## 🏗️ Architecture Overview

The project uses a fully declarative **DSCv3** configuration for idempotent system setup, orchestrated directly by the DSC CLI engine.

### 📄 Core Files

| File | Purpose |
| :--- | :--- |
| `configuration.yaml` | Desired State definition (template with placeholders) |
| `Invoke-Bootstrap.ps1` | Main automation engine |
| `Invoke-Lint.ps1` | Configuration syntax validator |
| `wsl-tools.yaml` | WSL development tools manifest |
| `Invoke-WslBootstrap.ps1` | WSL environment setup script |

### 📚 Detailed Documentation

See the `docs/` folder for detailed references:
- **[docs/dsc-resources.md](docs/dsc-resources.md)** - DSCv3 resource reference
- **[docs/scripts.md](docs/scripts.md)** - Script usage and parameters

### 🔗 Useful Links
- **[Official DSC v3 Documentation](https://learn.microsoft.com/en-gb/powershell/dsc/overview?view=dsc-3.0&preserveView=true)**
- [WinGet Configuration Docs](https://learn.microsoft.com/en-us/windows/package-manager/configuration/)

---

## 🚀 Quick Start

```powershell
# Test configuration (show drift, no changes)
.\Invoke-Bootstrap.ps1 -Test

# Interactive apply (show drift, confirm, then apply)
.\Invoke-Bootstrap.ps1

# Force apply (skip confirmation)
.\Invoke-Bootstrap.ps1 -Force

# Lint only (validate YAML syntax)
.\Invoke-Lint.ps1
```

---

## 🛠️ Maintenance Guide

### ➕ Adding New Tools or Settings

1. Open `configuration.yaml`
2. Add a new resource block using kebab-case naming (inside-out)
3. Use appropriate resource type:
   - `Microsoft.WinGet/Package` - Install apps
   - `Microsoft.Windows/Registry` - Registry tweaks
   - `PSDesiredStateConfiguration/WindowsOptionalFeature` - Windows features
   - `PSDesiredStateConfiguration/File` - File contents

### 🔤 Template Placeholders

| Placeholder | Description |
| :--- | :--- |
| `{{USER_PROFILE}}` | Windows user profile path |
| `{{REPO_ROOT_WSL}}` | Repository path inside WSL |

### 🏷️ Naming Convention

All resource names use **kebab-case** with **inside-out** naming:
- ✅ `vscode-package`, `wsl-feature`, `explorer-show-hidden-files-registry`
- ❌ `Install Visual Studio Code`, `package-vscode`

---

## 📦 Prerequisites

Ensure DSC v3 and required modules are installed:

```powershell
# Check available resources
dsc resource list

# Key resources used:
# - PSDesiredStateConfiguration/WindowsOptionalFeature
# - PSDesiredStateConfiguration/File
# - Microsoft.WinGet/Package
# - Microsoft.Windows/Registry
# - Microsoft.Windows.Settings/WindowsSettings
```

---

## 🔮 Future Roadmap

- **Schema Evolution**: Migrate to `2024/04` schema when WinGet supports root-level parameters
- **Improved Drift Detection**: WinGet may add native drift reporting
- **User Provisioning**: Automate WSL user creation

---

*Maintained with ❤️ by Antigravity*
