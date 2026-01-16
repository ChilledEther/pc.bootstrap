# 📚 Resource Reference Catalog

This catalog details the **DSCv3 Resources** used in the `pc.bootstrap` project. Use this as a reference when expanding your `configuration.yaml`.

---

## 🛠️ Essential Resources

### 📦 Microsoft.WinGet/Package

The primary resource for installing applications.

```yaml
- name: vscode-package
  type: Microsoft.WinGet/Package
  properties:
    id: Microsoft.VisualStudioCode
    source: winget
```

- **id**: The unique package identifier (find via `winget search <name>`).
- **source**: Usually `winget`, but can be `msstore`.

---

### ⚙️ Microsoft.Windows.Settings/WindowsSettings

Configures modern Windows settings. Requires `allowPrerelease: true`.

```yaml
- name: system-appearance-settings
  type: Microsoft.Windows.Settings/WindowsSettings
  metadata:
    winget:
      allowPrerelease: true
      securityContext: elevated
  properties:
    AppColorMode: Dark
    SystemColorMode: Dark
    TaskbarAlignment: Middle
```

| Property           | Options          |
| :----------------- | :--------------- |
| `AppColorMode`     | `Light`, `Dark`  |
| `SystemColorMode`  | `Light`, `Dark`  |
| `TaskbarAlignment` | `Left`, `Middle` |

---

### 🔑 Microsoft.Windows/Registry

Directly manipulates the Windows Registry for deep system tweaks.

```yaml
- name: explorer-hidden-files
  type: Microsoft.Windows/Registry
  properties:
    keyPath: HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    valueName: Hidden
    valueData:
      DWord: 1
```

- **keyPath**: The full path to the registry key.
- **valueData**: Supports `String`, `DWord`, `Binary`, `ExpandString`, `MultiString`, and `QWord`.

---

### 🧩 PSDesiredStateConfiguration/WindowsOptionalFeature

Enables or disables core Windows components.

```yaml
- name: wsl-feature
  type: PSDesiredStateConfiguration/WindowsOptionalFeature
  properties:
    Name: Microsoft-Windows-Subsystem-Linux
    Ensure: Present
```

---

### 📄 PSDesiredStateConfiguration/File

Manages local file content, ideal for dotfiles and configurations.

```yaml
- name: wsl-config-file
  type: PSDesiredStateConfiguration/File
  properties:
    DestinationPath: "{{USER_PROFILE}}\\.wslconfig"
    Contents: |
      [wsl2]
      memory=8GB
      processors=4
    Ensure: Present
```

### ⚡ PSDscResources/Script

The "Swiss Army Knife" for tasks not covered by existing resources. It allows you to run arbitrary PowerShell logic for testing and applying state.

```yaml
- name: custom-wsl-distro
  type: PSDscResources/Script
  properties:
    GetScript: |
      return @{ Result = "Present" }
    TestScript: |
      $Distro = wsl -l -v | Select-String "Ubuntu"
      return $null -ne $Distro
    SetScript: |
      wsl --install -d Ubuntu --no-launch
```

- **GetScript**: Returns a hash table representing the current state.
- **TestScript**: Returns `$true` if the system is in the desired state, `$false` otherwise.
- **SetScript**: The logic that runs to fix the state if `TestScript` returns `$false`.

---

## 🔍 Resource Discovery

To find and explore all available resources on your machine, use these commands:

### 1. The Global Resource List

Lists every resource the DSC engine can see, including those from adapters.

```powershell
dsc resource list
```

### 2. Inspecting a Schema

Want to know exactly what properties a resource supports? Use the schema command.

```powershell
dsc resource schema --resource Microsoft.WinGet/Package
```

### 3. Testing Your Local Config

Check your current state against a file without applying anything.

```powershell
dsc config test --file configuration.yaml
```

---

## 📐 Best Practices

### 🏷️ Naming Standards

We follow the **Inside-Out Kebab-Case** convention:

- **Good**: `docker-desktop-package`, `wsl-feature`, `path-env-variable`.
- **Bad**: `InstallDocker`, `package-docker`.

### 🔗 Dependencies

Use `dependsOn` to ensure resources are applied in order.

```yaml
- name: ubuntu-package
  type: Microsoft.WinGet/Package
  dependsOn:
    - wsl-feature
```

---

## 🔮 Legacy & Adapter Resources

Through the `Microsoft.Windows/WindowsPowerShell` adapter, we have access to hundreds of legacy DSC resources. Key ones include:

- `PSDesiredStateConfiguration/Environment`: Set `$env:PATH`, etc.
- `PSDesiredStateConfiguration/Service`: Manage Windows Services.
- `PSDesiredStateConfiguration/Archive`: Unzip tools or assets.
- `PSDscResources/Script`: Run arbitrary PowerShell logic.

---

_Reference for pc.bootstrap project_
