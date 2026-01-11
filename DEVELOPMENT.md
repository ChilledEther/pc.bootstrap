# 🧠 Development & Knowledge Base

This repository serves as a modern, declarative bootstrap system for Windows workstations using **WinGet** and **DSC v3**. 

## 🏗️ Architecture Overview

The project transitioned from a static `tools.yaml` manifest to a fully declarative **DSCv3** configuration. This allows for idempotent setup, where the system's state is defined rather than just running a list of install commands.

### 📄 Core Files

| File | Purpose | Key Standards |
| :--- | :--- | :--- |
| `configuration.yaml` | The Desired State definition (Template). | DSCv3 Schema 2023/08, Template Placeholders (`{{USER_PROFILE}}`). |
| `Invoke-Bootstrap.ps1` | The automation engine & pre-processor. | Path detection, Template resolution, Fail-Fast. |
| `wsl-tools.yaml` | Modular WSL tool manifest. | Compressed YAML, Enabled/Disabled toggles. |
| `Invoke-WslBootstrap.ps1` | WSL-side automation. | PowerShell-based, APT/Brew/Bun handling. |

---

## 🛠️ Maintenance Guide

### ➕ Adding New Tools or Settings
To add a new Windows package or Registry setting:
1.  Open `configuration.yaml`.
2.  Add a new block under `resources`. Use `Microsoft.WinGet/Package` for apps or `Microsoft.Windows/Registry` for tweaks.
3.  **Template Variables**: Use `{{USER_PROFILE}}` for Windows home paths and `{{REPO_ROOT_WSL}}` for internal WSL repo paths.

### 🧪 Validation & Application
We use a **Template Strategy** because WinGet 1.12 does not yet support root-level parameters in the CLI validator.
1.  **Do not** validate `configuration.yaml` directly if it has `{{PLACEHOLDERS}}`.
2.  Run `.\Invoke-Bootstrap.ps1`. This script generates a temporary `resolved-configuration.yaml` with your actual machine paths and applies it.

### ⚠️ Suppressing Informational Warnings
The WinGet 1.12 validator outputs informational messages like:
- *"The module was not provided..."*
- *"The configuration unit is not available publicly..."*

These are **informational only** and appear on all DSCv3 configurations, including machine-exported ones. They cannot be resolved through YAML syntax. Use `--ignore-warnings` to suppress them:
```powershell
winget configure validate --file config.yaml --ignore-warnings
```
`Invoke-Bootstrap.ps1` automatically includes this flag.

---

## 📚 Technical Reference (Knowledge Base)

### 🔗 Useful Links & Schemas
- **Stable DSCv3 Document Schema**: `https://raw.githubusercontent.com/PowerShell/DSC/main/schemas/2023/08/config/document.json`
- **WinGet Settings Schema**: `https://aka.ms/winget-settings.schema.json`
- **Official Docs**: [WinGet Configuration](https://learn.microsoft.com/en-us/windows/package-manager/configuration/)

### 🧩 DSCv3 Syntax Nuances (Stable track)
- **DependsOn**: Use the simple resource `name` string.
  - *Example*: `- "Install Ubuntu Linux Distribution"`
- **Flattening**: DSCv3 flattens `settings` and `directives` into top-level keys like `name`, `type`, and `properties`.
- **Processor Metadata**: We explicitly set the `dscv3` processor in the root metadata to unlock modern resource providers.

### 🔍 Sources & Discovery
- **Resource Investigation**: Use the `dsc` CLI to discover schemas:
  - `dsc resource list`: Shows all available resources.
  - `dsc resource schema --resource Microsoft.WinGet/Package`: Shows property requirements.
- **Dynamic Pathing**: `Invoke-Bootstrap.ps1` calculates paths using `$env:USERPROFILE` and `wslpath` at runtime, ensuring the repo is portable for any user.

---

## 🔮 Future Roadmap
- **Schema Evolution**: Transition to `2024/04` schema once WinGet stable supports root-level `parameters:`.
- **User Provisioning**: Automate default user creation in WSL distributions via DSC scripts.

---
*Maintained with ❤️ by Antigravity*
