#!/bin/bash

# polybar-msg cmd toggle
i3-msg gaps horizontal all toggle 160
i3-msg gaps vertical all toggle 80

modules=("date" "weather" "color-picker" "battery" "pulseaudio" "memory" "cpu" "wlan" "eth" "vpn" "xwindow", "docker")

for module in "${modules[@]}"; do
  echo "#${module}.module_toggle"
  polybar-msg action "#${module}.module_toggle"
done
