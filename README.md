Dotfiles and installation commands for new machines


# Installation

For a fresh machine, begin the installation by getting Git onto your system, cloning the repo, and
executing `setup.sh` on your machine. This will rustup your system, install `just` via cargo, and then execute the appropriate install for the system via the `just install-dev` command

- Clone the repo
- `cd dotfiles`
- `chmod +x setup.sh`
- `./setup.sh`

## MacOS

Run `xcode-select --install` in your terminal to get access to a version of git. It's recommended to install all offered toolchains with this command to act as system fallbacks. Brew will install and manage newer versions of many of these tools (including git). Brew-managed versions will be found and invoked first when called on the command-line.


## Outstanding issues

- rust installer isnt auto installable
- the env doesnt reload after rust is installed so that cargo is useable
- the mise command is incorrect - it doesnt install unprompted or work at all
- the install packages loop seems to jump over to other iteration before the command has finished working
- ncspot doesnt swap audio devices alongside macos if it's swapped (for example airpods connecting)
- alacritty loses opacity settings if fullscreened
    - is this a bug? is this a good thing?

- nerd fonts arent installed 

- dont know how to use ncspot or how the keybinds work. figure them out

- api keys arent being stored securely. should be able to get them into the apple keychain and store them there.
    
- ssh keys are removed from the agent on restart
    - mac os needs extra config settings - add to agent and use keychain. probably also needs to be added manually during creation, too

## Installation automation improvements

- Pull macos settings from somewhere (first research whether theyr epersisted over icloud)
