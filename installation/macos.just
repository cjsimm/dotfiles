HEAD_FORMULAE := "neovim"
BREW_TAP_FILE := source_dir() + "/packages/taps.txt"
BREW_PACKAGE_FILE := source_dir() + "/packages/brew.txt"
BREW_CASK_FILE := source_dir() + "/packages/brew_cask.txt"

# Install a full developer environment on MacOS
[macos]
_install: install-homebrew install-taps install-packages install-casks

# Install homebrew and set zsh profile to enable its use
install-homebrew:
    #!/usr/bin/env sh
    echo 'Installing homebrew...'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'Adding post-install configuration to .zprofile...'
    echo >> /Users/$(whoami)/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$(whoami)/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

# Install taps defined in packages/taps.txt for use with brew
install-taps:
    #!/usr/bin/env sh
    echo 'Adding homebrew taps listed in taps.txt...'
    while read -r tap; do
        brew tap "$tap"
        echo "Added '$tap' tap."
    done < {{BREW_TAP_FILE}}

# Install brew packages defined in packages/brew.txt
install-packages:
    #!/usr/bin/env sh
    echo 'Installing brew packages listed in brew.txt...'
    while read -r package; do
        echo "Installing $package..."
        if printf "%s\n" {{HEAD_FORMULAE}} | grep -q $package; then
            brew install --HEAD "$package"
        else
            brew install "$package"
        fi
    done < {{BREW_PACKAGE_FILE}}

# Install brew casks defined in packages/brew_cask.txt
install-casks:
    #!/usr/bin/env sh
    echo 'Installing applications listed in cask.txt file...'
    while read -r cask; do
        echo "installing $cask..."
        brew install --cask "$cask"
    done < {{BREW_CASK_FILE}}

[macos]
change-hostname hostname="":
    #!/usr/bin/env sh
    if [ -z "{{hostname}}" ]; then
        echo "Failed to change hostname. Add a hostname argument."
        exit 1
    fi
    echo "Changing hostname on system to '{{hostname}}'"
    system_names=(
        ComputerName
        HostName
        LocalHostName
    )
    for name in "${system_names[@]}"; do
        sudo scutil --set "$name" {{hostname}}
    done
    sudo dscacheutil -flushcache

[macos]
set-aliases:
    #!/usr/bin/env sh
    echo >> /Users/$(whoami)/.zshrc
    echo "alias la='ls -a'" >> /Users/$(whoami)/.zshrc
    echo "alias vi='nvim'" >> /Users/$(whoami)/.zshrc
    echo 'eval "$(starship init zsh)"' >> /Users/$(whoami)/.zshrc
    echo "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    just zsh-history
    source /Users/$(whoami)/.zshrc

# Adds configuration into .zshrc to use historical commands when scrolling up and down through suggested commands
zsh-history:
    #!/usr/bin/env sh
    HOME="/Users/$(whoami)"
    ZSHRC_FILE="$HOME/.zshrc"
    lines=(
        "# History Settings - U/D Arrow keys through shared history file"
        "HISTFILE=$HOME/.zhistory"
        "SAVEHIST=1000"
        "HISTSIZE=999"
        "setopt share_history"
        "setopt hist_expire_dups_first"
        "setopt hist_ignore_dups"
        "setopt hist_verify"
        "bindkey '^[[A' history-search-backward"
        "bindkey '^[[B' history-search-forward"
    )
    for line in "${lines[@]}"; do
        echo "$line" >> "$ZSHRC_FILE"
    done
