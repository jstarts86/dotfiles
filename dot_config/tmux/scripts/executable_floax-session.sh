#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$HOME/.config/tmux/plugins/tmux-floax"

sanitize_session_name() {
    printf '%s' "$1" | tr -c '[:alnum:]_.-' '_'
}

action="${1:-toggle}"
prefix="$(tmux show-option -gqv '@floax-session-prefix')"
if [ -z "$prefix" ]; then
    prefix="__floax__"
fi

current_session_name="$(tmux display-message -p '#{session_name}')"
current_client_name="$(tmux display-message -p '#{client_name}')"
current_pane_id="$(tmux display-message -p '#{pane_id}')"

if [[ "$current_session_name" == "$prefix"* ]]; then
    floax_session_name="$current_session_name"
else
    floax_session_name="${prefix}$(sanitize_session_name "$current_session_name")"
    tmux setenv -g ORIGIN_CLIENT_NAME "$current_client_name"
    tmux setenv -g ORIGIN_PANE_ID "$current_pane_id"
fi

tmux setenv -g FLOAX_SESSION_NAME "$floax_session_name"

case "$action" in
    toggle)
        exec "$PLUGIN_DIR/scripts/floax.sh"
        ;;
    menu)
        exec "$PLUGIN_DIR/scripts/menu.sh"
        ;;
    *)
        echo "Unknown action: $action" >&2
        exit 1
        ;;
esac
