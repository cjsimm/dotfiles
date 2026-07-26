DOTFILES_SKILLS_DIR := justfile_directory() + "/skills"
CODEX_SKILLS_DIR := home_dir() + "/.codex/skills"

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

# Set up portable skills and other agent-harness integrations.
setup-agent-workflows: link-codex-skills
