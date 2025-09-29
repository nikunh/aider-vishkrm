#!/bin/bash
set -e

# Logging mechanism for debugging
LOG_FILE="/tmp/aider-install.log"
log_debug() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] $*" >> "$LOG_FILE"
}

# Initialize logging
log_debug "=== AIDER INSTALL STARTED ==="
log_debug "Script path: $0"
log_debug "PWD: $(pwd)"
log_debug "Environment: USER=$USER HOME=$HOME"

# Install Aider using pipx
echo "Installing Aider..."

# Get username from environment or default to babaji
USERNAME=${USERNAME:-"babaji"}
USER_HOME="/home/${USERNAME}"

# Install aider using pipx as the non-root user
if ! command -v aider &> /dev/null; then
    echo "Installing aider via pipx..."
    if command -v pipx &> /dev/null; then
        # Install as the target user if sudo is available and we're running as different user
        if [ "$USER" != "$USERNAME" ] && [ -d "$USER_HOME" ] && command -v sudo &> /dev/null; then
            sudo -u "$USERNAME" pipx install aider-chat
        else
            # Install as current user or fallback to direct pipx install
            pipx install aider-chat
        fi
    else
        echo "Warning: pipx not found, falling back to pip3..."
        pip3 install --user aider-chat
    fi
fi

# Copy aider configuration files if they exist
SCRIPT_DIR="$(dirname "$0")"
if [ -d "$SCRIPT_DIR/configs" ]; then
    # Copy to /etc/skel for new users
    if [ -d "/etc/skel" ]; then
        mkdir -p "/etc/skel/.aider"
        cp -rf "$SCRIPT_DIR/configs"/* "/etc/skel/.aider/"
    fi
    
    # Copy to existing user
    if [ -d "$USER_HOME" ]; then
        mkdir -p "$USER_HOME/.aider"
        cp -rf "$SCRIPT_DIR/configs"/* "$USER_HOME/.aider/"
        if [ "$USER" != "$USERNAME" ]; then
            chown -R ${USERNAME}:${USERNAME} "$USER_HOME/.aider" 2>/dev/null || chown -R ${USERNAME}:users "$USER_HOME/.aider" 2>/dev/null || true
        fi
    fi
fi

# 🧩 Create Self-Healing Environment Fragment (Symlink-based v2.0)
create_environment_fragment() {
    local feature_name="aider"
    
    # Create authoritative fragment in image
    local fragment_source_dir="/etc/skel/.devcontainer-fragments"
    mkdir -p "$fragment_source_dir"
    local fragment_source_file="$fragment_source_dir/.${feature_name}.zshrc"
    
    # Create fragment content with self-healing detection
    # Create fragment content with self-healing detection
    cat > "$fragment_source_file" << 'EOF'
# 🤖 Aider AI Coding Assistant Environment Fragment (Symlink-based v2.0)
# Self-healing detection and environment setup

# Check if aider is available
aider_available=false

# Check for aider in common locations
if command -v aider >/dev/null 2>&1; then
    aider_available=true
elif command -v pipx >/dev/null 2>&1; then
    # Check if aider is installed via pipx
    PIPX_BIN_DIR="$(pipx environment 2>/dev/null | grep PIPX_BIN_DIR | cut -d= -f2)"
    if [ -n "$PIPX_BIN_DIR" ] && [ -x "$PIPX_BIN_DIR/aider" ]; then
        aider_available=true
        if [[ ":$PATH:" != *":$PIPX_BIN_DIR:"* ]]; then
            export PATH="$PIPX_BIN_DIR:$PATH"
        fi
    fi
fi

# Ensure local bin is in PATH
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    # Recheck after adding local bin
    if [ -x "$HOME/.local/bin/aider" ]; then
        aider_available=true
    fi
fi

# If aider is not available, cleanup this fragment symlink
if [ "$aider_available" = false ]; then
    echo "Aider removed, cleaning up environment"
    rm -f "$HOME/.ohmyzsh_source_load_scripts/.aider.zshrc"
fi
EOF

    # Create symlink in /etc/skel
    if [ -d "/etc/skel/.ohmyzsh_source_load_scripts" ]; then
        ln -sf "$fragment_source_file" "/etc/skel/.ohmyzsh_source_load_scripts/.${feature_name}.zshrc"
    fi

    # Create symlink for existing user
    if [ -d "$USER_HOME" ]; then
        mkdir -p "$USER_HOME/.ohmyzsh_source_load_scripts"
        ln -sf "$fragment_source_file" "$USER_HOME/.ohmyzsh_source_load_scripts/.${feature_name}.zshrc"
        if [ "$USER" != "$USERNAME" ]; then
            chown -h ${USERNAME}:${USERNAME} "$USER_HOME/.ohmyzsh_source_load_scripts/.${feature_name}.zshrc" 2>/dev/null || chown -h ${USERNAME}:users "$USER_HOME/.ohmyzsh_source_load_scripts/.${feature_name}.zshrc" 2>/dev/null || true
        fi
    fi
    
    echo "Self-healing environment fragment symlink created: .aider.zshrc"
}

# Call the fragment creation function
create_environment_fragment

echo "Aider installation completed."

# Clean up
if command -v sudo &> /dev/null; then
    sudo apt-get clean
else
    apt-get clean
fi

log_debug "=== AIDER INSTALL COMPLETED ==="
# Test automation Tue Sep 23 19:56:50 BST 2025
