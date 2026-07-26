# Personal keybindings

`Leader` in Neovim is `Space`. Herdr's `Prefix` is `Ctrl-Space`.

## Herdr

### Configured

| Keys | Action |
| --- | --- |
| `Ctrl-Space` | Enter Herdr prefix mode. |
| `Ctrl-h/j/k/l` | Shared Neovim/Herdr navigation. In Neovim, move through editor splits first; at an edge, move to the neighbouring Herdr pane. |
| `Prefix h/j/k/l` | Focus Herdr pane left/down/up/right. |
| `Alt-Shift-h/l` | Previous/next Herdr tab. |
| `Prefix _` | Split top/bottom. |
| `Prefix |` | Split left/right. |
| `Prefix \\` | Return to the last focused pane. |

### Useful built-ins (not custom-configured)

| Keys | Action |
| --- | --- |
| `Prefix z` | Zoom/unzoom the focused pane. |
| `Prefix b` | Toggle sidebar visibility. |
| `Prefix o` | Focus the visible notification target. |
| `Prefix g` | Open the searchable session navigator. Filter with `b`/`w`/`i`/`d` for blocked/working/idle/done. |
| `Prefix Tab` / `Prefix Shift-Tab` | Cycle panes forward/backward. |
| `Prefix r`, then `h/j/k/l` | Resize a pane. |
| `Prefix Shift-h/j/k/l` | Swap pane left/down/up/right. |
| `Prefix ?` | Show active keybindings. |

`Prefix {` / `Prefix }` were discussed as tmux-style up/down pane swaps, but
are not configured.

## Neovim

### Core editing and windows

| Mode | Keys | Action |
| --- | --- | --- |
| Normal | `Leader pv` | Open the current buffer's directory in netrw. |
| Normal | `Leader s` | Start a whole-buffer replacement for the word under cursor. |
| Normal | `Leader sv` / `Leader sh` | Create vertical / horizontal Neovim split. |
| Normal | `Leader ts` | Toggle tabs versus spaces and list mode. |
| Normal | `Ctrl-d/u/b/f` | Half/page movement, then centre the cursor. |
| Normal | `n` / `N` | Next/previous search result, centred and opened. |
| Normal | `Q` | Disabled. |
| Visual | `Leader y` | Yank to system clipboard. |
| Visual | `Leader p` | Paste without replacing the unnamed register. |

### Herdr pane navigation

| Mode | Keys | Action |
| --- | --- | --- |
| Normal | `Ctrl-h/j/k/l` | Move left/down/up/right through Neovim splits, then cross into Herdr at an edge. Outside Herdr, fall back to tmux when present. |

### Netrw

| Mode | Keys | Action |
| --- | --- | --- |
| Normal | `Ctrl-l` | Refresh the netrw listing; this intentionally overrides shared right navigation. |

### Telescope

| Mode | Keys | Action |
| --- | --- | --- |
| Normal | `Leader ff` | Find files, including hidden and ignored files. |
| Normal | `Leader fg` | Live grep, including hidden files. |
| Normal | `Leader fb` | List buffers. |
| Normal | `Leader fh` | Search help tags. |
| Normal | `Leader fs` | List document symbols. |
| Normal | `Leader fu` | Open undo history. |
| Telescope insert | `Ctrl-j` / `Ctrl-k` | Next/previous result. |
| Telescope insert | `Ctrl-q` | Send selected entries to, then open, quickfix. |

### LSP (buffer-local, when an LSP attaches)

| Mode | Keys | Action |
| --- | --- | --- |
| Normal | `gD` | Go to declaration. |
| Normal | `gd` | Find definitions with Telescope. |
| Normal/Visual | `Leader ca` | Code action. |
| Normal | `Leader rn` | Rename symbol. |
| Normal | `Leader D` | Buffer diagnostics in Telescope. |
| Normal | `Leader d` | Show diagnostics at the cursor. |

### CodeCompanion

| Mode | Keys | Action |
| --- | --- | --- |
| Normal/Visual | `Leader ac` | Toggle Codex chat. |
| Normal | `Leader an` | Start a Codex chat. |
| Normal/Visual | `Leader aa` | Open CodeCompanion actions. |
| Visual | `Leader as` | Add selection to Codex chat. |
| Visual | `Leader ai` | Edit selection in place with Gemini. |
| Visual | `Leader at` | Generate tests with Gemini. |
| Visual | `Leader ae` | Explain selection with Gemini. |
| Visual | `Leader ap` | Start a freeform Gemini prompt for selection. |

### CodeCompanion chat buffer

| Mode | Keys | Action |
| --- | --- | --- |
| Insert | `Ctrl-s` | Submit message. |
| Normal | `Enter` | Submit message. |
| Normal | `q` | Stop active request. |
| Normal | `ga` | Choose adapter/model. |
| Normal | `gm` | Add a message while the agent works. |
| Normal | `gr` | Regenerate reply. |
| Normal | `?` | Show chat-buffer mappings. |
