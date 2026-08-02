# Dotfiles

Personal developer-environment configuration and installation recipes for macOS and Debian-based Linux systems.

The repository uses [`just`](https://github.com/casey/just) to coordinate installation. It manages shell configuration, terminal and editor settings, command-line tools, language tooling, Python packages, and portable Codex skills from one version-controlled directory.

## What is included

- zsh configuration with completions, syntax highlighting, autosuggestions, history search, aliases, Starship, and mise
- Neovim, tmux, Alacritty, WezTerm, btop, ncspot, neofetch, and Git configuration
- Common command-line tools such as `eza`, `bat`, `lazygit`, `ripgrep`, `tealdeer`, and `httpie`
- mise-managed versions of tree-sitter, Node.js, Python, Go, Lua, fzf, stylua, OpenCode, and Herdr
- Python packages for data work, Jupyter, HTTP requests, and terminal utilities
- Docker tooling and Alacritty themes
- Portable Codex skills from the [`skills/`](skills/) directory
- Utility recipes for SSH keys, Python test directories, and Obsidian backups

## Installation

The bootstrap process has two stages:

1. `setup.sh` installs Rust and the `just` command.
2. `just setup-dev` performs the platform-specific installation and configuration.

### Prerequisites

You need Git, curl, and an account with permission to install software. The installation also requires network access and may prompt for `sudo` credentials.

On macOS, install Apple’s command-line tools first:

```sh
xcode-select --install
```

On Debian or Ubuntu, install the basic build tools first:

```sh
sudo apt update
sudo apt install -y build-essential curl git
```

### Bootstrap a machine

```sh
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
chmod +x setup.sh
./setup.sh
source "$HOME/.cargo/env"
just setup-dev
```

`setup-dev` asks for a hostname, then:

1. Links the repository’s `.config` directory to `~/.config`.
2. Installs platform-specific packages and tools.
3. Configures zsh, installs the mise-managed tools, and installs Codex ACP globally through the mise-managed Node.js runtime.
4. Changes the hostname.
5. Installs Alacritty themes when Alacritty is available.
6. Links the repository’s portable Codex skills.

After installation, restart the shell or source the generated shell configuration:

```sh
source ~/.zshrc
```

## Platform support

### macOS

The macOS recipes install Homebrew, Brew formulae, and GUI applications from the package lists in [`installation/packages/`](installation/packages/). The current Homebrew paths assume Apple Silicon (`/opt/homebrew`). The generated zsh configuration points `CODEX_PATH` at the Homebrew Codex binary so the ACP adapter uses the same Codex installation. Docker Compose is additionally linked into Docker’s CLI plugin directory so that `docker compose` is available.

### Debian-based Linux

The Linux recipes target Debian-based distributions with `apt`, `dpkg`, and systemd. They update the system, install packages, configure mise, install Docker Engine, build Neovim from source, and install tools such as eza, HTTPie, Starship, and pastel.

The Linux installation is intended primarily for a development workstation or VM. Alacritty and Nerd Fonts are not part of the default Linux installation; `just install-alacritty` is available as a separate recipe. If a native `codex` executable is already available, the generated zsh configuration uses it; otherwise the ACP adapter keeps using its bundled Codex.

This repository does not currently provide equivalent recipes for Arch, Fedora, Alpine, WSL-specific Docker setups, or non-systemd Linux environments.

## Package lists and configuration

Platform-specific packages are declared in:

- [`installation/packages/brew.txt`](installation/packages/brew.txt) — macOS command-line tools
- [`installation/packages/brew_cask.txt`](installation/packages/brew_cask.txt) — macOS GUI applications and fonts
- [`installation/packages/debian.txt`](installation/packages/debian.txt) — Debian packages
- [`installation/packages/python.txt`](installation/packages/python.txt) — Python packages installed with pip
- [`installation/packages/taps.txt`](installation/packages/taps.txt) — Homebrew taps

The shared configuration lives under [`.config/`](.config/). `setup-dev` symlinks the entire directory into `~/.config`, so changes made in the repository are immediately used by applications.

## Useful recipes

Run `just --list` to see every available recipe. Common commands include:

```sh
just setup-dev
just symlink-config -f
just configure-zshrc-file
just install-globals
just install-codex-acp
just install-pypi
just install-alacritty-themes
just link-codex-skills
just install-alacritty       # Linux, optional
just ssh-keygen
just python-test-directory
just obsidian-backup
```

### SSH keys

`just ssh-keygen` creates an Ed25519 key, appends a host entry to `~/.ssh/config`, copies the public key to the clipboard when `pbcopy` or `xclip` is available, and removes the public-key file afterward. It does not configure an SSH agent or platform keychain.

### Configuration safety

`just symlink-config -f` removes the existing `~/.config` directory before creating the symlink. Back up any configuration you want to keep before using the `-f` option.

The repository ignores machine-local credentials, including `.config/gcloud/`. Do not commit cloud credentials, API keys, tokens, or generated application state.

## macOS/Linux parity

The shared shell, application configuration, mise tools, Python package list, and Codex skill setup are intended to work on both platforms. The installation mechanisms and available applications differ:

| Area | macOS | Debian-based Linux |
| --- | --- | --- |
| Package manager | Homebrew | apt plus external repositories and installers |
| Neovim | Homebrew HEAD build | Latest source build |
| Docker | Docker formulae plus Compose plugin link | Docker Engine installer |
| GUI applications | Brew casks, including Alacritty and fonts | Not installed by default |
| Shell plugins | Homebrew paths | `/usr/share` paths |
| Hostname | `scutil` | `hostnamectl` and `/etc/hosts` |
| Codex skills | Symlinked from `skills/` | Symlinked from `skills/` |

Parity is currently partial. Linux has a working Debian-oriented path, but it does not yet match the macOS application set or all workstation conveniences. See the TODO list below for known gaps.

## Known issues and TODO

### Installation and portability

- Add a shebang and portable shell behavior to `setup.sh`; its current `[[ ... ]]` syntax assumes Bash even though the script has no shebang.
- Replace hardcoded `~/dotfiles` and `/Users/...` paths with paths derived from the repository and current user.
- Make the zsh history path portable; Linux currently receives a macOS `/Users/<user>/.zhistory` path.
- Make repeated setup runs idempotent instead of appending duplicate entries to `.zshrc`.
- Add explicit checks for required commands, supported architectures, and failed package installations.
- Decide whether to support only Debian/Ubuntu or add package-manager implementations for other Linux distributions.
- Support Intel macOS as well as Apple Silicon Homebrew paths.

### macOS/Linux parity

- Add Linux installation and configuration for Nerd Fonts and Alacritty.
- Decide on a consistent Docker strategy between Docker Desktop/Colima on macOS and Docker Engine on Linux.
- Add Linux equivalents for important macOS cask applications where applicable.
- Remove the amd64-only HTTPie repository configuration or make it architecture-aware.
- Make Neovim installation reproducible by pinning versions or using the same installation strategy on both platforms.
- Ensure Python and pip installation works with Debian’s externally managed Python environments.
- Install or remove the `bulletty`/`rss` alias consistently on both platforms.
- Add `bat` to the macOS package list, since the shared shell aliases `cat` to `bat`.

### Shell, security, and tooling

- Replace destructive `~/.config` replacement with a backup or merge-based approach.
- Add further ignore rules for generated credentials and application state as new tools are adopted.
- Add macOS Keychain support for API keys and SSH-agent persistence.
- Improve SSH key-agent setup on Linux and macOS.
- Replace discontinued neofetch or document an alternative.
- Document ncspot keybindings and investigate audio-device switching.
- Add tests or dry-run validation for the `just` recipes.
- Expand Neovim documentation, including CodeCompanion history, LLM defaults, merge-conflict navigation, and Telescope filtering.
- Document terminal font requirements for Nerd Font icons used by Starship and Neovim.

## License

This is a personal configuration repository. Review the files and installation commands before using them on another machine.
