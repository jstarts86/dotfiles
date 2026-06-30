#!/usr/bin/env bash

set -euo pipefail

tmux_env_or_empty() {
    local value
    value="$(tmux show-environment -g "$1" 2>/dev/null || true)"
    case "$value" in
        "$1="*)
            printf '%s' "${value#*=}"
            ;;
    esac
}

sesh_items() {
    sesh list --icons 2>/dev/null || sesh list -t --icons
}

picker_mode="${1:-tmux-popup}"
prefix="$(tmux show-option -gqv '@floax-session-prefix')"
if [ -z "$prefix" ]; then
    prefix="__floax__"
fi

current_session_name="$(tmux display-message -p '#{session_name}')"
current_client_name="$(tmux display-message -p '#{client_name}')"
origin_client_name="$(tmux_env_or_empty ORIGIN_CLIENT_NAME)"
origin_pane_id="$(tmux_env_or_empty ORIGIN_PANE_ID)"

if [ "$picker_mode" != "plain-popup" ] && [[ "$current_session_name" == "$prefix"* ]] && [ -n "$origin_pane_id" ]; then
    tmux display-popup \
        -t "$origin_pane_id" \
        -w 84% \
        -h 74% \
        -E \
        "$HOME/.config/tmux/scripts/sesh-connect.sh plain-popup"
    exit 0
fi

if [ "$picker_mode" = "plain-popup" ]; then
    selected="$(
        sesh_items | fzf \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons 2>/dev/null || sesh list -t --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}'
    )" || exit 0
else
    selected="$(
        sesh_items | fzf-tmux -p 80%,70% \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons 2>/dev/null || sesh list -t --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}'
    )" || exit 0
fi

if [ -z "$selected" ]; then
    exit 0
fi

selected_name="$(printf '%s\n' "$selected" | sed 's/^[^[:space:]]\{1,\}[[:space:]]*//')"

if [[ "$current_session_name" == "$prefix"* ]] && [ -n "$origin_client_name" ] && [ "$origin_client_name" != "$current_client_name" ]; then
    if tmux has-session -t "$selected_name" 2>/dev/null; then
        tmux switch-client -c "$origin_client_name" -t "$selected_name"
        tmux detach-client -t "$current_client_name"
        exit 0
    fi
fi

exec sesh connect --switch "$selected"
