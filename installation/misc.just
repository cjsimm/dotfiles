set shell := ["zsh", "-cu"]
ZSHRC_FILE := home_dir() + "/.zshrc"

# Install the global tools defined in dotfiles mise.toml config file
install-globals:
    mise install --force --verbose

# Pull the alacritty themes to support alacritty theme setup
install-alacritty-themes:
    echo "Installing a selection of open source alacritty themes..."
    THEME_DIR="$HOME/.config/alacritty/themes"
    mkdir -p "$THEME_DIR"
    git clone https://github.com/alacritty/alacritty-theme.git "$THEME_DIR"
