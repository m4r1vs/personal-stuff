#!/bin/bash

# Kill all apps with the Wayland ID "manim_preview"
pkill -f 'mpv.*--wayland-app-id=manim_preview'

sleep 0.1

# Check if a file was provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <input-file>"
  exit 1
fi

# get active window
active_window=$(hyprctl activewindow -j | jq -r '.address')

# Run mpv with the specified options and input file
mpv --wayland-app-id=manim_preview --loop "$1" > /dev/null &

# TODO: Loop until the window is created
# Check if the window with Wayland ID "manim_preview" is created
while ! hyprctl clients | grep -q 'manim_preview'; do
  :
done

# Focus old window again
hyprctl dispatch focuswindow address:$active_window

# Apply window settings
hyprctl dispatch setfloating manim_preview
hyprctl dispatch resizewindowpixel exact 1920 1080,manim_preview
hyprctl dispatch movewindowpixel exact 0 0,manim_preview
