ag() {
    local AG_EXE="/mnt/c/Users/x/AppData/Local/Programs/Antigravity/bin/antigravity"
    # Fallback to 'Ubuntu' or your preferred distro name if the variable is missing
    local DISTRO="${WSL_DISTRO_NAME:-Ubuntu}"
    local TARGET="${1:-.}"
    
    # Resolve the absolute path
    if [ -e "$TARGET" ]; then
        TARGET=$(realpath "$TARGET")
    fi

    # Explicitly use the --folder-uri if it's a directory
    if [ -d "$TARGET" ]; then
        "$AG_EXE" --folder-uri "vscode-remote://wsl+$DISTRO$TARGET" > /dev/null 2>&1
    else
        "$AG_EXE" --remote "wsl+$DISTRO" "$TARGET" > /dev/null 2>&1
    fi
}

# uv
export PATH="~/.local/bin:$PATH"

# To prevent accidental opening of code from WSL, alias code to ag
alias code='ag'

# Windows docker and WSL2 integration
alias docker='docker.exe'

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"