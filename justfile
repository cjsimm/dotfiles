import 'installation/macos.just'
import 'installation/debian.just'
import 'installation/misc.just'
import 'misc/utils.just'
import 'misc/formatting.just'

# Future default task. Does nothing for now
backup:
    @echo 'Backup the installation'

# Setup a full developer environment from base for an automatically detected target platform
setup-dev:
    just divider "Initial Setup"
    just symlink-config -f
    just divider "Installing packages, toolchains, and applications"
    just installation
    just divider "Setup Complete!"
    echo "call the ssh-keygen command to gen keys for ssh connections!" 

# Install packages, toolchains, and applications for development
installation: _install install-globals install-pypi

