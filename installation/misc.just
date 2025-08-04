
# Install the global tools defined in dotfiles mise.toml config file
install-globals:
    mise install --force --verbose
    # this isnt a platform independent implementation
    echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
    src ~/.zshrc


# Pull the alacritty themes to support alacritty theme setup
install-alacritty-themes:
    #!/usr/bin/env sh
    echo "Installing a selection of open source alacritty themes..."
    THEME_DIR="$HOME/.config/alacritty/themes"
    mkdir -p "$THEME_DIR"
    git clone https://github.com/alacritty/alacritty-theme.git "$THEME_DIR"
