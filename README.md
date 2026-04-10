# Dotfiles

This repository is laid out as a direct mirror of parts of `$HOME`.

Examples:
- `.zshrc` maps to `~/.zshrc`
- `.config/tmux/tmux.conf` maps to `~/.config/tmux/tmux.conf`
- `karabiner/...` maps to `~/karabiner/...`

Because of that layout, GNU Stow should treat the entire `dotfiles` repo as one package.

## Install GNU Stow

On macOS:

```sh
brew install stow
```

Check it:

```sh
stow --version
```

## Repo Layout Note

This repo is a single Stow package, not a multi-package repo.

That means:
- You stow the whole repo at once.
- You generally run `stow` from the parent directory of this repo.
- You cannot cleanly stow only `tmux` or only `zsh` unless the repo is restructured into package folders like `zsh/.zshrc`, `tmux/.config/tmux/tmux.conf`, and so on.

## Basic Usage

If the repo lives at `~/dotfiles`, go to its parent directory:

```sh
cd ~
```

Dry run first:

```sh
stow -nv -t "$HOME" dotfiles
```

Apply it:

```sh
stow -v -t "$HOME" dotfiles
```

What this does:
- `-n` means no changes, just preview
- `-v` means verbose output
- `-t "$HOME"` sets your home directory as the target
- `dotfiles` is the package name, because the package is the repo itself

## Most Common Situations

### 1. Fresh machine, no existing dotfiles

```sh
git clone <your-repo-url> ~/dotfiles
cd ~
stow -nv -t "$HOME" dotfiles
stow -v -t "$HOME" dotfiles
```

### 2. Files already exist in `$HOME` and Stow reports conflicts

Stow will refuse to overwrite real files.

Preview conflicts:

```sh
cd ~
stow -nv -t "$HOME" dotfiles
```

If the existing file should be replaced by the repo version, back it up first:

```sh
mv ~/.zshrc ~/.zshrc.backup
mv ~/.config/tmux ~/.config/tmux.backup
```

Then stow again:

```sh
stow -v -t "$HOME" dotfiles
```

### 3. You want to adopt existing local files into the repo

Use `--adopt` only when you understand what it does. It moves the existing target files into the package, then creates symlinks.

Preview first:

```sh
cd ~
stow -nv --adopt -t "$HOME" dotfiles
```

Apply:

```sh
stow -v --adopt -t "$HOME" dotfiles
```

After that:
- inspect the git diff
- confirm Stow moved the expected files into the repo
- commit the adopted changes intentionally

### 4. You changed files inside this repo and want links refreshed

Usually this is enough:

```sh
cd ~
stow -R -v -t "$HOME" dotfiles
```

`-R` restows the package by unstowing and stowing it again.

### 5. You want to remove the symlinks created by Stow

```sh
cd ~
stow -D -v -t "$HOME" dotfiles
```

This removes the symlinks Stow manages. It does not delete the files in the repo.

### 6. You only want to test what Stow would do

```sh
cd ~
stow -nv -t "$HOME" dotfiles
```

This should be your default before any risky Stow operation.

## Safe Workflow

Use this sequence when you are unsure:

```sh
cd ~
stow -nv -t "$HOME" dotfiles
stow -R -v -t "$HOME" dotfiles
```

If there are conflicts:
- back up the conflicting target files first
- or use `--adopt` if you want to pull those target files into this repo

## Conflict Examples

If Stow complains about:

```text
~/.zshrc
```

then one of these is true:
- `~/.zshrc` already exists as a regular file
- `~/.zshrc` is a symlink pointing somewhere unexpected

Inspect it:

```sh
ls -l ~/.zshrc
```

If Stow complains about:

```text
~/.config/tmux/tmux.conf
```

inspect the parent tree:

```sh
ls -la ~/.config
ls -la ~/.config/tmux
```

## Recommended Commands

Fresh link:

```sh
cd ~ && stow -v -t "$HOME" dotfiles
```

Preview only:

```sh
cd ~ && stow -nv -t "$HOME" dotfiles
```

Restow after edits:

```sh
cd ~ && stow -R -v -t "$HOME" dotfiles
```

Adopt existing files:

```sh
cd ~ && stow -v --adopt -t "$HOME" dotfiles
```

Remove links:

```sh
cd ~ && stow -D -v -t "$HOME" dotfiles
```

## Important Limitation

With the current repo structure, Stow sees `dotfiles` as one package.

So if you want workflows like:
- stow only `zsh`
- stow only `tmux`
- unstow only `karabiner`

you should restructure the repo into package directories.

Example future structure:

```text
dotfiles/
  zsh/.zshrc
  tmux/.config/tmux/tmux.conf
  ghostty/.config/ghostty/config
  yazi/.config/yazi/yazi.toml
  karabiner/.config/karabiner/karabiner.json
```

Then you could run:

```sh
cd ~/dotfiles
stow zsh
stow tmux
stow yazi
```

## Related Notes

If you also use these tools, install them separately as needed:

```sh
brew tap FelixKratz/formulae
brew install borders
```

SketchyBar reference:

```text
https://github.com/FelixKratz/dotfiles?tab=readme-ov-file
```

Optional install script reference:

```sh
curl -L https://raw.githubusercontent.com/FelixKratz/dotfiles/master/install_sketchybar.sh | sh
```
