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
symlink-config:
    ln -s ~/dotfiles/.config ~/.config
    @echo 'Symlinked dotfiles config directory to system config'

    
