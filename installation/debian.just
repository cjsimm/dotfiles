DEBIAN_PACKAGE_FILE := source_dir() + "/packages/debian.txt"

# Install a full developer environment on a debian-based distro
[linux]
_install: system-update install-packages install-docker

    # add any keyrings/custom repositories necessary


    # install software from a list with apt-get

    # possibly have a separate install command for docker

    # build neovim from source. store this in own file so that a 
    # macos implementation can be made in the future and not be managed 
    # by brew

[linux]
system-update:
    #!/usr/bin/env sh
    @just divider "Updating system packages"
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
    #!/usr/bin/env sh
    echo "Installing debian repo packages listed in {{DEBIAN_PACKAGE_FILE}}"
    while read -r package; do
        echo "Installing $package..."
        if sudo apt install -y "$package"; then
            echo "$package installed successfully."
        else
            echo "Failed to install $package."
        fi
    done < {{DEBIAN_PACKAGE_FILE}}

# Install docker engine and related packages via the docker install convenience script
[linux]
install-docker:
    #!/usr/bin/env sh
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh

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

        

