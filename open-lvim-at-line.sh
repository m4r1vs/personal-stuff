#!/bin/env zsh
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

notify-send "$FILE"

if [[ "$FILE" != /* ]]; then    # Check for non-absolute paths
  if [[ "$FILE" == */* ]]; then # Check for relative paths with nested directories
    # Extract the directory part and the filename
    DIRNAME=$(dirname "$FILE")
    BASENAME=$(basename "$FILE")

    # Resolve to absolute path using the current pane's active path
    CURRENT_PATH=$(tmux display-message -p -F "#{pane_current_path}")
    FULL_PATH="$CURRENT_PATH/$DIRNAME"

    # Find the file recursively within the specified subdirectory
    FOUND_FILE=$(find "$FULL_PATH" -type f -name "$BASENAME" 2> /dev/null | head -n 1)
  else
    # Handle other relative paths (no nested directories, just filenames)
    CURRENT_PATH=$(tmux display-message -p -F "#{pane_current_path}")
    FOUND_FILE=$(find "$CURRENT_PATH" -type f -name "$FILE" 2> /dev/null | head -n 1)
  fi

  # Common file check and notification logic
  if [ -z "$FOUND_FILE" ]; then
    notify-send "Error: File not found in current pane's active path."
    exit 1
  else
    FILE="$FOUND_FILE"
  fi
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
  LVIM_CMD="lvim +'call cursor($LINE, $CHAR)' $FILE"
else
  LVIM_CMD="lvim +$LINE $FILE"
fi

# somehow on my machine, the PATH is not set correctly when the script is run from alacritty
PATH=/home/mn/perl5/bin:/home/mn/.local/share/mise/installs/node/20/bin:/home/mn/.local/share/mise/installs/python/latest/bin:/home/mn/.local/share/mise/installs/go/1.22.3/bin:/home/mn/.local/share/mise/installs/go/1.22.3/go/bin:/home/mn/.local/share/mise/installs/flutter/latest/bin:/home/mn/.local/share/mise/installs/dart/latest/bin:/home/mn/.local/share/mise/installs/dart/latest/dart-sdk/bin:/home/mn/.local/share/mise/installs/java/12/bin:/home/mn/.local/share/mise/installs/yarn/1.22.22/bin:/home/mn/.local/share/mise/installs/bun/latest/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/mn/.local/bin:/home/mn/.cargo/bin:/home/mn/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin:/home/mn/.local/share/JetBrains/Toolbox/scripts

# Send command to tmux to open a new pane with lvim at the specified line
tmux split-window -h "$LVIM_CMD"

# Switch to the new pane automatically
tmux last-pane
tmux select-pane -R
