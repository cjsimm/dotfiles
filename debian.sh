#!/usr/bin/env bash

set -e 

base_install() {
    echo "Updating package repository and installing basic development packages"
    sudo apt-get update
    sudo apt-get install -y git tmux neofetch build-essential \
        libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev curl git \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev cmake
    echo "Installations complete."
}

install_nvim() {
    echo "Building neovim from source..."
    sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential
    git clone https://github.com/neovim/neovim
    cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
    cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
    cd .. && rm -rf neovim
    echo "Neovim installed and source cleaned up."
}

amend_bashrc() {
    echo "Amending .bashrc file..."
    cat <<EOL >> "$HOME/.bashrc"
alias python=python3
alias vi="nvim"
alias vim="nvim"
alias la="ls -A"
export XDG_HOME_CONFIG="$HOME/.config"
EOL
}

install_config() {
    echo "Adding dotfiles..."
    mkdir ~/.config
    git clone https://github.com/cjsimm/dotfiles.git
    mv dotfiles/.[!.]* ~/.config
    rm -rf dotfiles
}

install_env_managers() {
    # pyenv
    echo "Installing pyenv..."
    curl https://pyenv.run | bash
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
    echo 'eval "$(pyenv init -)"' >> ~/.profile
    python_latest_version=$(pyenv install --list | grep -v - | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1 | tr -d '[:space:]')
    echo "Installing latest version of python ($latest_version) and setting as default..."
    pyenv install $python_latest_version
    pyenv global $python_latest_version
    # nvm
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    echo "Installing latest version of node..."
    nvm install node
}

cd "$HOME"
base_install
install_nvim
install_config
amend_bashrc
install_env_managers
exit 0
