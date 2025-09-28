# Symlink the .config dir to the appropriate system location. Takes -f as an argument to force
symlink-config override_flag="":
    @if [ -e ~/.config ] && [ "{{override_flag}}" != "-f" ]; then \
    echo "Warning: ~/.config already exists."; \
    echo "This command will remove the existing ~/.config directory"; \
    echo "A symlink to the 'dotfiles/.config' directory will be made in its place."; \
    echo "Ensure you have backedup any files you with to preserve in '~/.config', then run 'just symlink-config -f' to proceed with overwrite."; \
    exit 1; \
    else \
    rm -rf ~/.config; \
    ln -s ~/dotfiles/.config ~/.config; \
    echo 'Symlinked dotfiles config directory to system config'; \
    fi

# Generate an RSA4096 public/private key pair. Add host information to .ssh/config, copy public key to clipboard and delete from system
ssh-keygen:
    #!/usr/bin/env sh
    echo "Q. What is the alias for this key? (e.g. GitHub): "
    read -r host_alias

    echo "Q. What is the host name or the host IP?: "
    read -r host_name

    echo "Q. What is the username assigned to this key?: "
    read -r user_name

    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/$host_alias" -N ""

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
obsidian-sync:
	#!/usr/bin/env sh
	cd ~/obsidian
	git pull
	git add --all
	git commit -m "Backup {{datetime_utc('%Y-%m-%d %H:%M:%S')}}"
	git push
