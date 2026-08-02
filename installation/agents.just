DOTFILES_SKILLS_DIR := justfile_directory() + "/skills"
CODEX_SKILLS_DIR := home_dir() + "/.codex/skills"
HERDR_NAVIGATION_PLUGIN := "paulbkim-dev/vim-herdr-navigation"
HERDR_NAVIGATION_PLUGIN_ID := "vim-herdr-navigation"

# Symlink every portable skill into Codex without replacing its system-managed skills.
link-codex-skills:
    #!/usr/bin/env sh
    set -eu
    source_dir="{{DOTFILES_SKILLS_DIR}}"
    destination_dir="{{CODEX_SKILLS_DIR}}"

    mkdir -p "$destination_dir"
    for skill_dir in "$source_dir"/*; do
        [ -d "$skill_dir" ] || continue
        skill_name=$(basename "$skill_dir")
        destination="$destination_dir/$skill_name"

        if [ -L "$destination" ]; then
            rm "$destination"
        elif [ -e "$destination" ]; then
            echo "Refusing to replace existing non-symlink: $destination" >&2
            exit 1
        fi

        ln -s "$skill_dir" "$destination"
        echo "Linked Codex skill: $skill_name"
    done

# Install the Herdr plugin referenced by .config/herdr/config.toml.
# Herdr stores installed plugins globally, so make this safe to rerun.
install-herdr-plugin:
    #!/usr/bin/env sh
    set -eu

    if ! command -v mise >/dev/null 2>&1; then
        echo "mise is required to install the Herdr plugin." >&2
        exit 1
    fi

    if ! mise exec -- herdr --version >/dev/null 2>&1; then
        echo "The mise-managed Herdr binary is unavailable. Run 'just install-globals' first." >&2
        exit 1
    fi

    if mise exec -- herdr plugin list --plugin "{{HERDR_NAVIGATION_PLUGIN_ID}}" --json | grep -q "{{HERDR_NAVIGATION_PLUGIN_ID}}"; then
        echo "Herdr plugin already installed: {{HERDR_NAVIGATION_PLUGIN_ID}}"
        exit 0
    fi

    echo "Installing Herdr plugin: {{HERDR_NAVIGATION_PLUGIN}}"
    mise exec -- herdr plugin install "{{HERDR_NAVIGATION_PLUGIN}}" --yes
    mise exec -- herdr plugin list --plugin "{{HERDR_NAVIGATION_PLUGIN_ID}}"

# Set up portable skills and other agent-harness integrations.
setup-agent-workflows: link-codex-skills install-herdr-plugin
