test-file:
    echo 'this is a recipe'

# Future default task. running 
backup:
    @echo 'Backup the installation'

#[macos]
install-dev: backup test-file
    # install git

    # install brew

    # install brew packages

    # programming languages
    # curl https://sh.rustup.rs -sSf | sh    



