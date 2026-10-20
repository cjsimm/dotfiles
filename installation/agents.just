HERDR_NAVIGATION_PLUGIN := "paulbkim-dev/vim-herdr-navigation"
HERDR_NAVIGATION_PLUGIN_ID := "vim-herdr-navigation"
HERDR_INTEGRATIONS := "codex"

# Merge portable preferences into the local config, preserving machine-specific settings.
apply-codex-settings:
    #!/usr/bin/env -S uv run --with tomlkit==0.13.3 python
    import os
    import shutil
    import stat
    import tempfile
    from collections.abc import MutableMapping
    from pathlib import Path

    import tomlkit

    def merge(existing, portable):
        for key, value in portable.items():
            if isinstance(existing.get(key), MutableMapping) and isinstance(value, MutableMapping):
                merge(existing[key], value)
            else:
                existing[key] = value

    source = Path("{{justfile_directory()}}/.config/codex/config.toml")
    target = (Path(os.environ.get("CODEX_HOME", Path.home() / ".codex")) / "config.toml").resolve()
    portable = tomlkit.parse(source.read_text())
    original = target.read_text() if target.exists() else ""
    existing = tomlkit.parse(original)
    merge(existing, portable)
    updated = tomlkit.dumps(existing)
    tomlkit.parse(updated)

    if updated == original:
        print("Codex settings already applied.")
        raise SystemExit(0)

    target.parent.mkdir(parents=True, exist_ok=True)
    mode = stat.S_IMODE(target.stat().st_mode) if target.exists() else 0o600
    if target.exists():
        with tempfile.NamedTemporaryFile(prefix="config.toml.backup-", dir=target.parent, delete=False) as backup:
            shutil.copyfile(target, backup.name)
        print(f"Backup: {backup.name}")

    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", dir=target.parent, delete=False) as output:
            temporary = Path(output.name)
            output.write(updated)
        temporary.chmod(mode)
        os.replace(temporary, target)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    print(f"Applied settings to {target}")

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
setup-agent-workflows: apply-codex-settings install-herdr-plugin install-herdr-integrations
