# Configure zsh with plugins, appropriate aliases, and evaluations
configure-zshrc-file:
	echo >> {{ZSHRC_FILE}}
	just _zsh-eval
	just _zsh-codex-path
	just _zsh-tab-complete
	just _zsh-alias
	just _zsh-history
	just _zsh-plugins

# Adds zshrc plugin initialization to the .zshrc file
[linux]
_zsh-plugins:
	#!/usr/bin/env zsh
	echo "Adding configuration for zsh plugins to source file..."
	lines=(
		"source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
		"source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	)
	for line in "${lines[@]}"; do
		echo "$line" >> {{ZSHRC_FILE}}
	done
	source {{ZSHRC_FILE}}

# Adds zshrc plugin initialization to the .zshrc file
[macos]
_zsh-plugins:
	#!/usr/bin/env zsh
	echo "Adding configuration for zsh plugins to source file..."
	lines=(
		"source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
		"source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	)
	for line in "${lines[@]}"; do
		echo "$line" >> {{ZSHRC_FILE}}
	done
	source {{ZSHRC_FILE}}

# Configure the Codex executable used by the ACP adapter on macOS. The
# Homebrew cask exposes the binary from Homebrew's prefix.
[macos]
_zsh-codex-path:
	#!/usr/bin/env zsh
	CODEX_PATH="$(brew --prefix)/bin/codex"
	if [[ ! -x "$CODEX_PATH" ]]; then
		echo "Homebrew Codex binary not found at $CODEX_PATH." >&2
		exit 1
	fi
	echo "export CODEX_PATH=\"$CODEX_PATH\"" >> {{ZSHRC_FILE}}
	source {{ZSHRC_FILE}}

# Linux uses the adapter's bundled Codex by default, but supports an existing
# native Codex installation without introducing a Homebrew dependency.
[linux]
_zsh-codex-path:
	#!/usr/bin/env zsh
	if command -v codex >/dev/null 2>&1; then
		CODEX_PATH="$(command -v codex)"
		echo "export CODEX_PATH=\"$CODEX_PATH\"" >> {{ZSHRC_FILE}}
		source {{ZSHRC_FILE}}
	else
		echo "No native Codex binary found; ACP will use its bundled Codex."
	fi

# Adds eval commands required by packages to the .zshrc file. This should be factored out so that some kind of starship command takes care of getting this into the zshrc file
_zsh-eval:
	#!/usr/bin/env zsh
	echo "Adding binary evaluations to source file..."
	echo 'eval "$(starship init zsh)"' >> {{ZSHRC_FILE}}
	echo 'eval "$(mise activate zsh)"' >> {{ZSHRC_FILE}}


# Enables tab complete and directory cycling in zsh shell
_zsh-tab-complete:
	#!/usr/bin/env zsh
	echo "Enabling tab-complete..."
	lines=(
		"autoload -Uz compinit"
		"compinit"
	)
	for line in "${lines[@]}"; do
		echo "$line" >> {{ZSHRC_FILE}}
	done
	source {{ZSHRC_FILE}}

# Adds alias changes appropriate for the zsh config to the .zshrc file
_zsh-alias:
	#!/usr/bin/env zsh
	echo "Setting aliases in .zshrc file..."
	lines=(
		"# Aliases"
		"alias ls='eza'"
		"alias la='eza -a'"
		"alias vi='nvim'"
		"alias cat='bat'"
		"alias lg='lazygit'"
		"alias venv-new='python -m venv .venv'"
		"alias venv='source .venv/bin/activate'"
		"alias jl='jupyter lab --ContentsManager.allow_hidden=True'"
		"alias justdot='just --justfile ~/dotfiles/justfile --working-directory .'"
		"alias rss='bulletty'"
	)
	for line in "${lines[@]}"; do
		echo "$line" >> {{ZSHRC_FILE}}
	done
	source {{ZSHRC_FILE}}
	
# Adds configuration into .zshrc to use historical commands when scrolling up and down through suggested commands
_zsh-history:
	#!/usr/bin/env zsh
	echo "Enabling zsh history on arrow u/d..."
	HOME="/Users/$(whoami)"
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
		echo "$line" >> {{ZSHRC_FILE}}
	done
	source {{ZSHRC_FILE}}
