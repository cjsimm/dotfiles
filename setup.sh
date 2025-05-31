# This initial entry point script is currently only optimized for MacOS installations
# This script should take some arguments that allows you to control what exactly youre going to setup.
# BY default, it should just bring you to a state where youre now prepared to execute anything
# in the just file
echo 'Installing the rust toolchain...'
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo 'Installing just commandline tool to enable further execution'
cargo install just
