# 🧠 Development & Knowledge Base

This repository serves as a modern, declarative bootstrap system for Windows workstations using **WinGet** and **DSC v3**. 

## 🏗️ Architecture Overview

The project transitioned from a static `tools.yaml` manifest to a fully declarative **DSCv3** configuration. This allows for idempotent setup, where the system's state is defined rather than just running a list of install commands.

### 📄 Core Files

| File | Purpose | Key Standards |
| :--- | :--- | :--- |
| `configuration.yaml` | The Desired State definition. | DSCv3 Schema, Flattened properties, Resource Names. |
| `Invoke-Bootstrap.ps1` | The automation engine. | Verb-Noun naming, Splatting, Fail-Fast ($ErrorActionPreference). |
| `README.md` | User-facing documentation. | Premium aesthetics, Emojis, Clear Quick Start. |
| `config/tools.yaml` | Legacy source of truth. | Kept for historical reference/WSL tool list. |

---

## 🛠️ Maintenance Guide

### ➕ Adding New Tools
To add a new Windows package:
1.  Open `configuration.yaml`.
2.  Add a new block under `resources`.
3.  Use the `Microsoft.WinGet.DSC/WinGetPackage` type.
4.  Ensure you provide a descriptive `name` and the correct `id` from `winget search`.

```yaml
  - name: Install My New Tool
    type: Microsoft.WinGet.DSC/WinGetPackage
    properties:
      id: Publisher.ToolID
      source: winget
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
- **Latest DSCv3 Document Schema**: `https://raw.githubusercontent.com/PowerShell/DSC/main/schemas/2024/04/config/document.json`
- **WinGet Settings Schema**: `https://aka.ms/winget-settings.schema.json`
- **Official Docs**: [WinGet Configuration](https://learn.microsoft.com/en-us/windows/package-manager/configuration/)

### 🔍 Context7 Library Ref
When using **Context7** for updates, use the following Library ID:
- `/microsoft/winget-cli` (Contains 900+ snippets for Winget & DSC)

### 🧩 DSCv3 Syntax Nuances
- **DependsOn**: Must use the format `"[ResourceType]ResourceName"`. 
  - *Example*: `"[Microsoft.WinGet.DSC/WinGetPackage]Install Windows Subsystem for Linux"`
- **Flattening**: Unlike 0.2.0 which used `directives` and `settings`, DSCv3 flattens these into top-level keys like `name`, `type`, `dependsOn`, and `properties`.

---

## 🔮 Future Roadmap
- **WSL Internal Automation**: Implement a post-setup script inside the Ubuntu distro to install `brew`, `bun`, and `uv` using the legacy `tools.yaml` as a guide.
- **User Provisioning**: Automate the default user creation in WSL distributions via DSC scripts.

---
*Maintained with ❤️ by Antigravity*
