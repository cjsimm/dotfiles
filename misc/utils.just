DOTFILES_CONFIG_DIR := justfile_directory() + "/.config"

# Symlink the repository .config directory to the appropriate system location. Takes -f as an argument to force.
symlink-config override_flag="":
    #!/usr/bin/env sh
    set -eu
    config_path="$HOME/.config"
    repository_config="{{DOTFILES_CONFIG_DIR}}"

    if [ -L "$config_path" ] && [ "$config_path" -ef "$repository_config" ]; then
        echo "~/.config already links to $repository_config"
        exit 0
    fi

    if [ -e "$config_path" ] || [ -L "$config_path" ]; then
        if [ "{{override_flag}}" != "-f" ]; then
            echo "Refusing to replace existing ~/.config without -f." >&2
            echo "Run 'just symlink-config -f' to move it to a timestamped backup before linking." >&2
            exit 1
        fi

        backup_base="$HOME/.config.backup-$(date +%Y%m%d-%H%M%S)"
        backup_path="$backup_base"
        backup_suffix=1
        while [ -e "$backup_path" ] || [ -L "$backup_path" ]; do
            backup_path="${backup_base}-${backup_suffix}"
            backup_suffix=$((backup_suffix + 1))
        done

        mv "$config_path" "$backup_path"
        echo "Backed up existing ~/.config to $backup_path"
        echo "To recover: rm \"$config_path\" && mv \"$backup_path\" \"$config_path\""
    fi

    ln -s "$repository_config" "$config_path"
    echo "Symlinked $repository_config to ~/.config"

# Generate an RSA4096 public/private key pair. Add host information to .ssh/config, copy public key to clipboard and delete from system
ssh-keygen:
    #!/usr/bin/env sh
    echo "Q. What is the alias for this key? (e.g. GitHub): "
    read -r host_alias

    echo "Q. What is the host name or the host IP?: "
    read -r host_name

    echo "Q. What is the username assigned to this key?: "
    read -r user_name

    ssh-keygen -t ed25519 -f "$HOME/.ssh/$host_alias" -N ""

    {
      echo ""
      echo "Host $host_alias"
      echo "  HostName $host_name"
      echo "  User $user_name"
      echo "  IdentityFile ~/.ssh/$host_alias"
    } >> "$HOME/.ssh/config"

    echo "Copying public key to clipboard"
    if command -v pbcopy >/dev/null 2>&1; then
      pbcopy < "$HOME/.ssh/$host_alias.pub"
    elif command -v xclip >/dev/null 2>&1; then
      xclip -selection clipboard < "$HOME/.ssh/$host_alias.pub"
    else
      echo "Could not copy public key to clipboard. Please copy it manually:"
      cat "$HOME/.ssh/$host_alias.pub"
    fi
    rm "$HOME/.ssh/$host_alias.pub"
    echo "Public key deleted from the system."
    echo "Setup complete.'$host_alias' key-pair genned."

# Create a standard Python pytest test directory
python-test-directory:
	mkdir -p tests/{unit,integration} && touch tests/{__init__.py,conftest.py} tests/unit/{__init__.py,conftest.py} tests/integration/{__init__.py,conftest.py}

# Pull/push obsidian vault to version control
obsidian-backup:
	#!/usr/bin/env sh
	cd ~/obsidian
	git pull
	git add --all
	git commit -m "Backup {{datetime_utc('%Y-%m-%d %H:%M:%S')}}"
	git push
