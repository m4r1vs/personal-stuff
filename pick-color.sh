#!/bin/sh

sleep 0.25
color=$(/home/$USER/.cargo/bin/xcolor)
output=$(echo ${color%????????})

if [ "${output:0:1}" == "#" ]; then
  notify-send "Copied $output to Clipboard :)" -i /usr/share/icons/Papirus/48x48/apps/colorpicker.svg
  echo -n $output | xclip -i -selection "clipboard"
fi

