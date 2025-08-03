import 'installation/macos.just'
import 'installation/debian.just'
import 'installation/misc.just'
import 'installation/python.just'
import 'misc/utils.just'
import 'misc/formatting.just'

# Future default task. Does nothing for now
backup:
    @echo 'Backup the installation'

# Setup a full developer environment from base for an automatically detected target platform
setup-dev:
    #!/usr/bin/env sh
    just divider "Initial Setup"
    echo "Enter hostname for the system:"
    read hostname
    just symlink-config -f
    just divider "Installing packages, toolchains, and applications"
    just installation
    just divider "System Settings"
    just change-hostname hostname="$hostname"
    just configure-rc-file
    just install-alacritty-themes
    just divider "Setup Complete!"
    echo "call the ssh-keygen command to gen keys for ssh connections!" 

# Install packages, toolchains, and applications for development
installation: _install install-globals install-pypi

