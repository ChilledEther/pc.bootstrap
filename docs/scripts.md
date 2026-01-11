# 🔧 Script Reference

This document describes the PowerShell scripts in the pc.bootstrap project.

---

## Invoke-Bootstrap.ps1

The main bootstrap automation script.

### Usage

```powershell
# Interactive mode: show drift, ask for confirmation, then apply
.\Invoke-Bootstrap.ps1

# Test mode: show drift only, no changes applied
.\Invoke-Bootstrap.ps1 -Test

# Force mode: skip confirmation, apply immediately
.\Invoke-Bootstrap.ps1 -Force
```

### Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `-Test` | Switch | Run drift detection only, don't apply changes |
| `-Force` | Switch | Skip confirmation prompt, apply immediately |

### Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  1. Detect dynamic paths ($env:USERPROFILE, wslpath)        │
│  2. Resolve template placeholders in configuration.yaml    │
│  3. Transform dependsOn syntax for DSC CLI compatibility   │
│  4. Run DSC drift detection (shows ✅/⚠️ per resource)     │
│  5. [If not -Test] Prompt for confirmation                  │
│  6. [If confirmed or -Force] Apply via winget configure    │
│  7. Cleanup temporary files                                 │
└─────────────────────────────────────────────────────────────┘
```

### Template Placeholders

The script resolves these placeholders in `configuration.yaml`:

| Placeholder | Replaced With | Example |
| :--- | :--- | :--- |
| `{{USER_PROFILE}}` | `$env:USERPROFILE` | `C:\Users\jarre` |
| `{{REPO_ROOT_WSL}}` | WSL path to repo | `/home/jjr/projects/repos/pc.bootstrap` |

---

## Invoke-Lint.ps1

Validates the configuration YAML syntax.

### Usage

```powershell
.\Invoke-Lint.ps1
```

### What It Does
- Runs `winget configure validate` on configuration.yaml
- Uses `--ignore-warnings` to suppress informational messages
- Returns exit code 0 on success, non-zero on failure

---

## Invoke-WslBootstrap.ps1

Bootstraps the WSL (Ubuntu) environment with development tools.

### Usage

Called automatically by the bootstrap via DSC, or manually:

```powershell
wsl -u root -e pwsh -File /path/to/Invoke-WslBootstrap.ps1 -RepoPath /path/to/repo
```

### Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `-RepoPath` | String | Absolute path to the repository inside WSL |

### What It Installs

Reads from `wsl-tools.yaml` and installs:
- APT packages (git, curl, etc.)
- Homebrew packages (yq, gh, etc.)
- Bun packages (via Homebrew-installed Bun)

---

## Generated Files

These files are created during execution and should be gitignored:

| File | Purpose |
| :--- | :--- |
| `resolved-configuration.yaml` | Configuration with placeholders resolved |
| `dsc-test-configuration.yaml` | Configuration transformed for DSC CLI testing |

---

*Reference for pc.bootstrap project*
