#!/bin/bash

DUNSTIFY_TAG="-h string:x-dunst-stack-tag:tmux-session-switch"
DUNSTIFY_APPNAME="-a tmux"
DUNSTIFY_TIMEOUT="-t 1000"
DUNSTIFY_TITLE="_tmux"
TMUX_SESSION_LIST_COMMAND="/home/mn/code/personal-stuff/list-tmux-sessions-rust/target/release/list-tmux-sessions-rust"

dunstify $DUNSTIFY_TAG $DUNSTIFY_APPNAME $DUNSTIFY_TIMEOUT "$DUNSTIFY_TITLE" "$($TMUX_SESSION_LIST_COMMAND)"
