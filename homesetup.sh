#!/bin/bash

# List of programs in the order they should be moved to workspaces
ordered_programs=("brave-browser" "Alacritty" "jetbrains-idea" "Mattermost" "spotify" "obsidian")

# Declare an associative array where each program is mapped to a command string
declare -A programs
programs=(
  ["spotify"]="spotify"
  ["obsidian"]="obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=TouchpadOverscrollHistoryNavigation"
  ["Mattermost"]="mattermost-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=TouchpadOverscrollHistoryNavigation"
  ["jetbrains-idea"]="/home/mn/.local/share/JetBrains/Toolbox/apps/intellij-idea-ultimate/bin/idea"
  ["Alacritty"]="alacritty"
  ["brave-browser"]="brave"
)

# Function to check if a program is running
is_running() {
  hyprctl clients | grep -i "class: $1" &> /dev/null
  return $?
}

# Get the names of connected monitors
monitors=($(hyprctl monitors | grep "name" | awk '{print $2}'))
num_monitors=${#monitors[@]}

# Determine primary and secondary monitors
primary_monitor="eDP-1"
if [[ $num_monitors -gt 1 ]]; then
  secondary_monitor="${monitors[1]}"
else
  secondary_monitor="$primary_monitor"
fi

# Open each program if not already open and move it to the correct workspace
for class_name in "${!programs[@]}"; do

  echo "Starting program with class name: $class_name"

  # Check if program is already open, if not, start it
  if ! is_running "$class_name"; then
    eval "${programs[$class_name]}" &
  fi
done

sleep 4 # Give it a moment to open

# Initialize the workspace counter
workspace=1

# Move each program to the correct workspace and monitor
for class_name in "${ordered_programs[@]}"; do

  # Determine the target monitor for the workspace
  if ((workspace % 2 == 0)); then
    monitor="$primary_monitor"
  else
    monitor="$secondary_monitor"
  fi

  # Move program to its workspace on the chosen monitor
  hyprctl dispatch movetoworkspacesilent "$workspace","$class_name"
  # hyprctl dispatch moveworkspacetomonitor "$workspace" "$monitor"

  # Increment workspace number for the next program
  ((workspace++))
done
