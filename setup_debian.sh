#!/bin/bash

# =============================================================================
#         Debian/Ubuntu Personal Environment Quick Setup Script
#
# Author: Yann (noby)
# Description: This script automates the installation and configuration
#              of vim, git, and Docker on a fresh Debian/Ubuntu system.
# Usage: curl -sSL <raw_github_url> | sudo bash
# =============================================================================

# --- Script Safety and Best Practices ---

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if running as root or with sudo
if [ "$(id -u)" -ne 0 ]; then
   echo "❌ This script must be run as root or with sudo." >&2
   exit 1
fi

# Get the original user who invoked sudo
# This is crucial for placing config files in the correct user's home directory
ORIGINAL_USER=${SUDO_USER:-$(whoami)}
USER_HOME=$(getent passwd "$ORIGINAL_USER" | cut -d: -f6)

echo "🚀 Starting setup for user: $ORIGINAL_USER in home directory: $USER_HOME"


# --- 1. System Update and Essential Packages ---

echo "🔄 Updating package lists..."
apt-get update -y

echo "📦 Installing essential packages: vim, git, curl..."
apt-get install -y vim git curl


# --- 2. Configure Vim ---

echo "✍️  Configuring Vim (.vimrc)..."

# Use cat with EOF for multi-line content, it's cleaner than multiple echos.
# This will create or overwrite the file.
cat << EOF > "$USER_HOME/.vimrc"
" Basic Vim settings
set number
set norelativenumber
" Add more of your favorite settings here
EOF

# Set correct ownership for the config file
chown "$ORIGINAL_USER":"$ORIGINAL_USER" "$USER_HOME/.vimrc"
echo "✅ Vim configured."


# --- 3. Configure Git ---

echo "✍️  Configuring Git..."

# Run git config commands as the original user
sudo -u "$ORIGINAL_USER" git config --global user.name "noby"
sudo -u "$ORIGINAL_USER" git config --global user.email "1326981297@qq.com"
sudo -u "$ORIGINAL_USER" git config --global init.defaultBranch "main"
sudo -u "$ORIGINAL_USER" git config --global core.excludesfile "$USER_HOME/.gitignore_global"
sudo -u "$ORIGINAL_USER" git config --global alias.l "log --pretty=oneline --abbrev-commit --all --graph"

echo "📝 Creating global .gitignore file..."
cat << 'EOF' > "$USER_HOME/.gitignore_global"
# Operating System Files
.DS_Store
.localized
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
desktop.ini
$RECYCLE.BIN/

# Build artifacts
*.class
*.jar
*.war
*.ear
*.zip
*.tar
*.gz
*.rar
target/  # Maven/Gradle build output directory
build/   # Gradle build output directory

# IDE and Editor files
.idea/          # IntelliJ IDEA project files
*.iml           # IntelliJ IDEA module files
.vscode/        # VS Code settings (unless explicitly shared)
.c9/            # Cloud9 IDE
.project        # Eclipse project files
.classpath      # Eclipse project files
.settings/      # Eclipse project settings
*.swp           # Vim swap files
*~              # Backup files from some editors
*.log           # Log files

# Package managers
node_modules/   # Node.js modules
npm-debug.log*

# Mac specific
.AppleDouble
.LSOverride
Icon?

EOF

# Set correct ownership for the gitignore file
chown "$ORIGINAL_USER":"$ORIGINAL_USER" "$USER_HOME/.gitignore_global"
echo "✅ Git configured."


# --- 4. Install Docker Engine (Official Method) ---

echo "🐳 Installing Docker..."

# Add Docker's official GPG key:
apt-get install -y ca-certificates gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the repository:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again to include Docker repo
apt-get update -y

# Install Docker Engine, CLI, and Compose
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add the user to the 'docker' group to run docker commands without sudo
usermod -aG docker "$ORIGINAL_USER"

echo "✅ Docker installed successfully."


# --- Finalization ---

echo ""
echo "🎉 All done! Your new Debian environment is ready."
echo "💡 IMPORTANT: To use Docker without sudo, you need to log out and log back in."

