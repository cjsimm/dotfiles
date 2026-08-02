HEAD_FORMULAE := "neovim"
BREW_TAP_FILE := source_dir() + "/packages/taps.txt"
BREW_PACKAGE_FILE := source_dir() + "/packages/brew.txt"
BREW_CASK_FILE := source_dir() + "/packages/brew_cask.txt"
BREW_SETUP := '''
set -eu
if [ -x /opt/homebrew/bin/brew ]; then
    brew_bin=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ]; then
    brew_bin=/usr/local/bin/brew
else
    brew_bin=$(command -v brew 2>/dev/null || true)
fi
if [ -z "$brew_bin" ]; then
    echo 'Homebrew was not found at /opt/homebrew/bin/brew, /usr/local/bin/brew, or on PATH.' >&2
    exit 1
fi
brew_shellenv=$("$brew_bin" shellenv) || {
    echo "Failed to initialize Homebrew from '$brew_bin'." >&2
    exit 1
}
eval "$brew_shellenv" || {
    echo 'Failed to evaluate Homebrew shell environment.' >&2
    exit 1
}
brew() { "$brew_bin" "$@"; }
'''


# Install a full developer environment on MacOS
[macos]
_install: install-homebrew install-taps install-packages install-casks link-compose-binary

# make symbolic link form docker-compose binary to docker plugins folder to get 'docker compose' command working on MacOS without the hyphen
link-compose-binary:
	#!/usr/bin/env sh
	mkdir -p ~/.docker/cli-plugins/
	ln $(which docker-compose) ~/.docker/cli-plugins/

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
	{{BREW_SETUP}}
	echo 'Adding homebrew taps listed in taps.txt...'
	while read -r tap; do
		tap=$(printf '%s\n' "$tap" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
		case "$tap" in
			''|'#'*) continue ;;
		esac
		brew tap "$tap"
		echo "Added '$tap' tap."
	done < {{BREW_TAP_FILE}}

# Install brew packages defined in packages/brew.txt
[macos]
install-packages:
    #!/usr/bin/env sh
    {{BREW_SETUP}}
    set --
    echo 'Installing brew packages listed in brew.txt...'
    while read -r package; do
        package=$(printf '%s\n' "$package" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
        case "$package" in
            ''|'#'*) continue ;;
        esac
        if printf '%s\n' {{HEAD_FORMULAE}} | grep -Fqx -- "$package"; then
            echo "Installing $package..."
            brew install --HEAD "$package"
            continue
        fi
        set -- "$@" "$package"
    done < {{BREW_PACKAGE_FILE}}
    if [ "$#" -gt 0 ]; then
        echo 'Installing regular brew packages...'
        brew install "$@"
    fi
    just _set-path

# Set path for any packages that require overriding native macos versions
_set-path:
    #!/usr/bin/env sh
    set -eu
    printf '%s\n' \
        '# PATH' \
        'export PATH="/opt/homebrew/opt/bison/bin:$PATH"' >> {{ZSHRC_FILE}}
    . {{ZSHRC_FILE}}

# Install brew casks defined in packages/brew_cask.txt
install-casks:
    #!/usr/bin/env sh
    {{BREW_SETUP}}
    echo 'Installing applications listed in cask.txt file...'
    while read -r cask; do
        cask=$(printf '%s\n' "$cask" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
        case "$cask" in
            ''|'#'*) continue ;;
        esac
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
