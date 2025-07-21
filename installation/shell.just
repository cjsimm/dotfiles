ZSHRC_FILE := home_dir() + "/.zshrc"

# Download latest versions of zsh and set as default shell
zsh-setup:
    #!/usr/bin/env sh
    echo "Setting zsh as default shell"
    # check if zsh install, if not install
    # update to latest version 
    # set as shell default 

configure-zshrc-file:
    #!/usr/bin/env sh
    echo >> {{ZSHRC_FILE}}
    just _zsh-eval
    just _zsh-alias
    just _zsh-history
    just _zsh-plugins
    source {{ZSHRC_FILE}}

_zsh-plugins:
    #!/usr/bin/env sh
    echo "Linux implementation"

# Adds zshrc plugin initialization to the .zshrc file
[macos]
_zsh-plugins:
    #!/usr/bin/env sh
    lines=(
        "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    )
    for line in "${lines[@]}"; do
        echo "$line" >> {{ZSHRC_FILE}}
    done
    source {{ZSHRC_FILE}}


    
# Adds eval commands required by packages to the .zshrc file
_zsh-eval:
    echo 'eval "$(starship init zsh)"' >> {{ZSHRC_FILE}}

# Adds alias changes appropriate for the zsh config to the .zshrc file
_zsh-alias:
    #!/usr/bin/env sh
    lines=(
        "# Aliases"
        "alias ls='eza'"
        "alias la='eza -a'"
        "alias vi='nvim'"
        "alias cat='bat'"
        "alias lg='lazygit'"
        "alias venv-new='python -m venv .venv'"
        "alias venv='source .venv/bin/activate'"
    )
    for line in "${lines[@]}"; do
        echo "$line" >> {{ZSHRC_FILE}}
    done
    source {{ZSHRC_FILE}}
        


# Adds configuration into .zshrc to use historical commands when scrolling up and down through suggested commands
_zsh-history:
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
    source {{ZSHRC_FILE}}

