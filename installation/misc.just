# Install the global tools defined in dotfiles mise.toml config file
install-globals:
	#!/usr/bin/env zsh
	mise trust
	mise activate
	source {{ZSHRC_FILE}} && mise install

# Install Codex ACP globally using the Node.js version managed by mise.
install-codex-acp:
	#!/usr/bin/env zsh
	set -euo pipefail

	if ! command -v mise >/dev/null 2>&1; then
		echo "mise is required to install Codex ACP." >&2
		exit 1
	fi

	if ! mise exec -- node --version >/dev/null 2>&1; then
		echo "The mise-managed Node.js runtime is unavailable. Run 'just install-globals' first." >&2
		exit 1
	fi

	if ! mise exec -- npm install --global @agentclientprotocol/codex-acp; then
		echo "Failed to install @agentclientprotocol/codex-acp." >&2
		exit 1
	fi

	if ! mise exec -- codex-acp --version; then
		echo "Codex ACP was installed but could not be executed." >&2
		exit 1
	fi

# Pull the alacritty themes to support alacritty theme setup
install-alacritty-themes:
	#!/usr/bin/env zsh
	if ! command -v alacritty &> /dev/null; then
		echo "Alacritty is not installed. Skipping theme installation."
		exit 0
	fi
	echo "Installing a selection of open source alacritty themes..."
	THEME_DIR="$HOME/.config/alacritty/themes"
	mkdir -p "$THEME_DIR"
	git clone https://github.com/alacritty/alacritty-theme.git "$THEME_DIR"

# Install bulletty rss feed
install-bulletty:
	#!/usr/bin/env zsh
	# IMPROVEMENT - Get my feeds into a single file and also import them
	cargo install bulletty
