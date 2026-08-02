import '../misc/formatting.just'

DEBIAN_PACKAGE_FILE := source_dir() + "/packages/debian.txt"
ARCHITECTURE := if os() == "linux" { `dpkg --print-architecture` } else { `uname -m` }
NERD_FONTS_VERSION := "v3.3.0"
NERD_FONTS_URL := "https://github.com/ryanoasis/nerd-fonts/releases/download/" + NERD_FONTS_VERSION + "/FiraCode.zip"
NERD_FONTS_DIR := home_dir() + "/.local/share/fonts/FiraCode"

# Install a full developer environment on a debian-based distro
[linux]
_install: system-update install-packages install-mise install-docker install-neovim install-pastel install-eza install-httpie install-starship zsh-setup

# Perform standard debian system package update and upgrade
[linux]
system-update:
	#!/usr/bin/env sh
	echo "Updating package lists..."
	sudo apt update
	echo "Upgrading installed packages..."
	sudo apt upgrade -y
	echo "Removing unneeded packages..."
	sudo apt autoremove -y
	echo "Cleaning up cached package files..."
	sudo apt clean
	echo "System update complete!"

# Install packages defined in packages/debian.txt
[linux]
install-packages:
	#!/usr/bin/env sh
	echo "Installing debian repo packages listed in {{DEBIAN_PACKAGE_FILE}}"
	while read -r package; do
		echo "Installing $package..."
		if sudo apt install -y "$package"; then
			echo "$package installed successfully."
		else
			echo "Failed to install $package."
		fi
	done < {{DEBIAN_PACKAGE_FILE}}

# Install mise for debian based system via non-official apt repo signed with mise gpgp key
[linux]
install-mise:
	#!/usr/bin/env sh
	sudo install -dm 755 /etc/apt/keyrings
	curl -fsSL https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg > /dev/null
	echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch={{ARCHITECTURE}}] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
	sudo apt update
	sudo apt install -y mise

# Install docker engine and related packages via the docker install convenience script
[linux]
install-docker:
	#!/usr/bin/env sh
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
	rm get-docker.sh

# Install HTTPie for easy CLI API calls
[linux]
install-httpie:
	#!/usr/bin/env sh
	set -eu
	if [ "{{ARCHITECTURE}}" = "amd64" ]; then
		echo "Installing HTTPie from the upstream amd64 repository..."
		sudo install -dm 755 /usr/share/keyrings
		curl -fsSL https://packages.httpie.io/deb/KEY.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/httpie.gpg > /dev/null
		echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" | sudo tee /etc/apt/sources.list.d/httpie.list > /dev/null
	else
		echo "Installing HTTPie from the native Debian repository for {{ARCHITECTURE}}..."
		sudo rm -f /etc/apt/sources.list.d/httpie.list /usr/share/keyrings/httpie.gpg
	fi
	if ! sudo apt-get update; then
		echo "Failed to update apt package lists for HTTPie installation." >&2
		exit 1
	fi
	if ! sudo apt-get install -y httpie; then
		echo "Failed to install HTTPie for {{ARCHITECTURE}}." >&2
		exit 1
	fi
	if ! http --version; then
		echo "HTTPie installation verification failed." >&2
		exit 1
	fi

# build neovim from source for debian-based systems
[linux]
install-neovim:
	#!/usr/bin/env sh
	just divider "Building and Installing Neovim From Source..."
	echo "cloning into neovim repo..."
	git clone https://github.com/neovim/neovim
	# nvim build arg requires different value for amd64
	if [ "{{ARCHITECTURE}}" = 'amd64' ]; then
		NVIM_ARCH_BUILD_ARG="x86_64"
	else
		NVIM_ARCH_BUILD_ARG={{ARCHITECTURE}}
	fi
	echo "architecture flag set to ${NVIM_ARCH_BUILD_ARG}"
	echo "building neovim from source..."
	cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
	cd build && cpack -G DEB && sudo dpkg -i nvim-linux-${NVIM_ARCH_BUILD_ARG}.deb
	echo "build complete. removing src from system..."
	cd ../..
	rm -rf neovim

# install pastel (colour picker tool). Managed by cargo
[linux]
install-pastel:
	#!/usr/bin/env sh
	echo "Installing pastel via cargo..."
	cargo install pastel

#install the eza command line tool (ls replacement)
[linux]
install-eza:
	sudo mkdir -p /etc/apt/keyrings
	wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
	echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
	sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
	sudo apt update
	sudo apt install -y eza

# Install the pinned FiraCode Nerd Font release used by the Alacritty config
[linux]
install-nerdfonts:
	#!/usr/bin/env sh
	set -eu

	FONT_DIR="{{NERD_FONTS_DIR}}"
	EXPECTED_FONTS="FiraCodeNerdFontMono-Regular.ttf FiraCodeNerdFontMono-Bold.ttf"
	mkdir -p "$FONT_DIR"

	fonts_are_installed=true
	for font in $EXPECTED_FONTS; do
		if [ ! -f "$FONT_DIR/$font" ]; then
			fonts_are_installed=false
			break
		fi
	done

	if [ "$fonts_are_installed" = true ]; then
		echo "FiraCode Nerd Font {{NERD_FONTS_VERSION}} is already installed in $FONT_DIR."
	else
		if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
			echo "Failed to install FiraCode Nerd Font: curl and unzip are required." >&2
			exit 1
		fi

		tmp_dir=$(mktemp -d)
		trap 'rm -rf "$tmp_dir"' EXIT
		archive="$tmp_dir/FiraCode.zip"

		echo "Downloading FiraCode Nerd Font {{NERD_FONTS_VERSION}}..."
		if ! curl --fail --location --silent --show-error --retry 3 "{{NERD_FONTS_URL}}" --output "$archive"; then
			echo "Failed to download FiraCode Nerd Font {{NERD_FONTS_VERSION}}." >&2
			exit 1
		fi
		unzip -q "$archive" -d "$tmp_dir/fonts"

		for font in $EXPECTED_FONTS; do
			if [ ! -f "$tmp_dir/fonts/$font" ]; then
				echo "Failed to install FiraCode Nerd Font: expected $font was not in the archive." >&2
				exit 1
			fi
			install -m 644 "$tmp_dir/fonts/$font" "$FONT_DIR/$font"
		done
	fi

	if command -v fc-cache >/dev/null 2>&1; then
		fc-cache -f "$FONT_DIR"
		echo "FiraCode Nerd Font is ready in $FONT_DIR (font cache refreshed)."
	else
		echo "FiraCode Nerd Font files verified in $FONT_DIR. fc-cache was not found; refresh the cache after installing fontconfig."
	fi

# install starship through the auto-install script
[linux]
install-starship:
    # also need a nerdfont here
    curl -sS https://starship.rs/install.sh | sh -s -- -y


# Download latest versions of zsh and set as default shell
[linux]
zsh-setup:
	#!/usr/bin/env sh
	echo "Setting zsh as default shell"
	sudo chsh -s $(which zsh)
	echo . "$HOME/.cargo/env" >> {{ZSHRC_FILE}}

#################################
# Debian-based commands not included in the _install recipe
#################################

# Change the hostname of the debian system
[linux]
change-hostname hostname="":
	#!/usr/bin/env sh
	if [ -z "{{hostname}}" ]; then
		echo "Failed to change hostname. Add a hostname argument."
		exit 1
	fi
	CURRENT_HOSTNAME=$(hostname)
	echo "Changing hostname on system to '{{hostname}}'"
	hostnamectl set-hostname {{hostname}}
	echo "Updating /etc/hosts file..."
	# check and update the 127.0.1.1 entry (common on debian for main hostname)
	if grep -qE "^127\.0\.1\.1\s+${CURRENT_HOSTNAME}(\s|$)" /etc/hosts; then
		sudo sed -i "s/^127\.0\.1\.1\s\+${CURRENT_HOSTNAME}\(\s\+.*\)*$/127.0.1.1\t{{hostname}}\1/" /etc/hosts
		echo "/etc/hosts entry for 127.0.1.1 updated."
		# check and update the 127.0.0.1 entry if it points to the old hostname
	elif grep -qE "^127\.0\.0\.1\s+${CURRENT_HOSTNAME}(\s|$)" /etc/hosts; then
		sudo sed -i "s/^127\.0\.0\.1\s\+${CURRENT_HOSTNAME}\(\s\+.*\)*$/127.0.0.1\t{{hostname}}\1/" /etc/hosts
		echo "/etc/hosts entry for 127.0.0.1 updated."
	else
		echo "No specific entry for '$CURRENT_HOSTNAME' found in /etc/hosts to update (127.0.1.1 or 127.0.0.1)."
		echo "You may need to manually verify /etc/hosts if issues arise, though 'hostnamectl' usually manages the primary system hostname."
	fi

# Install Alacritty as an optional Linux GUI recipe; it is intentionally not part of _install.
[linux]
install-alacritty:
	#!/usr/bin/env sh
	set -eu

	if ! command -v cargo >/dev/null 2>&1; then
		echo "Cargo is required to install Alacritty. Install Rust/Cargo and try again." >&2
		exit 1
	fi

	echo "Installing Alacritty native build dependencies..."
	sudo apt-get update
	sudo apt-get install -y cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
	echo "Installing Alacritty with Cargo..."
	cargo install --locked alacritty

	if ! command -v alacritty >/dev/null 2>&1; then
		echo "Alacritty installation completed but alacritty is not on PATH." >&2
		exit 1
	fi
	alacritty --version
