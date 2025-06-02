[doc('Prints a divider, with an intermediate message if a message argument is provided')]
divider MESSAGE="":
  @echo "--------------------------------------------------"
  @if [ -n "{{MESSAGE}}" ]; then \
    echo "--- {{MESSAGE}} ---"; \
  fi
  @echo "--------------------------------------------------"

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
