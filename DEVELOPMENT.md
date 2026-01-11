# 🧠 Development & Knowledge Base

This repository serves as a modern, declarative bootstrap system for Windows workstations using **WinGet** and **DSC v3**. 

## 🏗️ Architecture Overview

The project transitioned from a static `tools.yaml` manifest to a fully declarative **DSCv3** configuration. This allows for idempotent setup, where the system's state is defined rather than just running a list of install commands.

### 📄 Core Files

| File | Purpose | Key Standards |
| :--- | :--- | :--- |
| `configuration.yaml` | The Desired State definition. | DSCv3 Schema, Registry Settings (Dark Mode, Explorer), WSL Config. |
| `Invoke-Bootstrap.ps1` | The automation engine. | Verb-Noun naming, Splatting, Fail-Fast. |
| `README.md` | User-facing documentation. | Premium aesthetics, Emojis, Clear Quick Start. |
| `config/tools.yaml` | Legacy source of truth. | Kept for historical reference/WSL tool list. |

---

## 🛠️ Maintenance Guide

### ➕ Adding New Tools or Settings
To add a new Windows package or Registry setting:
1.  Open `configuration.yaml`.
2.  Add a new block under `resources`.
3.  For apps: Use `Microsoft.WinGet/Package`.
4.  For system settings (Dark Mode, Taskbar, etc.): Use the high-level `Microsoft.Windows.Settings/WindowsSettings` resource.
5.  For specific registry tweaks: Use `Microsoft.Windows/Registry`.

```yaml
  - name: WindowsSettings
    type: Microsoft.Windows.Settings/WindowsSettings
    metadata:
      allowPrerelease: true # Required for advanced settings
      securityContext: elevated
    properties:
      AppColorMode: Dark
      TaskbarAlignment: Center
```

### ⚙️ Configuring System Settings
We use the `PSDscResources/File` resource (via the DSC bridge) or direct DSCv3 providers to manage files like `.wslconfig`. 
- **Important**: In DSCv3, the syntax for these resources uses `properties: { DestinationPath: ..., Contents: ... }`.

### 🧪 Validation
Before committing changes, always validate your YAML:
```powershell
winget configure validate --file configuration.yaml
```

---

## 📚 Technical Reference (Knowledge Base)

### 🔗 Useful Links & Schemas
- **Latest DSCv3 Document Schema**: `https://raw.githubusercontent.com/PowerShell/DSC/main/schemas/2023/08/config/document.json`
- **WinGet Settings Schema**: `https://aka.ms/winget-settings.schema.json`
- **Official Docs**: [WinGet Configuration](https://learn.microsoft.com/en-us/windows/package-manager/configuration/)

### 🔍 Context7 Library Ref
When using **Context7** for updates, use the following Library ID:
- `/microsoft/winget-cli` (Contains 900+ snippets for Winget & DSC)

### 🧩 DSCv3 Syntax Nuances
- **DependsOn**: For the `2023/08` schema, reference dependencies using their simple `name` string.
  - *Example*: `- "Install Windows Subsystem for Linux"`
- **Flattening**: Unlike 0.2.0 which used `directives` and `settings`, DSCv3 flattens these into top-level keys like `name`, `type`, `dependsOn`, and `properties`.
- **Parameterization**: We use the `[[parameters('name')]]` syntax for dynamic paths. These are passed during execution via the `--parameter` flag in `Invoke-Bootstrap.ps1`.

### 🔍 Sources & Discovery
The information for advanced resources like `Microsoft.Windows.Settings/WindowsSettings` was sourced from:
- **GitHub Samples**: The [microsoft/winget-dsc](https://github.com/microsoft/winget-dsc) repository contains the latest community and official samples for WinGet Configuration.
- **Resource Investigation**: Use the `dsc` CLI to discover schemas directly on your machine:
  - `dsc resource list`: Shows all available resources.
  - `dsc resource schema --resource <Name>`: Shows the exact properties (like `AppColorMode` or `TaskbarAlignment`).
- **Dynamic Paths**: To avoid hardcoding user profiles, `Invoke-Bootstrap.ps1` detects `$env:USERPROFILE` and the WSL mirror path (via `wslpath`) and injects them into the configuration at runtime.

---

## 🔮 Future Roadmap
- **WSL Internal Automation**: Implement a post-setup script inside the Ubuntu distro to install `brew`, `bun`, and `uv` using the legacy `tools.yaml` as a guide.
- **User Provisioning**: Automate the default user creation in WSL distributions via DSC scripts.

---
*Maintained with ❤️ by Antigravity*
