#!/bin/bash

# Path to IntelliJ configuration directory (adjust if needed)
CONFIG_DIR="$HOME/.config/JetBrains/IntelliJIdea2024/options"
SCHEME_FILE="$CONFIG_DIR/colors.scheme.xml"

# Check if the colors.scheme.xml exists
if [[ ! -f "$SCHEME_FILE" ]]; then
  echo "Error: $SCHEME_FILE not found!"
  exit 1
fi

# Read the current theme (looking for <scheme name="Darcula"> or <scheme name="IntelliJ">)
CURRENT_THEME=$(grep -oP '(?<=<scheme name=")[^"]+' "$SCHEME_FILE")

# Toggle theme
if [[ "$CURRENT_THEME" == "Darcula" ]]; then
  echo "Switching to light theme (IntelliJ)"
  sed -i 's/<scheme name="Darcula">/<scheme name="IntelliJ">/' "$SCHEME_FILE"
elif [[ "$CURRENT_THEME" == "IntelliJ" ]]; then
  echo "Switching to dark theme (Darcula)"
  sed -i 's/<scheme name="IntelliJ">/<scheme name="Darcula">/' "$SCHEME_FILE"
else
  echo "Error: Unknown theme $CURRENT_THEME"
  exit 1
fi
