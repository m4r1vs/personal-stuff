#!/bin/bash

# Send the notification
dunstify -h string:x-dunst-stack-tag:test -a tmux -t 1000 "_tmux" "$(/home/mn/code/personal-stuff/list-tmux-sessions-c/tmuxls)"
