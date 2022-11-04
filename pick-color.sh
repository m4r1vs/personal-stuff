#!/bin/sh

sleep 0.4
color=$(colorpicker --preview --short --one-shot)
output=$(echo ${color%????????})

if [ "${output:0:1}" == "#" ]; then
  notify-send "Copied $output to Clipboard :)" -i /usr/share/icons/Papirus/48x48/apps/colorpicker.svg
  echo -n $output | xclip -i -selection "clipboard"
fi

