HERDR_NAVIGATION_PLUGIN := "paulbkim-dev/vim-herdr-navigation"
HERDR_NAVIGATION_PLUGIN_ID := "vim-herdr-navigation"
HERDR_INTEGRATIONS := "codex"

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

# Install the Herdr integrations required by the agentic workflow.
# Add integration names to HERDR_INTEGRATIONS as more agents are supported.
install-herdr-integrations:
    #!/usr/bin/env sh
    set -eu

    if ! command -v mise >/dev/null 2>&1; then
        echo "mise is required to install Herdr integrations." >&2
        exit 1
    fi

    if ! mise exec -- herdr --version >/dev/null 2>&1; then
        echo "The mise-managed Herdr binary is unavailable. Run 'just install-globals' first." >&2
        exit 1
    fi

    for integration in {{HERDR_INTEGRATIONS}}; do
        echo "Installing Herdr integration: $integration"
        mise exec -- herdr integration install "$integration"
    done

    mise exec -- herdr integration status

# Set up agent-harness integrations.
setup-agent-workflows: install-herdr-plugin install-herdr-integrations
