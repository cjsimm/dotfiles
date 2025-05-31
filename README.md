Dotfiles and installation commands for new machines


# Installation


For a fresh machine, begin the installation by getting Git onto your system, cloning the repo, and
executing `setup.sh` on your machine. This will rustup your system, install `just` via cargo, and then execute the appropriate install for the system via the `just install-dev` command

## MacOS

Run `xcode-select --install` in your terminal to get access to a version of git. It's recommended to install all offered toolchains with this command to act as system fallbacks. Brew will install and manage newer versions of many of these tools (including git). Brew-managed versions will be found and invoked first when called on the command-line.


