# 🔧 Script Reference

This document describes the PowerShell scripts in the pc.bootstrap project.

---

## setup.ps1

The root entry point script that proxies to `scripts/Invoke-WindowsSetup.ps1`.

## scripts/Invoke-WindowsSetup.ps1

The main Windows bootstrap automation engine.

### Usage

```powershell
# Interactive mode (shows drift, asks for confirmation)
.\setup.ps1

# Test mode (shows drift only)
.\setup.ps1 -Test

# Force mode (skip confirmation, apply immediately)
.\setup.ps1 -Force

```

### Parameters

| Parameter | Type   | Description                                   |
| :-------- | :----- | :-------------------------------------------- |
| `-Test`   | Switch | Run drift detection only, don't apply changes |
| `-Force`  | Switch | Skip confirmation prompt, apply immediately   |

### Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  1. Detect dynamic paths ($env:USERPROFILE, wslpath)        │
│  2. Resolve template placeholders in configuration.yaml     │
│  3. Run DSC drift detection (shows ✅/⚠️ per resource)      │
│  4. [If not -Test] Prompt for confirmation                  │
│  5. [If confirmed or -Force] Apply via dsc config set       │
│  6. Cleanup temporary files                                 │
└─────────────────────────────────────────────────────────────┘
```

### Template Placeholders

The script resolves these placeholders in `configuration.yaml`:

| Placeholder         | Replaced With      | Example                                 |
| :------------------ | :----------------- | :-------------------------------------- |
| `{{USER_PROFILE}}`  | `$env:USERPROFILE` | `C:\Users\jarre`                        |
| `{{REPO_ROOT_WSL}}` | WSL path to repo   | `/home/jjr/projects/repos/pc.bootstrap` |

---

## Invoke-Lint.ps1

Validates the configuration YAML syntax.

### Usage

```powershell
.\scripts\Invoke-Lint.ps1
```

### What It Does

- Runs `dsc config validate` (planned) or basic validation
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

| Parameter   | Type   | Description                                |
| :---------- | :----- | :----------------------------------------- |
| `-RepoPath` | String | Absolute path to the repository inside WSL |

### What It Installs

Installs tools directly defined in the script:

- APT packages (git, powershell, curl, etc.)
- Homebrew packages (bun, uv, gh, etc.)
- Sets up global profile persistence
- Creates an onboarding marker at `/root/.wsl-bootstrapped`

---

## Generated Files

These files are created during execution and should be gitignored:

| File                          | Purpose                                  |
| :---------------------------- | :--------------------------------------- |
| `resolved-configuration.yaml` | Configuration with placeholders resolved |

---

_Reference for pc.bootstrap project_
