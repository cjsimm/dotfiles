PYTHON_PACKAGE_FILE := source_dir() + "packages/python.txt"

# Install the global tools defined in dotfiles mise.toml config file
install-globals:
    mise install --force --verbose
    echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
    src ~/.zshrc

# Install common python packages for the global python installation
install-pypi:
    #!/usr/bin/env sh
    echo 'Installing python packages listed in python.txt...'
    while read -r package; do
        pip install "$package"
    done < {{PYTHON_PACKAGE_FILE}}
