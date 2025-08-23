# This initial entry point script is currently only optimized for MacOS installations
# This script should take some arguments that allows you to control what exactly youre going to setup.
# BY default, it should just bring you to a state where youre now prepared to execute anything
# in the just file
echo 'Installing the rust toolchain...'
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
echo 'Installing just commandline tool to enable further execution'
cargo install just
echo "##################################"
echo "System ready for further installation. Run \`just installation\` to proceed with a standard developer installation for your system. Execute \`just -l\` to see further recipe options"
echo "##################################"
if [[ "$SHELL" == *"zsh"* ]]; then
    echo "Please run \`source ~/.zshrc\` before continuing"
elif [[ "$SHELL" == *"bash"* ]]; then
    echo "Please run \`source ~/.bashrc\` before continuing"
fi
echo "##################################"
