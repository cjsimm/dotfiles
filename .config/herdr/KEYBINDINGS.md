# Herdr keybindings

Prefix: `Ctrl-Space` (press and release, then press the second key).

## Active workflow

| Keys | Action |
| --- | --- |
| `Ctrl-h/j/k/l` | Navigate Neovim splits and Herdr panes seamlessly. |
| `Prefix h/j/k/l` | Focus the neighbouring Herdr pane. |
| `Alt-Shift-h/l` | Previous/next tab. |
| `Prefix _` | Split the focused pane top/bottom. |
| `Prefix |` | Split the focused pane left/right. |
| `Prefix \` | Return to the last focused pane. |

`Ctrl-h/j/k/l` first moves between Neovim windows. At a Neovim edge, it moves
to the adjacent Herdr pane. Netrw deliberately keeps its own `Ctrl-l` refresh
mapping.

## High-value built-ins to memorize

| Keys | Action |
| --- | --- |
| `Prefix z` | Zoom/unzoom the focused pane. |
| `Prefix b` | Toggle the sidebar for more screen space. |
| `Prefix o` | Jump to the visible notification target. |
| `Prefix g` | Open the searchable session navigator. |
| `Prefix Tab` / `Prefix Shift-Tab` | Cycle forward/backward through panes. |
| `Prefix r`, then `h/j/k/l` | Resize the focused pane. |
| `Prefix ?` | Show Herdr's live keybinding reference. |

In the session navigator, use `b`, `w`, `i`, or `d` to filter blocked,
working, idle, or done agents; press Enter to focus the selection.

## Pane rearrangement

These built-ins swap the focused pane with its neighbour:

| Keys | Action |
| --- | --- |
| `Prefix Shift-h/j/k/l` | Swap left/down/up/right. |

We discussed optionally adding tmux-style `Prefix {` and `Prefix }` for swap
up/down. They are **not currently configured**.
