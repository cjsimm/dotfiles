import '../misc/formatting.just'

DEBIAN_PACKAGE_FILE := source_dir() + "/packages/debian.txt"
ARCHITECTURE := `dpkg --print-architecture` 

# Install a full developer environment on a debian-based distro
[linux]
_install: system-update install-packages install-mise install-docker install-neovim install-pastel zsh-setup

# Perform standard debian system package update and upgrade
[linux]
system-update:
    #!/usr/bin/env sh
    echo "Updating package lists..."
    @sudo apt update
    echo "Upgrading installed packages..."
    @sudo apt upgrade -y
    echo "Removing unneeded packages..."
    @sudo apt autoremove -y
    echo "Cleaning up cached package files..."
    @sudo apt clean
    echo "System update complete!"

# Install packages defined in packages/debian.txt
[linux]
install-packages:
    echo "Installing debian repo packages listed in {{DEBIAN_PACKAGE_FILE}}"
    while read -r package; do
        echo "Installing $package..."
        if sudo apt install -y "$package"; then
            echo "$package installed successfully."
        else
            echo "Failed to install $package."
        fi
    done < {{DEBIAN_PACKAGE_FILE}}

# Install mise for debian based system via non-official apt repo signed with mise gpgp key
[linux]
install-mise:
    sudo install -dm 755 /etc/apt/keyrings
    curl -fsSL https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch={{ARCHITECTURE}}] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    sudo apt update
    sudo apt install -y mise

# Install docker engine and related packages via the docker install convenience script
[linux]
install-docker:
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh

# build neovim from source for debian-based systems
[linux]
install-neovim:
    @just divider "Building and Installing Neovim From Source..."
    echo "cloning into neovim repo..."
    git clone https://github.com/neovim/neovim
    # nvim build arg requires different value for amd64
    if [ "{{ARCHITECTURE}}" = 'amd64' ]; then
        NVIM_ARCH_BUILD_ARG="x86_64"
    else
        NVIM_ARCH_BUILD_ARG={{ARCHITECTURE}}
    fi
    echo "architecture flag set to ${NVIM_ARCH_BUILD_ARG}"
    echo "building neovim from source..."
    cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
    cd build && cpack -G DEB && sudo dpkg -i nvim-linux-${NVIM_ARCH_BUILD_ARG}.deb
    echo "build complete. removing src from system..."
    cd ../..
    rm -rf neovim

# install pastel (colour picker tool). Managed by cargo
[linux]
install-pastel:
    @echo "Installing pastel..."
    cargo install pastel

# Download latest versions of zsh and set as default shell
[linux]
zsh-setup:
    echo "Setting zsh as default shell"
    chsh -s $(which zsh)

#################################
# Debian-based commands not included in the _install recipe
#################################

# Change the hostname of the debian system
[linux]
change-hostname hostname="":
    #!/usr/bin/env sh
    if [ -z "{{hostname}}" ]; then
        echo "Failed to change hostname. Add a hostname argument."
        exit 1
    fi
    CURRENT_HOSTNAME=$(hostname)
    echo "Changing hostname on system to '{{hostname}}'"
    hostnamectl set-hostname {{hostname}}
    echo "Updating /etc/hosts file..."
    # check and update the 127.0.1.1 entry (common on debian for main hostname)
    if grep -qE "^127\.0\.1\.1\s+${CURRENT_HOSTNAME}(\s|$)" /etc/hosts; then
        sudo sed -i "s/^127\.0\.1\.1\s\+${CURRENT_HOSTNAME}\(\s\+.*\)*$/127.0.1.1\t{{hostname}}\1/" /etc/hosts
        echo "/etc/hosts entry for 127.0.1.1 updated."
    # check and update the 127.0.0.1 entry if it points to the old hostname
    elif grep -qE "^127\.0\.0\.1\s+${CURRENT_HOSTNAME}(\s|$)" /etc/hosts; then
        sudo sed -i "s/^127\.0\.0\.1\s\+${CURRENT_HOSTNAME}\(\s\+.*\)*$/127.0.0.1\t{{hostname}}\1/" /etc/hosts
        echo "/etc/hosts entry for 127.0.0.1 updated."
    else
        echo "No specific entry for '$CURRENT_HOSTNAME' found in /etc/hosts to update (127.0.1.1 or 127.0.0.1)."
        echo "You may need to manually verify /etc/hosts if issues arise, though 'hostnamectl' usually manages the primary system hostname."
    fi

# Install alacritty. Included in a separate command as not useful for a headless setup
[linux]
install-alacritty:
    apt install cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
    cargo install alacritty
        

