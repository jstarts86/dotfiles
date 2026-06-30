#!/usr/bin/env bash

set -euo pipefail

sanitize_session_name() {
    printf '%s' "$1" | tr -c '[:alnum:]_.-' '_'
}

closed_session_name="${1:-}"
if [ -z "$closed_session_name" ]; then
    exit 0
fi

prefix="$(tmux show-option -gqv '@floax-session-prefix')"
if [ -z "$prefix" ]; then
    prefix="__floax__"
fi

case "$closed_session_name" in
    "$prefix"*)
        exit 0
        ;;
esac

floax_session_name="${prefix}$(sanitize_session_name "$closed_session_name")"
if tmux has-session -t "$floax_session_name" 2>/dev/null; then
    tmux kill-session -t "$floax_session_name"
fi
