import 'installation/macos.just'
import 'installation/debian.just'
import 'installation/misc.just'
import 'misc/utils.just'

# Future default task. running 
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
installation: install install-globals install-pypi

# Symlink the .config dir to the appropriate system location
symlink-config override_flag="":
    @if [ -e ~/.config ] && [ "{{override_flag}}" != "-f" ]; then \
    echo "Warning: ~/.config already exists."; \
    echo "This command will remove the existing ~/.config directory"; \
    echo "A symlink to the 'dotfiles/.config' directory will be made in its place."; \
    echo "Ensure you have backedup any files you with to preserve in '~/.config', then run 'just symlink-config -f' to proceed with overwrite."; \
    exit 1; \
    else \
    rm -rf ~/.config; \
    ln -s ~/dotfiles/.config ~/.config; \
    echo 'Symlinked dotfiles config directory to system config'; \
    fi
