#!/bin/bash
# This script opens a new tmux pane with neovim at a specified file and line number.

# Check if there is an argument provided
if [ -z "$1" ]; then
  notify-send "Usage: $0 /path/to/file:line_number"
  exit 1
fi

# Extract the file path, line number, and optional character number from the argument
IFS=':' read -r FILE LINE CHAR <<< "$1"

# Validate the inputs
if [ -z "$FILE" ] || [ -z "$LINE" ]; then
  notify-send "Invalid format. Please use /path/to/file:line_number[:character_number]"
  exit 1
fi

# Check if the specified file exists
if [ ! -f "$FILE" ]; then
  notify-send "Error: File does not exist."
  exit 1
fi

# Check if tmux is running
if ! tmux info &> /dev/null; then
  notify-send "tmux is not running. Please start tmux first."
  exit 1
fi

# Check if character number is provided and construct the lvim command accordingly
if [ -n "$CHAR" ]; then
  LVIM_CMD="lvim +\"call cursor($LINE, $CHAR)\" $FILE"
else
  LVIM_CMD="lvim +$LINE $FILE"
fi

# Send command to tmux to open a new pane with lvim at the specified line
tmux split-window -h "$LVIM_CMD"

# Switch to the new pane automatically
tmux last-pane
tmux select-pane -R
