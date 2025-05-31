import 'installation/macos.just'
import 'installation/debian.just'
import 'misc/utils.just'

test-file:
    echo 'this is a recipe'

# Future default task. running 
backup:
    @echo 'Backup the installation'

setup-dev: install 
    # figure out operating system and install appropriate one


    # curl https://sh.rustup.rs -sSf | sh    
    @echo 'and the next one doesnt...'
    @just divider



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
