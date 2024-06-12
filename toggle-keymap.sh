#!/bin/bash

if [ "$(cat /home/mn/.keymap-state)" == "de" ]; then
  echo "us" > ~/.keymap-state
  notify-send "US keyboard layout" -h string:x-dunst-stack-tag:tmux-session-switch -t 1100 -i /usr/share/icons/Papirus/48x48/categories/preferences-desktop-keyboard-shortcuts.svg
  setxkbmap -layout us
else
  echo "de" > ~/.keymap-state
  notify-send "German keyboard layout" -h string:x-dunst-stack-tag:tmux-session-switch -t 1100 -i /usr/share/icons/Papirus/48x48/categories/preferences-desktop-keyboard-shortcuts.svg
  setxkbmap -layout de
fi
