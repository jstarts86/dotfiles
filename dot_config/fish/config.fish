
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/anaconda3/bin/conda
    eval /opt/anaconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/opt/anaconda3/etc/fish/conf.d/conda.fish"
        . "/opt/anaconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/opt/anaconda3/bin" $PATH
    end
end
# <<< conda initialize <<<
# ------------------------------------------------------------------------------
# Fish Shell Configuration
# ------------------------------------------------------------------------------
fish_add_path -g /opt/homebrew/bin # For Apple Silicon
# --- Path Modifications ---
# Note: fish_add_path adds to fish_user_paths, which is prepended to PATH.
# It also ensures paths are not duplicated.
fish_add_path -g $HOME/bin
fish_add_path -g /usr/local/bin
fish_add_path -g "$HOME/.local/bin"
fish_add_path -g /opt/homebrew/opt/llvm/bin
fish_add_path -g ~/.console-ninja/.bin
fish_add_path -g /opt/homebrew/opt/flex/bin
fish_add_path -g /opt/homebrew/opt/bison/bin
fish_add_path -g $HOME/development/flutter/bin
fish_add_path -g /nix/var/nix/profiles/default/bin # From export PATH=$PATH:/nix/...
fish_add_path -g /opt/homebrew/Cellar/postgresql@17/17.2/bin/ # Specific version
fish_add_path -g /opt/homebrew/opt/postgresql@17/bin # General pg bin
fish_add_path -g /opt/homebrew/opt/ruby/bin
fish_add_path -g /Applications/MATLAB_R2024b.app/bin
fish_add_path -g /opt/homebrew/opt/openjdk@21/bin

# --- Environment Variables ---
set -gx EDITOR nvim

# Lua Rocks
set -gx LUA_CPATH ";;$HOME/.luarocks/lib/lua/5.1/?.so"
set -gx LUA_PATH ";;$HOME/.luarocks/share/lua/5.1/?.lua;$HOME/.luarocks/share/lua/5.1/?/init.lua"
# PostgreSQL (if needed beyond PATH, PGDATA is often set by Homebrew services)
set -gx LDFLAGS "-L/opt/homebrew/opt/postgresql@17/lib"
set -gx CPPFLAGS "-I/opt/homebrew/opt/postgresql@17/include"
# set -gx PGDATA /opt/homebrew/var/postgresql@17 # Usually managed by brew services

# Java Home
set -gx JAVA_HOME (brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home
# Or if you prefer the explicit path:
# set -gx JAVA_HOME /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home


# --- Aliases ---
alias nvim-lazy "NVIM_APPNAME=LazyNvim nvim"
alias lvim "NVIM_APPNAME=LazyNvim nvim"
alias vim nvim
alias ls "eza"
alias ll "eza -alh"
alias la "eza -a" # Common alias, adding it
alias l "eza -lF" # Another common one
alias tree "eza --tree"
alias gcane "git commit --amend --no-edit"
alias cat "bat --paging=never" # Added --paging=never as bat can sometimes interfere with pipes

# --- Functions ---

# Neovim config switcher
function nvims
    set -l items "default" "LazyNvim"
    set -l config (printf "%s\n" $items | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)

    if test -z "$config"
        echo "Nothing selected"
        return 0
    else if test "$config" = "default"
        set config ""
    end
    # In Fish, environment variables for a single command are set like this:
    env NVIM_APPNAME=$config nvim $argv
end

# Kitty Reload
function kitty-reload
    # Ensure pidof is available or use pgrep
    if command -v pidof > /dev/null
        kill -SIGUSR1 (pidof kitty)
    else if command -v pgrep > /dev/null
        kill -SIGUSR1 (pgrep kitty)
    else
        echo "Neither pidof nor pgrep found to reload kitty."
        return 1
    end
end

# Yazi cd integration
function y
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    # Pass arguments to yazi using $argv
    command yazi $argv --cwd-file="$tmp"
    if set -l cwd (command cat -- "$tmp"); and test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end
    command rm -f -- "$tmp"
end

# Custom fzf function to cd into selected directory
function fzf-cd-home-widget
    set -l selected_dir (fd --type d --hidden --exclude .git --exclude node_modules --exclude .cache --exclude .local/share --exclude Library . "$HOME" | \
                         fzf --height 50% --reverse --border --prompt="Select Directory > " \
                             --preview 'eza --tree --level=2 --color=always {}' \
                             --bind 'ctrl-/:toggle-preview')

    if test -n "$selected_dir"
        # Replace current commandline buffer and execute
        commandline -r "cd \"$selected_dir\""
        commandline -f execute
    else
        # Repaint to clear fzf output if cancelled
        commandline -f repaint
    end
end


# --- Key Bindings ---
# Vi mode
fish_vi_key_bindings

# Bind nvims function (Example: Alt+N)
# Zsh's ^a is Ctrl+A. In Fish, \ca.
# The Zsh `bindkey -s ^a "nvims\n"` means type "nvims" and press enter.
# In Fish, you'd call the function and then execute the command line.
# This makes Ctrl+A run the nvims function and then execute whatever it put on the command line (if anything)
# However, nvims itself is interactive, so we just want to call it.
# A more direct way to just run the function:
# bind \ca 'nvims' # This will just run the function, fzf will take over.

# Bind fzf-cd-home-widget to Ctrl+F
bind \cf fzf-cd-home-widget


# --- Tool Initializations ---

# NVM (Node Version Manager)
# The best way to use NVM with Fish is often with a plugin manager like Fisher:
# fisher install jorgebucaran/nvm.fish
# set -U nvm_default_version lts/* # Or your preferred version
# Then, nvm will be available.
# If you want to try sourcing it directly (might need `bass` for full compatibility if nvm.sh isn't pure POSIX):
#set -q NVM_DIR; or set -gx NVM_DIR "$HOME/.nvm"
#function nvm_load --on-event fish_prompt
#    bass source $NVM_DIR/nvm.sh --no-use ';' nvm use default --silent &>/dev/null
#    functions --erase nvm_load
#end
# Or, if you have nvm.fish installed (e.g. via Homebrew or Fisher):
# if test -f (brew --prefix nvm)/nvm.sh # Adjust path if not brew
#   source (brew --prefix nvm)/nvm.sh
# end


# Zoxide (Smarter cd)
if command -v zoxide > /dev/null
    zoxide init fish | source
end

# FZF (Command-line fuzzy finder)
# FZF installation usually provides a fish script.
if test -f ~/.fzf.fish
    source ~/.fzf.fish
end
# Or if installed via package manager, it might be elsewhere.
# For Homebrew on macOS:
# if test -f (brew --prefix)/opt/fzf/shell/key-bindings.fish
#   source (brew --prefix)/opt/fzf/shell/key-bindings.fish
# end
# if test -f (brew --prefix)/opt/fzf/shell/completion.fish
#   source (brew --prefix)/opt/fzf/shell/completion.fish
# end


# Conda (Anaconda/Miniconda)
# Run `conda init fish` once in your terminal. It will modify or create
# necessary files in ~/.config/fish/
# The following is what it typically adds to config.fish or a conf.d file:
# if command -s conda; and test -f (conda info --base)/etc/fish/conf.d/conda.fish
#   source (conda info --base)/etc/fish/conf.d/conda.fish
# end
# Make sure to run `conda init fish` if you haven't.


# rbenv (Ruby environment)
# status --is-interactive; and rbenv init -fish | source
# Or using a plugin like https://github.com/fnichol/rbenv-fish for more robust integration
if command -v rbenv > /dev/null
  status --is-interactive; and rbenv init -fish | source
end

# luaenv (if you use it, similar to rbenv)
# if command -v luaenv > /dev/null
#   status --is-interactive; and luaenv init -fish | source
# end
if status --is-interactive
    # Check if the TMUX environment variable is NOT set (meaning we're not already in tmux)
    # and if the tmux command is available
    if not set -q TMUX; and command -v tmux >/dev/null
        # Start a new tmux session or attach to an existing one.
        # -A: If a session with the given name exists, attach to it. Otherwise, create it.
        # -s main: Names the session "main". You can choose any name.
        # If you want tmux to take over the current shell process (so when tmux exits, the terminal closes):
        # exec tmux new-session -A -s main
        # If you want to fall back to the fish shell if tmux exits:
        tmux new-session -A -s main
    end
end

# Nix Environment
# The Zsh script likely sets environment variables.
# Fish usually sources a specific fish script if Nix provides one, or you might need `bass`
# if it's a pure POSIX sh script that sets environment variables.
#if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  # If nix-daemon.sh is a POSIX script that exports variables, you might need bass:
  # bass source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  # Or if it's simple enough or has fish compatibility:
#  source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
#end
# Check Nix documentation for the recommended Fish shell integration.
# Often, Nix might create a file like /nix/var/nix/profiles/default/etc/profile.d/nix.fish


# --- Oh My Zsh / Theme / Plugin Equivalents ---
# Powerlevel10k: This is Zsh-specific.
# For Fish, a popular and powerful theme is Tide:
#   fisher install IlanCosman/tide
#   Run `tide configure` to set it up.
#
# Zsh plugins (git, zsh-autosuggestions, zsh-syntax-highlighting, tmux, nvm):
# - git: Fish has excellent built-in git completions and prompt integration.
# - zsh-autosuggestions: Built into Fish.
# - zsh-syntax-highlighting: Built into Fish.
# - tmux: For tmux integration, you might look for specific Fish plugins or configure tmux directly.
#   e.g., https://github.com/fish-shell/fish-plugin-tmux
# - nvm: Covered above, preferably with jorgebucaran/nvm.fish via Fisher.

# Angular CLI completions:
# Zsh: NG_COMMANDS="..."; complete -W "$NG_COMMANDS" ng
# Fish: Fish has its own completion system. You'd need to write or find
#       Fish completions for `ng`. They go in `~/.config/fish/completions/ng.fish`.
#       The Angular CLI might provide these, or you can search for them.
#       Example structure for a completion file:
#       # ~/.config/fish/completions/ng.fish
#       # set -l ng_commands add build config doc e2e generate help lint new run serve test update version xi18n
#       # complete -c ng -n "__fish_use_subcommand" -a $ng_commands -d "Angular CLI command"
#       # Further completions for subcommands would go here.
#       # For now, this is commented out as it requires a separate file.

# --- Final Sanity Checks / Welcome Message (Optional) ---
# echo "Welcome to Fish! Your config.fish is loaded."

# Consider using Fisher for managing Fish plugins: https://github.com/jorgebucaran/fisher
zoxide init fish | source
