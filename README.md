# Dotfiles

Managed with [chezmoi](https://chezmoi.io/).

## Quick Start (Fresh Machine)

```sh
sh -c "$(curl -fsLS get.chezmoi.io)"
chezmoi init --apply jstarts86/dotfiles
```

That's it — `chezmoi init` clones the repo to `~/.local/share/chezmoi` and
`--apply` deploys everything immediately.

## Common Workflows

```sh
chezmoi diff                             # preview changes before applying
chezmoi apply                            # apply pending changes
chezmoi edit ~/.zshrc                    # edit a managed file via chezmoi
chezmoi update                           # pull latest from remote + apply
chezmoi add ~/.some-new-file             # adopt a new file into chezmoi
chezmoi re-add ~/.zshrc                  # re-adopt a file that's diverged
```

Always run `chezmoi diff` before `chezmoi apply` to review what will change.

## Linux / DGX Spark

On the first `chezmoi apply` on a Linux system, the
`run_once_install-linux.sh` bootstrap script installs:

- zsh, tmux, fzf, ripgrep, fd-find, build tooling
- Starship prompt, Atuin shell history
- Yazi file manager

The `zprofile` template also configures CUDA paths for the DGX Spark.

## Repo Layout

Uses chezmoi's source-directory naming conventions:

| Source | Target |
|---|---|
| `dot_zshrc` | `~/.zshrc` |
| `dot_config/ghostty/config` | `~/.config/ghostty/config` |
| `private_dot_ssh/` | `~/.ssh/` (0700 permissions) |
| `dot_zprofile.tmpl` | `~/.zprofile` (OS-templated) |
| `run_once_*.sh.tmpl` | runs once per machine |

Files ending in `.tmpl` are Go templates evaluated at apply time (e.g.
`dot_zprofile.tmpl` renders different content on macOS vs Linux).

`private_` prefixed files/dirs get restrictive permissions.

## Key Notes

- **Do not** clone the repo manually — `chezmoi init` handles that.
- **Do not** edit files directly in `$HOME` — use `chezmoi edit` so the
  source stays in sync.
- The dotfiles source lives at `~/.local/share/chezmoi` by default.
- `karabiner/` files are stored in the repo but excluded from chezmoi
  deployment (via `.chezmoiignore`).
