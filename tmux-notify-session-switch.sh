#!/bin/bash

# Get the current session name
SESSION_NAME=$(tmux display-message -p '#S')
WINDOW_NAME=$(tmux display-message -p '#W')
CURRENT_FOLDER=$(tmux display-message -p '#{pane_current_path}')

SWITCHER=$(/home/mn/code/personal-stuff/list-tmux-sessions.sh)

CURRENT_FOLDER=${CURRENT_FOLDER/\/home\/$USER/\~}

# Send the notification
dunstify -h string:x-dunst-stack-tag:test -a tmux -t 1000 "_tmux" "$SWITCHER"
