#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Exit if any command in a pipeline fails.
set -o pipefail

# Define the installation directory for Metasploit Framework.
MSF_DIR="/opt/metasploit-framework"

# Define ASCII color codes for better readability in the terminal.
RED='\033[0;31m'    # Red color
GREEN='\033[0;32m'  # Green color
YELLOW='\033[0;33m' # Yellow color
NC='\033[0m'       # No Color (resets terminal color)

# Base64-encoded ASCII art Banner, This decodes and prints a simple banner.
BASE64_ASCII_BANNER="CgogICAgICAgICAgICAgICAuO2x4TzBLWFhYSzBPeGw6LgogICAgICAgICAgICxvMFdNTU1NTU1NTU1NTU1NTU1NTU1LZCwKICAgICAgICAneE5NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NV3gsCiAgICAgIDpLTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTUs6CiAgICAuS01NTU1NTU1NTU1NTU1NTVdOTk5XTU1NTU1NTU1NTU1NTU1NWCwKICAgbFdNTU1NTU1NTU1NTVhkOi4uICAgICAuLjtkS01NTU1NTU1NTU1NTW8KICB4TU1NTU1NTU1NTVdkLiAgICAgICAgICAgICAgIC5vTk1NTU1NTU1NTU1rCiBvTU1NTU1NTU1NTXguICAgICAgICAgICAgICAgICAgICBkTU1NTU1NTU1NTXgKLldNTU1NTU1NTU06ICAgICAgICAgICAgICAgICAgICAgICA6TU1NTU1NTU1NTSwKeE1NTU1NTU1NTW8gICAgICAgICAgICAgICAgICAgICAgICAgbE1NTU1NTU1NTU8KTk1NTU1NTU1NVyAgICAgICAgICAgICAgICAgICAgLGNjY2Njb01NTU1NTU1NTVdsY2NjY2M7Ck1NTU1NTU1NTVggICAgICAgICAgICAgICAgICAgICA7S01NTU1NTU1NTU1NTU1NTU1NTVg6Ck5NTU1NTU1NTVcuICAgICAgICAgICAgICAgICAgICAgIDtLTU1NTU1NTU1NTU1NTU1YOgp4TU1NTU1NTU1NZCAgICAgICAgICAgICAgICAgICAgICAgICwwTU1NTU1NTU1NTUs7Ci5XTU1NTU1NTU1NYyAgICAgICAgICAgICAgICAgICAgICAgICAnT01NTU1NTTAsCiBsTU1NTU1NTU1NTWsuICAgICAgICAgICAgICAgICAgICAgICAgIC5rTU1PJwogIGRNTU1NTU1NTU1NV2QnICAgICAgICAgICAgICAgICAgICAgICAgIC4uCiAgIGNXTU1NTU1NTU1NTU1OeGMnLiAgICAgICAgICAgICAgICAjIyMjIyMjIyMjCiAgICAuME1NTU1NTU1NTU1NTU1NTU1XYyAgICAgICAgICAgICMrIyAgICAjKyMKICAgICAgOzBNTU1NTU1NTU1NTU1NTU1vLiAgICAgICAgICArOisKICAgICAgICAuZE5NTU1NTU1NTU1NTU1vICAgICAgICAgICsjKys6KysjKwogICAgICAgICAgICdvT1dNTU1NTU1NTW8gICAgICAgICAgICAgICAgKzorCiAgICAgICAgICAgICAgIC4sY2RrTzBLOyAgICAgICAgOis6ICAgIDorOgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDo6Ojo6OjorOgogICAgICAgICAgICAgICAgICAgICAgICAgICAgCgpbKl0gTWV0YXNwbG9pdCBMaW51eCBJbnN0YWxsZXIgYW5kIFVwZGF0ZXIKWypdIEJ5IERhcmtjYXN0Cgo="
echo "$BASE64_ASCII_BANNER" | base64 -d

# Ensures the script is run on a Linux system.
check_os() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        echo -e "${RED}[✘] This script is for Linux only.${NC}"
        exit 1
    else
        echo -e "${GREEN}[✔] Linux detected. Continuing...${NC}"
    fi
}

# Call the check_os function to verify the OS.
check_os

# Function to install Metasploit Framework.
function install_msf() {
    echo -e "${GREEN}[*] Updating system and installing dependencies...${NC}"
    # Update package lists and upgrade existing packages.
    sudo apt update && sudo apt upgrade -y
    # Install all necessary dependencies for Metasploit.
    sudo apt install -y autoconf bison build-essential libapr1 libaprutil1 libcurl4-openssl-dev \
    libgmp-dev libpcap-dev libpq-dev libreadline-dev libsqlite3-dev libssl-dev libxml2 libxml2-dev \
    libxslt1-dev libyaml-dev ncurses-dev openssl postgresql postgresql-contrib ruby ruby-dev wget \
    xsel zlib1g zlib1g-dev git curl libffi-dev libgdbm-dev libncurses5-dev libtool libv8-dev pkg-config gnupg2

    # Check if the Metasploit directory already exists.
    if [ -d "$MSF_DIR" ]; then
        echo -e "${YELLOW}[!] Directory $MSF_DIR already exists. Please remove it first or use --upgrade.${NC}"
        exit 1
    fi

    echo -e "${GREEN}[*] Cloning Metasploit Framework to $MSF_DIR...${NC}"
    # Clone the Metasploit Framework repository using sudo for permissions in /opt.
    sudo git clone https://github.com/rapid7/metasploit-framework.git "$MSF_DIR"
    # Change ownership of the cloned directory to the current user.
    # This is crucial so that subsequent gem installations are done as the user, not root.
    sudo chown -R "$USER":"$USER" "$MSF_DIR"

    echo -e "${GREEN}[*] Installing Bundler and Ruby gems...${NC}"
    # Install bundler for the current user.
    # This ensures it's installed in the user's gem directory (e.g., ~/.local/share/gem/ruby/X.X.0).
    gem install bundler

    # Dynamically determine the user's Ruby gem installation path.
    # This is where 'bundle' and other gem executables will be located.
    local GEM_HOME=$(ruby -e 'print Gem.user_dir')
    # Add the gem executable path to the beginning of the PATH environment variable.
    # This makes sure the shell can find the 'bundle' command.
    export PATH="$GEM_HOME/bin:$PATH"
    # Set BUNDLE_USER_HOME to a user-writable directory for Bundler's internal configuration and cache.
    export BUNDLE_USER_HOME="$HOME/.bundle"

    # Create the user's bundle directory if it doesn't exist.
    mkdir -p "$BUNDLE_USER_HOME"

    # Change to the Metasploit Framework directory.
    cd "$MSF_DIR"
    # Configure Bundler to install gems within the user's specified GEM_HOME.
    # This avoids permission issues by not trying to write to system-wide gem paths.
    bundle config set --local path "$GEM_HOME"
    # Configure Bundler to skip development and test dependencies to reduce installation size.
    bundle config set --local without 'development test'
    # Install all required Ruby gems for Metasploit Framework.
    bundle install

    echo -e "${GREEN}[*] Creating symlinks...${NC}"
    # Create symbolic links for msfconsole and msfvenom in /usr/local/bin.
    # This allows running 'msfconsole' and 'msfvenom' directly from any terminal.
    sudo ln -sf "$MSF_DIR/msfconsole" /usr/local/bin/msfconsole
    sudo ln -sf "$MSF_DIR/msfvenom" /usr/local/bin/msfvenom

    echo -e "${GREEN}[*] Starting PostgreSQL service...${NC}"
    # Start the PostgreSQL database service. Metasploit uses this for data storage.
    sudo systemctl start postgresql
    # Enable PostgreSQL to start automatically on boot.
    sudo systemctl enable postgresql

    echo -e "${GREEN}[*] Installation complete! Run 'msfconsole' to start.${NC}"
}

# Function to upgrade Metasploit Framework.
function upgrade_msf() {
    # Check if Metasploit is already installed.
    if [ ! -d "$MSF_DIR" ]; then
        echo -e "${YELLOW}[!] Metasploit not found at $MSF_DIR. Please run --install first.${NC}"
        exit 1
    fi

    echo -e "${GREEN}[*] Pulling latest Metasploit Framework changes...${NC}"
    # Change to the Metasploit Framework directory.
    cd "$MSF_DIR"

    # Pull the latest changes from the Git repository.
    if ! git pull; then
        echo -e "${YELLOW}[!] Git pull failed. Please resolve conflicts manually.${NC}"
        echo -e "${YELLOW}[!] Suggested commands:${NC}"
        echo "    git stash"
        echo "    git pull"
        echo "    git stash pop"
        exit 1
    fi

    echo -e "${GREEN}[*] Checking bundle status...${NC}"
    # Dynamically determine the user's Ruby gem installation path for the upgrade function.
    local GEM_HOME=$(ruby -e 'print Gem.user_dir')
    # Add the gem executable path to the PATH for this function.
    export PATH="$GEM_HOME/bin:$PATH"
    # Set BUNDLE_USER_HOME for the upgrade function as well.
    export BUNDLE_USER_HOME="$HOME/.bundle"

    # Configure bundle to install gems within the user's specified GEM_HOME for upgrades too.
    bundle config set --local path "$GEM_HOME"

    # Check if all gems are installed and up to date.
    if ! bundle check >/dev/null 2>&1; then
        echo -e "${GREEN}[*] Installing missing gems...${NC}"
        # Install any missing or updated gems.
        bundle install
    else
        echo -e "${GREEN}[*] All gems are already installed and up to date.${NC}"
    fi

    echo -e "${GREEN}[*] Upgrade complete! Run 'msfconsole' to start.${NC}"
}

# Main script logic: parse command-line arguments.
if [[ "$1" == "--install" ]]; then
    install_msf # Call the install function if --install is provided.
elif [[ "$1" == "--upgrade" ]]; then
    upgrade_msf # Call the upgrade function if --upgrade is provided.
else
    # Display usage instructions if no valid argument is provided.
    echo "Usage: $0 --install | --upgrade"
    exit 1
fi