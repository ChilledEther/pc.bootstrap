# 📚 DSCv3 Resource Reference

This document provides detailed information about the DSCv3 resources used in this project.

---

## 🧩 Resource Types

### PSDesiredStateConfiguration/WindowsOptionalFeature
Enables or disables Windows optional features.

```yaml
- name: wsl-feature
  type: PSDesiredStateConfiguration/WindowsOptionalFeature
  metadata:
    winget:
      securityContext: elevated
  properties:
    Name: Microsoft-Windows-Subsystem-Linux
    Ensure: Present
```

**Properties:**
| Property | Type | Description |
| :--- | :--- | :--- |
| `Name` | string | The feature name (e.g., `Microsoft-Windows-Subsystem-Linux`) |
| `Ensure` | string | `Present` or `Absent` |

---

### Microsoft.WinGet/Package
Installs applications via WinGet.

```yaml
- name: vscode-package
  type: Microsoft.WinGet/Package
  properties:
    id: Microsoft.VisualStudioCode
    source: winget
```

**Properties:**
| Property | Type | Description |
| :--- | :--- | :--- |
| `id` | string | The WinGet package ID |
| `source` | string | Package source (typically `winget`) |

---

### Microsoft.Windows/Registry
Manages Windows Registry keys and values.

```yaml
- name: explorer-show-hidden-files-registry
  type: Microsoft.Windows/Registry
  properties:
    keyPath: HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    valueName: Hidden
    valueData:
      DWord: 1
```

**Properties:**
| Property | Type | Description |
| :--- | :--- | :--- |
| `keyPath` | string | Full registry path |
| `valueName` | string | Name of the registry value |
| `valueData` | object | Value data (supports `DWord`, `String`, etc.) |

---

### Microsoft.Windows.Settings/WindowsSettings
Configures Windows system settings (requires `allowPrerelease: true`).

```yaml
- name: windows-personalization-settings
  type: Microsoft.Windows.Settings/WindowsSettings
  metadata:
    winget:
      allowPrerelease: true
      securityContext: elevated
  properties:
    AppColorMode: Dark
    SystemColorMode: Dark
    DeveloperMode: true
    TaskbarAlignment: Middle
```

**Properties:**
| Property | Type | Description |
| :--- | :--- | :--- |
| `AppColorMode` | string | `Light` or `Dark` |
| `SystemColorMode` | string | `Light` or `Dark` |
| `DeveloperMode` | boolean | Enable developer mode |
| `TaskbarAlignment` | string | `Left` or `Middle` |

---

### PSDesiredStateConfiguration/File
Manages file contents (requires PowerShell DSC module).

```yaml
- name: wslconfig-file
  type: PSDesiredStateConfiguration/File
  properties:
    DestinationPath: "C:\\Users\\user\\.wslconfig"
    Contents: |
      [wsl2]
      memory=8GB
    Ensure: Present
```

**Properties:**
| Property | Type | Description |
| :--- | :--- | :--- |
| `DestinationPath` | string | Full path to the file |
| `Contents` | string | File contents |
| `Ensure` | string | `Present` or `Absent` |

---

### Microsoft.DSC.Transitional/RunCommandOnSet
Executes commands during the Set phase (not idempotent).

```yaml
- name: wsl-environment-init
  type: Microsoft.DSC.Transitional/RunCommandOnSet
  properties:
    executable: wsl
    arguments:
      - -u
      - root
      - -e
      - pwsh
      - -File
      - "/path/to/script.ps1"
```

**Properties:**
| Property | Type | Description |
| :--- | :--- | :--- |
| `executable` | string | The command to run |
| `arguments` | array | Command arguments |

---

## 📦 Available PSDesiredStateConfiguration Resources

These resources are available via the `Microsoft.Windows/WindowsPowerShell` adapter:

| Resource | Description |
| :--- | :--- |
| `PSDesiredStateConfiguration/Archive` | Extract archive files |
| `PSDesiredStateConfiguration/Environment` | Manage environment variables |
| `PSDesiredStateConfiguration/File` | Manage file contents |
| `PSDesiredStateConfiguration/Group` | Manage local groups |
| `PSDesiredStateConfiguration/GroupSet` | Manage multiple groups |
| `PSDesiredStateConfiguration/Log` | Write log messages |
| `PSDesiredStateConfiguration/Package` | Manage MSI packages |
| `PSDesiredStateConfiguration/ProcessSet` | Manage multiple processes |
| `PSDesiredStateConfiguration/Registry` | Manage registry (alternative to Microsoft.Windows/Registry) |
| `PSDesiredStateConfiguration/Script` | Run PowerShell scripts |
| `PSDesiredStateConfiguration/Service` | Manage Windows services |
| `PSDesiredStateConfiguration/ServiceSet` | Manage multiple services |
| `PSDesiredStateConfiguration/SignatureValidation` | Validate signatures |
| `PSDesiredStateConfiguration/User` | Manage local users |
| `PSDesiredStateConfiguration/WaitForAll` | Wait for all resources |
| `PSDesiredStateConfiguration/WaitForAny` | Wait for any resource |
| `PSDesiredStateConfiguration/WaitForSome` | Wait for some resources |
| `PSDesiredStateConfiguration/WindowsFeature` | Manage Windows Server features |
| `PSDesiredStateConfiguration/WindowsFeatureSet` | Manage multiple Windows Server features |
| `PSDesiredStateConfiguration/WindowsOptionalFeature` | Manage Windows client optional features |
| `PSDesiredStateConfiguration/WindowsOptionalFeatureSet` | Manage multiple optional features |
| `PSDesiredStateConfiguration/WindowsPackageCab` | Install CAB packages |
| `PSDesiredStateConfiguration/WindowsProcess` | Manage Windows processes |

---

## 🔗 Useful Commands

```powershell
# List all available DSC resources
dsc resource list

# Get schema for a specific resource
dsc resource schema --resource Microsoft.WinGet/Package

# Test a configuration (shows drift)
dsc config test --file config.yaml

# Get current state of resources in a config
dsc config get --file config.yaml
```

---

## ⚠️ Known Limitations

1. **WinGet `configure test`** - Only lists resources, doesn't show drift. Use `dsc config test` instead.
2. **`dependsOn` syntax** - WinGet uses simple names, DSC CLI requires `resourceId()` function. The bootstrap script transforms this automatically.
3. **PSDesiredStateConfiguration/File** - DSC CLI can't parse multiline `Contents` blocks. These resources are excluded from drift testing but still applied.
4. **WindowsSettings resource** - May report false drift due to detection issues.

---

*Reference for pc.bootstrap project*
