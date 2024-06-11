#!/bin/bash

# Get the current session name
# SWITCHER=$(/home/mn/code/personal-stuff/list-tmux-sessions.sh)
SWITCHER=$(/home/mn/code/personal-stuff/list-tmux-sessions-c/tmuxls)

# Send the notification
dunstify -h string:x-dunst-stack-tag:test -a tmux -t 1000 "_tmux" "$SWITCHER"
