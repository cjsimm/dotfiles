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

## Todo

- implement an ubuntu/linux version of the installation flow, refactoring if required
- set tmux text bar to use a lighter colour to offset the blue
- introduce more extreme starship settings with fg and bg colours, or some kind of cool separator between the prompt and the cmdline (dotted line of something
- adapt gitconfig file with some minor changes
- store api keys in the apple keychain and pull them from there during shell init
- get font and other additional information into neofetch correctly 
    - font doesnt show up
    - terminal is set to tmux instead of alacritty or Terminal: /dev/ttys004 if outside tmux
- consider swapping python lanfuage server to ruff instead of pyright
- add calibre to software list 
- add beancount to software list

*Big todo: * Implement the dotfile setup for wsl/debian


## Outstanding issues

- rust installer isnt auto installable
- the env doesnt reload after rust is installed so that cargo is useable
- the install packages loop seems to jump over to other iteration before the command has finished working (macos)
- ncspot doesnt swap audio devices alongside macos if it's swapped (for example airpods connecting)
    - this seems to be a problem in an underlying library that is quite hard to fix
- dont know how to use ncspot or how the keybinds work. figure them out

- api keys arent being stored securely. should be able to get them into the apple keychain and store them there.
    - export LLM_API_KEY=$(security find-generic-password -a "$USER" -s "LLM_API_KEY" -w)

- neofetch doesnt show the correct terminal or font
    - something to do with neofetch not being able to read the terminal through macos
    - neofetch was discontinued, go looking for a new program instead maybe that forks it
    
- ssh keys are removed from the agent on restart (macos)
    - mac os needs extra config settings - add to agent and use keychain. probably also needs to be added manually during creation, too

## Installation automation improvements

- Pull macos settings from somewhere (first research whether theyre persisted over icloud)

## Linux Setup Feature

## Todo

- find out how to handle multiple flavours of linux and package managers
- Update readme with any linux specific information required

## Linux specifc implementations

- _install (master command in debian.just) 

- configure-rc-file (can be factored out into own file)
    - add command that downloads or updates zsh
    - add command that ensure zsh is the default shell

- change-hostname

- install docker via a build from source

## Notes

- just implement debian for now, and figure out how to refactor for other flavours and package managers at a later date
