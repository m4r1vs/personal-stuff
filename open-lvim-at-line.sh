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

if [[ "$FILE" != /* ]]; then
  # Relative path: Find the file from the current pane's active path recursively
  CURRENT_PATH=$(tmux display-message -p -F "#{pane_current_path}")
  FOUND_FILE=$(find "$CURRENT_PATH" -type f -name "$FILE" 2> /dev/null | head -n 1)

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

# echo "$LVIM_CMD" | xclip -selection clipboard

# Send command to tmux to open a new pane with lvim at the specified line
TMUX_CMD="tmux split-window -h \"$LVIM_CMD\""

echo "$TMUX_CMD" | xclip -selection clipboard

# attach to current tmux session
tmux split-window -h "$LVIM_CMD"

# paste the command to the terminal and run it
# xdotool key ctrl+shift+v
# xdotool key Return

# Switch to the new pane automatically
# tmux last-pane
# tmux select-pane -R
