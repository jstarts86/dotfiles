#!/bin/sh

tmux split-window -h -c "#{pane_current_path}" "gh dash"
tmux select-pane -L
