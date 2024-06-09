#!/bin/bash

# Get the current tmux session id
current_session=$(tmux display-message -p '#S')

# Switch to the previous session
tmux switch-client -p

# Kill the session with the saved id
tmux kill-session -t "$current_session"
